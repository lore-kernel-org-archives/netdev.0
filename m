From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/6] net: dsa: mv88e6xxx: add a software reset
 op
Date: Fri, 02 Dec 2016 12:23:11 -0500 (EST)
Message-ID: <20161202.122311.1045081741040479698.davem@davemloft.net>
References: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com>
        <20161130225930.25510-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161130225930.25510-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed, 30 Nov 2016 17:59:27 -0500

> @@ -765,6 +765,9 @@ struct mv88e6xxx_ops {
>  	int (*phy_write)(struct mv88e6xxx_chip *chip, int addr, int reg,
>  			 u16 val);
>  
> +	/* Switch Software Reset */
> +	int (*reset)(struct mv88e6xxx_chip *chip);
> +

I think Andrew's request to name this method "g1_reset" is reasonable, please
respin with that change.

Thanks.
