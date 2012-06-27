From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] l2tp: use per-cpu variables for u64_stats updates
Date: Wed, 27 Jun 2012 23:20:22 +0200
Message-ID: <1340832022.26242.131.camel@edumazet-glaptop>
References: <1340798457-28270-1-git-send-email-tparkin@katalix.com>
	 <1340823810.26242.81.camel@edumazet-glaptop> <4FEB6B64.5060708@hp.com>
	 <1340829541.26242.90.camel@edumazet-glaptop>
	 <20120627135034.7db7d0eb@nehalam.linuxnetplumber.net>
	 <4FEB73EF.9090702@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Rick Jones <rick.jones2@hp.com>,
	Tom Parkin <tparkin@katalix.com>, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, James Chapman <jchapman@katalix.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:54178 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932222Ab2F0VU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 17:20:27 -0400
Received: by bkcji2 with SMTP id ji2so1467582bkc.19
        for <netdev@vger.kernel.org>; Wed, 27 Jun 2012 14:20:25 -0700 (PDT)
In-Reply-To: <4FEB73EF.9090702@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-27 at 13:58 -0700, Ben Greear wrote:

> It's worse than that:  Even on 64-bit kernels, counters that are returned by
> netlink and /proc/net/dev as 64-bit may still wrap themselves at 32-bit
> intervals.

Really ?

Thats incredible you dont send a bug report then.
