From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 2/2] netxen: fix tx descriptor structure
Date: Wed,  9 Sep 2009 13:09:23 -0700
Message-ID: <1252526963-25621-2-git-send-email-dhananjay@netxen.com>
References: <1252526963-25621-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Amit Kumar Salecha <amit@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:27042 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752777AbZIIUJa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 16:09:30 -0400
In-Reply-To: <1252526963-25621-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit@qlogic.com>

Fix the offset of vlan_TCI field in cmd_desc_type0.

Signed-off-by: Amit Kumar Salecha <amit@qlogic.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 2a52479..2371888 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -348,9 +348,9 @@ struct cmd_desc_type0 {
 
 	__le64 addr_buffer4;
 
-	__le16 vlan_TCI;
-	__le16 reserved;
 	__le32 reserved2;
+	__le16 reserved;
+	__le16 vlan_TCI;
 
 } __attribute__ ((aligned(64)));
 
-- 
1.6.0.2

