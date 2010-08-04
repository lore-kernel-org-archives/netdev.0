From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/s390/net/qeth_l3_main.c: Use %pI6
Date: Wed, 04 Aug 2010 09:50:12 -0700
Message-ID: <1280940612.1005.91.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ursula Braun <ursula.braun@de.ibm.com>,
	linux390 <linux390@de.ibm.com>,
	linux-s390 <linux-s390@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Format an ipv6 address using vsprintf extensions.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/s390/net/qeth_l3_main.c |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index e22ae24..561bdc8 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -103,12 +103,7 @@ int qeth_l3_string_to_ipaddr4(const char *buf, __u8 *addr)
 
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
