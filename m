From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] ipv6: use stronger hash for reassembly queue hash
 table
Date: Fri, 08 Mar 2013 08:15:10 -0800
Message-ID: <1362759310.15793.244.camel@edumazet-glaptop>
References: <20130307214211.GP7941@order.stressinduktion.org>
	 <20130308055718.GA28531@order.stressinduktion.org>
	 <20130308130433.GB28531@order.stressinduktion.org>
	 <1362754386.15793.226.camel@edumazet-glaptop>
	 <20130308150831.GD28531@order.stressinduktion.org>
	 <1362756219.15793.240.camel@edumazet-glaptop>
	 <20130308155404.GE28531@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f178.google.com ([209.85.210.178]:58007 "EHLO
	mail-ia0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933093Ab3CHQPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 11:15:21 -0500
Received: by mail-ia0-f178.google.com with SMTP id o25so1611353iad.23
        for <netdev@vger.kernel.org>; Fri, 08 Mar 2013 08:15:13 -0800 (PST)
In-Reply-To: <20130308155404.GE28531@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-08 at 16:54 +0100, Hannes Frederic Sowa wrote:

> Btw. did s.o. have a look at skb->rxhash? I just started looking after
> its many users but perhaps someone did this job already.

You mean for IPv6 ?

Most of us use the rxhash provided by the NIC, our software fallback is
a best effort as well for RPS or some qdisc.

If some hacker specifically cook packets hashing to same rxhash, thats
fine.
