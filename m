From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Subject: [PATCH 5/7] [DCCP]: Introduce two new socket options
Date: Fri, 22 Sep 2006 14:30:14 +1200
Message-ID: <200609221430.14555.ian.mcdonald@jandi.co.nz>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:35492 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932232AbWIVCfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 22:35:31 -0400
Received: by nf-out-0910.google.com with SMTP id o25so922338nfa
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 19:35:30 -0700 (PDT)
To: Arnaldo de Melo <acme@mandriva.com>,
	David Miller <davem@davemloft.net>,
	"dccp (vger)" <dccp@vger.kernel.org>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This creates two new socket options DCCP_SOCKOPT_TX_PACKET_SIZE
and DCCP_SOCKOPT_RX_PACKET_SIZE. DCCP_SOCKOPT_PACKET_SIZE doesn't
work and packet size should be set independently on two half
connections.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index a073164..ef1c57b 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -200,6 +200,8 @@ #define DCCP_SOCKOPT_PACKET_SIZE	1
 #define DCCP_SOCKOPT_SERVICE		2
 #define DCCP_SOCKOPT_CHANGE_L		3
 #define DCCP_SOCKOPT_CHANGE_R		4
+#define DCCP_SOCKOPT_TX_PACKET_SIZE	5
+#define DCCP_SOCKOPT_RX_PACKET_SIZE	6
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
