From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] ssb/sdio: fix printk format warnings
Date: Tue, 15 Sep 2009 14:52:40 -0700
Message-ID: <20090915145240.d847dea8.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, akpm <akpm@linux-foundation.org>
To: linux-mmc@vger.kernel.org, Michael Buesch <mb@bu3sch.de>
Return-path: <linux-mmc-owner@vger.kernel.org>
Sender: linux-mmc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix printk format warnings:

drivers/ssb/sdio.c:336: warning: format '%u' expects type 'unsigned int', but argument 7 has type 'size_t'
drivers/ssb/sdio.c:443: warning: format '%u' expects type 'unsigned int', but argument 7 has type 'size_t'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/ssb/sdio.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- linux-next-20090914.orig/drivers/ssb/sdio.c
+++ linux-next-20090914/drivers/ssb/sdio.c
@@ -333,7 +333,7 @@ static void ssb_sdio_block_read(struct s
 		goto out;
 
 err_out:
-	dev_dbg(ssb_sdio_dev(bus), "%04X:%04X (width=%u, len=%u), error %d\n",
+	dev_dbg(ssb_sdio_dev(bus), "%04X:%04X (width=%u, len=%zu), error %d\n",
 		bus->sdio_sbaddr >> 16, offset, reg_width, saved_count, error);
 out:
 	sdio_release_host(bus->host_sdio);
@@ -440,7 +440,7 @@ static void ssb_sdio_block_write(struct 
 		goto out;
 
 err_out:
-	dev_dbg(ssb_sdio_dev(bus), "%04X:%04X (width=%u, len=%u), error %d\n",
+	dev_dbg(ssb_sdio_dev(bus), "%04X:%04X (width=%u, len=%zu), error %d\n",
 		bus->sdio_sbaddr >> 16, offset, reg_width, saved_count, error);
 out:
 	sdio_release_host(bus->host_sdio);




---
~Randy
LPC 2009, Sept. 23-25, Portland, Oregon
http://linuxplumbersconf.org/2009/
