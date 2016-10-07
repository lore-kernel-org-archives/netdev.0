From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v4 09/10] ARM: sunxi: Enable sun8i-emac driver on sunxi_defconfig
Date: Fri,  7 Oct 2016 10:25:56 +0200
Message-ID: <1475828757-926-10-git-send-email-clabbe.montjoie@gmail.com>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net, f.fainelli@gmail.com,
        andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36177 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756379AbcJGI2d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 04:28:33 -0400
In-Reply-To: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable the sun8i-emac driver in the sunxi default configuration

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/configs/sunxi_defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/configs/sunxi_defconfig b/arch/arm/configs/sunxi_defconfig
index 714da33..153707a 100644
--- a/arch/arm/configs/sunxi_defconfig
+++ b/arch/arm/configs/sunxi_defconfig
@@ -40,6 +40,7 @@ CONFIG_ATA=y
 CONFIG_AHCI_SUNXI=y
 CONFIG_NETDEVICES=y
 CONFIG_SUN4I_EMAC=y
+CONFIG_SUN8I_EMAC=y
 # CONFIG_NET_VENDOR_ARC is not set
 # CONFIG_NET_CADENCE is not set
 # CONFIG_NET_VENDOR_BROADCOM is not set
-- 
2.7.3
