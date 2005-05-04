From: Andi Kleen <ak@muc.de>
Subject: Re: Mystery packet killing tg3
Date: Wed, 04 May 2005 20:30:00 +0200
Message-ID: <m14qdiyhcn.fsf@muc.de>
References: <20050502162405.65dfb4a9@localhost.localdomain>
	<20050502200251.38271b61.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050502200251.38271b61.davem@davemloft.net> (David S.
 Miller's message of "Mon, 2 May 2005 20:02:51 -0700")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> writes:
>
> This usually means that there is some DMA corruption.
> For example, some bug in the x86_64 IOMMU code or similar
> causes a bogus DMA address to be fed to the tg3 or even
> worse a DMA mapping is unmapped before tg3 is actually
> done with it.

IOMMU code on x86-64 should be never active unless Stephen
used IOMMU_DEBUG or iommu=force.  THat is because the tg3
is a 64bit capable device and should always use bypass.

> Since AMD promised me an Opteron system last year, but never
> made good on that promise, I've never been able to work on
> fixing this bug myself. :-/

You could just buy one ,-) Lowend A64s boards+cpus are *really* cheap
these days. And it will likely be much quieter than a noisy
original AMD box.  And the IOMMU works on that too if you force
it (normally it is never active because they dont have enough
memory to need remapping) 

-Andi
