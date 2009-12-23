From: Avi Kivity <avi@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Wed, 23 Dec 2009 16:28:29 +0200
Message-ID: <4B32290D.8090008@redhat.com>
References: <4B1D4F29.8020309@gmail.com> <200912231407.20130.bzolnier@gmail.com> <4B321B9F.6030707@redhat.com> <200912231508.25355.bzolnier@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	kvm@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756083AbZLWO3L@vger.kernel.org>
In-Reply-To: <200912231508.25355.bzolnier@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/23/2009 04:08 PM, Bartlomiej Zolnierkiewicz wrote:
>
>> The device model is exposed to the guest.  If you change it, the guest
>> breaks.
>>      
> Huh?  Shouldn't non-vbus aware guests continue to work just fine?
>    

Sure.  But we aren't merging this code in order not to use it.  If we 
switch development focus to vbus, we have to ask everyone who's riding 
on virtio to switch.  Alternatively we maintain both models.

If vbus was the only way to get this kind of performance, I know what 
I'd choose.  But if it isn't, why inflict the change on users?

Consider a pxe-booting guest (or virtio-blk vs. a future veblk).  Is 
switching drivers in initrd something you want your users to do? [1]

One of the advantages of virtualization is stable hardware.  I don't 
want to let it go without a very good reason.

[1] I remember the move from /dev/hda to /dev/sda a few years ago, it 
isn't a good memory.

-- 
error compiling committee.c: too many arguments to function
