From: Jeff Mahoney <jeffm@suse.com>
Subject: [PATCH] mpc5xxx_can: Fix typo causing build failure (of_dev -> ofdev)
Date: Wed, 13 Apr 2011 10:57:03 -0400
Message-ID: <4DA5B9BF.2010809@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Network Development <netdev@vger.kernel.org>
To: Grant Likely <grant.likely@secretlab.ca>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:36058 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757163Ab1DMO5G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 10:57:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 The variable is named ofdev, not of_dev.

Signed-off-by: Jeff Mahoney <jeffm@suse.com>
---
 drivers/net/can/mscan/mpc5xxx_can.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/can/mscan/mpc5xxx_can.c
+++ b/drivers/net/can/mscan/mpc5xxx_can.c
@@ -260,7 +260,7 @@ static int __devinit mpc5xxx_can_probe(s
 
 	if (!ofdev->dev.of_match)
 		return -EINVAL;
-	data = (struct mpc5xxx_can_data *)of_dev->dev.of_match->data;
+	data = (struct mpc5xxx_can_data *)ofdev->dev.of_match->data;
 
 	base = of_iomap(np, 0);
 	if (!base) {
-- 
Jeff Mahoney
SUSE Labs
