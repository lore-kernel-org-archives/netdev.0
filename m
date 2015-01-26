From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 1/2] ARM: exynos5440-sd5v1: switch to fixed-link DT binding
Date: Mon, 26 Jan 2015 10:37:37 +0800
Message-ID: <1422239858-3452-2-git-send-email-ming.lei@canonical.com>
References: <1422239858-3452-1-git-send-email-ming.lei@canonical.com>
Cc: linux-samsung-soc@vger.kernel.org, Kukjin Kim <kgene@kernel.org>,
	netdev@vger.kernel.org, Byungho An <bh74.an@samsung.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ming Lei <ming.lei@canonical.com>
To: linux-arm-kernel@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-Reply-To: <1422239858-3452-1-git-send-email-ming.lei@canonical.com>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The previous dts property isn't standard way for fixed phy
support, and switch to the fixed-link DT binding.

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 arch/arm/boot/dts/exynos5440-sd5v1.dts |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/arch/arm/boot/dts/exynos5440-sd5v1.dts b/arch/arm/boot/dts/exynos5440-sd5v1.dts
index 268609a..ee65a5c 100644
--- a/arch/arm/boot/dts/exynos5440-sd5v1.dts
+++ b/arch/arm/boot/dts/exynos5440-sd5v1.dts
@@ -28,8 +28,10 @@
 	};
 
 	gmac: ethernet@00230000 {
-		fixed_phy;
-		phy_addr = <1>;
+		fixed-link {
+			speed = <1000>;
+			full-duplex;
+		};
 	};
 
 	spi {
-- 
1.7.9.5
