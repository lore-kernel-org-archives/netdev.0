From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.8-rc1] pci.ids update for Prism GT
	devices
Date: Thu, 15 Jul 2004 17:19:08 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200407151719.09061.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_sBq9AFG0NM8Y7f4"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_sBq9AFG0NM8Y7f4
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-07-15 Margit Schubert-While <margitsw@t-online.de>

* Update pci.ids for known Prism54 GT devices.

Jeff, this has been passed to the pci.ids project.
I am not sure if this should go through you/netdev.
(Loosely related)
If not please pass on to LKML.

The one replacement of 17cf:0014 is correct; the
devices originate with Z-Com; others are clones/repackages.
(of which there are several)

Margit











--Boundary-00=_sBq9AFG0NM8Y7f4
Content-Type: text/x-diff;
  charset="us-ascii";
  name="kernpciids.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="kernpciids.patch"

diff -Naur linux-2.6.8-01/drivers/pci/pci.ids linux-2.6.8-02/drivers/pci/pci.ids
--- linux-2.6.8-01/drivers/pci/pci.ids	2004-07-12 19:31:57.000000000 +0200
+++ linux-2.6.8-02/drivers/pci/pci.ids	2004-07-15 07:32:33.000000000 +0200
@@ -4905,12 +4905,24 @@
 	3873  Prism 2.5 Wavelan chipset
 		1186 3501  DWL-520 Wireless PCI Adapter
 		1186 3700  DWL-520 Wireless PCI Adapter, Rev E1
+		1385 4105  MA311 802.11b wireless adapter
 		1668 0414  HWP01170-01 802.11b PCI Wireless Adapter
 		16a5 1601  AIR.mate PC-400 PCI Wireless LAN Adapter
 		1737 3874  WMP11 Wireless 802.11b PCI Adapter
 		8086 2513  Wireless 802.11b MiniPCI Adapter
+	3886  Intersil ISL3886 [Prism Javelin/Prism Xbow]
+		17cf 0037  Z-Com XG-901 and clones Wireless Adapter
 	3890  Intersil ISL3890 [Prism GT/Prism Duette]
-		17cf 0014  Ovislink WL-5400PCM, Prism GT
+		10b8 2802  SMC2802W Wireless PCI Adapter
+		10b8 2835  SMC2835W Wireless Cardbus Adapter
+		10b8 a835  SMC2835W V2 Wireless Cardbus Adapter
+		1113 ee03  SMC2802W V2 Wireless PCI Adapter
+		1186 3202  D-Link DWL-G650 A1 Wireless Adapter
+		1259 c104  Corega CG-WLCB54GT Wireless Adapter
+		1385 4800  Netgear WG511 Wireless Adapter
+		16a5 1605  ALLNET ALL0271 Wireless PCI Adapter
+		17cf 0014  Z-Com XG-600 and clones Wireless Adapter
+		17cf 0020  Z-Com XG-900 and clones Wireless Adapter
 	8130  HMP8130 NTSC/PAL Video Decoder
 	8131  HMP8131 NTSC/PAL Video Decoder
 1261  Matsushita-Kotobuki Electronics Industries, Ltd.

--Boundary-00=_sBq9AFG0NM8Y7f4
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_sBq9AFG0NM8Y7f4--
