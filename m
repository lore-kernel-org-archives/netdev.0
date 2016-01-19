From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCH 2/8] rfkill: Improve code readability
Date: Tue, 19 Jan 2016 10:42:37 -0500
Message-ID: <1453218163-31998-3-git-send-email-jprvita@endlessm.com>
References: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcel@holtmann.org, linux-wireless@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jprvita@endlessm.com,
	linux@endlessm.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:34162 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754881AbcASPoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 10:44:05 -0500
In-Reply-To: <1453218163-31998-1-git-send-email-jprvita@endlessm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFKILL_BLOCK_SW value have just been saved to prev, no need to check it
again in the if expression. This makes code a little bit easier to read=
=2E

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 net/rfkill/core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index 4d6d726..838e869 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -285,7 +285,7 @@ static void rfkill_set_block(struct rfkill *rfkill,=
 bool blocked)
 	spin_lock_irqsave(&rfkill->lock, flags);
 	prev =3D rfkill->state & RFKILL_BLOCK_SW;
=20
-	if (rfkill->state & RFKILL_BLOCK_SW)
+	if (prev)
 		rfkill->state |=3D RFKILL_BLOCK_SW_PREV;
 	else
 		rfkill->state &=3D ~RFKILL_BLOCK_SW_PREV;
--=20
2.5.0
