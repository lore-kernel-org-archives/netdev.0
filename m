From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/4] myri10ge - Driver core
Date: Fri, 26 May 2006 06:30:59 -0400
Message-ID: <4476D8E3.40101@garzik.org>
References: <20060517220218.GA13411@myri.com>	 <20060523153928.GB5938@krispykreme>	 <1148543810.13249.265.camel@localhost.localdomain>	 <200605261149.18415.netdev@axxeo.de> <1148637720.8089.145.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Oeser <netdev@axxeo.de>, Anton Blanchard <anton@samba.org>,
	Brice Goglin <brice@myri.com>, netdev@vger.kernel.org,
	gallatin@myri.com, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:5321 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751377AbWEZKbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 06:31:19 -0400
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1148637720.8089.145.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin Herrenschmidt wrote:
>>> No proper interface exposed, he'll have to do an #ifdef powerpc here or
>>> such and use __ioremap with explicit page attributes. I have a hack to
>>> do that automatically for memory covered by prefetchable PCI BARs when
>>> mmap'ing from userland but not for kernel ioremap.
>> Stupid question: pci_iomap() is NOT what you are looking for, right?
>>
>> Implementation is at the end of lib/iomap.c
> 
> No, there is no difference there, pci_iomap won't help for passing in
> platform specific page attributes for things like write combining.

Since we already have ioremap_nocache(), maybe adding ioremap_wcomb() is 
appropriate?

	Jeff


