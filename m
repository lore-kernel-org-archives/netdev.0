From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 2/9][ATM]: convert from pci_module_init to pci_register_driver
Date: Mon, 07 Mar 2005 17:04:00 -0500
Message-ID: <200503072204.j27M41BT020891@ginger.cmf.nrl.navy.mil>
Cc: davem@redhat.com
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/07 14:23:39-05:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: convert from pci_module_init to pci_register_driver
#   
#   Signed-off-by: Christophe Lucas <c.lucas@ifrance.com>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/zatm.c
#   2005/03/07 14:23:21-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: convert from pci_module_init to pci_register_driver
#   
#   Signed-off-by: Christophe Lucas <c.lucas@ifrance.com>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/nicstar.c
#   2005/03/07 14:23:21-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: convert from pci_module_init to pci_register_driver
#   
#   Signed-off-by: Christophe Lucas <c.lucas@ifrance.com>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/lanai.c
#   2005/03/07 14:23:21-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: convert from pci_module_init to pci_register_driver
#   
#   Signed-off-by: Christophe Lucas <c.lucas@ifrance.com>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/iphase.c
#   2005/03/07 14:23:21-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: convert from pci_module_init to pci_register_driver
#   
#   Signed-off-by: Christophe Lucas <c.lucas@ifrance.com>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/horizon.c
#   2005/03/07 14:23:21-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: convert from pci_module_init to pci_register_driver
#   
#   Signed-off-by: Christophe Lucas <c.lucas@ifrance.com>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/he.c
#   2005/03/07 14:23:21-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: convert from pci_module_init to pci_register_driver
#   
#   Signed-off-by: Christophe Lucas <c.lucas@ifrance.com>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/firestream.c
#   2005/03/07 14:23:21-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: convert from pci_module_init to pci_register_driver
#   
#   Signed-off-by: Christophe Lucas <c.lucas@ifrance.com>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
# drivers/atm/ambassador.c
#   2005/03/07 14:23:21-05:00 chas@relax.cmf.nrl.navy.mil +1 -1
#   [ATM]: convert from pci_module_init to pci_register_driver
#   
#   Signed-off-by: Christophe Lucas <c.lucas@ifrance.com>
#   Signed-off-by: Domen Puncer <domen@coderock.org>
#   Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
# 
diff -Nru a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
--- a/drivers/atm/ambassador.c	2005-03-07 15:33:10 -05:00
+++ b/drivers/atm/ambassador.c	2005-03-07 15:33:10 -05:00
@@ -2447,7 +2447,7 @@
   amb_check_args();
   
   // get the juice
-  return pci_module_init(&amb_driver);
+  return pci_register_driver(&amb_driver);
 }
 
 /********** module exit **********/
diff -Nru a/drivers/atm/firestream.c b/drivers/atm/firestream.c
--- a/drivers/atm/firestream.c	2005-03-07 15:33:10 -05:00
+++ b/drivers/atm/firestream.c	2005-03-07 15:33:10 -05:00
@@ -2034,7 +2034,7 @@
 	int error;
 
 	func_enter ();
-	error = pci_module_init(&firestream_driver);
+	error = pci_register_driver(&firestream_driver);
 	func_exit ();
 	return error;
 }
diff -Nru a/drivers/atm/he.c b/drivers/atm/he.c
--- a/drivers/atm/he.c	2005-03-07 15:33:10 -05:00
+++ b/drivers/atm/he.c	2005-03-07 15:33:10 -05:00
@@ -3079,7 +3079,7 @@
 
 static int __init he_init(void)
 {
-	return pci_module_init(&he_driver);
+	return pci_register_driver(&he_driver);
 }
 
 static void __exit he_cleanup(void)
diff -Nru a/drivers/atm/horizon.c b/drivers/atm/horizon.c
--- a/drivers/atm/horizon.c	2005-03-07 15:33:10 -05:00
+++ b/drivers/atm/horizon.c	2005-03-07 15:33:10 -05:00
@@ -2938,7 +2938,7 @@
   hrz_check_args();
   
   // get the juice
-  return pci_module_init(&hrz_driver);
+  return pci_register_driver(&hrz_driver);
 }
 
 /********** module exit **********/
diff -Nru a/drivers/atm/iphase.c b/drivers/atm/iphase.c
--- a/drivers/atm/iphase.c	2005-03-07 15:33:10 -05:00
+++ b/drivers/atm/iphase.c	2005-03-07 15:33:10 -05:00
@@ -3274,7 +3274,7 @@
 {
 	int ret;
 
-	ret = pci_module_init(&ia_driver);
+	ret = pci_register_driver(&ia_driver);
 	if (ret >= 0) {
 		ia_timer.expires = jiffies + 3*HZ;
 		add_timer(&ia_timer); 
diff -Nru a/drivers/atm/lanai.c b/drivers/atm/lanai.c
--- a/drivers/atm/lanai.c	2005-03-07 15:33:10 -05:00
+++ b/drivers/atm/lanai.c	2005-03-07 15:33:10 -05:00
@@ -2746,7 +2746,7 @@
 {
 	int x;
 
-	x = pci_module_init(&lanai_driver);
+	x = pci_register_driver(&lanai_driver);
 	if (x != 0)
 		printk(KERN_ERR DEV_LABEL ": no adapter found\n");
 	return x;
diff -Nru a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
--- a/drivers/atm/nicstar.c	2005-03-07 15:33:10 -05:00
+++ b/drivers/atm/nicstar.c	2005-03-07 15:33:10 -05:00
@@ -381,7 +381,7 @@
 
    XPRINTK("nicstar: nicstar_init() called.\n");
 
-   error = pci_module_init(&nicstar_driver);
+   error = pci_register_driver(&nicstar_driver);
    
    TXPRINTK("nicstar: TX debug enabled.\n");
    RXPRINTK("nicstar: RX debug enabled.\n");
diff -Nru a/drivers/atm/zatm.c b/drivers/atm/zatm.c
--- a/drivers/atm/zatm.c	2005-03-07 15:33:10 -05:00
+++ b/drivers/atm/zatm.c	2005-03-07 15:33:10 -05:00
@@ -1639,7 +1639,7 @@
 
 static int __init zatm_init_module(void)
 {
-	return pci_module_init(&zatm_driver);
+	return pci_register_driver(&zatm_driver);
 }
 
 module_init(zatm_init_module);
