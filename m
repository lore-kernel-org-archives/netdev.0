From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 2/3] e100: Sort Device IDs
Date: Thu, 6 Jan 2005 17:02:15 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061410030.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>

diff -up net-drivers-2.6/drivers/net/e100.c net-drivers-2.6/drivers/net/e100.c.new
--- net-drivers-2.6/drivers/net/e100.c	2004-12-02 10:09:34.000000000 -0800
+++ net-drivers-2.6/drivers/net/e100.c.new	2004-12-02 10:09:36.000000000 -0800
@@ -200,6 +200,7 @@ static struct pci_device_id e100_id_tabl
 	INTEL_8255X_ETHERNET_DEVICE(0x1055, 5),
 	INTEL_8255X_ETHERNET_DEVICE(0x1056, 5),
 	INTEL_8255X_ETHERNET_DEVICE(0x1057, 5),
+	INTEL_8255X_ETHERNET_DEVICE(0x1059, 0),
 	INTEL_8255X_ETHERNET_DEVICE(0x1064, 6),
 	INTEL_8255X_ETHERNET_DEVICE(0x1065, 6),
 	INTEL_8255X_ETHERNET_DEVICE(0x1066, 6),
@@ -208,7 +209,6 @@ static struct pci_device_id e100_id_tabl
 	INTEL_8255X_ETHERNET_DEVICE(0x1069, 6),
 	INTEL_8255X_ETHERNET_DEVICE(0x106A, 6),
 	INTEL_8255X_ETHERNET_DEVICE(0x106B, 6),
-	INTEL_8255X_ETHERNET_DEVICE(0x1059, 0),
 	INTEL_8255X_ETHERNET_DEVICE(0x1209, 0),
 	INTEL_8255X_ETHERNET_DEVICE(0x1229, 0),
 	INTEL_8255X_ETHERNET_DEVICE(0x2449, 2),
