From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RESEND][PATCH 2.6.27-rc3] ixp4xx_eth: fix dma_mapping_error()
 compile errors
Date: Thu, 14 Aug 2008 04:28:46 -0400
Message-ID: <48A3ECBE.9050909@garzik.org>
References: <200808131908.m7DJ8EAp013777@harpo.it.uu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41411 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754006AbYHNI2y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 04:28:54 -0400
In-Reply-To: <200808131908.m7DJ8EAp013777@harpo.it.uu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mikael Pettersson wrote:
> The arm ixp4xx_eth driver doesn't compile in 2.6.27-rc1:
> 
>   CC [M]  drivers/net/arm/ixp4xx_eth.o
> drivers/net/arm/ixp4xx_eth.c: In function 'eth_poll':
> drivers/net/arm/ixp4xx_eth.c:554: warning: passing argument 1 of 'dma_mapping_error' makes pointer from integer without a cast
> drivers/net/arm/ixp4xx_eth.c:554: error: too few arguments to function 'dma_mapping_error'
> drivers/net/arm/ixp4xx_eth.c: In function 'eth_xmit':
> drivers/net/arm/ixp4xx_eth.c:701: warning: passing argument 1 of 'dma_mapping_error' makes pointer from integer without a cast
> drivers/net/arm/ixp4xx_eth.c:701: error: too few arguments to function 'dma_mapping_error'
> drivers/net/arm/ixp4xx_eth.c: In function 'init_queues':
> drivers/net/arm/ixp4xx_eth.c:886: warning: passing argument 1 of 'dma_mapping_error' makes pointer from integer without a cast
> drivers/net/arm/ixp4xx_eth.c:886: error: too few arguments to function 'dma_mapping_error'
> make[3]: *** [drivers/net/arm/ixp4xx_eth.o] Error 1
> make[2]: *** [drivers/net/arm] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2
> 
> dma_mapping_error() changed in 2.6.27-rc1 to also take a device parameter,
> but nobody bothered updating ixp4xx_eth.c. Fixed by passing the appropriate
> device value in the dma_mapping_error() calls.
> 
> Tested on an ixp425 box.
> 
> Signed-off-by: Mikael Pettersson <mikpe@it.uu.se>
> Acked-by: Krzysztof Halasa <khc@pm.waw.pl>
> ---

applied


