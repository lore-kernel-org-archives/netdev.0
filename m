From: David Miller <davem@davemloft.net>
Subject: [PATCH] be2net: Kill set but unused variable 'req' in
 lancer_fw_download()
Date: Thu, 19 May 2011 18:50:16 -0400 (EDT)
Message-ID: <20110519.185016.1362090415828746216.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50049 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555Ab1ESWuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 18:50:19 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4JMoHas029750
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 May 2011 15:50:18 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/benet/be_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index ce6edac..4b5e0ed 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2736,7 +2736,6 @@ static int lancer_fw_download(struct be_adapter *adapter,
 #define LANCER_FW_DOWNLOAD_CHUNK      (32 * 1024)
 #define LANCER_FW_DOWNLOAD_LOCATION   "/prg"
 	struct be_dma_mem flash_cmd;
-	struct lancer_cmd_req_write_object *req;
 	const u8 *data_ptr = NULL;
 	u8 *dest_image_ptr = NULL;
 	size_t image_size = 0;
@@ -2765,7 +2764,6 @@ static int lancer_fw_download(struct be_adapter *adapter,
 		goto lancer_fw_exit;
 	}
 
-	req = flash_cmd.va;
 	dest_image_ptr = flash_cmd.va +
 				sizeof(struct lancer_cmd_req_write_object);
 	image_size = fw->size;
-- 
1.7.4.4

