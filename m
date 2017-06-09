From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 05/11] net: caif: convert to use DRIVER_ATTR_RO
Date: Fri,  9 Jun 2017 11:03:08 +0200
Message-ID: <20170609090314.13991-5-gregkh@linuxfoundation.org>
References: <20170609090314.13991-1-gregkh@linuxfoundation.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170609090314.13991-1-gregkh@linuxfoundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We are trying to get rid of DRIVER_ATTR(), and the caif driver's
attributes can be trivially changed to use DRIVER_ATTR_RO().

Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Cc: <netdev@vger.kernel.org>
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
