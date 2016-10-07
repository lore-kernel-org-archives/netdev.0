From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH v4 10/10] ARM: sunxi: Enable sun8i-emac driver on multi_v7_defconfig
Date: Fri,  7 Oct 2016 10:25:57 +0200
Message-ID: <1475828757-926-11-git-send-email-clabbe.montjoie@gmail.com>
References: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Corentin Labbe <clabbe.montjoie@gmail.com>
To: robh+dt@kernel.org, mark.rutland@arm.com,
        maxime.ripard@free-electrons.com, wens@csie.org,
        linux@armlinux.org.uk, davem@davemloft.net, f.fainelli@gmail.com,
        andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475828757-926-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Enable the sun8i-emac driver in the multi_v7 default configuration

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 arch/arm/configs/multi_v7_defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/configs/multi_v7_defconfig b/arch/arm/configs/multi_v7_defconfig
index 5845910..f44d633 100644
--- a/arch/arm/configs/multi_v7_defconfig
+++ b/arch/arm/configs/multi_v7_defconfig
@@ -229,6 +229,7 @@ CONFIG_NETDEVICES=y
 CONFIG_VIRTIO_NET=y
 CONFIG_HIX5HD2_GMAC=y
 CONFIG_SUN4I_EMAC=y
+CONFIG_SUN8I_EMAC=y
 CONFIG_MACB=y
 CONFIG_BCMGENET=m
 CONFIG_SYSTEMPORT=m
-- 
2.7.3
