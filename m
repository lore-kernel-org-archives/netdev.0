From: Ivan Babrou <ivan@cloudflare.com>
Subject: [PATCH] net: dummy: remove note about being Y by default
Date: Sat, 23 Apr 2016 12:58:03 +0000
Message-ID: <20160423125803.GA6583@cf>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trivial@kernel.org, "David S. Miller" <davem@davemloft.net>,
	David Ahern <dsa@cumulusnetworks.com>,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:36987 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751676AbcDWM6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Apr 2016 08:58:06 -0400
Received: by mail-wm0-f42.google.com with SMTP id n3so63224710wmn.0
        for <netdev@vger.kernel.org>; Sat, 23 Apr 2016 05:58:05 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Babrou <ivan@cloudflare.com>
---
 drivers/net/Kconfig | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 2a1ba62b..bd86a23 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -62,9 +62,8 @@ config DUMMY
 	  this device is consigned into oblivion) with a configurable IP
 	  address. It is most commonly used in order to make your currently
 	  inactive SLIP address seem like a real address for local programs.
-	  If you use SLIP or PPP, you might want to say Y here. Since this
-	  thing often comes in handy, the default is Y. It won't enlarge your
-	  kernel either. What a deal. Read about it in the Network
+	  If you use SLIP or PPP, you might want to say Y here. It won't
+	  enlarge your kernel. What a deal. Read about it in the Network
 	  Administrator's Guide, available from
 	  <http://www.tldp.org/docs.html#guide>.
 
-- 
2.8.1
