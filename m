From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.10-rc1 4/5] dscc4: removal of unneeded casts
Date: Fri, 14 Jan 2005 01:13:18 +0100
Message-ID: <20050114001318.GD2219@electric-eye.fr.zoreil.com>
References: <20050114000732.GA28864@electric-eye.fr.zoreil.com> <20050114000941.GA2219@electric-eye.fr.zoreil.com> <20050114001054.GB2219@electric-eye.fr.zoreil.com> <20050114001212.GC2219@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20050114001212.GC2219@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Removal of unneeded casts.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/wan/dscc4.c~dscc4-030 drivers/net/wan/dscc4.c
--- linux-2.6.11-rc1/drivers/net/wan/dscc4.c~dscc4-030	2005-01-14 00:54:54.446168638 +0100
+++ linux-2.6.11-rc1-fr/drivers/net/wan/dscc4.c	2005-01-14 00:54:54.449168149 +0100
@@ -750,7 +750,7 @@ static int __devinit dscc4_init_one(stru
 	if (rc < 0)
 	        goto err_iounmap_3;
 
-	priv = (struct dscc4_pci_priv *)pci_get_drvdata(pdev);
+	priv = pci_get_drvdata(pdev);
 
 	rc = request_irq(pdev->irq, dscc4_irq, SA_SHIRQ, DRV_NAME, priv->root);
 	if (rc < 0) {
@@ -892,8 +892,7 @@ static int dscc4_found1(struct pci_dev *
 	struct dscc4_dev_priv *root;
 	int i, ret = -ENOMEM;
 
-	root = (struct dscc4_dev_priv *)
-		kmalloc(dev_per_card*sizeof(*root), GFP_KERNEL);
+	root = kmalloc(dev_per_card*sizeof(*root), GFP_KERNEL);
 	if (!root) {
 		printk(KERN_ERR "%s: can't allocate data\n", DRV_NAME);
 		goto err_out;
@@ -906,7 +905,7 @@ static int dscc4_found1(struct pci_dev *
 			goto err_free_dev;
 	}
 
-	ppriv = (struct dscc4_pci_priv *) kmalloc(sizeof(*ppriv), GFP_KERNEL);
+	ppriv = kmalloc(sizeof(*ppriv), GFP_KERNEL);
 	if (!ppriv) {
 		printk(KERN_ERR "%s: can't allocate private data\n", DRV_NAME);
 		goto err_free_dev;

_
