From: Romain Perier <romain.perier@collabora.com>
Subject: [PATCH v4 18/19] usb: host: Remove remaining pci_pool in comments
Date: Wed,  1 Mar 2017 16:55:20 +0100
Message-ID: <20170301155521.30281-19-romain.perier@collabora.com>
References: <20170301155521.30281-1-romain.perier@collabora.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org, linux-scsi@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Romain Perier <romain.perier@collabora.com>,
        Peter Senna Tschudin <peter.senna@collabora.co.uk>
To: Dan Williams <dan.j.williams@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        jeffrey.t.kirsher@intel.com,
        "David S. Miller" <davem@davemloft.net>, stas.yakovlev@gmail.com,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Felipe Balbi <balbi@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20170301155521.30281-1-romain.perier@collabora.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This replaces remaining occurences of pci_pool by dma_pool, as
this is the new API that could be used for that purpose.

Signed-off-by: Romain Perier <romain.perier@collabora.com>
Reviewed-by: Peter Senna Tschudin <peter.senna@collabora.com>
---
 drivers/usb/host/ehci-hcd.c     | 2 +-
 drivers/usb/host/fotg210-hcd.c  | 2 +-
 drivers/usb/host/oxu210hp-hcd.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/usb/host/ehci-hcd.c b/drivers/usb/host/ehci-hcd.c
index ac2c4ea..6e834b83 100644
--- a/drivers/usb/host/ehci-hcd.c
+++ b/drivers/usb/host/ehci-hcd.c
@@ -597,7 +597,7 @@ static int ehci_run (struct usb_hcd *hcd)
 	/*
 	 * hcc_params controls whether ehci->regs->segment must (!!!)
 	 * be used; it constrains QH/ITD/SITD and QTD locations.
-	 * pci_pool consistent memory always uses segment zero.
+	 * dma_pool consistent memory always uses segment zero.
 	 * streaming mappings for I/O buffers, like pci_map_single(),
 	 * can return segments above 4GB, if the device allows.
 	 *
diff --git a/drivers/usb/host/fotg210-hcd.c b/drivers/usb/host/fotg210-hcd.c
index 1c5b34b..ced08dc 100644
--- a/drivers/usb/host/fotg210-hcd.c
+++ b/drivers/usb/host/fotg210-hcd.c
@@ -5047,7 +5047,7 @@ static int fotg210_run(struct usb_hcd *hcd)
 	/*
 	 * hcc_params controls whether fotg210->regs->segment must (!!!)
 	 * be used; it constrains QH/ITD/SITD and QTD locations.
-	 * pci_pool consistent memory always uses segment zero.
+	 * dma_pool consistent memory always uses segment zero.
 	 * streaming mappings for I/O buffers, like pci_map_single(),
 	 * can return segments above 4GB, if the device allows.
 	 *
diff --git a/drivers/usb/host/oxu210hp-hcd.c b/drivers/usb/host/oxu210hp-hcd.c
index bcf531c..ed20fb3 100644
--- a/drivers/usb/host/oxu210hp-hcd.c
+++ b/drivers/usb/host/oxu210hp-hcd.c
@@ -2708,7 +2708,7 @@ static int oxu_run(struct usb_hcd *hcd)
 
 	/* hcc_params controls whether oxu->regs->segment must (!!!)
 	 * be used; it constrains QH/ITD/SITD and QTD locations.
-	 * pci_pool consistent memory always uses segment zero.
+	 * dma_pool consistent memory always uses segment zero.
 	 * streaming mappings for I/O buffers, like pci_map_single(),
 	 * can return segments above 4GB, if the device allows.
 	 *
-- 
2.9.3
