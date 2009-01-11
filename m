From: Jan Engelhardt <jengelh@medozas.de>
Subject: net: constify VFTs
Date: Sun, 11 Jan 2009 23:44:28 +0100 (CET)
Message-ID: <alpine.LSU.2.00.0901112343330.20350@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:39459 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384AbZAKWof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 17:44:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

parent 2b9b79b49bef5f00559bb275400ae024434db780 (v2.6.29-rc1-5-g2b9b79b)
commit 5b692aa02e68392e41a5b341e5c965b382fda948
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sun Jan 11 23:43:38 2009 +0100

net: constify VFTs

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 drivers/net/bonding/bond_main.c         |    2 +-
 drivers/net/hamradio/bpqether.c         |    2 +-
 drivers/net/hamradio/scc.c              |    2 +-
 drivers/net/hamradio/yam.c              |    2 +-
 drivers/net/pppoe.c                     |    2 +-
 drivers/net/pppol2tp.c                  |    4 ++--
 drivers/net/wireless/ath5k/debug.c      |    2 +-
 drivers/net/wireless/libertas/debugfs.c |   14 +++++++-------
 drivers/net/wireless/strip.c            |    2 +-
 9 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9fb3883..21bce2c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3369,7 +3369,7 @@ static int bond_info_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-static struct seq_operations bond_info_seq_ops = {
+static const struct seq_operations bond_info_seq_ops = {
 	.start = bond_info_seq_start,
 	.next  = bond_info_seq_next,
 	.stop  = bond_info_seq_stop,
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 46f8f33..d7b2cc2 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -454,7 +454,7 @@ static int bpq_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-static struct seq_operations bpq_seqops = {
+static const struct seq_operations bpq_seqops = {
 	.start = bpq_seq_start,
 	.next = bpq_seq_next,
 	.stop = bpq_seq_stop,
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index c011af7..4bc795b 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -2073,7 +2073,7 @@ static int scc_net_seq_show(struct seq_file *seq, void *v)
         return 0;
 }
 
-static struct seq_operations scc_net_seq_ops = {
+static const struct seq_operations scc_net_seq_ops = {
 	.start  = scc_net_seq_start,
 	.next   = scc_net_seq_next,
 	.stop   = scc_net_seq_stop,
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 5407f74..7127751 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -787,7 +787,7 @@ static int yam_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-static struct seq_operations yam_seqops = {
+static const struct seq_operations yam_seqops = {
 	.start = yam_seq_start,
 	.next = yam_seq_next,
 	.stop = yam_seq_stop,
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index c22b305..5efc3d1 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -1030,7 +1030,7 @@ static void pppoe_seq_stop(struct seq_file *seq, void *v)
 	read_unlock_bh(&pppoe_hash_lock);
 }
 
-static struct seq_operations pppoe_seq_ops = {
+static const struct seq_operations pppoe_seq_ops = {
 	.start		= pppoe_seq_start,
 	.next		= pppoe_seq_next,
 	.stop		= pppoe_seq_stop,
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index f1a9467..635dd5f 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -2517,7 +2517,7 @@ out:
 	return 0;
 }
 
-static struct seq_operations pppol2tp_seq_ops = {
+static const struct seq_operations pppol2tp_seq_ops = {
 	.start		= pppol2tp_seq_start,
 	.next		= pppol2tp_seq_next,
 	.stop		= pppol2tp_seq_stop,
@@ -2565,7 +2565,7 @@ static int pppol2tp_proc_release(struct inode *inode, struct file *file)
 	return seq_release(inode, file);
 }
 
-static struct file_operations pppol2tp_proc_fops = {
+static const struct file_operations pppol2tp_proc_fops = {
 	.owner		= THIS_MODULE,
 	.open		= pppol2tp_proc_open,
 	.read		= seq_read,
diff --git a/drivers/net/wireless/ath5k/debug.c b/drivers/net/wireless/ath5k/debug.c
index ccaeb5c..d281b6e 100644
--- a/drivers/net/wireless/ath5k/debug.c
+++ b/drivers/net/wireless/ath5k/debug.c
@@ -165,7 +165,7 @@ static int reg_show(struct seq_file *seq, void *p)
 	return 0;
 }
 
-static struct seq_operations register_seq_ops = {
+static const struct seq_operations register_seq_ops = {
 	.start = reg_start,
 	.next  = reg_next,
 	.stop  = reg_stop,
diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index ec4efd7..50e28a0 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -629,7 +629,7 @@ static ssize_t lbs_rdrf_write(struct file *file,
 		res = -EFAULT;
 		goto out_unlock;
 	}
-	priv->rf_offset = simple_strtoul((char *)buf, NULL, 16);
+	priv->rf_offset = simple_strtoul(buf, NULL, 16);
 	res = count;
 out_unlock:
 	free_page(addr);
@@ -680,12 +680,12 @@ out_unlock:
 }
 
 struct lbs_debugfs_files {
-	char *name;
+	const char *name;
 	int perm;
 	struct file_operations fops;
 };
 
-static struct lbs_debugfs_files debugfs_files[] = {
+static const struct lbs_debugfs_files debugfs_files[] = {
 	{ "info", 0444, FOPS(lbs_dev_info, write_file_dummy), },
 	{ "getscantable", 0444, FOPS(lbs_getscantable,
 					write_file_dummy), },
@@ -693,7 +693,7 @@ static struct lbs_debugfs_files debugfs_files[] = {
 				lbs_sleepparams_write), },
 };
 
-static struct lbs_debugfs_files debugfs_events_files[] = {
+static const struct lbs_debugfs_files debugfs_events_files[] = {
 	{"low_rssi", 0644, FOPS(lbs_lowrssi_read,
 				lbs_lowrssi_write), },
 	{"low_snr", 0644, FOPS(lbs_lowsnr_read,
@@ -708,7 +708,7 @@ static struct lbs_debugfs_files debugfs_events_files[] = {
 				lbs_highsnr_write), },
 };
 
-static struct lbs_debugfs_files debugfs_regs_files[] = {
+static const struct lbs_debugfs_files debugfs_regs_files[] = {
 	{"rdmac", 0644, FOPS(lbs_rdmac_read, lbs_rdmac_write), },
 	{"wrmac", 0600, FOPS(NULL, lbs_wrmac_write), },
 	{"rdbbp", 0644, FOPS(lbs_rdbbp_read, lbs_rdbbp_write), },
@@ -735,7 +735,7 @@ void lbs_debugfs_remove(void)
 void lbs_debugfs_init_one(struct lbs_private *priv, struct net_device *dev)
 {
 	int i;
-	struct lbs_debugfs_files *files;
+	const struct lbs_debugfs_files *files;
 	if (!lbs_dir)
 		goto exit;
 
@@ -938,7 +938,7 @@ static ssize_t lbs_debugfs_write(struct file *f, const char __user *buf,
 	return (ssize_t)cnt;
 }
 
-static struct file_operations lbs_debug_fops = {
+static const struct file_operations lbs_debug_fops = {
 	.owner = THIS_MODULE,
 	.open = open_file_generic,
 	.write = lbs_debugfs_write,
diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index 7015f24..d6bf8d2 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -1125,7 +1125,7 @@ static int strip_seq_show(struct seq_file *seq, void *v)
 }
 
 
-static struct seq_operations strip_seq_ops = {
+static const struct seq_operations strip_seq_ops = {
 	.start = strip_seq_start,
 	.next  = strip_seq_next,
 	.stop  = strip_seq_stop,
-- 
# Created with git-export-patch

