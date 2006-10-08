From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] prism54: use BUILG_BUG_ON
Date: Sun, 8 Oct 2006 15:58:55 +0400
Message-ID: <20061008115855.GD5344@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: prism54-private@prism54.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:21697 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1751109AbWJHL7L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Oct 2006 07:59:11 -0400
Received: by nf-out-0910.google.com with SMTP id x30so1648680nfb
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2006 04:59:09 -0700 (PDT)
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/wireless/prism54/isl_oid.h |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

--- a/drivers/net/wireless/prism54/isl_oid.h
+++ b/drivers/net/wireless/prism54/isl_oid.h
@@ -106,14 +106,14 @@ struct obj_attachment {
 static inline void
 __bug_on_wrong_struct_sizes(void)
 {
-	BUG_ON(sizeof (struct obj_ssid) != 34);
-	BUG_ON(sizeof (struct obj_key) != 34);
-	BUG_ON(sizeof (struct obj_mlme) != 12);
-	BUG_ON(sizeof (struct obj_mlmeex) != 14);
-	BUG_ON(sizeof (struct obj_buffer) != 8);
-	BUG_ON(sizeof (struct obj_bss) != 60);
-	BUG_ON(sizeof (struct obj_bsslist) != 4);
-	BUG_ON(sizeof (struct obj_frequencies) != 2);
+	BUILD_BUG_ON(sizeof (struct obj_ssid) != 34);
+	BUILD_BUG_ON(sizeof (struct obj_key) != 34);
+	BUILD_BUG_ON(sizeof (struct obj_mlme) != 12);
+	BUILD_BUG_ON(sizeof (struct obj_mlmeex) != 14);
+	BUILD_BUG_ON(sizeof (struct obj_buffer) != 8);
+	BUILD_BUG_ON(sizeof (struct obj_bss) != 60);
+	BUILD_BUG_ON(sizeof (struct obj_bsslist) != 4);
+	BUILD_BUG_ON(sizeof (struct obj_frequencies) != 2);
 }
 
 enum dot11_state_t {

