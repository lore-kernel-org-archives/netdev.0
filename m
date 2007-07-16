From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 5/7][ATM]: [lanai] sram_test_word() must be __devinit
Date: Mon, 16 Jul 2007 12:31:14 -0400
Message-ID: <200707161631.l6GGVE24009346@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:47466 "EHLO
	ginger.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752568AbXGPREm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2007 13:04:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ATM]: [lanai] sram_test_word() must be __devinit

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: chas williams <chas@cmf.nrl.navy.mil>

---
commit 9b3515b17a74eff9aad7409dd64888cf0cd03d4d
tree 6b10b2df62cd24cfc86558c70ecc761e5bcaf724
parent b7560ad591d645443595555766df2f2c687e9e65
author Adrian Bunk <bunk@stusta.de> Thu, 12 Jul 2007 11:17:16 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Thu, 12 Jul 2007 11:17:16 -0400

 drivers/atm/lanai.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/atm/lanai.c b/drivers/atm/lanai.c
index 4e1fa50..0ac201e 100644
--- a/drivers/atm/lanai.c
+++ b/drivers/atm/lanai.c
@@ -553,8 +553,8 @@ static inline void sram_write(const struct lanai_dev *lanai,
 	writel(val, sram_addr(lanai, offset));
 }
 
-static int __init sram_test_word(
-	const struct lanai_dev *lanai, int offset, u32 pattern)
+static int __devinit sram_test_word(const struct lanai_dev *lanai,
+				    int offset, u32 pattern)
 {
 	u32 readback;
 	sram_write(lanai, pattern, offset);
