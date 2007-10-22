From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 4/5] Cut off ec_ptr from net_device
Date: Mon, 22 Oct 2007 16:36:43 +0400
Message-ID: <471C995B.4010901@openvz.org>
References: <471C9830.5070407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39147 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752702AbXJVMgC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 08:36:02 -0400
In-Reply-To: <471C9830.5070407@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 504f843..472d9cc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -579,7 +579,9 @@ struct net_device
 	void			*ip_ptr;	/* IPv4 specific data	*/  
 	void                    *dn_ptr;        /* DECnet specific data */
 	void                    *ip6_ptr;       /* IPv6 specific data */
+#if defined(CONFIG_ECONET) || defined(CONFIG_ECONET_MODULE)
 	void			*ec_ptr;	/* Econet specific data	*/
+#endif
 #if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 	void			*ax25_ptr;	/* AX.25 specific data */
 #endif
-- 
1.5.3.4

