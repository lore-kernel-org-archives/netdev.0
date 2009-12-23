From: Avi Kivity <avi@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 22:26:13 +0200
Message-ID: <4B327CE5.7050705@redhat.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org>	<4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com>	<4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu>	<20091223101340.GC20539@basil.fritz.box>	<20091223185150.GA9587@elte.hu> <877hsdcwza.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755898AbZLWU1I@vger.kernel.org>
In-Reply-To: <877hsdcwza.fsf@basil.nowhere.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/23/2009 09:27 PM, Andi Kleen wrote:
> Ingo Molnar<mingo@elte.hu>  writes:
>
>    
>> Yes, there's (obviously) compatibility requirements and artifacts and past
>> mistakes (as with any software interface), but you need to admit it to
>>      
> Yes that's exactly what I meant.
>    

And we do make plenty of mistakes.  And when we fix them, we have to 
maintain bug-compatibility to allow live migration from the broken 
version to the good version.  If you're ever feeling overly happy, do 
some compat work in qemu and it will suck a year's worth or two of your 
life force a pop.

>> yourself that your "virtualization is sloppy just like hardware" claim is just
>>      
> In my experience hardware is a lot less sloppy than software.
> Imagine your latest CPU had as many regressions as 2.6.32 @)
>
> I wish software and even VMs were as good.
>
>    

Me too.

>> a cheap excuse to not do a proper job of interface engineering.
>>      
> Past mistakes cannot be easily fixed. And undoubtedly even the new
> shiny interfaces will have bugs and problems. Also the behaviour is
> often not completely understood. Maybe it can be easier debugged with
> fully available source, but even then it's hard to fix the old
> software (or rather even if you can fix it deploy the fixes). In
> that regard it's a lot like hardware.
>
> I agree with you that this makes it important to design good
> interfaces, but again realistically mistakes will be made
> and they cannot be all fixed retroactively.
>    

Our principal tool for this is to avoid introducing new interfaces 
whenever possible.  We try to stick to established hardware standards 
(so we don't need to sloppily define them, and get guest compatibility 
for free).

Hardware (both virt and non-virt) faces the same problems as software 
here.  So as hardware solutions are introduced, we adopt them, and 
usually the virt extensions vendors follow with accelerations for these 
paths as well.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.
