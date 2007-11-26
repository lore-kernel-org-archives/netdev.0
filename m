From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000: Fix for 32 bits platforms with 64 bits resources
Date: Mon, 26 Nov 2007 15:15:12 -0800
Message-ID: <474B5380.9040104@intel.com>
References: <20071116073821.548CCDDDF4@ozlabs.org> <474791D3.1090607@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:7632 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755632AbXKZXPj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Nov 2007 18:15:39 -0500
In-Reply-To: <474791D3.1090607@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Benjamin Herrenschmidt wrote:
>> The e1000 driver stores the content of the PCI resources into
>> unsigned long's before ioremapping. This breaks on 32 bits
>> platforms that support 64 bits MMIO resources such as ppc 44x.
>>
>> This fixes it by removing those temporary variables and passing
>> directly the result of pci_resource_start/len to ioremap.
>>
>> The side effect is that I removed the assignments to the netdev
>> fields mem_start, mem_end and base_addr, which are totally useless
>> for PCI devices.
>>
>> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
>> -- 
>>
>>  drivers/net/e1000/e1000_main.c |   18 +++++-------------
>>  1 file changed, 5 insertions(+), 13 deletions(-)
> 
> Looks good to me.  auke?

yes, please apply.

Acked-by: Auke Kok <auke-jan.h.kok@intel.com>



Auke
