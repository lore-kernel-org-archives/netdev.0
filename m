From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 1/6] The file ksz_common.c will be used by other KSZ
 switch drivers.
Date: Thu, 7 Sep 2017 23:24:49 +0200
Message-ID: <20170907212449.GQ11248@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218C4@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD411219FF@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD411219FF@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 07, 2017 at 09:08:58PM +0000, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>
> 
> Break ksz_common.c into 2 files so that the common code can be used by other KSZ switch drivers.
> 
> Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
> ---
> diff --git a/drivers/net/dsa/microchip/Makefile b/drivers/net/dsa/microchip/Makefile
> index ed335e2..0961c30 100644
> --- a/drivers/net/dsa/microchip/Makefile
> +++ b/drivers/net/dsa/microchip/Makefile
> @@ -1,2 +1,2 @@
> -obj-$(CONFIG_MICROCHIP_KSZ)	        += ksz_common.o
> +obj-$(CONFIG_MICROCHIP_KSZ)	        += ksz9477.o ksz_common.o
>  obj-$(CONFIG_MICROCHIP_KSZ_SPI_DRIVER)	+= ksz_spi.o

Hi Tristram

I would of thought this would break the build. You don't add ksz9477.c
until the next patch.

Each patch needs to compile, otherwise you break git bisect.

     Andrew
