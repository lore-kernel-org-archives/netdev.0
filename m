From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH v2 7/9] drivers: net: Mark functions as static in 4965-debug.c
Date: Sat, 14 Dec 2013 17:58:38 +0530
Message-ID: <e2e1afdbd3f2a70aba2217531604b31cce6dd8ca.1386911124.git.rashika.kheria@gmail.com>
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

This patch marks the function il4965_ucode_rx_stats_read(),
il4965_ucode_tx_stats_read() and il4965_ucode_general_stats_read() in
4965-debug.c as static because they are not used outside this file.

Thus, it also removes the following warnings in
wireless/iwlegacy/4965-debug.c:

drivers/net/wireless/iwlegacy/4965-debug.c:59:1: warning: no previous p=
rototype for =E2=80=98il4965_ucode_rx_stats_read=E2=80=99 [-Wmissing-pr=
ototypes]
drivers/net/wireless/iwlegacy/4965-debug.c:471:1: warning: no previous =
prototype for =E2=80=98il4965_ucode_tx_stats_read=E2=80=99 [-Wmissing-p=
rototypes]
drivers/net/wireless/iwlegacy/4965-debug.c:637:1: warning: no previous =
prototype for =E2=80=98il4965_ucode_general_stats_read=E2=80=99 [-Wmiss=
ing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/net/wireless/iwlegacy/4965-debug.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/4965-debug.c b/drivers/net/w=
ireless/iwlegacy/4965-debug.c
index c8153fc..e0597bf 100644
--- a/drivers/net/wireless/iwlegacy/4965-debug.c
+++ b/drivers/net/wireless/iwlegacy/4965-debug.c
@@ -55,7 +55,7 @@ il4965_stats_flag(struct il_priv *il, char *buf, int =
bufsz)
 	return p;
 }
=20
-ssize_t
+static ssize_t
 il4965_ucode_rx_stats_read(struct file *file, char __user *user_buf,
 			   size_t count, loff_t *ppos)
 {
@@ -467,7 +467,7 @@ il4965_ucode_rx_stats_read(struct file *file, char =
__user *user_buf,
 	return ret;
 }
=20
-ssize_t
+static ssize_t
 il4965_ucode_tx_stats_read(struct file *file, char __user *user_buf,
 			   size_t count, loff_t *ppos)
 {
@@ -633,7 +633,7 @@ il4965_ucode_tx_stats_read(struct file *file, char =
__user *user_buf,
 	return ret;
 }
=20
-ssize_t
+static ssize_t
 il4965_ucode_general_stats_read(struct file *file, char __user *user_b=
uf,
 				size_t count, loff_t *ppos)
 {
--=20
1.7.9.5
