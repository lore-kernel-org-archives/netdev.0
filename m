From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ETHOC should depend on HAS_DMA
Date: Fri, 20 Nov 2009 13:56:57 -0800 (PST)
Message-ID: <20091120.135657.78955091.davem@davemloft.net>
References: <10f740e80911201119h6db1e2e1t2c6d40ef1e614094@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: heiko.carstens@de.ibm.com, thierry.reding@avionic-design.de,
	schwidefsky@de.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45583
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755921AbZKTV4k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 16:56:40 -0500
In-Reply-To: <10f740e80911201119h6db1e2e1t2c6d40ef1e614094@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Fri, 20 Nov 2009 20:19:10 +0100

> Subject: [PATCH] net: ETHOC should depend on HAS_DMA
> 
> When building for Sun 3:
> 
> drivers/net/ethoc.c:1091: undefined reference to `dma_free_coherent'
> drivers/built-in.o: In function `ethoc_probe':
> drivers/net/ethoc.c:965: undefined reference to `dma_alloc_coherent'
> drivers/net/ethoc.c:1063: undefined reference to `dma_free_coherent'
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied, thanks.
