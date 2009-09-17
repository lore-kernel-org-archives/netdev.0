From: David Miller <davem@davemloft.net>
Subject: Re: [crash] kernel BUG at net/core/pktgen.c:3503!
Date: Thu, 17 Sep 2009 10:29:23 -0700 (PDT)
Message-ID: <20090917.102923.174779685.davem@davemloft.net>
References: <20090911.202543.52533792.davem@davemloft.net>
	<20090915183647.GA11628@elte.hu>
	<20090915185112.GA17587@lenovo>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: gorcunov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35543
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753094AbZIQR3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 13:29:06 -0400
In-Reply-To: <20090915185112.GA17587@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrill Gorcunov <gorcunov@gmail.com>
Date: Tue, 15 Sep 2009 22:51:12 +0400

> [Ingo Molnar - Tue, Sep 15, 2009 at 08:36:47PM +0200]
> | 
> | not sure which merge caused this, but i got this boot crash with latest 
> | -git:
> | 
> | calling  flow_cache_init+0x0/0x1b9 @ 1
> | initcall flow_cache_init+0x0/0x1b9 returned 0 after 64 usecs
> | calling  pg_init+0x0/0x37c @ 1
> | pktgen 2.72: Packet Generator for packet performance testing.
> | ------------[ cut here ]------------
> | kernel BUG at net/core/pktgen.c:3503!
> | invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> | last sysfs file: 
> | 
> 
> Hi Ingo,
> 
> just curious, will the following patch fix the problem?
> I've been fixing problem with familiar symthoms on
> system with custome virtual cpu implementation so
> it may not help in mainline but anyway :)

Ingo, does Cyrill's patch help?
