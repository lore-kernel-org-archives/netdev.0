From: Ian Campbell <ijc@hellion.org.uk>
Subject: [PATCH net] net: thunderx: remove effective "default y" from Kconfig if ARCH_THUNDER=y
Date: Tue,  4 Aug 2015 20:25:55 +0100
Message-ID: <1438716355-11515-1-git-send-email-ijc@hellion.org.uk>
Cc: Ian Campbell <ijc@hellion.org.uk>,
	Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
	Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As well as for kernels built only for ThunderX ARCH_THUNDERX is also enabled
for kernels which support multiple platforms (such as distro kernels). Thus
"default ARCH_THUNDER" is inappropriate.

I believe default m is equally frowned upon, so remove the line completely
rather than "default m if ARCH_THUNDER".

Signed-off-by: Ian Campbell <ijc@hellion.org.uk>
Cc: Sunil Goutham <sgoutham@cavium.com>
Cc: Robert Richter <rric@kernel.org>
Cc: Derek Chickles <derek.chickles@caviumnetworks.com>
Cc: Satanand Burla <satananda.burla@caviumnetworks.com>
Cc: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Cc: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/cavium/Kconfig | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index 3584420..9b35d14 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -16,7 +16,6 @@ if NET_VENDOR_CAVIUM
 config THUNDER_NIC_PF
 	tristate "Thunder Physical function driver"
 	depends on 64BIT
-	default ARCH_THUNDER
 	select THUNDER_NIC_BGX
 	---help---
 	  This driver supports Thunder's NIC physical function.
@@ -29,14 +28,12 @@ config THUNDER_NIC_PF
 config THUNDER_NIC_VF
 	tristate "Thunder Virtual function driver"
 	depends on 64BIT
-	default ARCH_THUNDER
 	---help---
 	  This driver supports Thunder's NIC virtual function
 
 config	THUNDER_NIC_BGX
 	tristate "Thunder MAC interface driver (BGX)"
 	depends on 64BIT
-	default ARCH_THUNDER
 	select PHYLIB
 	select MDIO_OCTEON
 	---help---
-- 
2.1.4
