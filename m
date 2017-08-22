From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net] macsec: add genl family module alias
Date: Tue, 22 Aug 2017 15:36:08 +0200
Message-ID: <dde846e6ac5c2bc4189c240be6ccaa54d3b60d5e.1503406499.git.sd@queasysnail.net>
Cc: Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60484 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932833AbdHVNgR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 22 Aug 2017 09:36:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This helps tools such as wpa_supplicant can start even if the macsec
module isn't loaded yet.

Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
I think this should go to stable as well.

 drivers/net/macsec.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 5e1ab1160856..98e4deaa3a6a 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -3521,6 +3521,7 @@ module_init(macsec_init);
 module_exit(macsec_exit);
 
 MODULE_ALIAS_RTNL_LINK("macsec");
+MODULE_ALIAS_GENL_FAMILY("macsec");
 
 MODULE_DESCRIPTION("MACsec IEEE 802.1AE");
 MODULE_LICENSE("GPL v2");
-- 
2.14.1
