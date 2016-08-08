From: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
Subject: [PATCH 2/2] mwifiex: simplify length computation for some memset
Date: Mon,  8 Aug 2016 09:39:00 +0200
Message-ID: <1470641940-26681-1-git-send-email-christophe.jaillet@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Christophe JAILLET <christophe.jaillet@wanadoo.fr>
To: akarwar@marvell.com, nishants@marvell.com,
	linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp03.smtpout.orange.fr ([80.12.242.125]:50922 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752159AbcHHHjI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 03:39:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch should be a no-op. It just simplifies code by using the name of
a variable instead of its type when calling 'sizeof'.

Signed-off-by: Christophe JAILLET <christophe.jaillet@wanadoo.fr>
---
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/sta_ioctl.c b/drivers/net/wireless/marvell/mwifiex/sta_ioctl.c
index 78819e8..644f3a2 100644
--- a/drivers/net/wireless/marvell/mwifiex/sta_ioctl.c
+++ b/drivers/net/wireless/marvell/mwifiex/sta_ioctl.c
@@ -574,7 +574,7 @@ int mwifiex_enable_hs(struct mwifiex_adapter *adapter)
 
 	adapter->hs_activate_wait_q_woken = false;
 
-	memset(&hscfg, 0, sizeof(struct mwifiex_ds_hs_cfg));
+	memset(&hscfg, 0, sizeof(hscfg));
 	hscfg.is_invoke_hostcmd = true;
 
 	adapter->hs_enabling = true;
@@ -1138,7 +1138,7 @@ int mwifiex_set_encode(struct mwifiex_private *priv, struct key_params *kp,
 {
 	struct mwifiex_ds_encrypt_key encrypt_key;
 
-	memset(&encrypt_key, 0, sizeof(struct mwifiex_ds_encrypt_key));
+	memset(&encrypt_key, 0, sizeof(encrypt_key));
 	encrypt_key.key_len = key_len;
 	encrypt_key.key_index = key_index;
 
-- 
2.7.4


---
L'absence de virus dans ce courrier électronique a été vérifiée par le logiciel antivirus Avast.
https://www.avast.com/antivirus
