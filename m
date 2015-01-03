From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] Revert "ipw2200: select CFG80211_WEXT"
Date: Sat, 03 Jan 2015 15:59:48 +0100
Message-ID: <1420297188.2397.3.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Kosina <jkosina@suse.cz>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit dddd60220f41775e634258efd1b54c6fa81ce706.

The raison d'=C3=AAtre of commit dddd60220f41 ("ipw2200: select
CFG80211_WEXT") was reverted in commit 2d36e008739e ("Revert "cfg80211:
make WEXT compatibility unselectable""). So revert this commit too.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
 drivers/net/wireless/ipw2x00/Kconfig | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/Kconfig b/drivers/net/wireles=
s/ipw2x00/Kconfig
index 21de4fe6cf2d..91c0cb3c368e 100644
--- a/drivers/net/wireless/ipw2x00/Kconfig
+++ b/drivers/net/wireless/ipw2x00/Kconfig
@@ -65,8 +65,7 @@ config IPW2100_DEBUG
=20
 config IPW2200
 	tristate "Intel PRO/Wireless 2200BG and 2915ABG Network Connection"
-	depends on PCI && CFG80211
-	select CFG80211_WEXT
+	depends on PCI && CFG80211 && CFG80211_WEXT
 	select WIRELESS_EXT
 	select WEXT_SPY
 	select WEXT_PRIV
--=20
2.1.0
