From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next] Modify Liquidio Kconfig for crc lib
Date: Tue, 16 Jun 2015 16:51:43 -0700
Message-ID: <1434498703-6365-1-git-send-email-rvatsavayi@caviumnetworks.com>
References: <CAD3Xx4J-nVXvOdV4wdos44Tvm8iR-c_bSwN=E5W+=RbOtTwTCw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <valentinrothberg@gmail.com>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0084.outbound.protection.outlook.com ([207.46.100.84]:56976
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752680AbbFPXzb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Jun 2015 19:55:31 -0400
In-Reply-To: <CAD3Xx4J-nVXvOdV4wdos44Tvm8iR-c_bSwN=E5W+=RbOtTwTCw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch contains changes in liquidio Kconfig for
selecting LIBCRC32C.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index 5e7a0e2..c4d6bbe 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -46,7 +46,7 @@ config LIQUIDIO
 	depends on 64BIT
 	select PTP_1588_CLOCK
 	select FW_LOADER
-	select LIBCRC32
+	select LIBCRC32C
 	---help---
 	  This driver supports Cavium LiquidIO Intelligent Server Adapters
 	  based on CN66XX and CN68XX chips.
-- 
1.8.4.2
