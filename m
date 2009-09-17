From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: [PATCH 2/2] net: remove print_mac as it's not anymore used
Date: Thu, 17 Sep 2009 02:07:39 +0200
Message-ID: <1253146059-4169-2-git-send-email-plagnioj@jcrosoft.com>
References: <1253146059-4169-1-git-send-email-plagnioj@jcrosoft.com>
Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:45524 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750759AbZIQAJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 20:09:06 -0400
In-Reply-To: <1253146059-4169-1-git-send-email-plagnioj@jcrosoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
---
 include/linux/if_ether.h |    8 --------
 net/ethernet/eth.c       |    7 -------
 2 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 580b600..b1a19a7 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -136,14 +136,6 @@ extern struct ctl_table ether_table[];
 
 extern ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len);
 
-/*
- *	Display a 6 byte device address (MAC) in a readable format.
- */
-extern char *print_mac(char *buf, const unsigned char *addr) __deprecated;
-#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
-#define MAC_BUF_SIZE	18
-#define DECLARE_MAC_BUF(var) char var[MAC_BUF_SIZE]
-
 #endif
 
 #endif	/* _LINUX_IF_ETHER_H */
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 5a883af..dd3db88 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -393,10 +393,3 @@ ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len)
 	return ((ssize_t) l);
 }
 EXPORT_SYMBOL(sysfs_format_mac);
-
-char *print_mac(char *buf, const unsigned char *addr)
-{
-	_format_mac_addr(buf, MAC_BUF_SIZE, addr, ETH_ALEN);
-	return buf;
-}
-EXPORT_SYMBOL(print_mac);
-- 
1.6.4

