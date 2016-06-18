From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] brcmfmac: include also core.h header in cfg80211.h
Date: Sat, 18 Jun 2016 18:49:38 +0200
Message-ID: <1466268596-12178-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Arend van Spriel <arend.vanspriel@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	Hante Meuleman <hante.meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	linux-wireless@vger.kernel.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	brcm80211-dev-list.pdl@broadcom.com (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:34604 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbcFRQuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 12:50:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This header provides two inline functions using struct brcmf_if so we
need core.h to avoid:

drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h: In functio=
n =E2=80=98ndev_to_prof=E2=80=99:
drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h:368:13: err=
or: dereferencing pointer to incomplete type
  return &ifp->vif->profile;
             ^
drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h: In functio=
n =E2=80=98ndev_to_vif=E2=80=99:
drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h:374:12: err=
or: dereferencing pointer to incomplete type
  return ifp->vif;
            ^

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.=
h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h
index 04bfc7e..7d77f86 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.h
@@ -20,6 +20,7 @@
 /* for brcmu_d11inf */
 #include <brcmu_d11.h>
=20
+#include "core.h"
 #include "fwil_types.h"
 #include "p2p.h"
=20
--=20
1.8.4.5
