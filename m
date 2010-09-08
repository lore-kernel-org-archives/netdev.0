From: frank.blaschka@de.ibm.com
Subject: [patch 2/4] [PATCH] qeth: Use %pI6
Date: Wed, 08 Sep 2010 09:14:40 +0200
Message-ID: <20100908071601.252074972@de.ibm.com>
References: <20100908071438.085729717@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Joe Perches <joe@perches.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:50101 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757729Ab0IHHQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 03:16:08 -0400
Content-Disposition: inline; filename=601-qeth-pi6.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Format an ipv6 address using vsprintf extensions.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l3_main.c |    7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2010-09-07 09:57:18.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2010-09-07 09:57:34.000000000 +0200
@@ -103,12 +103,7 @@ int qeth_l3_string_to_ipaddr4(const char
 
 void qeth_l3_ipaddr6_to_string(const __u8 *addr, char *buf)
 {
-	sprintf(buf, "%02x%02x:%02x%02x:%02x%02x:%02x%02x"
-		     ":%02x%02x:%02x%02x:%02x%02x:%02x%02x",
-		     addr[0], addr[1], addr[2], addr[3],
-		     addr[4], addr[5], addr[6], addr[7],
-		     addr[8], addr[9], addr[10], addr[11],
-		     addr[12], addr[13], addr[14], addr[15]);
+	sprintf(buf, "%pI6", addr);
 }
 
 int qeth_l3_string_to_ipaddr6(const char *buf, __u8 *addr)

