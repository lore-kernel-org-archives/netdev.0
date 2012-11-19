From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 249/493] drivers: connector: remove use of __devinit
Date: Mon, 19 Nov 2012 13:23:18 -0500
Message-ID: <1353349642-3677-249-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Evgeniy Polyakov <zbr@ioremap.net>, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41428 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093Ab2KSSdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:33:45 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devinit is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Evgeniy Polyakov <zbr@ioremap.net> 
Cc: netdev@vger.kernel.org 
---
 drivers/connector/connector.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 965b781..3d8ce60 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -256,7 +256,7 @@ static struct cn_dev cdev = {
 	.input   = cn_rx_skb,
 };
 
-static int __devinit cn_init(void)
+static int cn_init(void)
 {
 	struct cn_dev *dev = &cdev;
 	struct netlink_kernel_cfg cfg = {
-- 
1.8.0
