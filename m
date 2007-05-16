From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000: Fix msi enable leak on error, don't print error
 message,	cleanup
Date: Wed, 16 May 2007 08:35:31 -0700
Message-ID: <464B24C3.10302@intel.com>
References: <20070516083120.23311.3272.stgit@localhost.localdomain> <464B2426.9060502@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	hpa@zytor.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:31685 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757637AbXEPPfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 11:35:37 -0400
In-Reply-To: <464B2426.9060502@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Auke Kok wrote:
>> pci_enable_msi failure is a normal event so we should not print any error.
>> Going over the code I spotted a missing pci_disable_msi() leak when irq
>> allocation fails. The whole code also needed a cleanup, so I combined the
>> two different calls to pci_request_irq into a single call making this
>> look a lot better.
>>
>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> Cc: H. Peter Anvin <hpa@zytor.com>
> 
> Looks OK, but compounds (and highlights) another problem:  you shouldn't 
> be adding CONFIG_PCI_MSI ifdefs to the code.  MSI support is properly 
> set up in the headers to enable working code even if CONFIG_PCI_MSI is 
> disabled.
> 
> Revise your patch to remove CONFIG_PCI_MSI tests, and I'll include it 
> straightaway.

OK, on its way.

Thanks.

Auke
