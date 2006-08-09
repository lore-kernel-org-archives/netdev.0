From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
Date: Wed, 9 Aug 2006 09:46:48 +0400
Message-ID: <20060809054648.GD17446@2ka.mipt.ru>
References: <20060808193325.1396.58813.sendpatchset@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Phillips <phillips@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:23432 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S965077AbWHIFrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 01:47:37 -0400
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Disposition: inline
In-Reply-To: <20060808193325.1396.58813.sendpatchset@lappy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 09:33:25PM +0200, Peter Zijlstra (a.p.zijlstra@chello.nl) wrote:
>    http://lwn.net/Articles/144273/
>    "Kernel Summit 2005: Convergence of network and storage paths"
> 
> We believe that an approach very much like today's patch set is
> necessary for NBD, iSCSI, AoE or the like ever to work reliably. 
> We further believe that a properly working version of at least one of
> these subsystems is critical to the viability of Linux as a modern
> storage platform.

There is another approach for that - do not use slab allocator for
network dataflow at all. It automatically has all you pros amd if
implemented correctly can have a lot of additional usefull and
high-performance features like full zero-copy and total fragmentation
avoidance.

-- 
	Evgeniy Polyakov
