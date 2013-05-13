From: Jongsung Kim <neidhard.kim@lge.com>
Subject: [PATCH v3 3/4] net: phy: realtek: add suspend/resume handlers for the RTL8211B
Date: Mon, 13 May 2013 18:58:39 +0900
Message-ID: <1368439120-26322-3-git-send-email-neidhard.kim@lge.com>
References: <518CD784.1030709@cogentembedded.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jongsung Kim <neidhard.kim@lge.com>
To: davem@davemloft.net, peppe.cavallaro@st.com,
	chohnstaedt@innominate.com, heiko.carstens@de.ibm.com,
	schwidefsky@de.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <518CD784.1030709@cogentembedded.com>
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
