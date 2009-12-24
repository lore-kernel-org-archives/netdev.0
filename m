From: Gleb Natapov <gleb@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Thu, 24 Dec 2009 08:58:20 +0200
Message-ID: <20091224065820.GE4490@redhat.com>
References: <4B1D4F29.8020309@gmail.com>
 <87637zdy9g.fsf@basil.nowhere.org>
 <4B30E654.40702@codemonkey.ws>
 <200912221701.56840.bzolnier@gmail.com>
 <4B30F214.80206@codemonkey.ws>
 <20091223065129.GA19600@elte.hu>
 <20091223101340.GC20539@basil.fritz.box>
 <20091223185150.GA9587@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756486AbZLXG7O@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091223185150.GA9587@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 23, 2009 at 07:51:50PM +0100, Ingo Molnar wrote:
> 
> * Andi Kleen <andi@firstfloor.org> wrote:
> 
> > > - Are a pure software concept and any compatibility mismatch is                                      
> > >   self-inflicted. The patches are in fact breaking the ABI to KVM                                                
> > 
> > In practice, especially considering older kernel releases, VMs behave like 
> > hardware, with all its quirks, compatibility requirements, sometimes not 
> > fully understood, etc.
> 
> I stopped reading your reply here. That's not actually fully true of KVM, at 
> all.
> 
> Virtualization isnt voodoo magic with some hidden souce in some magic hardware 
> component that no-one can understand fully. This isnt some mystic hardware 
> vendor coming up with some code and going away in the next quarter, with 
> barely anything documented and thousands of users left with hardware 
> components which we need to support under Linux somehow.
> 
> This is Linux virtualization, where _both_ the host and the guest source code 
> is fully known, and bugs (if any) can be found with a high degree of 
It may sound strange but Windows is very popular guest and last I
checked my HW there was no Windows sources there, but the answer to that
is to emulate HW as close as possible to real one and then closed source
guests will not have a reason to be upset.

> determinism. This is Linux where the players dont just vanish overnight, and 
> are expected to do a proper job.
> 
> Yes, there's (obviously) compatibility requirements and artifacts and past 
> mistakes (as with any software interface), but you need to admit it to 
> yourself that your "virtualization is sloppy just like hardware" claim is just 
> a cheap excuse to not do a proper job of interface engineering.
> 
> Thanks,
> 
> 	Ingo
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
			Gleb.
