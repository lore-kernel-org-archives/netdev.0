From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Pull request for 'upstream' branch
Date: Thu, 15 Jun 2006 23:21:09 +0200
Message-ID: <20060615212109.GA6817@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, palopezv@gmail.com, nacc@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:44703 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1031425AbWFOVVS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 17:21:18 -0400
To: jeff@garik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please pull from branch 'upstream' to get the change below:

git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git

Patch applies both to jeff#upstream and jeff#upstream-fixes

Shortlog
--------

Pedro Alejandro L=F3pez-Valencia:
      sundance: PCI ID for ip100a


Patch
-----

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index 61eec46..f13b2a1 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -94,11 +94,13 @@
 	Version LK1.10 (Philippe De Muyter phdm@macqel.be):
 	- Make 'unblock interface after Tx underrun' work
=20
+	Version LK1.11 (Pedro Alejandro Lopez-Valencia palopezv at gmail.com)=
:
+	- Add support for IC Plus Corporation IP100A chipset
 */
=20
 #define DRV_NAME	"sundance"
-#define DRV_VERSION	"1.01+LK1.10"
-#define DRV_RELDATE	"28-Oct-2005"
+#define DRV_VERSION	"1.01+LK1.11"
+#define DRV_RELDATE	"14-Jun-2006"
=20
=20
 /* The user-configurable values.
@@ -287,6 +289,7 @@ static struct pci_device_id sundance_pci
 	{0x1186, 0x1002, 0x1186, 0x1040, 0, 0, 3},
 	{0x1186, 0x1002, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 4},
 	{0x13F0, 0x0201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 5},
+	{0x13F0, 0x0200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 6},
 	{0,}
 };
 MODULE_DEVICE_TABLE(pci, sundance_pci_tbl);
@@ -305,6 +308,7 @@ static const struct pci_id_info pci_id_t
 	{"D-Link DFE-530TXS FAST Ethernet Adapter"},
 	{"D-Link DL10050-based FAST Ethernet Adapter"},
 	{"Sundance Technology Alta"},
+	{"IC Plus Corporation IP100A FAST Ethernet Adapter"},
 	{NULL,},			/* 0 terminated list. */
 };
=20

