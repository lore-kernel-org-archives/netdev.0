From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 5/5] net: dsa: mv88e6xxx: Implement the 6390
 external MDIO bus
Date: Wed, 25 Jan 2017 02:32:30 +0100
Message-ID: <20170125013230.GB5043@lunn.ch>
References: <1485266031-4980-1-git-send-email-andrew@lunn.ch>
 <1485266031-4980-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Gregory Clement <gregory.clement@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44680 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751071AbdAYBcc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 20:32:32 -0500
Content-Disposition: inline
In-Reply-To: <1485266031-4980-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> index 7d24add45e74..572d585dc1e2 100644
> --- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> @@ -387,6 +387,7 @@
>  #define GLOBAL2_PTP_AVB_DATA	0x17
>  #define GLOBAL2_SMI_PHY_CMD			0x18
>  #define GLOBAL2_SMI_PHY_CMD_BUSY		BIT(15)
> +#define GLOBAL2_SMI_PHY_CMD_EXTERNAL		BIT(13)
>  #define GLOBAL2_SMI_PHY_CMD_MODE_22		BIT(12)
>  #define GLOBAL2_SMI_PHY_CMD_OP_22_WRITE_DATA	((0x1 << 10) | \

Hi Gregory

Please could you check if the 88E6341 has an external MDIO. Global 2,
register 0x18, bit 13.

Thanks
	Andrew
