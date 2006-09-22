From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Subject: [PATCH 1/7] [DCCP]: Introduce constants for CCID numbers
Date: Fri, 22 Sep 2006 14:25:36 +1200
Message-ID: <200609221425.37592.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:35492 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932222AbWIVCfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 22:35:12 -0400
Received: by nf-out-0910.google.com with SMTP id o25so922338nfa
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 19:35:12 -0700 (PDT)
To: Arnaldo de Melo <acme@mandriva.com>,
	David Miller <davem@davemloft.net>,
	"dccp (vger)" <dccp@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>,
	Andrea Bittau <a.bittau@cs.ucl.ac.uk>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This change introduces a constant for CCID numbers.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 2d7671c..a073164 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -169,6 +169,12 @@ enum {
 	DCCPO_MAX_CCID_SPECIFIC = 255,
 };
 
+/* DCCP CCIDS */
+enum {
+	DCCPC_CCID2 = 2,
+	DCCPC_CCID3 = 3,
+};
+
 /* DCCP features */
 enum {
 	DCCPF_RESERVED = 0,
@@ -320,7 +326,7 @@ static inline unsigned int dccp_hdr_len(
 /* initial values for each feature */
 #define DCCPF_INITIAL_SEQUENCE_WINDOW		100
 #define DCCPF_INITIAL_ACK_RATIO			2
-#define DCCPF_INITIAL_CCID			2
+#define DCCPF_INITIAL_CCID			DCCPC_CCID2
 #define DCCPF_INITIAL_SEND_ACK_VECTOR		1
 /* FIXME: for now we're default to 1 but it should really be 0 */
 #define DCCPF_INITIAL_SEND_NDP_COUNT		1
