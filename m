From: Jingju Hou <houjingj@marvell.com>
Subject: [PATCH v2 net-next] net: phy: marvell: Add Wake from LAN support for 88E1510 PHY
Date: Mon, 23 Jan 2017 10:58:15 +0800
Message-ID: <1485140295-11339-1-git-send-email-houjingj@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jszhang@marvell.com>, <netdev@vger.kernel.org>,
        Jingju Hou <houjingj@marvell.com>
To: <davem@davemloft.net>, <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016f401.pphosted.com ([67.231.148.174]:33564 "EHLO
        mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750708AbdAWC65 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 21:58:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is test on BG4CT platform with 88E1518 marvell PHY.

Signed-off-by: Jingju Hou <houjingj@marvell.com>
---
Since v1:
- add some commit messages

 drivers/net/phy/marvell.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index 0b78210..ed0d235 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -1679,6 +1679,8 @@ static int marvell_probe(struct phy_device *phydev)
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
 		.did_interrupt = &m88e1121_did_interrupt,
+		.get_wol = &m88e1318_get_wol,
+		.set_wol = &m88e1318_set_wol,
 		.resume = &marvell_resume,
 		.suspend = &marvell_suspend,
 		.get_sset_count = marvell_get_sset_count,
-- 
1.9.1
