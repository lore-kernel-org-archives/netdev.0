From: Jeff Garzik <jeff@garzik.org>
Subject: Re: ata and netdev (was Re: -mm merge plans for 2.6.23)
Date: Tue, 10 Jul 2007 14:57:16 -0400
Message-ID: <4693D68C.7000303@garzik.org>
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>	<4693C4F8.40903@garzik.org> <20070710112458.e9dbb55e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	IDE/ATA development list <linux-ide@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Tejun Heo <htejun@gmail.com>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Deepak Saxena <dsaxena@plexity.net>,
	Dan Faerch <dan@hacker.dk>, Benjamin LaHaise <bcrl@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20070710112458.e9dbb55e.akpm@linux-foundation.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Tue, 10 Jul 2007 13:42:16 -0400
> Jeff Garzik <jeff@garzik.org> wrote:
> 
>> (just to provide my indicator of status)
> 
> Thanks.
> 
>>> libata-add-irq_flags-to-struct-pata_platform_info-fix.patch
>> are other pata_platform people happy with this?  I don't know embedded 
>> well enough to know if adding this struct member will break things.
> 
> This is just a silly remove-unneeded-cast-of-void* cleanup.  I wrote this
> as a fixup against
> libata-add-irq_flags-to-struct-pata_platform_info.patch with the intention
> of folding it into that base patch, but you went and merged the submitter's
> original patch so this trivial fixup got stranded in -mm.  Feel free to give
> it the piss-off-too-trivial treatment.

I'm sorry, I didn't look closely enough.  I was referring to the 
add-irq-flags patch itself, not your small fix.


>>> ata-ahci-alpm-store-interrupt-value.patch
>>> ata-ahci-alpm-expose-power-management-policy-option-to-users.patch
>>> ata-ahci-alpm-enable-link-power-management-for-ata-drivers.patch
>>> ata-ahci-alpm-enable-aggressive-link-power-management-for-ahci-controllers.patch
>>>
>>>  These appear to need some work.
>> seemed mostly OK to me.  what comments did I miss?
> 
> Oh, I thought these were the patches which affected scsi and which James
> had issues with.  I guess I got confused.

hrm.  ISTR James wanted some cleanups, Kristen did some cleanups, then 
looking at the cleanups decided they were needed / appropriate at this time.

Anyway, these are in my mbox queue and the libata portions (of which the 
code is the majority) seem OK.  Need to give them a final review.

	Jeff



