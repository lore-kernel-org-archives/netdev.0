From: "Chickles, Derek" <Derek.Chickles@caviumnetworks.com>
Subject: RE: [PATCH net-next v5] Add support of Cavium Liquidio ethernet
 adapters
Date: Thu, 19 Feb 2015 20:44:11 +0000
Message-ID: <BY2PR07MB486BB911FB76C60D322131AFE2D0@BY2PR07MB486.namprd07.prod.outlook.com>
References: <BY2PR07MB4869D030A180D0147F3580AFE380@BY2PR07MB486.namprd07.prod.outlook.com>
	<1423704042-4026-1-git-send-email-rvatsavayi@caviumnetworks.com>
 <20150219.143610.1038570471548445608.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Burla, Satananda" <Satananda.Burla@caviumnetworks.com>,
	"Manlunas, Felix" <Felix.Manlunas@caviumnetworks.com>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>
To: David Miller <davem@davemloft.net>,
	"Vatsavayi, Raghu" <Raghu.Vatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0073.outbound.protection.outlook.com ([65.55.169.73]:32611
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752004AbbBSU7a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 15:59:30 -0500
In-Reply-To: <20150219.143610.1038570471548445608.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, February 19, 2015 11:36 AM
> To: Vatsavayi, Raghu
> Cc: netdev@vger.kernel.org; Chickles, Derek; Burla, Satananda; Manlunas,
> Felix; Vatsavayi, Raghu
> Subject: Re: [PATCH net-next v5] Add support of Cavium Liquidio ethernet
> adapters
> 
> From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
> Date: Wed, 11 Feb 2015 17:20:42 -0800
> 
> > +	pci_unmap_single(lio->oct_dev->pci_dev, finfo->dptr, skb->len,
> > +			 PCI_DMA_TODEVICE);
> 
> Please use the dma_*() variants of the DMA interfaces for which you
> will pass in a reference to the struct device embedded in the pci_dev.
> 
> This will allow you to later make use of various generic facilities
> we will build for DMA mapping SKBs in the networking, allocating
> networknig page frags, etc.
> 

You said you *will* be building these facilities. Are there any now
that we can take advantage of? (We'll move to the dma_* variants
regardless.)

Also, do you have any remaining style / global comments that we should
address?

Thanks,
Derek
