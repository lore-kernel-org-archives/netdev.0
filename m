From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: macb: Increase DMA buffer size
Date: Wed, 24 Aug 2016 21:17:04 +0200
Message-ID: <cccfc176-df56-4add-e6c8-e040f9da31dc@atmel.com>
References: <1472063159-13797-1-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, Nathan Sullivan <nathan.sullivan@ni.com>,
        <linux-kernel@vger.kernel.org>
To: Xander Huff <xander.huff@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:8459 "EHLO
        eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932825AbcHXTRK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 15:17:10 -0400
In-Reply-To: <1472063159-13797-1-git-send-email-xander.huff@ni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 24/08/2016 à 20:25, Xander Huff a écrit :
> From: Nathan Sullivan <nathan.sullivan@ni.com>
> 
> In recent testing with the RT patchset, we have seen cases where the
> transmit ring can fill even with up to 200 txbds in the ring.  Increase
> the size of the DMA rings to avoid overruns.
> 
> Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
> Acked-by: Ben Shelton <ben.shelton@ni.com>
> Acked-by: Jaeden Amero <jaeden.amero@ni.com>
> Natinst-ReviewBoard-ID: 83662
> ---
>  drivers/net/ethernet/cadence/macb.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 3256839..86a8e20 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -35,12 +35,12 @@
>  
>  #include "macb.h"
>  
> -#define MACB_RX_BUFFER_SIZE	128
> +#define MACB_RX_BUFFER_SIZE	1536

This change seems not covered by the commit message. Can you  please
separate the changes in 2 patches or elaborate a bit more the reason for
this RX buffer size change.

Bye,

>  #define RX_BUFFER_MULTIPLE	64  /* bytes */
>  #define RX_RING_SIZE		512 /* must be power of 2 */
>  #define RX_RING_BYTES		(sizeof(struct macb_dma_desc) * RX_RING_SIZE)
>  
> -#define TX_RING_SIZE		128 /* must be power of 2 */
> +#define TX_RING_SIZE		512 /* must be power of 2 */
>  #define TX_RING_BYTES		(sizeof(struct macb_dma_desc) * TX_RING_SIZE)
>  
>  /* level of occupied TX descriptors under which we wake up TX process */
> 


-- 
Nicolas Ferre
