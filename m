From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] brcmsmac: initialize morepending in brcms_b_recv()
Date: Sat, 22 Dec 2012 22:07:14 +0100
Message-ID: <1356210434-28435-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Piotr Haber <phaber@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jacques.telenet-ops.be ([195.130.132.50]:56958 "EHLO
	jacques.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071Ab2LVVHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2012 16:07:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/wireless/brcm80211/brcmsmac/main.c: In function =E2=80=98br=
cms_b_recv=E2=80=99:
drivers/net/wireless/brcm80211/brcmsmac/main.c:7636: warning: =E2=80=98=
morepending=E2=80=99 may be used uninitialized in this function

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/wireless/brcm80211/brcmsmac/main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/n=
et/wireless/brcm80211/brcmsmac/main.c
index 17594de..5f0f444 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -7633,7 +7633,7 @@ brcms_b_recv(struct brcms_hardware *wlc_hw, uint =
fifo, bool bound)
=20
 	uint n =3D 0;
 	uint bound_limit =3D bound ? RXBND : -1;
-	bool morepending;
+	bool morepending =3D false;
=20
 	skb_queue_head_init(&recv_frames);
=20
--=20
1.7.0.4
