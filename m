From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 7/9][ATM]: [iphase] use after free, found by Coverity tool
Date: Mon, 07 Mar 2005 17:07:32 -0500
Message-ID: <200503072207.j27M7WNh021002@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/07 15:16:16-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [iphase] use after free, found by Coverity tool
#   
#   Signed-off-by: Alexander Nyberg <alexn@dsv.su.se>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/iphase.c
#   2005/03/07 15:15:58-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: [iphase] use after free, found by Coverity tool
#   
#   Signed-off-by: Alexander Nyberg <alexn@dsv.su.se>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/iphase.c b/drivers/atm/iphase.c
--- a/drivers/atm/iphase.c	2005-03-07 15:36:19 -05:00
+++ b/drivers/atm/iphase.c	2005-03-07 15:36:19 -05:00
@@ -3244,8 +3244,8 @@
 	iadev_count--;
 	ia_dev[iadev_count] = NULL;
 	_ia_dev[iadev_count] = NULL;
+	IF_EVENT(printk("deregistering iav at (itf:%d)\n", dev->number);)
 	atm_dev_deregister(dev);
-	IF_EVENT(printk("iav deregistered at (itf:%d)\n", dev->number);)
 
       	iounmap(iadev->base);  
 	pci_disable_device(pdev);
