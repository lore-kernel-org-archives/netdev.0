From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC][PATCH 0/75] pci_module_init to pci_register_driver conversion
Date: Thu, 17 Aug 2006 08:35:12 -0400
Message-ID: <44E46280.2020109@garzik.org>
References: <20060817042634.0.CrzcY28443.28439.michal@ltg01-fedora.pl> <20060817055814.GA14950@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36266 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932340AbWHQMfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 08:35:16 -0400
To: Greg KH <greg@kroah.com>
In-Reply-To: <20060817055814.GA14950@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greg KH wrote:
> On Thu, Aug 17, 2006 at 04:26:35AM +0000, Michal Piotrowski wrote:
>> Hi,
>>
>> pci_module_init is obsolete.
>>
>> This patch series converts pci_module_init to pci_register_driver.
>>
>>
>> Can I remove this?
>>
>> include/linux/pci.h:385
>> /*
>>  * pci_module_init is obsolete, this stays here till we fix up all usages of it
>>  * in the tree.
>>  */
>> #define pci_module_init pci_register_driver
> 
> As repeated numerous times, it's up to the network developers if they
> will take this or not.
> 
> I'll hold off on taking this series, please push it through the driver
> subsystem maintainers.

It's already in subsystem trees, in fact.

But it is most definitely not 2.6.18-rc material :)

	Jeff



