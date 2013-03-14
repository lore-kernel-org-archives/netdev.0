From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash
 table
Date: Thu, 14 Mar 2013 11:34:32 +0100
Message-ID: <1363257272.29475.6.camel@edumazet-glaptop>
References: <20130307214211.GP7941@order.stressinduktion.org>
	 <20130308055718.GA28531@order.stressinduktion.org>
	 <20130308130433.GB28531@order.stressinduktion.org>
	 <1362754386.15793.226.camel@edumazet-glaptop>
	 <20130308150831.GD28531@order.stressinduktion.org>
	 <1362756219.15793.240.camel@edumazet-glaptop>
	 <20130313012715.GE14801@order.stressinduktion.org>
	 <1363152568.13690.35.camel@edumazet-glaptop>
	 <20130314013702.GA4129@order.stressinduktion.org>
	 <CAOaVG148gUzcb2qmg0B7kdWNzNzerMdXZzv2qamXq8ToUFsUyw@mail.gmail.com>
	 <20130314071408.GB4129@order.stressinduktion.org>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B718C@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org, brouer@redhat.com
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:55484 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756659Ab3CNKeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 06:34:36 -0400
Received: by mail-ee0-f51.google.com with SMTP id d17so923314eek.38
        for <netdev@vger.kernel.org>; Thu, 14 Mar 2013 03:34:35 -0700 (PDT)
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B718C@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-14 at 09:47 +0000, David Laight wrote:

> I'd also have thought that INETFRAGS_MAXDEPTH should be run-time tunable.

The useful thing would be to be able to resize the hash table, for some
heavy user cases.

Check net/ipv4/tcp_metrics.c : Not only we use a small depth, but is not
tunable.

#define TCP_METRICS_RECLAIM_DEPTH   5
