From: =?ISO-8859-1?Q?Emilio_L=F3pez?= <emilio@elopez.com.ar>
Subject: Re: [PATCHv3 1/6] net: Add EMAC ethernet driver found on Allwinner
 A10 SoC's
Date: Fri, 24 May 2013 09:46:32 -0300
Message-ID: <519F6128.9060608@elopez.com.ar>
References: <1369387394-9453-1-git-send-email-maxime.ripard@free-electrons.com> <1369387394-9453-2-git-send-email-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000009080808070406050104"
Cc: davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Roese <sr@denx.de>,
	Florian Fainelli <florian@openwrt.org>,
	kevin@allwinnertech.com, sunny@allwinnertech.com,
	shuge@allwinnertech.com
To: Maxime Ripard <maxime.ripard@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369387394-9453-2-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000009080808070406050104
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

El 24/05/13 06:23, Maxime Ripard escribió:
> From: Stefan Roese <sr@denx.de>
> 
> The Allwinner A10 has an ethernet controller that seem to be developped
> internally by them.
> 
> The exact feature set of this controller is unknown, since there is no
> public documentation for this IP, and this driver is mostly the one
> published by Allwinner that has been heavily cleaned up.
> 
> Signed-off-by: Stefan Roese <sr@denx.de>
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
> ---

(snip)

> +
> +config SUN4I_EMAC
> +        tristate "Allwinner A10 EMAC support"
> +	depends on ARCH_SUNXI
> +	depends on OF
> +	select CRC32
> +	select NET_CORE
> +	select MII
> +	select REGULATOR_FIXED_VOLTAGE
> +        ---help---
> +          Support for Allwinner A10 EMAC ethernet driver.
> +
> +          To compile this driver as a module, choose M here.  The module
> +          will be called sun4i-emac.
> +

You also need to select REGULATOR when you select REGULATOR_FIXED_VOLTAGE

I have attached a fixup patch you can use with git autosquash

Cheers,

Emilio

--------------000009080808070406050104
Content-Type: text/x-diff;
 name="fixup-regulator.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="fixup-regulator.patch"

>From f1b94482b4975ce1f7bc542208718f26d5dfa140 Mon Sep 17 00:00:00 2001
From: =?UTF-8?q?Emilio=20L=C3=B3pez?= <emilio@elopez.com.ar>
Date: Fri, 17 May 2013 10:11:16 -0300
Subject: [PATCH] fixup! net: Add EMAC ethernet driver found on Allwinner A10
 SoC's

---
 drivers/net/ethernet/allwinner/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/allwinner/Kconfig b/drivers/net/ethernet/allwinner/Kconfig
index 7bbd500..47ecbe0 100644
--- a/drivers/net/ethernet/allwinner/Kconfig
+++ b/drivers/net/ethernet/allwinner/Kconfig
@@ -26,6 +26,7 @@ config SUN4I_EMAC
 	select CRC32
 	select NET_CORE
 	select MII
+	select REGULATOR
 	select REGULATOR_FIXED_VOLTAGE
 	select PHYLIB
         ---help---
-- 
1.8.1.6


--------------000009080808070406050104--
