From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 2/2] net: via-rhine: Fix incorrect placement of __initdata
Date: Wed,  7 Aug 2013 16:08:16 +0530
Message-ID: <1375871896-25821-2-git-send-email-sachin.kamat@linaro.org>
References: <1375871896-25821-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, sachin.kamat@linaro.org, rl@hellgate.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:34862 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932675Ab3HGKzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 06:55:04 -0400
Received: by mail-pb0-f52.google.com with SMTP id wz12so1724029pbc.39
        for <netdev@vger.kernel.org>; Wed, 07 Aug 2013 03:55:03 -0700 (PDT)
In-Reply-To: <1375871896-25821-1-git-send-email-sachin.kamat@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__initdata should be placed between the variable name and equal
sign for the variable to be placed in the intended section.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/ethernet/via/via-rhine.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index b75eb9e..c8f088a 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -2407,7 +2407,7 @@ static struct pci_driver rhine_driver = {
 	.driver.pm	= RHINE_PM_OPS,
 };
 
-static struct dmi_system_id __initdata rhine_dmi_table[] = {
+static struct dmi_system_id rhine_dmi_table[] __initdata = {
 	{
 		.ident = "EPIA-M",
 		.matches = {
-- 
1.7.9.5
