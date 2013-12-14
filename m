From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH v2 8/9] drivers: net: Mark functions as static in debug.c
Date: Sat, 14 Dec 2013 18:00:25 +0530
Message-ID: <f72a822c9171b17d2d51a221820e30d0ca1ecd36.1386911124.git.rashika.kheria@gmail.com>
References: <a610f6ee6bb992b91e43bdc851f3db62fc3decd5.1386911123.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a610f6ee6bb992b91e43bdc851f3db62fc3decd5.1386911123.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch marks the function il_clear_traffic_stats() in debug.c as
static because they are not used outside this file.

Thus, it also removes the following warnings in
wireless/iwlegacy/debug.c:

drivers/net/wireless/iwlegacy/debug.c:35:1: warning: no previous protot=
ype for =E2=80=98il_clear_traffic_stats=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/net/wireless/iwlegacy/debug.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/iwlegacy/debug.c b/drivers/net/wirele=
ss/iwlegacy/debug.c
index eff2650..b7e03dd 100644
--- a/drivers/net/wireless/iwlegacy/debug.c
+++ b/drivers/net/wireless/iwlegacy/debug.c
@@ -31,7 +31,7 @@
=20
 #include "common.h"
=20
-void
+static void
 il_clear_traffic_stats(struct il_priv *il)
 {
 	memset(&il->tx_stats, 0, sizeof(struct traffic_stats));
--=20
1.7.9.5
