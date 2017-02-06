From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v5 3/4] net: phy: Allow pre-declaration of MDIO
 devices
Date: Mon, 6 Feb 2017 14:48:08 +0100
Message-ID: <20170206134808.GG32506@lunn.ch>
References: <20170204210245.14812-1-f.fainelli@gmail.com>
 <20170204210245.14812-4-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jason Cooper <jason@lakedaemon.net>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
        <linux-arm-kernel@lists.infradead.org>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170204210245.14812-4-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/include/linux/mod_devicetable.h b/include/linux/mod_devicetable.h
> index 8a57f0b1242d..8850fcaf50db 100644
> --- a/include/linux/mod_devicetable.h
> +++ b/include/linux/mod_devicetable.h
> @@ -501,6 +501,7 @@ struct platform_device_id {
>  	kernel_ulong_t driver_data;
>  };
>  
> +#define MDIO_NAME_SIZE		32

...

> +struct mdio_board_info {
> +	const char	*bus_id;
> +	char		modalias[MDIO_NAME_SIZE];
> +

I think it might be better to use MII_BUS_ID_SIZE. These are all
related, so using one define should avoid surprise buffer overruns,
truncation's.

	Andrew
