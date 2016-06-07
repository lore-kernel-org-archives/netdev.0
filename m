From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] brcmfmac: include required headers in cfg80211.h
Date: Tue,  7 Jun 2016 08:20:21 +0200
Message-ID: <1465280428-5782-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
	linux-wireless@vger.kernel.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	brcm80211-dev-list@broadcom.com (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without this including cfg80211.h in a wrong order could result in:

drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h:122:24: err=
or: array type has incomplete element type
  struct brcmf_wsec_key key[BRCMF_MAX_DEFAULT_KEYS];
                        ^
drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h:291:24: err=
or: field =E2=80=98p2p=E2=80=99 has incomplete type
  struct brcmf_p2p_info p2p;
                        ^
drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h:297:27: err=
or: field =E2=80=98pmk_list=E2=80=99 has incomplete type
  struct brcmf_pmk_list_le pmk_list;
                           ^
drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h:317:28: err=
or: field =E2=80=98assoclist=E2=80=99 has incomplete type
  struct brcmf_assoclist_le assoclist;

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.=
h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h
index c6f9986..04bfc7e 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h
@@ -20,6 +20,9 @@
 /* for brcmu_d11inf */
 #include <brcmu_d11.h>
=20
+#include "fwil_types.h"
+#include "p2p.h"
+
 #define WL_NUM_SCAN_MAX			10
 #define WL_TLV_INFO_MAX			1024
 #define WL_BSS_INFO_MAX			2048
--=20
1.8.4.5
