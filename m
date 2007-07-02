From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: quirk_e100_interrupt() called too early
Date: Mon, 02 Jul 2007 12:03:27 -0700
Message-ID: <46894BFF.70405@intel.com>
References: <4683A80F.5020605@semihalf.com> <4683DB44.9070704@intel.com> <200706282007.27841.bjorn.helgaas@hp.com> <4688B258.4000501@funkwerk-ec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	Marian Balakowicz <m8@semihalf.com>,
	"linux-pci@atrey.karlin.mff.cuni.cz"
	<linux-pci@atrey.karlin.mff.cuni.cz>,
	"len.brown@intel.com" <len.brown@intel.com>,
	NetDev <netdev@vger.kernel.org>
To: Nils Rennebarth <nils.rennebarth@funkwerk-ec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28138 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756233AbXGBTDa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 15:03:30 -0400
In-Reply-To: <4688B258.4000501@funkwerk-ec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nils Rennebarth wrote:
> Bjorn Helgaas wrote:
>> On Thursday 28 June 2007 10:01:08 am Kok, Auke wrote:
>> I copied Nils Rennebarth, who originally reported the bug:
>>   http://bugzilla.kernel.org/show_bug.cgi?id=5918
>> in case he can test your patch.
 >
> Most of the embedded boards we now work with appear to exhibit the same 
> behaviour: During boot the
> 
> Firmware left 0000:01:05.0 e100 interrupts enabled, disabling
> 
> message appears for all four e100 nics. (The mainboard is a em-8510A 
> btw.) When I have time I could try if the quirk still works with the
> mentioned patch, but I am quite busy with other things at the moment.

well, we're too late for 2.6.22 I think so you have some time. However I'd like 
to make sure we can get this in with 2.6.23. Alternatively, someone could always 
send me one of these boards ;)

Thanks for taking the time to test

Auke
