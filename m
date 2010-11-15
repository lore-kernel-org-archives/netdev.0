From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] atomic: add atomic_inc_not_zero_hint()
Date: Mon, 15 Nov 2010 08:16:57 -0600 (CST)
Message-ID: <alpine.DEB.2.00.1011150814480.19175@router.home>
References: <20101105102038.53e36f9e.akpm@linux-foundation.org> <1288980046.2882.1054.camel@edumazet-laptop> <20101105110828.52f061b3.akpm@linux-foundation.org> <1288981224.2882.1105.camel@edumazet-laptop> <20101105112821.57f80481.akpm@linux-foundation.org>
 <1288984844.2665.52.camel@edumazet-laptop> <20101105195101.GC15561@linux.vnet.ibm.com> <alpine.DEB.2.00.1011121313001.16754@router.home> <20101113222612.GD2825@linux.vnet.ibm.com> <alpine.DEB.2.00.1011150756130.19175@router.home>
 <20101115140739.GJ7269@basil.fritz.box>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@kernel.dk>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101115140739.GJ7269@basil.fritz.box>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 15 Nov 2010, Andi Kleen wrote:

> > It is another way to get an exclusive cache line
> > for situations like this. No need to give a hint.
>
> prefetchw doesn't work on Intel (or rather is equivalent to prefetch),
> for Intel you always need to explicitely write to get an exclusive
> line.

Argh. You mean x86. Itanium could do it and is also by Intel. Could you
please change that for x86 as well? Otherwise we will get more of these
weird code twisters.
