From: Colin King <colin.king@canonical.com>
Subject: [PATCH] batman-adv: fix spelling mistake "ourselve" -> "ourself"
Date: Sun, 25 Jun 2017 22:56:07 +0100
Message-ID: <20170625215607.30401-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Antonio Quartulli <a@unstable.cc>,
        "David S . Miller" <davem@davemloft.net>,
        b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in batadv_dbg debug message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/batman-adv/bat_v_ogm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index 1e3dc374bfde..d6dbf67acbb5 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -200,7 +200,7 @@ static void batadv_v_ogm_send(struct work_struct *work)
 				type = "unknown";
 			}
 
-			batadv_dbg(BATADV_DBG_BATMAN, bat_priv, "OGM2 from ourselve on %s surpressed: %s\n",
+			batadv_dbg(BATADV_DBG_BATMAN, bat_priv, "OGM2 from ourself on %s surpressed: %s\n",
 				   hard_iface->net_dev->name, type);
 
 			batadv_hardif_put(hard_iface);
-- 
2.11.0
