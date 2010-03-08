From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH 2/2] be2net: remove unused code in be_load_fw
Date: Mon, 8 Mar 2010 05:53:44 +0530
Message-ID: <20100308002342.GB18118@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:36883 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158Ab0CHAbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Mar 2010 19:31:01 -0500
Received: by gyh3 with SMTP id 3so597501gyh.19
        for <netdev@vger.kernel.org>; Sun, 07 Mar 2010 16:31:00 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch cleans up some unused code from be_load_fw().

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 7c9b57e..43e8032 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1993,16 +1993,7 @@ int be_load_fw(struct be_adapter *adapter, u8 *func)
 	struct be_dma_mem flash_cmd;
 	int status, i = 0;
 	const u8 *p;
-	char fw_ver[FW_VER_LEN];
-	char fw_cfg;
 
-	status = be_cmd_get_fw_ver(adapter, fw_ver);
-	if (status)
-		return status;
-
-	fw_cfg = *(fw_ver + 2);
-	if (fw_cfg == '0')
-		fw_cfg = '1';
 	strcpy(fw_file, func);
 
 	status = request_firmware(&fw, fw_file, &adapter->pdev->dev);
-- 
1.6.3.3

