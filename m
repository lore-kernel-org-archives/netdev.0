From: Jongsung Kim <neidhard.kim@lge.com>
Subject: [PATCH v2 3/4] net: phy: realtek: add suspend/resume handlers for the RTL8211B
Date: Fri, 10 May 2013 16:29:26 +0900
Message-ID: <1368170967-20589-3-git-send-email-neidhard.kim@lge.com>
References: <201305081910.27203.neidhard.kim@lge.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: r58129@freescale.com, davem@davemloft.net,
	sergei.shtylyov@cogentembedded.com, peppe.cavallaro@st.com,
	chohnstaedt@innominate.com, timur@freescale.com,
	heiko.carstens@de.ibm.com, schwidefsky@de.ibm.com,
	neidhard.kim@lge.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201305081910.27203.neidhard.kim@lge.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add compatible but missing generic PHY suspend/resume handlers for
the RTL8211B driver.

Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>
---
 drivers/net/phy/realtek.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
index 8e95e38..6f0726a 100644
--- a/drivers/net/phy/realtek.c
+++ b/drivers/net/phy/realtek.c
@@ -126,6 +126,8 @@ static struct phy_driver realtek_drv[] = {
 		.read_status	= &genphy_read_status,
 		.ack_interrupt	= &rtl821x_ack_interrupt,
 		.config_intr	= &rtl8211b_config_intr,
+		.suspend	= genphy_suspend,
+		.resume		= genphy_resume,
 		.driver		= { .owner = THIS_MODULE,},
 	},
 	{	/* RTL8211E */
-- 
1.7.1
