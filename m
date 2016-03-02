From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 6/7] bnx2x: define event data reserved fields as little-endian
Date: Wed,  2 Mar 2016 13:47:10 +0100
Message-ID: <1456922831-15071-7-git-send-email-mschmidt@redhat.com>
References: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873AbcCBMo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2016 07:44:27 -0500
In-Reply-To: <1456922831-15071-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For consistency with other event data structs and to lessen
the chance of a mistake should one of the reserved fields become
used in the future, define the reserved fields as little-endian.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index a24909a..91874d2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -5224,9 +5224,9 @@ struct vf_pf_event_data {
 struct vf_flr_event_data {
 	u8 vf_id;
 	u8 reserved0;
-	u16 reserved1;
-	u32 reserved2;
-	u32 reserved3;
+	__le16 reserved1;
+	__le32 reserved2;
+	__le32 reserved3;
 };
 
 /*
@@ -5235,9 +5235,9 @@ struct vf_flr_event_data {
 struct malicious_vf_event_data {
 	u8 vf_id;
 	u8 err_id;
-	u16 reserved1;
-	u32 reserved2;
-	u32 reserved3;
+	__le16 reserved1;
+	__le32 reserved2;
+	__le32 reserved3;
 };
 
 /*
-- 
2.5.0
