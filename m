From: Bill Pemberton <wfp5p@virginia.edu>
Subject: [PATCH 039/493] atm: remove use of __devexit_p
Date: Mon, 19 Nov 2012 13:19:48 -0500
Message-ID: <1353349642-3677-39-git-send-email-wfp5p@virginia.edu>
References: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from viridian.itc.Virginia.EDU ([128.143.12.139]:41579 "EHLO
	viridian.itc.virginia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032Ab2KSSh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 13:37:59 -0500
In-Reply-To: <1353349642-3677-1-git-send-email-wfp5p@virginia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CONFIG_HOTPLUG is going away as an option so __devexit_p is no longer
needed.

Signed-off-by: Bill Pemberton <wfp5p@virginia.edu>
Cc: Chas Williams <chas@cmf.nrl.navy.mil> 
Cc: linux-atm-general@lists.sourceforge.net 
Cc: netdev@vger.kernel.org 
---
 drivers/atm/ambassador.c | 2 +-
 drivers/atm/eni.c        | 2 +-
 drivers/atm/firestream.c | 2 +-
 drivers/atm/he.c         | 2 +-
 drivers/atm/horizon.c    | 2 +-
 drivers/atm/iphase.c     | 2 +-
 drivers/atm/nicstar.c    | 2 +-
 7 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
index 89b30f3..9e9df4f 100644
--- a/drivers/atm/ambassador.c
+++ b/drivers/atm/ambassador.c
@@ -2378,7 +2378,7 @@ MODULE_DEVICE_TABLE(pci, amb_pci_tbl);
 static struct pci_driver amb_driver = {
 	.name =		"amb",
 	.probe =	amb_probe,
-	.remove =	__devexit_p(amb_remove_one),
+	.remove =	amb_remove_one,
 	.id_table =	amb_pci_tbl,
 };
 
diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 81e44f7..2dd26f9 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -2310,7 +2310,7 @@ static struct pci_driver eni_driver = {
 	.name		= DEV_LABEL,
 	.id_table	= eni_pci_tbl,
 	.probe		= eni_init_one,
-	.remove		= __devexit_p(eni_remove_one),
+	.remove		= eni_remove_one,
 };
 
 
diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index 86fed1b..5aae55d 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -2038,7 +2038,7 @@ static struct pci_driver firestream_driver = {
 	.name		= "firestream",
 	.id_table	= firestream_pci_tbl,
 	.probe		= firestream_init_one,
-	.remove		= __devexit_p(firestream_remove_one),
+	.remove		= firestream_remove_one,
 };
 
 static int __init firestream_init_module (void)
diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index b182c2f..c372814 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -2879,7 +2879,7 @@ MODULE_DEVICE_TABLE(pci, he_pci_tbl);
 static struct pci_driver he_driver = {
 	.name =		"he",
 	.probe =	he_init_one,
-	.remove =	__devexit_p(he_remove_one),
+	.remove =	he_remove_one,
 	.id_table =	he_pci_tbl,
 };
 
diff --git a/drivers/atm/horizon.c b/drivers/atm/horizon.c
index 7d01c2a..9d98421 100644
--- a/drivers/atm/horizon.c
+++ b/drivers/atm/horizon.c
@@ -2901,7 +2901,7 @@ MODULE_DEVICE_TABLE(pci, hrz_pci_tbl);
 static struct pci_driver hrz_driver = {
 	.name =		"horizon",
 	.probe =	hrz_probe,
-	.remove =	__devexit_p(hrz_remove_one),
+	.remove =	hrz_remove_one,
 	.id_table =	hrz_pci_tbl,
 };
 
diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 96cce6d..23b3627 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -3270,7 +3270,7 @@ static struct pci_driver ia_driver = {
 	.name =         DEV_LABEL,
 	.id_table =     ia_pci_tbl,
 	.probe =        ia_init_one,
-	.remove =       __devexit_p(ia_remove_one),
+	.remove =       ia_remove_one,
 };
 
 static int __init ia_module_init(void)
diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 1c70c45..cd4b90b 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -273,7 +273,7 @@ static struct pci_driver nicstar_driver = {
 	.name = "nicstar",
 	.id_table = nicstar_pci_tbl,
 	.probe = nicstar_init_one,
-	.remove = __devexit_p(nicstar_remove_one),
+	.remove = nicstar_remove_one,
 };
 
 static int __init nicstar_init(void)
-- 
1.8.0
