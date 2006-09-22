From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Subject: [PATCH 4/7] [DCCP]: Shift constants into header
Date: Fri, 22 Sep 2006 14:29:06 +1200
Message-ID: <200609221429.06266.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:44962 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932229AbWIVCf0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 22:35:26 -0400
Received: by nf-out-0910.google.com with SMTP id o25so922337nfa
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 19:35:26 -0700 (PDT)
To: Arnaldo de Melo <acme@mandriva.com>,
	David Miller <davem@davemloft.net>,
	"dccp (vger)" <dccp@vger.kernel.org>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This shifts some constants from ccid3.c to ccid3.h

This is not needed for in tree code (yet) but for my own work.

Makes sense to have constants in header though.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 67d2dc0..7b4699a 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -75,14 +75,6 @@ static struct dccp_tx_hist *ccid3_tx_his
 static struct dccp_rx_hist *ccid3_rx_hist;
 static struct dccp_li_hist *ccid3_li_hist;
 
-/* TFRC sender states */
-enum ccid3_hc_tx_states {
-       	TFRC_SSTATE_NO_SENT = 1,
-	TFRC_SSTATE_NO_FBACK,
-	TFRC_SSTATE_FBACK,
-	TFRC_SSTATE_TERM,
-};
-
 #ifdef CCID3_DEBUG
 static const char *ccid3_tx_state_name(enum ccid3_hc_tx_states state)
 {
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 0a2cb75..df4ff13 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -65,6 +65,14 @@ enum ccid3_options {
 	TFRC_OPT_RECEIVE_RATE	 = 194,
 };
 
+/* TFRC sender states */
+enum ccid3_hc_tx_states {
+	TFRC_SSTATE_NO_SENT = 1,
+	TFRC_SSTATE_NO_FBACK,
+	TFRC_SSTATE_FBACK,
+	TFRC_SSTATE_TERM,
+};
+
 struct ccid3_options_received {
 	u64 ccid3or_seqno:48,
 	    ccid3or_loss_intervals_idx:16;
