From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] smsc95xx: Add comments to the registers definition
Date: Mon, 10 Apr 2017 15:52:51 +0200
Message-ID: <20170410135251.GC19820@lunn.ch>
References: <20170410084521.w2kdjpdquvrg72mr@SMX-2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.org,
        Steve Glendinning <steve.glendinning@shawell.net>,
        Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Martin Wetterwald <martin@wetterwald.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53685 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753340AbdDJNxH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Apr 2017 09:53:07 -0400
Content-Disposition: inline
In-Reply-To: <20170410084521.w2kdjpdquvrg72mr@SMX-2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin

> @@ -2032,7 +2032,7 @@ static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
>  	skb_push(skb, 4);
>  	tx_cmd_b = (u32)(skb->len - 4);
>  	if (csum)
> -		tx_cmd_b |= TX_CMD_B_CSUM_ENABLE;
> +		tx_cmd_b |= TX_CMD_B_CSUM_EN;

This changed seems a step backwards, ENABLE is much more readable than EN.

>  
> -#define TX_CMD_B_CSUM_ENABLE		(0x00004000)
> -#define TX_CMD_B_ADD_CRC_DISABLE_	(0x00002000)
> -#define TX_CMD_B_DISABLE_PADDING_	(0x00001000)
> -#define TX_CMD_B_PKT_BYTE_LENGTH_	(0x000007FF)
> +#define TX_CMD_B_CSUM_EN	(0x00004000)	/* TX Checksum Enable */

And there is space for ABLE here.

    Andrew
