From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: rtl8723ae: Fix typo in firmware names
Date: Sun, 23 Jun 2013 18:14:43 -0500
Message-ID: <1372029283-20824-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org,
	=?UTF-8?q?Axel=20K=C3=B6llhofer?= <AxelKoellhofer@web.de>,
	Stable <stable@vger.kernel.org>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:39168 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002Ab3FWXPG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 19:15:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver loads its firmware from files rtlwifi/rtl8723fw*.bin, but th=
e
MODULE_FIRMWARE macros refer to rtlwifi/RTL8723aefw*.bin.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>  [3.8+]
Reported-by: Axel K=C3=B6llhofer <AxelKoellhofer@web.de>
---

John,

This patch can be pushed to the 3.11 stream. It is a bug, but it has
little consequence.

Larry
---
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c b/drivers/net/=
wireless/rtlwifi/rtl8723ae/sw.c
index e4c4cdc..d9ee2ef 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
@@ -251,7 +251,7 @@ static struct rtl_hal_cfg rtl8723ae_hal_cfg =3D {
 	.bar_id =3D 2,
 	.write_readback =3D true,
 	.name =3D "rtl8723ae_pci",
-	.fw_name =3D "rtlwifi/rtl8723aefw.bin",
+	.fw_name =3D "rtlwifi/rtl8723fw.bin",
 	.ops =3D &rtl8723ae_hal_ops,
 	.mod_params =3D &rtl8723ae_mod_params,
 	.maps[SYS_ISO_CTRL] =3D REG_SYS_ISO_CTRL,
@@ -353,8 +353,8 @@ MODULE_AUTHOR("Realtek WlanFAE	<wlanfae@realtek.com=
>");
 MODULE_AUTHOR("Larry Finger	<Larry.Finger@lwfinger.net>");
 MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Realtek 8723E 802.11n PCI wireless");
-MODULE_FIRMWARE("rtlwifi/rtl8723aefw.bin");
-MODULE_FIRMWARE("rtlwifi/rtl8723aefw_B.bin");
+MODULE_FIRMWARE("rtlwifi/rtl8723fw.bin");
+MODULE_FIRMWARE("rtlwifi/rtl8723fw_B.bin");
=20
 module_param_named(swenc, rtl8723ae_mod_params.sw_crypto, bool, 0444);
 module_param_named(debug, rtl8723ae_mod_params.debug, int, 0444);
--=20
1.8.1.4
