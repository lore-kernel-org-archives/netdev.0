From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/6] net: dsa: mv88e6xxx: add a software reset op
Date: Thu, 1 Dec 2016 00:26:33 +0100
Message-ID: <20161130232633.GS21645@lunn.ch>
References: <20161130225930.25510-1-vivien.didelot@savoirfairelinux.com>
 <20161130225930.25510-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161130225930.25510-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> index ab52c37..9e51405 100644
> --- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> +++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
> @@ -765,6 +765,9 @@ struct mv88e6xxx_ops {
>  	int (*phy_write)(struct mv88e6xxx_chip *chip, int addr, int reg,
>  			 u16 val);
>  
> +	/* Switch Software Reset */
> +	int (*reset)(struct mv88e6xxx_chip *chip);
> +

Hi Vivien

In my huge patch series of 6390, i've been using a g1_ prefix for
functionality which is in global 1, g2_ for global 2, etc.  This has
worked for everything so far with the exception of setting which
reserved MAC addresses should be sent to the CPU. Most devices have it
in g2, but 6390 has it in g1.

Please could you add the prefix.

       Andrew
