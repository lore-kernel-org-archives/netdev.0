From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 2.6.26 3/3] RDMA/cxgb3: Bump up the mpa connection setup timeout.
Date: Fri, 02 May 2008 11:17:45 -0500
Message-ID: <20080502161745.30500.99485.stgit@dell3.ogc.int>
References: <20080502161741.30500.95337.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:43357 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763560AbYEBQRq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 12:17:46 -0400
In-Reply-To: <20080502161741.30500.95337.stgit@dell3.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Testing on large clusters shows its way too short at 10 secs.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_cm.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/hw/cxgb3/iwch_cm.c
index b2db0a9..9ea3a07 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -67,10 +67,10 @@ int peer2peer = 0;
 module_param(peer2peer, int, 0644);
 MODULE_PARM_DESC(peer2peer, "Support peer2peer ULPs (default=0)");
 
-static int ep_timeout_secs = 10;
+static int ep_timeout_secs = 60;
 module_param(ep_timeout_secs, int, 0644);
 MODULE_PARM_DESC(ep_timeout_secs, "CM Endpoint operation timeout "
-				   "in seconds (default=10)");
+				   "in seconds (default=60)");
 
 static int mpa_rev = 1;
 module_param(mpa_rev, int, 0644);
