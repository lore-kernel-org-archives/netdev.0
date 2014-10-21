From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [PATCH 3/6] qeth: make local functions static in qeth_l3 module
Date: Tue, 21 Oct 2014 17:15:28 +0200
Message-ID: <1413904531-55663-4-git-send-email-blaschka@linux.vnet.ibm.com>
References: <1413904531-55663-1-git-send-email-blaschka@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Thomas Richter <tmricht@linux.vnet.ibm.com>,
	Frank Blaschka <blaschka@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:34423 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755691AbaJUPPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 11:15:49 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Tue, 21 Oct 2014 16:15:47 +0100
In-Reply-To: <1413904531-55663-1-git-send-email-blaschka@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

This patch makes 4 local functions static and removes
the prototypes from the header file.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3.h      | 4 ----
 drivers/s390/net/qeth_l3_main.c | 8 ++++----
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/s390/net/qeth_l3.h b/drivers/s390/net/qeth_l3.h
index 29c1c00..551a4b4 100644
--- a/drivers/s390/net/qeth_l3.h
+++ b/drivers/s390/net/qeth_l3.h
@@ -42,10 +42,6 @@ struct qeth_ipato_entry {
 };
 
 
-void qeth_l3_ipaddr4_to_string(const __u8 *, char *);
-int qeth_l3_string_to_ipaddr4(const char *, __u8 *);
-void qeth_l3_ipaddr6_to_string(const __u8 *, char *);
-int qeth_l3_string_to_ipaddr6(const char *, __u8 *);
 void qeth_l3_ipaddr_to_string(enum qeth_prot_versions, const __u8 *, char *);
 int qeth_l3_string_to_ipaddr(const char *, enum qeth_prot_versions, __u8 *);
 int qeth_l3_create_device_attributes(struct device *);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 857a990..625227ad 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -55,12 +55,12 @@ static int qeth_l3_isxdigit(char *buf)
 	return 1;
 }
 
-void qeth_l3_ipaddr4_to_string(const __u8 *addr, char *buf)
+static void qeth_l3_ipaddr4_to_string(const __u8 *addr, char *buf)
 {
 	sprintf(buf, "%i.%i.%i.%i", addr[0], addr[1], addr[2], addr[3]);
 }
 
-int qeth_l3_string_to_ipaddr4(const char *buf, __u8 *addr)
+static int qeth_l3_string_to_ipaddr4(const char *buf, __u8 *addr)
 {
 	int count = 0, rc = 0;
 	unsigned int in[4];
@@ -78,12 +78,12 @@ int qeth_l3_string_to_ipaddr4(const char *buf, __u8 *addr)
 	return 0;
 }
 
-void qeth_l3_ipaddr6_to_string(const __u8 *addr, char *buf)
+static void qeth_l3_ipaddr6_to_string(const __u8 *addr, char *buf)
 {
 	sprintf(buf, "%pI6", addr);
 }
 
-int qeth_l3_string_to_ipaddr6(const char *buf, __u8 *addr)
+static int qeth_l3_string_to_ipaddr6(const char *buf, __u8 *addr)
 {
 	const char *end, *end_tmp, *start;
 	__u16 *in;
-- 
1.8.5.5
