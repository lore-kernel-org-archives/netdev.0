From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] mdio: mdio_if_info::mmds should not be __bitwise
Date: Tue, 18 Aug 2009 17:59:38 +0100
Message-ID: <1250614778.2782.14.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:53467 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759407AbZHRQ7j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2009 12:59:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I misunderstood the meaning of __bitwise.  In practice it makes sparse
warn about every use of mmds which is certainly not what we want.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This should be safe to include in 2.6.31 but it's hardly critical.

Ben.

 include/linux/mdio.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/mdio.h b/include/linux/mdio.h
index cfdf1df..c779b49 100644
--- a/include/linux/mdio.h
+++ b/include/linux/mdio.h
@@ -304,7 +304,7 @@ static inline __u16 mdio_phy_id_devad(int phy_id)
  */
 struct mdio_if_info {
 	int prtad;
-	u32 __bitwise mmds;
+	u32 mmds;
 	unsigned mode_support;
 
 	struct net_device *dev;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

