From: Joe Perches <joe@perches.com>
Subject: [PATCH 15/24] rfkill: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:34 -0700
Message-ID: <0a0d9ce42d5d0bcef3517be27c2759350ca4e1f5.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/rfkill/rfkill-regulator.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/rfkill/rfkill-regulator.c b/net/rfkill/rfkill-regulator.c
index 18dc512..3ca7277 100644
--- a/net/rfkill/rfkill-regulator.c
+++ b/net/rfkill/rfkill-regulator.c
@@ -90,7 +90,6 @@ static int __devinit rfkill_regulator_probe(struct platform_device *pdev)
 				pdata->type,
 				&rfkill_regulator_ops, rfkill_data);
 	if (rf_kill == NULL) {
-		dev_err(&pdev->dev, "Cannot alloc rfkill device\n");
 		ret = -ENOMEM;
 		goto err_rfkill_alloc;
 	}
-- 
1.7.6.405.gc1be0
