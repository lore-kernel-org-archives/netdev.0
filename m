From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Fix static checker warning
Date: Wed, 12 Nov 2014 15:01:06 +0530
Message-ID: <1415784666-30224-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43985
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752555AbaKLJZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 04:25:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix static checker warning that got introduced in commit e2ac9628959cc152
("cxgb4: Cleanup macros so they follow the same style and look consistent, part
2") due to accidental checkin of bogus line.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index d13d36a..660bf0f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -5752,7 +5752,6 @@ static int adap_init0(struct adapter *adap)
 					    "No Configuration File present "
 					    "on adapter. Using hard-wired "
 					    "configuration parameters.\n");
-					goto bye;
 					ret = adap_init0_no_config(adap, reset);
 				}
 			}
-- 
1.7.1
