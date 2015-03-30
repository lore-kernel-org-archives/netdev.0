From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v2 5/6] brcm80211: drop pci_ids include
Date: Mon, 30 Mar 2015 12:59:43 +0200
Message-ID: <1427712964-16155-6-git-send-email-mst@redhat.com>
References: <1427712964-16155-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org,
	Arend van Spriel <arend@broadcom.com>,
	Brett Rudley <brudley@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Daniel Kim <dekim@broadcom.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1427712964-16155-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This file does not use any pci ids, drop
pci_ids.h include.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Acked-by: Arend van Spriel <arend@broadcom.com>
---
 drivers/net/wireless/brcm80211/brcmfmac/sdio.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
index faec35c..da479d4 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/sdio.c
@@ -18,7 +18,6 @@
 #include <linux/kernel.h>
 #include <linux/kthread.h>
 #include <linux/printk.h>
-#include <linux/pci_ids.h>
 #include <linux/netdevice.h>
 #include <linux/interrupt.h>
 #include <linux/sched.h>
-- 
MST
