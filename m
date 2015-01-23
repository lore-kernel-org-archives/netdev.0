From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 1/2] ARM: exynos5440-sd5v1: switch to fixed-link DT binding
Date: Fri, 23 Jan 2015 15:48:24 +0800
Message-ID: <1421999305-19267-2-git-send-email-ming.lei@canonical.com>
References: <1421999305-19267-1-git-send-email-ming.lei@canonical.com>
Cc: linux-samsung-soc@vger.kernel.org, Kukjin Kim <kgene@kernel.org>,
	netdev@vger.kernel.org, Byungho An <bh74.an@samsung.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ming Lei <ming.lei@canonical.com>
To: linux-arm-kernel@lists.infradead.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:55371 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbbAWHsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 02:48:50 -0500
In-Reply-To: <1421999305-19267-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
