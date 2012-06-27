From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 23:32:51 +0200
Message-ID: <1340832771.26242.160.camel@edumazet-glaptop>
References: <1340798457-28270-1-git-send-email-tparkin@katalix.com>
	 <1340823810.26242.81.camel@edumazet-glaptop> <4FEB6B64.5060708@hp.com>
	 <1340829541.26242.90.camel@edumazet-glaptop>
	 <20120627135034.7db7d0eb@nehalam.linuxnetplumber.net>
	 <4FEB73EF.9090702@candelatech.com>
	 <1340832022.26242.131.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Rick Jones <rick.jones2@hp.com>,
	Tom Parkin <tparkin@katalix.com>, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, James Chapman <jchapman@katalix.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:44414 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932129Ab2F0Vc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 17:32:58 -0400
Received: by bkcji2 with SMTP id ji2so1475106bkc.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 14:32:57 -0700 (PDT)
In-Reply-To: <1340832022.26242.131.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 23:20 +0200, Eric Dumazet wrote:
> On Wed, 2012-06-27 at 13:58 -0700, Ben Greear wrote:
> 
> > It's worse than that:  Even on 64-bit kernels, counters that are returned by
> > netlink and /proc/net/dev as 64-bit may still wrap themselves at 32-bit
> > intervals.
> 
> Really ?
> 
> Thats incredible you dont send a bug report then.

A bug report to the application author, not the kernel.

/proc/net/dev is an ASCII file, and nothing gives the width of a field.

Therefore, an application should cope with all cases (counter being a
32bit or 64bit integer), wrapping included.

Note that this has little to do with the application or kernel being
32/64 bit code.
