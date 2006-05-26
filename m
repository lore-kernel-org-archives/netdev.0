From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ip_conntrack_helper_pptp.c: fix sstate/cstate typo
Date: Fri, 26 May 2006 16:23:42 +0400
Message-ID: <20060526122342.GB7267@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:29329 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932422AbWEZMX5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 08:23:57 -0400
Received: by nf-out-0910.google.com with SMTP id h2so50061nfe
        for <netdev@vger.kernel.org>; Fri, 26 May 2006 05:23:56 -0700 (PDT)
To: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

--- a/net/ipv4/netfilter/ip_conntrack_helper_pptp.c
+++ b/net/ipv4/netfilter/ip_conntrack_helper_pptp.c
@@ -469,8 +469,8 @@ pptp_inbound_pkt(struct sk_buff **pskb,
 			DEBUGP("%s but no session\n", pptp_msg_name[msg]);
 			break;
 		}
-		if (info->sstate != PPTP_CALL_IN_REP
-		    && info->sstate != PPTP_CALL_IN_CONF) {
+		if (info->cstate != PPTP_CALL_IN_REP
+		    && info->cstate != PPTP_CALL_IN_CONF) {
 			DEBUGP("%s but never sent IN_CALL_REPLY\n",
 				pptp_msg_name[msg]);
 			break;

