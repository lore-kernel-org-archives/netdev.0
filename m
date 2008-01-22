From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: [PATCH] NET: constify data and function pointer tables
Date: Tue, 22 Jan 2008 20:47:32 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801222046170.5722@fbirervta.pbzchgretzou.qr>
References: <54038cd4f87a03884e4f59f8f3697889dfb63c54.1201030614.git.jengelh@computergmbh.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sovereign.computergmbh.de ([85.214.69.204]:33210 "EHLO
	sovereign.computergmbh.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751309AbYAVTrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 14:47:33 -0500
In-Reply-To: <54038cd4f87a03884e4f59f8f3697889dfb63c54.1201030614.git.jengelh@computergmbh.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jan Engelhardt <jengelh@computergmbh.de>
---
 drivers/net/bonding/bond_main.c         |    2 +-
 drivers/net/hamradio/bpqether.c         |    2 +-
 drivers/net/hamradio/scc.c              |    2 +-
 drivers/net/hamradio/yam.c              |    2 +-
 drivers/net/ibmveth.c                   |    2 +-
 drivers/net/pppoe.c                     |    2 +-
 drivers/net/pppol2tp.c                  |    4 ++--
 drivers/net/wireless/libertas/debugfs.c |   14 +++++++-------
 drivers/net/wireless/strip.c            |    2 +-
 9 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b0b2603..ca18eaa 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3252,7 +3252,7 @@ static int bond_info_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-static struct seq_operations bond_info_seq_ops = {
+static const struct seq_operations bond_info_seq_ops = {
 	.start = bond_info_seq_start,
 	.next  = bond_info_seq_next,
 	.stop  = bond_info_seq_stop,
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index 5ddf8b0..a93ad86 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -442,7 +442,7 @@ static int bpq_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-static struct seq_operations bpq_seqops = {
+static const struct seq_operations bpq_seqops = {
 	.start = bpq_seq_start,
 	.next = bpq_seq_next,
 	.stop = bpq_seq_stop,
diff --git a/drivers/net/hamradio/scc.c b/drivers/net/hamradio/scc.c
index 353d13e..6f1b449 100644
--- a/drivers/net/hamradio/scc.c
+++ b/drivers/net/hamradio/scc.c
@@ -2071,7 +2071,7 @@ static int scc_net_seq_show(struct seq_file *seq, void *v)
         return 0;
 }
 
-static struct seq_operations scc_net_seq_ops = {
+static const struct seq_operations scc_net_seq_ops = {
 	.start  = scc_net_seq_start,
 	.next   = scc_net_seq_next,
 	.stop   = scc_net_seq_stop,
diff --git a/drivers/net/hamradio/yam.c b/drivers/net/hamradio/yam.c
index 1c94286..797f7a5 100644
--- a/drivers/net/hamradio/yam.c
+++ b/drivers/net/hamradio/yam.c
@@ -788,7 +788,7 @@ static int yam_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-static struct seq_operations yam_seqops = {
+static const struct seq_operations yam_seqops = {
 	.start = yam_seq_start,
 	.next = yam_seq_next,
 	.stop = yam_seq_stop,
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 7d7758f..32800e2 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -1300,7 +1300,7 @@ static int ibmveth_seq_show(struct seq_file *seq, void *v)
 
 	return 0;
 }
-static struct seq_operations ibmveth_seq_ops = {
+static const struct seq_operations ibmveth_seq_ops = {
 	.start = ibmveth_seq_start,
 	.next  = ibmveth_seq_next,
 	.stop  = ibmveth_seq_stop,
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index a005d8f..a38e636 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -1026,7 +1026,7 @@ static void pppoe_seq_stop(struct seq_file *seq, void *v)
 	read_unlock_bh(&pppoe_hash_lock);
 }
 
-static struct seq_operations pppoe_seq_ops = {
+static const struct seq_operations pppoe_seq_ops = {
 	.start		= pppoe_seq_start,
 	.next		= pppoe_seq_next,
 	.stop		= pppoe_seq_stop,
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index a7556cd..a8793b3 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -2355,7 +2355,7 @@ out:
 	return 0;
 }
 
-static struct seq_operations pppol2tp_seq_ops = {
+static const struct seq_operations pppol2tp_seq_ops = {
 	.start		= pppol2tp_seq_start,
 	.next		= pppol2tp_seq_next,
 	.stop		= pppol2tp_seq_stop,
@@ -2403,7 +2403,7 @@ static int pppol2tp_proc_release(struct inode *inode, struct file *file)
 	return seq_release(inode, file);
 }
 
-static struct file_operations pppol2tp_proc_fops = {
+static const struct file_operations pppol2tp_proc_fops = {
 	.owner		= THIS_MODULE,
 	.open		= pppol2tp_proc_open,
 	.read		= seq_read,
diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index 0bda0b5..765c542 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -1569,7 +1569,7 @@ static ssize_t libertas_rdrf_write(struct file *file,
 		res = -EFAULT;
 		goto out_unlock;
 	}
-	priv->rf_offset = simple_strtoul((char *)buf, NULL, 16);
+	priv->rf_offset = simple_strtoul(buf, NULL, 16);
 	res = count;
 out_unlock:
 	free_page(addr);
@@ -1620,12 +1620,12 @@ out_unlock:
 }
 
 struct libertas_debugfs_files {
-	char *name;
+	const char *name;
 	int perm;
 	struct file_operations fops;
 };
 
-static struct libertas_debugfs_files debugfs_files[] = {
+static const struct libertas_debugfs_files debugfs_files[] = {
 	{ "info", 0444, FOPS(libertas_dev_info, write_file_dummy), },
 	{ "getscantable", 0444, FOPS(libertas_getscantable,
 					write_file_dummy), },
@@ -1635,7 +1635,7 @@ static struct libertas_debugfs_files debugfs_files[] = {
 	{ "setuserscan", 0600, FOPS(NULL, libertas_setuserscan), },
 };
 
-static struct libertas_debugfs_files debugfs_events_files[] = {
+static const struct libertas_debugfs_files debugfs_events_files[] = {
 	{"low_rssi", 0644, FOPS(libertas_lowrssi_read,
 				libertas_lowrssi_write), },
 	{"low_snr", 0644, FOPS(libertas_lowsnr_read,
@@ -1650,7 +1650,7 @@ static struct libertas_debugfs_files debugfs_events_files[] = {
 				libertas_highsnr_write), },
 };
 
-static struct libertas_debugfs_files debugfs_regs_files[] = {
+static const struct libertas_debugfs_files debugfs_regs_files[] = {
 	{"rdmac", 0644, FOPS(libertas_rdmac_read, libertas_rdmac_write), },
 	{"wrmac", 0600, FOPS(NULL, libertas_wrmac_write), },
 	{"rdbbp", 0644, FOPS(libertas_rdbbp_read, libertas_rdbbp_write), },
@@ -1677,7 +1677,7 @@ void libertas_debugfs_remove(void)
 void libertas_debugfs_init_one(wlan_private *priv, struct net_device *dev)
 {
 	int i;
-	struct libertas_debugfs_files *files;
+	const struct libertas_debugfs_files *files;
 	if (!libertas_dir)
 		goto exit;
 
@@ -1881,7 +1881,7 @@ static ssize_t wlan_debugfs_write(struct file *f, const char __user *buf,
 	return (ssize_t)cnt;
 }
 
-static struct file_operations libertas_debug_fops = {
+static const struct file_operations libertas_debug_fops = {
 	.owner = THIS_MODULE,
 	.open = open_file_generic,
 	.write = wlan_debugfs_write,
diff --git a/drivers/net/wireless/strip.c b/drivers/net/wireless/strip.c
index 88efe1b..cde07c6 100644
--- a/drivers/net/wireless/strip.c
+++ b/drivers/net/wireless/strip.c
@@ -1149,7 +1149,7 @@ static int strip_seq_show(struct seq_file *seq, void *v)
 }
 
 
-static struct seq_operations strip_seq_ops = {
+static const struct seq_operations strip_seq_ops = {
 	.start = strip_seq_start,
 	.next  = strip_seq_next,
 	.stop  = strip_seq_stop,
-- 
1.5.3.4

