From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 04/11] bnx2x: Add TX fault check for fiber PHYs
Date: Sun, 22 May 2011 22:20:18 -0700
Message-ID: <1306128018.3456.35.camel@localhost>
References: <1306063927.20872.86.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, eilong@broadcom.com
To: Yaniv Rosner <yanivr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:16072 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751168Ab1EWFUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 01:20:22 -0400
In-Reply-To: <1306063927.20872.86.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-05-22 at 14:32 +0300, Yaniv Rosner wrote:
> In case TX fault is detected on Fiber PHYs, declare the link as down
> until TX fault is gone.
[...]
> --- a/drivers/net/bnx2x/bnx2x_reg.h
> +++ b/drivers/net/bnx2x/bnx2x_reg.h
> @@ -6037,6 +6037,7 @@ Theotherbitsarereservedandshouldbezero*/
>  #define MDIO_PMA_REG_BCM_CTRL		0x0096
>  #define MDIO_PMA_REG_FEC_CTRL		0x00ab
>  #define MDIO_PMA_REG_RX_ALARM_CTRL	0x9000
> +#define MDIO_PMA_REG_TX_ALARM_CTRL	0x9001
>  #define MDIO_PMA_REG_LASI_CTRL		0x9002
>  #define MDIO_PMA_REG_RX_ALARM		0x9003
>  #define MDIO_PMA_REG_TX_ALARM		0x9004

By the way, the LASI registers are already named in <linux/mdio.h>:

#define MDIO_PMA_LASI_RXCTRL	0x9000	/* RX_ALARM control */
#define MDIO_PMA_LASI_TXCTRL	0x9001	/* TX_ALARM control */
#define MDIO_PMA_LASI_CTRL	0x9002	/* LASI control */
#define MDIO_PMA_LASI_RXSTAT	0x9003	/* RX_ALARM status */
#define MDIO_PMA_LASI_TXSTAT	0x9004	/* TX_ALARM status */
#define MDIO_PMA_LASI_STAT	0x9005	/* LASI status */

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

