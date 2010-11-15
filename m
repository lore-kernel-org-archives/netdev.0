From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Mon, 15 Nov 2010 15:07:39 +0100
Message-ID: <20101115140739.GJ7269@basil.fritz.box>
References: <20101105102038.53e36f9e.akpm@linux-foundation.org>
 <1288980046.2882.1054.camel@edumazet-laptop>
 <20101105110828.52f061b3.akpm@linux-foundation.org>
 <1288981224.2882.1105.camel@edumazet-laptop>
 <20101105112821.57f80481.akpm@linux-foundation.org>
 <1288984844.2665.52.camel@edumazet-laptop>
 <20101105195101.GC15561@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1011121313001.16754@router.home>
 <20101113222612.GD2825@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1011150756130.19175@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>,
	Nick Piggin <npiggin@kernel.dk>
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49482 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755738Ab0KOOHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 09:07:41 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011150756130.19175@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 15, 2010 at 07:57:10AM -0600, Christoph Lameter wrote:
> On Sat, 13 Nov 2010, Paul E. McKenney wrote:
> 
> > On Fri, Nov 12, 2010 at 01:14:12PM -0600, Christoph Lameter wrote:
> > >
> > > prefetchw() would be too much overhead?
> >
> > No idea.  Where do you believe that prefetchw() should be added?
> 
> It is another way to get an exclusive cache line
> for situations like this. No need to give a hint.

prefetchw doesn't work on Intel (or rather is equivalent to prefetch), 
for Intel you always need to explicitely write to get an exclusive
line.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
