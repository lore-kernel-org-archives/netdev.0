From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: [PATCH 03/17] batman-adv: Annotate functions with
	format strings
Date: Mon, 30 May 2011 09:22:48 +0200
Message-ID: <1306740182-2665-4-git-send-email-sven@narfation.org>
References: <1306740182-2665-1-git-send-email-sven@narfation.org>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
	<b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1306740182-2665-1-git-send-email-sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
	<mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
---
 net/batman-adv/bat_debugfs.c |    1 +
 net/batman-adv/main.h        |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/batman-adv/bat_debugfs.c b/net/batman-adv/bat_debugfs.c
index abaeec5..4577d3f 100644
--- a/net/batman-adv/bat_debugfs.c
+++ b/net/batman-adv/bat_debugfs.c
@@ -50,6 +50,7 @@ static void emit_log_char(struct debug_log *debug_log, char c)
 		debug_log->log_start = debug_log->log_end - log_buff_len;
 }
 
+__printf(2, 3)
 static int fdebug_log(struct debug_log *debug_log, char *fmt, ...)
 {
 	va_list args;
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 148b49e..ba28436 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -136,7 +136,7 @@ void dec_module_count(void);
 int is_my_mac(uint8_t *addr);
 
 #ifdef CONFIG_BATMAN_ADV_DEBUG
-int debug_log(struct bat_priv *bat_priv, char *fmt, ...);
+int debug_log(struct bat_priv *bat_priv, char *fmt, ...) __printf(2, 3);
 
 #define bat_dbg(type, bat_priv, fmt, arg...)			\
 	do {							\
@@ -145,6 +145,7 @@ int debug_log(struct bat_priv *bat_priv, char *fmt, ...);
 	}							\
 	while (0)
 #else /* !CONFIG_BATMAN_ADV_DEBUG */
+__printf(3, 4)
 static inline void bat_dbg(char type __always_unused,
 			   struct bat_priv *bat_priv __always_unused,
 			   char *fmt __always_unused, ...)
-- 
1.7.5.3
