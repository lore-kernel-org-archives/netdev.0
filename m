From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 5/7] be2net: fixup log msgs for async events
Date: Tue, 6 Aug 2013 09:27:19 +0530
Message-ID: <1375761441-22343-6-git-send-email-sathya.perla@emulex.com>
References: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:38636 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754442Ab3HFDz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 23:55:28 -0400
In-Reply-To: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Log the event type for unknown async events

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 53541a9..9f04dac 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -258,7 +258,8 @@ static void be_async_grp5_evt_process(struct be_adapter *adapter,
 		(struct be_async_event_grp5_pvid_state *)evt);
 	break;
 	default:
-		dev_warn(&adapter->pdev->dev, "Unknown grp5 event!\n");
+		dev_warn(&adapter->pdev->dev, "Unknown grp5 event 0x%x!\n",
+			 event_type);
 		break;
 	}
 }
@@ -279,7 +280,8 @@ static void be_async_dbg_evt_process(struct be_adapter *adapter,
 		adapter->flags |= BE_FLAGS_QNQ_ASYNC_EVT_RCVD;
 	break;
 	default:
-		dev_warn(&adapter->pdev->dev, "Unknown debug event\n");
+		dev_warn(&adapter->pdev->dev, "Unknown debug event 0x%x!\n",
+			 event_type);
 	break;
 	}
 }
-- 
1.7.1
