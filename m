From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] skge: add dma_mapping check
Date: Sun, 04 Aug 2013 18:35:53 -0700 (PDT)
Message-ID: <20130804.183553.514470399074672614.davem@davemloft.net>
References: <20130804172234.345913ae@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37601 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754117Ab3HEBgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 21:36:09 -0400
In-Reply-To: <20130804172234.345913ae@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Sun, 4 Aug 2013 17:22:34 -0700

> This old driver never checked for DMA mapping errors.
> Causing splats with the new DMA mapping checks:
> 	WARNING: at lib/dma-debug.c:937 check_unmap+0x47b/0x930()
> 	skge 0000:01:09.0: DMA-API: device driver failed to check map
> 
> Add checks and unwind code.
> 
> Reported-by: poma <pomidorabelisima@gmail.com>
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, but:

> -static void skge_rx_setup(struct skge_port *skge, struct skge_element *e,
> +static int skge_rx_setup(struct skge_port *skge, struct skge_element *e,
>  			  struct sk_buff *skb, unsigned int bufsize)

I reflowed the argument indentation for this in the final commit.

Thanks.
