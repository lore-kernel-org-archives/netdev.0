From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 11/15] be2net: pass proper hdr_size while flashing
 redboot.
Date: Fri, 11 Feb 2011 17:37:42 -0600
Message-ID: <20110211233742.GA18457@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51236 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757204Ab1BKXhp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:37:45 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 8975340..824d420 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2461,8 +2461,8 @@ static int be_flash_data(struct be_adapter *adapter,
 			continue;
 		if ((pflashcomp[i].optype == IMG_TYPE_REDBOOT) &&
 			(!be_flash_redboot(adapter, fw->data,
-			 pflashcomp[i].offset, pflashcomp[i].size,
-			 filehdr_size)))
+			pflashcomp[i].offset, pflashcomp[i].size, filehdr_size +
+			(num_of_images * sizeof(struct image_hdr)))))
 			continue;
 		p = fw->data;
 		p += filehdr_size + pflashcomp[i].offset
-- 
1.7.1

