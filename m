From: Julia Lawall <julia@diku.dk>
Subject: [PATCH] drivers/net/tg3.c: change the field used with the
 TG3_FLAG_10_100_ONLY constant
Date: Sat, 13 Mar 2010 10:01:09 +0100 (CET)
Message-ID: <Pine.LNX.4.64.1003131000420.30245@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

The constant TG3_FLAG_10_100_ONLY should be used with the tg3_flags field,
not the tg3_flags2 field, as done elsewhere in the same file.

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/tg3.c                   |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 0fa7688..fa8fb1a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9776,7 +9776,7 @@ static int tg3_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			   ADVERTISED_Pause |
 			   ADVERTISED_Asym_Pause;
 
-		if (!(tp->tg3_flags2 & TG3_FLAG_10_100_ONLY))
+		if (!(tp->tg3_flags & TG3_FLAG_10_100_ONLY))
 			mask |= ADVERTISED_1000baseT_Half |
 				ADVERTISED_1000baseT_Full;
 
