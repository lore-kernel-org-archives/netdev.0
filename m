From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 83/86] brcm80211: drop pci dependency
Date: Sun, 29 Mar 2015 15:43:26 +0200
Message-ID: <1427635734-24786-84-git-send-email-mst@redhat.com>
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
	Chen-Yu Tsai <wens@csie.org>,
	Hans de Goede <hdegoede@redhat.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1427635734-24786-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This file does not use any pci APIs, drop
pci header includes.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
index 227cb33..9331486 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
@@ -17,8 +17,6 @@
 
 #include <linux/types.h>
 #include <linux/netdevice.h>
-#include <linux/pci.h>
-#include <uapi/linux/pci_ids.h>
 #include <linux/sched.h>
 #include <linux/completion.h>
 #include <linux/scatterlist.h>
-- 
MST
