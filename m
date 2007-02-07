From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/4] ucc_geth: Change private immrbar_virt_to_phys to generic iopa
Date: Wed, 7 Feb 2007 10:36:58 -0600
Message-ID: <6D988EC5-4F41-45FA-9FBF-2AC5731D9B27@kernel.crashing.org>
References: <989B956029373F45A0B8AF02970818900D4332@zch01exm26.fsl.freescale.net>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <jeff@garzik.org>, <netdev@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>
To: Li Yang-r58472 <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:30341 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965684AbXBGQuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 11:50:00 -0500
In-Reply-To: <989B956029373F45A0B8AF02970818900D4332@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 7, 2007, at 3:34 AM, Li Yang-r58472 wrote:

>> On Feb 6, 2007, at 5:31 AM, Li Yang wrote:
>>
>>> Get rid of private immrbar_virt_to_phys() routine and
>>> use generic iopa().
>>
>> Nack. iopa() isn't that generic, shouldn't we really be using the dma
>> mapping API here?
>
> Do you mean the dma_map_single()?  dma_map_single can map memory space
> correctly, but I don't think it can handle ioremap-ed space.

What are you mapping?  It looks like buffer descriptor rings.  Are  
they being kept in QE sram?  If so that I think you can treat it as  
memory.  (I believe the SRAM behaves like memory, is cache-coherent,  
etc).

- k
