From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 6/7] cxgb3 - Add T3C rev
Date: Wed, 05 Sep 2007 15:58:36 -0700
Message-ID: <20070905225835.17308.87147.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:18974 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757161AbXIEW6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 18:58:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

add driver recognition for T3C rev board. 

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h     |    1 +
 drivers/net/cxgb3/cxgb3_main.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 7e9e43d..d3f276c 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -438,6 +438,7 @@ enum {					    /* chip revisions */
 	T3_REV_A  = 0,
 	T3_REV_B  = 2,
 	T3_REV_B2 = 3,
+	T3_REV_C  = 4,
 };
 
 struct trace_params {
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index ae9c213..9d360eb 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -768,6 +768,9 @@ static inline char t3rev2char(struct adapter *adapter)
 	case T3_REV_B2:
 		rev = 'b';
 		break;
+	case T3_REV_C:
+		rev = 'c';
+		break;
 	}
 	return rev;
 }
