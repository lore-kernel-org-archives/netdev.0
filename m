From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH -next] hydra: fix compilation
Date: Tue, 9 Dec 2008 04:18:55 +0300
Message-ID: <20081209011855.GA6785@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:62840 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000AbYLIBOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2008 20:14:33 -0500
Received: by nf-out-0910.google.com with SMTP id d3so697643nfc.21
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2008 17:14:31 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/hydra.c:163: error: 'hydra_netdev_ops' undeclared (first use in this function)

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/hydra.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/hydra.c
+++ b/drivers/net/hydra.c
@@ -94,7 +94,7 @@ static int __devinit hydra_init_one(struct zorro_dev *z,
     return 0;
 }
 
-static const struct net_device_ops etherh_netdev_ops = {
+static const struct net_device_ops hydra_netdev_ops = {
 	.ndo_open		= hydra_open,
 	.ndo_stop		= hydra_close,
 
