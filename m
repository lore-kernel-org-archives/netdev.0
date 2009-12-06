From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] include/linux/if_ether.h: Remove unused defines
 MAC_BUF_SIZE and DECLARE_MAC_BUF
Date: Sun, 06 Dec 2009 12:35:30 -0800
Message-ID: <1260131730.11126.127.camel@Joe-Laptop.home>
References: <1260131563.11126.124.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1079 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757539AbZLFUfY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2009 15:35:24 -0500
In-Reply-To: <1260131563.11126.124.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 005e152..299b412 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -137,8 +137,6 @@ extern struct ctl_table ether_table[];
 extern ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len);
 
 #define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
-#define MAC_BUF_SIZE	18
-#define DECLARE_MAC_BUF(var) char var[MAC_BUF_SIZE]
 
 #endif
 


