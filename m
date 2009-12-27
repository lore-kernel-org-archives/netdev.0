From: Avi Kivity <avi@redhat.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Sun, 27 Dec 2009 11:33:33 +0200
Message-ID: <4B3729ED.50006@redhat.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <4B3248F9.5030504@gmail.com> <4B327F3A.9020101@redhat.com> <4B328535.5040105@redhat.com> <4B33361E.3000605@gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60970 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750872AbZL0JeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Dec 2009 04:34:19 -0500
In-Reply-To: <4B33361E.3000605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/24/2009 11:36 AM, Gregory Haskins wrote:
>> As a twist on this, the VMware paravirt driver interface is so
>> hardware-like that they're getting hardware vendors to supply cards that
>> implement it.  Try that with a pure software approach.
>>      
> Any hardware engineer (myself included) will tell you that, generally
> speaking, what you can do in hardware you can do in software (think of
> what QEMU does today, for instance).  It's purely a cost/performance
> tradeoff.
>
> I can at least tell you that is true of vbus.  Anything on the vbus side
> would be equally eligible for a hardware implementation, though there is
> not reason to do this today since we have equivalent functionality in
> baremetal already.

There's a huge difference in the probability of vmware getting cards to 
their spec, or x86 vendors improving interrupt delivery to guests, 
compared to vbus being implemented in hardware.

> The only motiviation is if you wanted to preserve
> ABI etc, which is what vmware is presumably after.  However, I am not
> advocating this as necessary at this juncture.
>    

Maybe AlacrityVM users don't care about compatibility, but my users do.

-- 
error compiling committee.c: too many arguments to function

