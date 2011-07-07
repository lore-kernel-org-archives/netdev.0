From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH net-next] net: doc: fix compile warning of no format arguments
 in ifenslave.c
Date: Thu, 07 Jul 2011 15:04:31 +0800
Message-ID: <4E155A7F.6050008@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: rdunlap@xenotime.net, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-doc@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix following warning in ifenslave.c with gcc version 4.5.2 (Ubuntu/Linaro 4.5.2-8ubuntu4).

Documentation/networking/ifenslave.c:263:4: warning: format not a string literal and no format arguments
Documentation/networking/ifenslave.c:271:3: warning: format not a string literal and no format arguments
Documentation/networking/ifenslave.c:277:3: warning: format not a string literal and no format arguments
Documentation/networking/ifenslave.c:285:3: warning: format not a string literal and no format arguments
Documentation/networking/ifenslave.c:291:3: warning: format not a string literal and no format arguments
Documentation/networking/ifenslave.c:292:3: warning: format not a string literal and no format arguments
Documentation/networking/ifenslave.c:312:4: warning: format not a string literal and no format arguments
Documentation/networking/ifenslave.c:323:3: warning: format not a string literal and no format arguments
Documentation/networking/ifenslave.c:342:4: warning: format not a string literal and no format arguments


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 Documentation/networking/ifenslave.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/Documentation/networking/ifenslave.c b/Documentation/networking/ifenslave.c
index 2bac961..65968fb 100644
--- a/Documentation/networking/ifenslave.c
+++ b/Documentation/networking/ifenslave.c
@@ -260,7 +260,7 @@ int main(int argc, char *argv[])
 		case 'V': opt_V++; exclusive++; break;
 
 		case '?':
-			fprintf(stderr, usage_msg);
+			fprintf(stderr, "%s", usage_msg);
 			res = 2;
 			goto out;
 		}
@@ -268,13 +268,13 @@ int main(int argc, char *argv[])
 
 	/* options check */
 	if (exclusive > 1) {
-		fprintf(stderr, usage_msg);
+		fprintf(stderr, "%s", usage_msg);
 		res = 2;
 		goto out;
 	}
 
 	if (opt_v || opt_V) {
-		printf(version);
+		printf("%s", version);
 		if (opt_V) {
 			res = 0;
 			goto out;
@@ -282,14 +282,14 @@ int main(int argc, char *argv[])
 	}
 
 	if (opt_u) {
-		printf(usage_msg);
+		printf("%s", usage_msg);
 		res = 0;
 		goto out;
 	}
 
 	if (opt_h) {
-		printf(usage_msg);
-		printf(help_msg);
+		printf("%s", usage_msg);
+		printf("%s", help_msg);
 		res = 0;
 		goto out;
 	}
@@ -309,7 +309,7 @@ int main(int argc, char *argv[])
 			goto out;
 		} else {
 			/* Just show usage */
-			fprintf(stderr, usage_msg);
+			fprintf(stderr, "%s", usage_msg);
 			res = 2;
 			goto out;
 		}
@@ -320,7 +320,7 @@ int main(int argc, char *argv[])
 	master_ifname = *spp++;
 
 	if (master_ifname == NULL) {
-		fprintf(stderr, usage_msg);
+		fprintf(stderr, "%s", usage_msg);
 		res = 2;
 		goto out;
 	}
@@ -339,7 +339,7 @@ int main(int argc, char *argv[])
 
 	if (slave_ifname == NULL) {
 		if (opt_d || opt_c) {
-			fprintf(stderr, usage_msg);
+			fprintf(stderr, "%s", usage_msg);
 			res = 2;
 			goto out;
 		}
-- 
1.7.4.1
