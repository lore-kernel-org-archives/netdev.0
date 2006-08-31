From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] change max_dgram_qlen sysctl to __read_mostly
Date: Thu, 31 Aug 2006 16:35:37 -0400
Message-ID: <44F74819.4070902@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030806030303020103020309"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:31128 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S932342AbWHaUfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 16:35:39 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030806030303020103020309
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Change AF_UNIX sysctl_unix_max_dgram_qlen to __read_mostly.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------030806030303020103020309
Content-Type: text/x-patch;
 name="af_unix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="af_unix.patch"

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 7c91c20..b43a278 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -117,7 +117,7 @@
 #include <net/checksum.h>
 #include <linux/security.h>
 
-int sysctl_unix_max_dgram_qlen = 10;
+int sysctl_unix_max_dgram_qlen __read_mostly = 10;
 
 struct hlist_head unix_socket_table[UNIX_HASH_SIZE + 1];
 DEFINE_SPINLOCK(unix_table_lock);

--------------030806030303020103020309--
