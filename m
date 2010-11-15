From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Mon, 15 Nov 2010 15:39:07 +0100
Message-ID: <20101115143907.GN7269@basil.fritz.box>
References: <20101105110828.52f061b3.akpm@linux-foundation.org>
 <1288981224.2882.1105.camel@edumazet-laptop>
 <20101105112821.57f80481.akpm@linux-foundation.org>
 <1288984844.2665.52.camel@edumazet-laptop>
 <20101105195101.GC15561@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1011121313001.16754@router.home>
 <20101113222612.GD2825@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1011150756130.19175@router.home>
 <1289830636.2607.70.camel@edumazet-laptop>
 <alpine.DEB.2.00.1011150821000.19175@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	Nick Piggin <npiggin@kernel.dk>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:54222 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755874Ab0KOOjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 09:39:09 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011150821000.19175@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > atomic_read() and atomic_cmpxchg(). We tried prefetchw() and it was a
> > performance drop. It was with only 16 cpus contending on neighbour
> 
> Does prefetchw work? Andi claims that prefetchw is not working on
> x86 and I doubt that you ran tests on Itanium.

AMD supports it due to their MOESI protocol, but it's not supported
in MESIF as used by Intel QPI.  The kernel maps it on Intel to 
ordinary prefetch.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
