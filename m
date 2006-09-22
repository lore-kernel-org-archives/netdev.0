From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Subject: [PATCH 2/7] [DCCP]: Use constants for CCIDs
Date: Fri, 22 Sep 2006 14:26:44 +1200
Message-ID: <200609221426.45216.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:35492 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932224AbWIVCfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 22:35:16 -0400
Received: by nf-out-0910.google.com with SMTP id o25so922338nfa
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 19:35:16 -0700 (PDT)
To: Arnaldo de Melo <acme@mandriva.com>,
	David Miller <davem@davemloft.net>,
	"dccp (vger)" <dccp@vger.kernel.org>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With constants for CCID numbers this now uses them in some places.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 457dd3d..2efb505 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -808,7 +808,7 @@ static void ccid2_hc_rx_packet_recv(stru
 }
 
 static struct ccid_operations ccid2 = {
-	.ccid_id		= 2,
+	.ccid_id		= DCCPC_CCID2,
 	.ccid_name		= "ccid2",
 	.ccid_owner		= THIS_MODULE,
 	.ccid_hc_tx_obj_size	= sizeof(struct ccid2_hc_tx_sock),
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 195aa95..67d2dc0 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -1240,7 +1240,7 @@ static int ccid3_hc_tx_getsockopt(struct
 }
 
 static struct ccid_operations ccid3 = {
-	.ccid_id		   = 3,
+	.ccid_id		   = DCCPC_CCID3,
 	.ccid_name		   = "ccid3",
 	.ccid_owner		   = THIS_MODULE,
 	.ccid_hc_tx_obj_size	   = sizeof(struct ccid3_hc_tx_sock),
