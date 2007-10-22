From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 3/5] Cut off ax25_ptr from net_device
Date: Mon, 22 Oct 2007 16:35:39 +0400
Message-ID: <471C991B.9010204@openvz.org>
References: <471C9830.5070407@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:39076 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752485AbXJVMe5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Oct 2007 08:34:57 -0400
In-Reply-To: <471C9830.5070407@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c41a5c4..504f843 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -580,7 +580,9 @@ struct net_device
 	void                    *dn_ptr;        /* DECnet specific data */
 	void                    *ip6_ptr;       /* IPv6 specific data */
 	void			*ec_ptr;	/* Econet specific data	*/
+#if defined(CONFIG_AX25) || defined(CONFIG_AX25_MODULE)
 	void			*ax25_ptr;	/* AX.25 specific data */
+#endif
 	struct wireless_dev	*ieee80211_ptr;	/* IEEE 802.11 specific data,
 						   assign before registering */
 
-- 
1.5.3.4

