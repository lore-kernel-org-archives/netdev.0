From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/3] net: phy: micrel: Staticize ksz8873mll_read_status()
Date: Tue, 06 Aug 2013 17:29:35 +0900
Message-ID: <000101ce927f$15413560$3fc3a020$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Hector Palacios <hector.palacios@digi.com>,
	"David J. Choi" <david.choi@micrel.com>,
	Jingoo Han <jg1.han@samsung.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:33944 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753435Ab3HFI3h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 04:29:37 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MR3009BQOV617E0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 06 Aug 2013 17:29:35 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ksz8873mll_read_status() is used only in this file.
Fix the following sparse warning:

drivers/net/phy/micrel.c:147:5: warning: symbol 'ksz8873mll_read_status' was not declared. Should it be static?

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/phy/micrel.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 2510435..9ca4945 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -144,7 +144,7 @@ static int ks8051_config_init(struct phy_device *phydev)
 #define KSZ8873MLL_GLOBAL_CONTROL_4	0x06
 #define KSZ8873MLL_GLOBAL_CONTROL_4_DUPLEX	(1 << 6)
 #define KSZ8873MLL_GLOBAL_CONTROL_4_SPEED	(1 << 4)
-int ksz8873mll_read_status(struct phy_device *phydev)
+static int ksz8873mll_read_status(struct phy_device *phydev)
 {
 	int regval;
 
-- 
1.7.10.4
