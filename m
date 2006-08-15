From: Pavel Machek <pavel@suse.cz>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
Date: Tue, 15 Aug 2006 19:17:55 +0000
Message-ID: <20060815191754.GH4032@ucw.cz>
References: <20060808193325.1396.58813.sendpatchset@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gprs189-60.eurotel.cz ([160.218.189.60]:23046 "EHLO
	spitz.ucw.cz") by vger.kernel.org with ESMTP id S965197AbWHOTUb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 15:20:31 -0400
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Disposition: inline
In-Reply-To: <20060808193325.1396.58813.sendpatchset@lappy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> Recently, Peter Zijlstra and I have been busily collaborating on a
> solution to the memory deadlock problem described here:
> 
>    http://lwn.net/Articles/144273/
>    "Kernel Summit 2005: Convergence of network and storage paths"
> 
> We believe that an approach very much like today's patch set is
> necessary for NBD, iSCSI, AoE or the like ever to work reliably. 
> We further believe that a properly working version of at least one of
> these subsystems is critical to the viability of Linux as a modern
> storage platform.
...
> Unfortunately, a particularly nasty form of memory deadlock arises from
> the fact that receive side of the network stack is also a sort of

What about transmit side? I believe you need to reply to ARPs or you
will be unable to communicate over ethernet...
-- 
Thanks for all the (sleeping) penguins.
