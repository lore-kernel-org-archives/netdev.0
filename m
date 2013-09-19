From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 26/51] DMA-API: usb: ohci-sa1111: add a note
	about DMA masks
Date: Thu, 19 Sep 2013 22:51:02 +0100
Message-ID: <E1VMm7q-0007iO-68@rmk-PC.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Alan Stern <stern@rowland.harvard.edu>
To: alsa-devel@alsa-project.org, b43-dev@lists.infradead.org,
 devel@driverdev.osuosl.org, devicetree@vger.kernel.org,
 dri-devel@lists.freedesktop.org, e1000-devel@lists.sourceforge.net,
 linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-ide@vger.kernel.org, linux-media@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-nvme@lists.infradead.org,
 linux-omap@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org,
 linux-tegra@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 uclinux-dist-devel@blackfin.uclinux.org
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20130919212235.GD12758@n2100.arm.linux.org.uk>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

Add a comment to explain why this driver doesn't call any of the DMA
API dma_set_mask() functions.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/usb/host/ohci-sa1111.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/usb/host/ohci-sa1111.c b/drivers/usb/host/ohci-sa1111.c
index 17b2a7d..aa9e127 100644
--- a/drivers/usb/host/ohci-sa1111.c
+++ b/drivers/usb/host/ohci-sa1111.c
@@ -185,6 +185,12 @@ static int ohci_hcd_sa1111_probe(struct sa1111_dev *dev)
 	if (usb_disabled())
 		return -ENODEV;
 
+	/*
+	 * We don't call dma_set_mask_and_coherent() here because the
+	 * DMA mask has already been appropraitely setup by the core
+	 * SA-1111 bus code (which includes bug workarounds.)
+	 */
+
 	hcd = usb_create_hcd(&ohci_sa1111_hc_driver, &dev->dev, "sa1111");
 	if (!hcd)
 		return -ENOMEM;
-- 
1.7.4.4
