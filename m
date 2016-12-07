From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next] macsec: remove first zero and add attribute name in comments
Date: Wed,  7 Dec 2016 23:02:09 +0800
Message-ID: <1481122929-19147-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:45180 "EHLO
        cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932109AbcLGPEU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 10:04:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove first zero for add, and use full attribute name in comments.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/macsec.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index cc00eb0..f83cf66 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -3346,19 +3346,18 @@ static struct net *macsec_get_link_net(const struct net_device *dev)
 
 static size_t macsec_get_size(const struct net_device *dev)
 {
-	return 0 +
-		nla_total_size_64bit(8) + /* SCI */
-		nla_total_size(1) + /* ICV_LEN */
-		nla_total_size_64bit(8) + /* CIPHER_SUITE */
-		nla_total_size(4) + /* WINDOW */
-		nla_total_size(1) + /* ENCODING_SA */
-		nla_total_size(1) + /* ENCRYPT */
-		nla_total_size(1) + /* PROTECT */
-		nla_total_size(1) + /* INC_SCI */
-		nla_total_size(1) + /* ES */
-		nla_total_size(1) + /* SCB */
-		nla_total_size(1) + /* REPLAY_PROTECT */
-		nla_total_size(1) + /* VALIDATION */
+	return  nla_total_size_64bit(8) + /* IFLA_MACSEC_SCI */
+		nla_total_size(1) + /* IFLA_MACSEC_ICV_LEN */
+		nla_total_size_64bit(8) + /* IFLA_MACSEC_CIPHER_SUITE */
+		nla_total_size(4) + /* IFLA_MACSEC_WINDOW */
+		nla_total_size(1) + /* IFLA_MACSEC_ENCODING_SA */
+		nla_total_size(1) + /* IFLA_MACSEC_ENCRYPT */
+		nla_total_size(1) + /* IFLA_MACSEC_PROTECT */
+		nla_total_size(1) + /* IFLA_MACSEC_INC_SCI */
+		nla_total_size(1) + /* IFLA_MACSEC_ES */
+		nla_total_size(1) + /* IFLA_MACSEC_SCB */
+		nla_total_size(1) + /* IFLA_MACSEC_REPLAY_PROTECT */
+		nla_total_size(1) + /* IFLA_MACSEC_VALIDATION */
 		0;
 }
 
-- 
1.8.3.1
