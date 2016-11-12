From: Colin King <colin.king@canonical.com>
Subject: [PATCH] ps3_gelic: fix spelling mistake in debug message
Date: Sat, 12 Nov 2016 17:20:30 +0000
Message-ID: <20161112172030.7583-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        "David S . Miller" <davem@davemloft.net>,
        Muhammad Falak R Wani <falakreyaz@gmail.com>,
        Christophe Jaillet <christophe.jaillet@wanadoo.fr>,
        Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake "unmached" to "unmatched" in
debug message.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/toshiba/ps3_gelic_wireless.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
index b3abd02..eed18f8 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_wireless.c
@@ -1694,7 +1694,7 @@ struct gelic_wl_scan_info *gelic_wl_find_best_bss(struct gelic_wl_info *wl)
 				pr_debug("%s: bssid matched\n", __func__);
 				break;
 			} else {
-				pr_debug("%s: bssid unmached\n", __func__);
+				pr_debug("%s: bssid unmatched\n", __func__);
 				continue;
 			}
 		}
-- 
2.10.2
