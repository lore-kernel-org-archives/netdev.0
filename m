From: akpm@linux-foundation.org
Subject: [patch 5/6] e100: fix printk format warning
Date: Thu, 03 Jul 2008 23:43:12 -0700
Message-ID: <200807040643.m646hCaG017243@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	randy.dunlap@oracle.com, jeffrey.t.kirsher@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43641 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752938AbYGDGoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2008 02:44:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix printk format warning:

drivers/net/e100.c:1145: warning: format '%d' expects type 'int', but argument 5 has type 'size_t'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/e100.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/e100.c~e100-fix-printk-format-warning drivers/net/e100.c
--- a/drivers/net/e100.c~e100-fix-printk-format-warning
+++ a/drivers/net/e100.c
@@ -1142,7 +1142,7 @@ static const struct firmware *e100_reque
 	/* Firmware should be precisely UCODE_SIZE (words) plus three bytes
 	   indicating the offsets for BUNDLESMALL, BUNDLEMAX, INTDELAY */
 	if (fw->size != UCODE_SIZE * 4 + 3) {
-		DPRINTK(PROBE,ERR, "Firmware \"%s\" has wrong size %d\n",
+		DPRINTK(PROBE,ERR, "Firmware \"%s\" has wrong size %zu\n",
 			fw_name, fw->size);
 		release_firmware(fw);
 		return ERR_PTR(-EINVAL);
_
