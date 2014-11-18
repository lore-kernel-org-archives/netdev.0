From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 2/4] arch: Add lightweight memory barriers fast_rmb()
 and fast_wmb()
Date: Tue, 18 Nov 2014 11:43:32 +1100
Message-ID: <1416271412.18381.20.camel@kernel.crashing.org>
References: <20141117171005.22333.96544.stgit@ahduyck-server>
	 <20141117171812.22333.90395.stgit@ahduyck-server>
	 <CA+55aFxZ9dhB074p3OAQLyQ53TuRjVOo33h6OOda1soh-9xxnQ@mail.gmail.com>
	 <546A6EB2.6020304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Peter Zijlstra <peterz@infradead.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Ingo Molnar <mingo@kernel.org>,
	Michael Neuling <mikey@neuling.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	donald.c.skidmore@intel.com, matthew.vick@intel.com,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Paul McKenney <paulmck@linux.vnet.ibm.com>,
	nic_swsd@realtek.com, Will Deacon <will.deacon@arm.com>,
	Michael Ellerman <michael@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Martin Schwidefsky <sch
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <546A6EB2.6020304@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-11-17 at 13:54 -0800, Alexander Duyck wrote:

> What would you think of the name "coherent_*mb()"?  I would prefer to 
> avoid dma in the name since, at least in my mind, that implies MMIO.

I'm lazy, I like typing less, so I like dma_* but I don't object to
coherent_* if at least one more person thinks it makes the semantics
clearer :)

> It also ties in well with dma_alloc_coherent/dma_free_coherent which is 
> what would typically be used to allocate the memory we would be using 
> the barrier to protect anyway.

Agreed.

> > And yes, in the same spirit, it would probably be good to try to
> > eventually get rid of the plain "*mb()" functions, and perhaps call
> > them "mmio_*mb()" to clarify that they are about ordering memory wrt
> > mmio.
> >
> > Hmm?
> >
> >                          Linus
> 
> I will work on pulling all of the coherent barrier cases out of using 
> the plain "*mb()" calls first.  We need to sort that out before we could 
> look at renaming the plain barrier functions.

Makes sense.

Cheers,
Ben.

> - Alex
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
