From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v2] 3c59x: fix PCI resource management
Date: Mon, 06 May 2013 22:23:14 +0400
Message-ID: <5187F512.4070104@cogentembedded.com>
References: <201305020240.34487.sergei.shtylyov@cogentembedded.com> <20130506.122040.1138770239806939990.davem@davemloft.net> <5187E884.7060101@cogentembedded.com> <20130506.135305.1659397370290340459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de,
	tedheadster@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:54299 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754831Ab3EFSXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 14:23:17 -0400
Received: by mail-lb0-f175.google.com with SMTP id w20so3714018lbh.34
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 11:23:16 -0700 (PDT)
In-Reply-To: <20130506.135305.1659397370290340459.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06-05-2013 21:53, David Miller wrote:

>>>> @@ -1215,12 +1217,13 @@ static int vortex_probe1(struct device *
>>>>    	vp->mii.reg_num_mask = 0x1f;
>>>>
>>>>    	/* Makes sure rings are at least 16 byte aligned. */
>>>> -	vp->rx_ring = pci_alloc_consistent(pdev, sizeof(struct boom_rx_desc) *
>>>> -	RX_RING_SIZE
>>>> -					   + sizeof(struct boom_tx_desc) * TX_RING_SIZE,
>>>> -					   &vp->rx_ring_dma);
>>>> +	vp->rx_ring = pci_alloc_consistent(pdev,
>>>> + sizeof(struct boom_rx_desc) * RX_RING_SIZE +
>>>> + sizeof(struct boom_tx_desc) * TX_RING_SIZE,
>>>> +				&vp->rx_ring_dma);

>>> This code was properly indented before your changes, but it isn't
>>> afterwards.

>>     David, that's not my change, it's was Andrew Morton who changed that
>>     (in order not to cross 80 columns).

> Ok, whoever submits this next needs to undo that.

     How about I completely drop this change (and maybe deal with it in 
a subsequent cleanup patch)?

WBR, Sergei
