From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] ath9k: Use static const
Date: Fri, 21 Feb 2014 14:46:43 -0800
Message-ID: <1393022803.2594.27.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Trivially reduces text size too.

$ size drivers/net/wireless/ath/ath9k/debug.o*
   text	   data	    bss	    dec	    hex	filename
  34436	   2528	   5128	  42092	   a46c	drivers/net/wireless/ath/ath9k/debug.o.new
  34464	   2528	   5128	  42120	   a488	drivers/net/wireless/ath/ath9k/debug.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath9k/debug.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/ath/ath9k/debug.c
index ab7264c..9131175 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -135,7 +135,8 @@ static ssize_t read_file_ani(struct file *file, char __user *user_buf,
 	struct ath_softc *sc = file->private_data;
 	struct ath_common *common = ath9k_hw_common(sc->sc_ah);
 	struct ath_hw *ah = sc->sc_ah;
-	unsigned int len = 0, size = 1024;
+	unsigned int len = 0;
+	const unsigned int size = 1024;
 	ssize_t retval = 0;
 	char *buf;
 
@@ -307,13 +308,13 @@ static ssize_t read_file_antenna_diversity(struct file *file,
 	struct ath_antenna_stats *as_main = &sc->debug.stats.ant_stats[ANT_MAIN];
 	struct ath_antenna_stats *as_alt = &sc->debug.stats.ant_stats[ANT_ALT];
 	struct ath_hw_antcomb_conf div_ant_conf;
-	unsigned int len = 0, size = 1024;
+	unsigned int len = 0;
+	const unsigned int size = 1024;
 	ssize_t retval = 0;
 	char *buf;
-	char *lna_conf_str[4] = {"LNA1_MINUS_LNA2",
-				 "LNA2",
-				 "LNA1",
-				 "LNA1_PLUS_LNA2"};
+	static const char *lna_conf_str[4] = {
+		"LNA1_MINUS_LNA2", "LNA2", "LNA1", "LNA1_PLUS_LNA2"
+	};
 
 	buf = kzalloc(size, GFP_KERNEL);
 	if (buf == NULL)
@@ -716,10 +717,13 @@ static ssize_t read_file_queues(struct file *file, char __user *user_buf,
 	struct ath_softc *sc = file->private_data;
 	struct ath_txq *txq;
 	char *buf;
-	unsigned int len = 0, size = 1024;
+	unsigned int len = 0;
+	const unsigned int size = 1024;
 	ssize_t retval = 0;
 	int i;
-	char *qname[4] = {"VO", "VI", "BE", "BK"};
+	static const char *qname[4] = {
+		"VO", "VI", "BE", "BK"
+	};
 
 	buf = kzalloc(size, GFP_KERNEL);
 	if (buf == NULL)
