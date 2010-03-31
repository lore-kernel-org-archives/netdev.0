From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH 1/3] be2net: fix a bug in flashing the redboot section
Date: Wed, 31 Mar 2010 17:17:45 +0530
Message-ID: <20100331114735.GA9068@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:52107 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756841Ab0CaLri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 07:47:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 43e8032..a08faf3 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1855,7 +1855,7 @@ static bool be_flash_redboot(struct be_adapter *adapter,
 	p += crc_offset;
 
 	status = be_cmd_get_flash_crc(adapter, flashed_crc,
-			(img_start + image_size - 4));
+			(image_size - 4));
 	if (status) {
 		dev_err(&adapter->pdev->dev,
 		"could not get crc from flash, not flashing redboot\n");
-- 
1.6.3.3

