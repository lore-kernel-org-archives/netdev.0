From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 438/493] drivers: connector: remove use of __devexit
Date: Mon, 19 Nov 2012 13:26:27 -0500
Message-ID: <1353349642-3677-438-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Evgeniy Polyakov <zbr@ioremap.net>, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41508 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754302Ab2KSSfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:35:05 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit is no
longer needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Evgeniy Polyakov <zbr@ioremap.net> 
Cc: netdev@vger.kernel.org 
---
 drivers/connector/connector.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 3d8ce60..7b69591 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -281,7 +281,7 @@ static int cn_init(void)
 	return 0;
 }
 
-static void __devexit cn_fini(void)
+static void cn_fini(void)
 {
 	struct cn_dev *dev = &cdev;
 
-- 
1.8.0
