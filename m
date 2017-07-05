From: Biju Das <biju.das@bp.renesas.com>
Subject: [PATCH v 2/2] ARM: shmobile: defconfig: Enable Ethernet AVB
Date: Wed,  5 Jul 2017 14:01:51 +0100
Message-ID: <1499259711-56175-3-git-send-email-biju.das@bp.renesas.com>
References: <1499259711-56175-1-git-send-email-biju.das@bp.renesas.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms@verge.net.au>,
        Magnus Damm <magnus.damm@gmail.com>,
        Chris Paterson <chris.paterson2@renesas.com>,
        devicetree@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        Biju Das <biju.das@bp.renesas.com>
To: Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Russell King <linux@armlinux.org.uk>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1499259711-56175-1-git-send-email-biju.das@bp.renesas.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The iWave RZ/G1M Q7 SOM supports Gigabit Ethernet Phy (Micrel KSZ9031MNX).
Gigabit Ethernet support is available in Renesas AVB driver.
To increase hardware support enable the driver in the shmobile_defconfig
multiplatform configuration.

Signed-off-by: Biju Das <biju.das@bp.renesas.com>
Reviewed-by: Chris Paterson <chris.paterson2@renesas.com>
---
 arch/arm/configs/shmobile_defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/configs/shmobile_defconfig b/arch/arm/configs/shmobile_defconfig
index 3c66a42..d992911 100644
--- a/arch/arm/configs/shmobile_defconfig
+++ b/arch/arm/configs/shmobile_defconfig
@@ -83,6 +83,7 @@ CONFIG_NETDEVICES=y
 # CONFIG_NET_VENDOR_MICREL is not set
 # CONFIG_NET_VENDOR_NATSEMI is not set
 CONFIG_SH_ETH=y
+CONFIG_RAVB=y
 # CONFIG_NET_VENDOR_SEEQ is not set
 CONFIG_SMSC911X=y
 # CONFIG_NET_VENDOR_STMICRO is not set
-- 
1.9.1
