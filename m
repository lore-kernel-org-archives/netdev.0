From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] e100: fix printk format warning
Date: Wed, 18 Jun 2008 14:07:41 -0700
Message-ID: <20080618140741.79e21737.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, akpm <akpm@linux-foundation.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:12022 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbYFRVIX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 17:08:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix printk format warning:

drivers/net/e100.c:1145: warning: format '%d' expects type 'int', but argument 5 has type 'size_t'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/e100.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20080618.orig/drivers/net/e100.c
+++ linux-next-20080618/drivers/net/e100.c
@@ -1142,7 +1142,7 @@ static const struct firmware *e100_reque
 	/* Firmware should be precisely UCODE_SIZE (words) plus three bytes
 	   indicating the offsets for BUNDLESMALL, BUNDLEMAX, INTDELAY */
 	if (fw->size != UCODE_SIZE * 4 + 3) {
-		DPRINTK(PROBE,ERR, "Firmware \"%s\" has wrong size %d\n",
+		DPRINTK(PROBE,ERR, "Firmware \"%s\" has wrong size %zu\n",
 			fw_name, fw->size);
 		release_firmware(fw);
 		return ERR_PTR(-EINVAL);


---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
