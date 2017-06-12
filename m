From: <gregkh@linuxfoundation.org>
Subject: patch "net: caif: convert to use DRIVER_ATTR_RO" added to driver-core-testing
Date: Mon, 12 Jun 2017 16:15:24 +0200
Message-ID: <1497276924718@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
To: gregkh@linuxfoundation.org, davem@davemloft.net,
        dmitry.tarnyagin@lockless.no, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:56780 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752482AbdFLOPk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 10:15:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    net: caif: convert to use DRIVER_ATTR_RO

to my driver-core git tree which can be found at
    git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/driver-core.git
in the driver-core-testing branch.

The patch will show up in the next release of the linux-next tree
(usually sometime within the next 24 hours during the week.)

The patch will be merged to the driver-core-next branch sometime soon,
after it passes testing, and the merge window is open.

If you have any questions about this process, please let me know.


>From f85205c42eb0423e05c91d0276bfc86b136d42f6 Mon Sep 17 00:00:00 2001
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Fri, 9 Jun 2017 11:03:08 +0200
Subject: net: caif: convert to use DRIVER_ATTR_RO

We are trying to get rid of DRIVER_ATTR(), and the caif driver's
attributes can be trivially changed to use DRIVER_ATTR_RO().

Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Cc: <netdev@vger.kernel.org>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 drivers/net/caif/caif_spi.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index 3a529fbe539f..3281a3e0c144 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -289,44 +289,44 @@ static LIST_HEAD(cfspi_list);
 static spinlock_t cfspi_list_lock;
 
 /* SPI uplink head alignment. */
-static ssize_t show_up_head_align(struct device_driver *driver, char *buf)
+static ssize_t up_head_align_show(struct device_driver *driver, char *buf)
 {
 	return sprintf(buf, "%d\n", spi_up_head_align);
 }
 
-static DRIVER_ATTR(up_head_align, S_IRUSR, show_up_head_align, NULL);
+static DRIVER_ATTR_RO(up_head_align);
 
 /* SPI uplink tail alignment. */
-static ssize_t show_up_tail_align(struct device_driver *driver, char *buf)
+static ssize_t up_tail_align_show(struct device_driver *driver, char *buf)
 {
 	return sprintf(buf, "%d\n", spi_up_tail_align);
 }
 
-static DRIVER_ATTR(up_tail_align, S_IRUSR, show_up_tail_align, NULL);
+static DRIVER_ATTR_RO(up_tail_align);
 
 /* SPI downlink head alignment. */
-static ssize_t show_down_head_align(struct device_driver *driver, char *buf)
+static ssize_t down_head_align_show(struct device_driver *driver, char *buf)
 {
 	return sprintf(buf, "%d\n", spi_down_head_align);
 }
 
-static DRIVER_ATTR(down_head_align, S_IRUSR, show_down_head_align, NULL);
+static DRIVER_ATTR_RO(down_head_align);
 
 /* SPI downlink tail alignment. */
-static ssize_t show_down_tail_align(struct device_driver *driver, char *buf)
+static ssize_t down_tail_align_show(struct device_driver *driver, char *buf)
 {
 	return sprintf(buf, "%d\n", spi_down_tail_align);
 }
 
-static DRIVER_ATTR(down_tail_align, S_IRUSR, show_down_tail_align, NULL);
+static DRIVER_ATTR_RO(down_tail_align);
 
 /* SPI frame alignment. */
-static ssize_t show_frame_align(struct device_driver *driver, char *buf)
+static ssize_t frame_align_show(struct device_driver *driver, char *buf)
 {
 	return sprintf(buf, "%d\n", spi_frm_align);
 }
 
-static DRIVER_ATTR(frame_align, S_IRUSR, show_frame_align, NULL);
+static DRIVER_ATTR_RO(frame_align);
 
 int cfspi_xmitfrm(struct cfspi *cfspi, u8 *buf, size_t len)
 {
-- 
2.13.1
