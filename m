From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Add mac driver for w90p910
Date: Mon, 27 Jul 2009 11:24:59 -0700 (PDT)
Message-ID: <20090727.112459.224637019.davem@davemloft.net>
References: <5d5443650907201049j19fac3a6k4f2be7599ad240db@mail.gmail.com>
	<20090720.105217.236487133.davem@davemloft.net>
	<4A67EC88.8010001@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, soni.trilok@gmail.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	eric.y.miao@gmail.com
To: mcuos.com@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59485
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750756AbZG0SYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 14:24:52 -0400
In-Reply-To: <4A67EC88.8010001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wan ZongShun <mcuos.com@gmail.com>
Date: Thu, 23 Jul 2009 12:52:24 +0800

> I fixed up previous mac driver and make a patch relative to it.

This patch does not apply to the code actually in the tree,
for example:

>  	ether->tdesc = (struct tran_pdesc *)
> -			dma_alloc_coherent(NULL, sizeof(struct tran_pdesc),
> -				(dma_addr_t *)&ether->tdesc_phys, GFP_KERNEL);
> +		dma_alloc_coherent(&pdev->dev, sizeof(struct tran_pdesc),
> +					&ether->tdesc_phys, GFP_KERNEL);
> +

in the tree there is a space between '(dma_addr_t *)' and
'&ether->tdesc_phys', but the code you are patching against
does not have that space.

Please do two things:

1) Generate your patch properly against the code actually in
   the tree.

2) Create a coherent, verbose, commit message and proper subject
   line which describes one-by-one the bug fixes you are making
   to the driver.

Thanks.
