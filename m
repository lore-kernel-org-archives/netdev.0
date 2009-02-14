From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 17/43] drivers/net/cxgb3: fix sparse warnings: fix signedness
Date: Sat, 14 Feb 2009 22:16:19 +0100
Message-ID: <20090214211612.23489.60993.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:59358 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754855AbZBNVQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:16:24 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warning:
  drivers/net/cxgb3/ael1002.c:1010:60: warning: incorrect type in argument 4 (different signedness)

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/cxgb3/ael1002.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/cxgb3/ael1002.c
index 5c3c05d..e1b2249 100644
--- a/drivers/net/cxgb3/ael1002.c
+++ b/drivers/net/cxgb3/ael1002.c
@@ -1005,7 +1005,8 @@ static int ael2005_reset(struct cphy *phy, int wait)
 		{ 0, 0, 0, 0 }
 	};
 
-	int err, lasi_ctrl;
+	int err;
+	unsigned int lasi_ctrl;
 
 	err = mdio_read(phy, MDIO_DEV_PMA_PMD, LASI_CTRL, &lasi_ctrl);
 	if (err)

