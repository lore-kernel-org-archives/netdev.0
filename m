From: Dan Carpenter <error27@gmail.com>
Subject: [patch 2/2] be2net: remove superfluous externs
Date: Wed, 26 May 2010 16:47:39 +0200
Message-ID: <20100526144739.GM22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Subbu Seetharaman <subbus@serverengines.com>,
	Sarveshwar Bandi <sarveshwarb@serverengines.com>,
	Ajit Khaparde <ajitk@serverengines.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Sathya Perla <sathyap@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:46425 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755228Ab0EZOxk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 10:53:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes some sparse warnings:
drivers/net/benet/be_cmds.c:1503:12: warning: function
	'be_cmd_enable_magic_wol' with external linkage has definition
drivers/net/benet/be_cmds.c:1668:12: warning: function
	'be_cmd_get_seeprom_data' with external linkage has definition

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index c911bfb..f9c0d4d 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -1497,7 +1500,7 @@ err:
 	return status;
 }
 
-extern int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
+int be_cmd_enable_magic_wol(struct be_adapter *adapter, u8 *mac,
 				struct be_dma_mem *nonemb_cmd)
 {
 	struct be_mcc_wrb *wrb;
@@ -1662,7 +1665,7 @@ err:
 	return status;
 }
 
-extern int be_cmd_get_seeprom_data(struct be_adapter *adapter,
+int be_cmd_get_seeprom_data(struct be_adapter *adapter,
 				struct be_dma_mem *nonemb_cmd)
 {
 	struct be_mcc_wrb *wrb;
