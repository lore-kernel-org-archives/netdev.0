From: Wei Tang <tangwei@cmss.chinamobile.com>
Subject: [PATCH] net: the space is required before the open parenthesis '('
Date: Mon, 27 Jun 2016 18:12:46 +0800
Message-ID: <1467022366-3751-1-git-send-email-tangwei@cmss.chinamobile.com>
Cc: ast@kernel.org, daniel@iogearbox.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Wei Tang <tangwei@cmss.chinamobile.com>
To: davem@davemloft.net, tom@herbertland.com,
	hannes@stressinduktion.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The space is missing before the open parenthesis '(', and this
will introduce much more noise when checking patch around.

Signed-off-by: Wei Tang <tangwei@cmss.chinamobile.com>
---
 net/core/utils.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/core/utils.c b/net/core/utils.c
index 3d17ca8..cf5622b 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -133,7 +133,7 @@ int in4_pton(const char *src, int srclen,
 	s = src;
 	d = dbuf;
 	i = 0;
-	while(1) {
+	while (1) {
 		int c;
 		c = xdigit2bin(srclen > 0 ? *s : '\0', delim);
 		if (!(c & (IN6PTON_DIGIT | IN6PTON_DOT | IN6PTON_DELIM | IN6PTON_COLON_MASK))) {
@@ -283,11 +283,11 @@ cont:
 	i = 15; d--;
 
 	if (dc) {
-		while(d >= dc)
+		while (d >= dc)
 			dst[i--] = *d--;
-		while(i >= dc - dbuf)
+		while (i >= dc - dbuf)
 			dst[i--] = 0;
-		while(i >= 0)
+		while (i >= 0)
 			dst[i--] = *d--;
 	} else
 		memcpy(dst, dbuf, sizeof(dbuf));
-- 
1.9.1
