From: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Subject: [PATCH v5 18/19] usb: host: Remove remaining pci_pool in comments
Date: Wed,  8 Mar 2017 17:19:56 +0100
Message-ID: <20170308161957.28941-19-romain.perier@collabora.com>
References: <20170308161957.28941-1-romain.perier@collabora.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>,
        Peter Senna Tschudin <peter.senna-ZGY8ohtN/8pPYcu2f3hruQ@public.gmane.org>
To: Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
        "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Felipe Balbi <balbi-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170308161957.28941-1-romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This replaces remaining occurences of pci_pool by dma_pool, as
this is the new API that could be used for that purpose.

Signed-off-by: Romain Perier <romain.perier-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
Reviewed-by: Peter Senna Tschudin <peter.senna-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
