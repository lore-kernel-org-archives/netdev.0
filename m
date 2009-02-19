From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCHv2 06/11]Replace all DMA_32BIT_MASK macro with DMA_BIT_MASK(32)
Date: Thu, 19 Feb 2009 13:50:39 +0100
Message-ID: <499D559F.9020806@s5r6.in-berlin.de>
References: <499CFDC8.1070600@cn.fujitsu.com> <499D0221.9090407@cn.fujitsu.com> <20090219081403.GA5400@elte.hu> <499D1ED9.4040005@cn.fujitsu.com> <499D2728.1080208@cn.fujitsu.com> <499D2A2B.5080202@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Borislav Petkov <petkovbb@googlemail.com>
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:40654 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202AbZBSMus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 07:50:48 -0500
In-Reply-To: <499D2A2B.5080202@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yang Hongyang wrote:
> --- a/drivers/ieee1394/pcilynx.c
> +++ b/drivers/ieee1394/pcilynx.c
> @@ -1171,7 +1171,7 @@ static int __devinit add_card(struct pci_dev *dev,
>  
>          error = -ENXIO;
>  
> -        if (pci_set_dma_mask(dev, DMA_32BIT_MASK))
> +        if (pci_set_dma_mask(dev, DMA_BIT_MASK(32)))
>                  FAIL("DMA address limits not supported for PCILynx hardware");
>          if (pci_enable_device(dev))
>                  FAIL("failed to enable PCILynx hardware");

this hunk
Acked-by: Stefan Richter <stefanr@s5r6.in-berlin.de>
-- 
Stefan Richter
-=====-==--= --=- =--==
http://arcgraph.de/sr/
