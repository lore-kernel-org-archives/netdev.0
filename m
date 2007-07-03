From: Marian Balakowicz <m8@semihalf.com>
Subject: Re: quirk_e100_interrupt() called too early
Date: Tue, 03 Jul 2007 11:00:07 +0200
Message-ID: <468A1017.4030009@semihalf.com>
References: <4683A80F.5020605@semihalf.com> <4683DB44.9070704@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: bjorn.helgaas@hp.com, linux-pci@atrey.karlin.mff.cuni.cz,
	len.brown@intel.com, NetDev <netdev@vger.kernel.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.semihalf.com ([83.12.36.68]:33106 "EHLO mail.semihalf.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753613AbXGCJbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jul 2007 05:31:13 -0400
In-Reply-To: <4683DB44.9070704@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Marian Balakowicz wrote:
>> The patch below delays the quirk_100_interrupt() to pci_fixup_final
>> phase, which happens after bus enumeration and before device PCI enable
>> and device driver initialization - so, it seem to be still a good place
>> for this quirk. It works fine for me but I only tested it on a tqm5200.
>> Could someone please help and verify that on other platforms?
> 
> will try to do. This sounds indeed like the proper thing to do. Unfortunately I 
> don't have any NICs to repro this on (allthough I have a ppc box with said 
> firmware probe method).
> 
> Bjorn orignially wrote this patch, perhaps he can comment on the fixup move?
> 
> Also, please send a signed-off-by patch so I can push it forward as usual.

Sure, will do that, just wanted someone to have a look at it in the first place.

Best Regards,
Marian
