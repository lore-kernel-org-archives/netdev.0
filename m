From: Daniel Phillips <phillips@google.com>
Subject: Re: [RFC][PATCH 0/9] Network receive deadlock prevention for NBD
Date: Tue, 08 Aug 2006 22:52:34 -0700
Message-ID: <44D97822.5010007@google.com>
References: <20060808193325.1396.58813.sendpatchset@lappy> <20060809054648.GD17446@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.45.12]:11594 "EHLO
	smtp-out.google.com") by vger.kernel.org with ESMTP
	id S1030493AbWHIFwv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 01:52:51 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060809054648.GD17446@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Tue, Aug 08, 2006 at 09:33:25PM +0200, Peter Zijlstra (a.p.zijlstra@chello.nl) wrote:
> 
>>   http://lwn.net/Articles/144273/
>>   "Kernel Summit 2005: Convergence of network and storage paths"
>>
>>We believe that an approach very much like today's patch set is
>>necessary for NBD, iSCSI, AoE or the like ever to work reliably. 
>>We further believe that a properly working version of at least one of
>>these subsystems is critical to the viability of Linux as a modern
>>storage platform.
> 
> There is another approach for that - do not use slab allocator for
> network dataflow at all. It automatically has all you pros amd if
> implemented correctly can have a lot of additional usefull and
> high-performance features like full zero-copy and total fragmentation
> avoidance.

Agreed.  But probably more intrusive than davem would be happy with
at this point.

Regards,

Daniel
