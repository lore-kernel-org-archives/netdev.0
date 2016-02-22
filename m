From: "=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?=" <jprvita@gmail.com>
Subject: [PATCHv2 01/10] rfkill: Improve documentation language
Date: Mon, 22 Feb 2016 11:36:32 -0500
Message-ID: <1456159001-20307-2-git-send-email-jprvita@endlessm.com>
References: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Darren Hart <dvhart@infradead.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	platform-driver-x86@vger.kernel.org, linux-api@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux@endlessm.com,
	=?UTF-8?q?Jo=C3=A3o=20Paulo=20Rechi=20Vita?= <jprvita@endlessm.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1456159001-20307-1-git-send-email-jprvita@endlessm.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@endlessm.com>
---
 net/rfkill/core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index a805831..ffbc375 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -282,8 +282,8 @@ static void rfkill_set_block(struct rfkill *rfkill,=
 bool blocked)
 	spin_lock_irqsave(&rfkill->lock, flags);
 	if (err) {
 		/*
-		 * Failed -- reset status to _prev, this may be different
-		 * from what set set _PREV to earlier in this function
+		 * Failed -- reset status to _PREV, which may be different
+		 * from what we have set _PREV to earlier in this function
 		 * if rfkill_set_sw_state was invoked.
 		 */
 		if (rfkill->state & RFKILL_BLOCK_SW_PREV)
--=20
2.5.0

