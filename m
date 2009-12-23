From: Avi Kivity <avi@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 23:01:41 +0200
Message-ID: <4B328535.5040105@redhat.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <4B3248F9.5030504@gmail.com> <4B327F3A.9020101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4B327F3A.9020101@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/23/2009 10:36 PM, Avi Kivity wrote:
> On 12/23/2009 06:44 PM, Gregory Haskins wrote:
>>
>>>   - Are a pure software concept
>> By design.  In fact, I would describe it as "software to software
>> optimized" as opposed to trying to shoehorn into something that was
>> designed as a software-to-hardware interface (and therefore has
>> assumptions about the constraints in that environment that are not
>> applicable in software-only).
>>
>
> And that's the biggest mistake you can make.  Look at Xen, for 
> instance.  The paravirtualized the fork out of everything that moved 
> in order to get x86 virt going.  And where are they now? x86_64 
> syscalls are slow since they have to trap to the hypervisor and 
> (partially) flush the tlb.  With npt or ept capable hosts performance 
> is better for many workloads on fullvirt.  And paravirt doesn't 
> support Windows.  Their unsung hero Jeremy is still trying to upstream 
> dom0 Xen support.  And they get to support it forever.
>
> VMware stuck with the hardware defined interfaces.  Sure they had to 
> implement binary translation to get there, but as a result, they only 
> have to support one interface, all guests support it, and they can 
> drop it on newer hosts where it doesn't give them anything.

As a twist on this, the VMware paravirt driver interface is so 
hardware-like that they're getting hardware vendors to supply cards that 
implement it.  Try that with a pure software approach.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

