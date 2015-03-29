From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 57/86] brcm80211: use uapi/linux/pci_ids.h directly
Date: Sun, 29 Mar 2015 15:41:44 +0200
Message-ID: <1427635734-24786-58-git-send-email-mst@redhat.com>
References: <1427635734-24786-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Mika Westerberg <mika.westerberg@linux.intel.com>,
	Hans de Goede <hdegoede@redhat.com>,
	"Daniel (Deognyoun) Kim" <dekim@broadcom.com>,
	=?us-ascii?B?PT9VVEYtOD9xP1JhZmE9QzU9ODI9MjBNaT1DNT04MmVja2k/PQ==?=
	<zajec5@gmail.com>, Julia Lawall <Julia.Lawall@lip6.fr>,
	Brian Norris <computersforpeace@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Markus Elfring <elfring@users.sourceforge.net>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1427635734-24786-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Header moved from linux/pci_ids.h to uapi/linux/pci_ids.h,
use the new header directly so we can drop
the wrapper in include/linux/pci_ids.h.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/wireless/brcm80211/include/brcm_hw_ids.h | 2 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c     | 2 +-
 drivers/net/wireless/brcm80211/brcmfmac/sdio.c       | 2 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c       | 2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/include/brcm_hw_ids.h b/drivers/net/wireless/brcm80211/include/brcm_hw_ids.h
index 2124a17..bd1370e 100644
--- a/drivers/net/wireless/brcm80211/include/brcm_hw_ids.h
+++ b/drivers/net/wireless/brcm80211/include/brcm_hw_ids.h
@@ -17,7 +17,7 @@
 #ifndef	_BRCM_HW_IDS_H_
 #define	_BRCM_HW_IDS_H_
 
-#include <linux/pci_ids.h>
+#include <uapi/linux/pci_ids.h>
 #include <linux/mmc/sdio_ids.h>
 
 #define BRCM_USB_VENDOR_ID_BROADCOM	0x0a5c
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
index 7944224..227cb33 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
@@ -18,7 +18,7 @@
 #include <linux/types.h>
 #include <linux/netdevice.h>
 #include <linux/pci.h>
-#include <linux/pci_ids.h>
+#include <uapi/linux/pci_ids.h>
 #include <linux/sched.h>
 #include <linux/completion.h>
 #include <linux/scatterlist.h>
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
index faec35c..5c4755d 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
@@ -18,7 +18,7 @@
 #include <linux/kernel.h>
 #include <linux/kthread.h>
 #include <linux/printk.h>
-#include <linux/pci_ids.h>
+#include <uapi/linux/pci_ids.h>
 #include <linux/netdevice.h>
 #include <linux/interrupt.h>
 #include <linux/sched.h>
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index eb8584a..de0ef7bb 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -17,7 +17,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
-#include <linux/pci_ids.h>
+#include <uapi/linux/pci_ids.h>
 #include <linux/if_ether.h>
 #include <net/cfg80211.h>
 #include <net/mac80211.h>
-- 
MST
