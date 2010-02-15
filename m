From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -mm] ssb: open-code dma_alloc_coherent
Date: Sun, 14 Feb 2010 22:24:46 -0800 (PST)
Message-ID: <20100214.222446.138687519.davem@davemloft.net>
References: <20100215142111R.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org, mb@bu3sch.de,
	stefano.brivio@polimi.it, Larry.Finger@lwfinger.net,
	akpm@linux-foundation.org
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46110
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754323Ab0BOGYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 01:24:32 -0500
In-Reply-To: <20100215142111R.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Mon, 15 Feb 2010 14:21:58 +0900

> From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
> Subject: [PATCH -mm] ssb: open-code dma_alloc_coherent
> 
> This removes ssb_dma_alloc_consistent, a wrapper for
> dma_alloc_coherent and pci_alloc_consistent. dma_alloc_coherent
> internally calls pci_alloc_consistent against pci devices so we always
> use dma_alloc_coherent.
> 
> I prefer to use the DMA API directly instead of creating the ssb_dma_
> API. We have been removing any bus specific DMA APIs.
> 
> One disadvantage of this approach that we lost the debugging ability
> of checking the buggy usage of the DMA API against non DMA-capable ssb
> buses. But I guess that the ssb drivers are mature enough and can cope
> with such change?
> 
> I plan to replace all the ssb_dma API if this approach is fine.
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

I'm fine with this:

Acked-by: David S. Miller <davem@davemloft.net>
