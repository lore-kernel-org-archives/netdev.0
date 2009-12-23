From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 19:51:50 +0100
Message-ID: <20091223185150.GA9587@elte.hu>
References: <4B1D4F29.8020309@gmail.com>
 <87637zdy9g.fsf@basil.nowhere.org>
 <4B30E654.40702@codemonkey.ws>
 <200912221701.56840.bzolnier@gmail.com>
 <4B30F214.80206@codemonkey.ws>
 <20091223065129.GA19600@elte.hu>
 <20091223101340.GC20539@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	Avi Kivity <avi@redhat.com>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752037AbZLWSwd@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091223101340.GC20539@basil.fritz.box>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Andi Kleen <andi@firstfloor.org> wrote:

> > - Are a pure software concept and any compatibility mismatch is                                      
> >   self-inflicted. The patches are in fact breaking the ABI to KVM                                                
> 
> In practice, especially considering older kernel releases, VMs behave like 
> hardware, with all its quirks, compatibility requirements, sometimes not 
> fully understood, etc.

I stopped reading your reply here. That's not actually fully true of KVM, at 
all.

Virtualization isnt voodoo magic with some hidden souce in some magic hardware 
component that no-one can understand fully. This isnt some mystic hardware 
vendor coming up with some code and going away in the next quarter, with 
barely anything documented and thousands of users left with hardware 
components which we need to support under Linux somehow.

This is Linux virtualization, where _both_ the host and the guest source code 
is fully known, and bugs (if any) can be found with a high degree of 
determinism. This is Linux where the players dont just vanish overnight, and 
are expected to do a proper job.

Yes, there's (obviously) compatibility requirements and artifacts and past 
mistakes (as with any software interface), but you need to admit it to 
yourself that your "virtualization is sloppy just like hardware" claim is just 
a cheap excuse to not do a proper job of interface engineering.

Thanks,

	Ingo
