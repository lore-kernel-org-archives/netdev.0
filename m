From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] 3c59x: fix PCI resource management
Date: Mon, 06 May 2013 13:53:05 -0400 (EDT)
Message-ID: <20130506.135305.1659397370290340459.davem@davemloft.net>
References: <201305020240.34487.sergei.shtylyov@cogentembedded.com>
	<20130506.122040.1138770239806939990.davem@davemloft.net>
	<5187E884.7060101@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	tedheadster@gmail.com
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754735Ab3EFRxH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 13:53:07 -0400
In-Reply-To: <5187E884.7060101@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 06 May 2013 21:29:40 +0400

> Hello.
> 
> On 06-05-2013 20:20, David Miller wrote:
> 
>>> @@ -1215,12 +1217,13 @@ static int vortex_probe1(struct device *
>>>   	vp->mii.reg_num_mask = 0x1f;
>>>
>>>   	/* Makes sure rings are at least 16 byte aligned. */
>>> -	vp->rx_ring = pci_alloc_consistent(pdev, sizeof(struct boom_rx_desc) *
>>> -	RX_RING_SIZE
>>> -					   + sizeof(struct boom_tx_desc) * TX_RING_SIZE,
>>> -					   &vp->rx_ring_dma);
>>> +	vp->rx_ring = pci_alloc_consistent(pdev,
>>> + sizeof(struct boom_rx_desc) * RX_RING_SIZE +
>>> + sizeof(struct boom_tx_desc) * TX_RING_SIZE,
>>> +				&vp->rx_ring_dma);
> 
>> This code was properly indented before your changes, but it isn't
>> afterwards.
> 
>    David, that's not my change, it's was Andrew Morton who changed that
>    (in order not to cross 80 columns).

Ok, whoever submits this next needs to undo that.
