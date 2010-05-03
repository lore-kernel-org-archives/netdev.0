From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] skge: use the DMA state API instead of the pci
 equivalents
Date: Mon, 03 May 2010 15:32:26 -0700 (PDT)
Message-ID: <20100503.153226.267391665.davem@davemloft.net>
References: <20100428095730K.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: fujita.tomonori@lab.ntt.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43402
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753338Ab0ECWcU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 18:32:20 -0400
In-Reply-To: <20100428095730K.fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Date: Wed, 28 Apr 2010 09:57:04 +0900

> This replace the PCI DMA state API (include/linux/pci-dma.h) with the
> DMA equivalents since the PCI DMA state API will be obsolete.
> 
> No functional change.
> 
> For further information about the background:
> 
> http://marc.info/?l=linux-netdev&m=127037540020276&w=2
> 
> Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

Stephen have you had a chance to smoke test this yet?
I'd like to apply it as it's been rotting in patchwork
for almost a week now.
