From: kaber@trash.net
Subject: [PATCH 64/79] netfilter: xtables: add missing aliases for autoloading via iptables
Date: Wed, 19 Jan 2011 20:15:04 +0100
Message-ID: <1295464519-21763-65-git-send-email-kaber@trash.net>
References: <1295464519-21763-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295464519-21763-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/netfilter/xt_IDLETIMER.c |    2 ++
 net/netfilter/xt_LED.c       |    2 ++
 net/netfilter/xt_cpu.c       |    2 ++
 3 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/xt_IDLETIMER.c b/net/netfilter/xt_IDLETIMER.c
index be1f22e..3bdd443 100644
--- a/net/netfilter/xt_IDLETIMER.c
+++ b/net/netfilter/xt_IDLETIMER.c
@@ -313,3 +313,5 @@ MODULE_AUTHOR("Timo Teras <ext-timo.teras@nokia.com>");
 MODULE_AUTHOR("Luciano Coelho <luciano.coelho@nokia.com>");
 MODULE_DESCRIPTION("Xtables: idle time monitor");
 MODULE_LICENSE("GPL v2");
+MODULE_ALIAS("ipt_IDLETIMER");
+MODULE_ALIAS("ip6t_IDLETIMER");
diff --git a/net/netfilter/xt_LED.c b/net/netfilter/xt_LED.c
index a414050..993de2b 100644
--- a/net/netfilter/xt_LED.c
+++ b/net/netfilter/xt_LED.c
@@ -31,6 +31,8 @@
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Adam Nielsen <a.nielsen@shikadi.net>");
 MODULE_DESCRIPTION("Xtables: trigger LED devices on packet match");
+MODULE_ALIAS("ipt_LED");
+MODULE_ALIAS("ip6t_LED");
 
 static LIST_HEAD(xt_led_triggers);
 static DEFINE_MUTEX(xt_led_mutex);
diff --git a/net/netfilter/xt_cpu.c b/net/netfilter/xt_cpu.c
index b39db8a..c7a2e54 100644
--- a/net/netfilter/xt_cpu.c
+++ b/net/netfilter/xt_cpu.c
@@ -22,6 +22,8 @@
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Eric Dumazet <eric.dumazet@gmail.com>");
 MODULE_DESCRIPTION("Xtables: CPU match");
+MODULE_ALIAS("ipt_cpu");
+MODULE_ALIAS("ip6t_cpu");
 
 static int cpu_mt_check(const struct xt_mtchk_param *par)
 {
-- 
1.7.2.3

