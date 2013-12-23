From: Josh Triplett <josh@joshtriplett.org>
Subject: [PATCH 2/7] net: wireless: brcm80211: Drop debug version with build
 date/time
Date: Mon, 23 Dec 2013 13:55:03 -0800
Message-ID: <69320ca2cc6f70265844d70b890d661dc4186f8b.1387833347.git.josh@joshtriplett.org>
References: <cover.1387833347.git.josh@joshtriplett.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1387833347.git.josh@joshtriplett.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel already has this information, and individual drivers
shouldn't duplicate that.  This also eliminates the use of __DATE__ and
__TIME__, which make the build non-deterministic.

Signed-off-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
index 9431af2..78e2999b 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
@@ -32,15 +32,8 @@
 #define BRCMF_DEFAULT_SCAN_UNASSOC_TIME	40
 #define BRCMF_DEFAULT_PACKET_FILTER	"100 0 0 0 0x01 0x00"
 
-#ifdef DEBUG
-static const char brcmf_version[] =
-	"Dongle Host Driver, version " BRCMF_VERSION_STR "\nCompiled on "
-	__DATE__ " at " __TIME__;
-#else
 static const char brcmf_version[] =
 	"Dongle Host Driver, version " BRCMF_VERSION_STR;
-#endif
-
 
 bool brcmf_c_prec_enq(struct device *dev, struct pktq *q,
 		      struct sk_buff *pkt, int prec)
-- 
1.8.5.2
