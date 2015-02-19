From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5] Add support of Cavium Liquidio ethernet
 adapters
Date: Thu, 19 Feb 2015 16:21:47 -0500 (EST)
Message-ID: <20150219.162147.987651422309233299.davem@davemloft.net>
References: <1423704042-4026-1-git-send-email-rvatsavayi@caviumnetworks.com>
	<20150219.143610.1038570471548445608.davem@davemloft.net>
	<BY2PR07MB486BB911FB76C60D322131AFE2D0@BY2PR07MB486.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Raghu.Vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
	Satananda.Burla@caviumnetworks.com,
	Felix.Manlunas@caviumnetworks.com
To: Derek.Chickles@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58007 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbbBSVVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 16:21:49 -0500
In-Reply-To: <BY2PR07MB486BB911FB76C60D322131AFE2D0@BY2PR07MB486.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chickles, Derek" <Derek.Chickles@caviumnetworks.com>
Date: Thu, 19 Feb 2015 20:44:11 +0000

>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Thursday, February 19, 2015 11:36 AM
>> To: Vatsavayi, Raghu
>> Cc: netdev@vger.kernel.org; Chickles, Derek; Burla, Satananda; Manlunas,
>> Felix; Vatsavayi, Raghu
>> Subject: Re: [PATCH net-next v5] Add support of Cavium Liquidio ethernet
>> adapters
>> 
>> From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
>> Date: Wed, 11 Feb 2015 17:20:42 -0800
>> 
>> > +	pci_unmap_single(lio->oct_dev->pci_dev, finfo->dptr, skb->len,
>> > +			 PCI_DMA_TODEVICE);
>> 
>> Please use the dma_*() variants of the DMA interfaces for which you
>> will pass in a reference to the struct device embedded in the pci_dev.
>> 
>> This will allow you to later make use of various generic facilities
>> we will build for DMA mapping SKBs in the networking, allocating
>> networknig page frags, etc.
>> 
> 
> You said you *will* be building these facilities. Are there any now
> that we can take advantage of? (We'll move to the dma_* variants
> regardless.)

There is a page frag allocator that the ENIC guys wrote which I've
asked them to make completely generic before inclusion.

> Also, do you have any remaining style / global comments that we should
> address?

I will re-review the driver after you make another spin.

It is extremely time intensive to walk over your driver beacuse it
is so huge, so those of us who are actually trying to help you by
reviewing your code have to do it piecemeal.

So asking us to look into "everything" is not really all that tenable.

This is going to be a long process and it's going to take time, and
it's important to understand that people are volunteering their time
to do these reviews.
