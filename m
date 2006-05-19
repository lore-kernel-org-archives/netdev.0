From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] irda: fixup type of ->lsap_state
Date: Fri, 19 May 2006 15:42:37 +0400
Message-ID: <20060519114237.GB17751@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:60088 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932293AbWESLoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 07:44:11 -0400
Received: by nf-out-0910.google.com with SMTP id o63so45749nfa
        for <netdev@vger.kernel.org>; Fri, 19 May 2006 04:44:10 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

--- a/include/net/irda/irlmp.h
+++ 1/include/net/irda/irlmp.h
@@ -112,7 +112,7 @@ struct lsap_cb {
 
 	struct timer_list watchdog_timer;
 
-	IRLMP_STATE     lsap_state;  /* Connection state */
+	LSAP_STATE      lsap_state;  /* Connection state */
 	notify_t        notify;      /* Indication/Confirm entry points */
 	struct qos_info qos;         /* QoS for this connection */
 

