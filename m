From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [PATCH 2.6] pci.ids for e1000
Date: Thu, 11 Sep 2003 18:11:16 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309111808100.8763-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Add missing Device and Subdevice IDs for devices support by e1000.  I've 
updated pciids.sourceforge.net, but those changes don't seem to be getting 
approved/pushed out.

----------------

--- linux-2.6.0-test5/drivers/pci/pci.ids	2003-09-08 12:50:06.000000000 -0700
+++ linux-2.6.0-test5/drivers/pci/pci.ids.new	2003-09-11 17:45:32.000000000 -0700
@@ -6228,28 +6228,73 @@
 		8086 1004  PRO/1000 T Server Adapter
 		8086 2004  PRO/1000 T Server Adapter
 	1008  82544EI Gigabit Ethernet Controller (Copper)
+		1014 0269  iSeries 1000/100/10 Ethernet Adapter
+		1028 011c  PRO/1000 XT Network Connection
 		8086 1107  PRO/1000 XT Server Adapter
 		8086 2107  PRO/1000 XT Server Adapter
 		8086 2110  PRO/1000 XT Server Adapter
+		8086 3108  PRO/1000 XT Network Connection
 	1009  82544EI Gigabit Ethernet Controller (Fiber)
+		1014 0268  iSeries Gigabit Ethernet Adapter
 		8086 1109  PRO/1000 XF Server Adapter
 		8086 2109  PRO/1000 XF Server Adapter
 	100c  82544GC Gigabit Ethernet Controller (Copper)
 		8086 1112  PRO/1000 T Desktop Adapter
 		8086 2112  PRO/1000 T Desktop Adapter
 	100d  82544GC Gigabit Ethernet Controller (LOM)
+		1028 0123  PRO/1000 XT Network Connection
+		107b 891f  82544GC Based Network Connection
+		8086 110d  82544GC Based Network Connection
 	100e  82540EM Gigabit Ethernet Controller
+		1014 0265  PRO/1000 MT Network Connection
+		1014 0267  PRO/1000 MT Network Connection
+		1014 026a  PRO/1000 MT Network Connection
+		107b 8920  PRO/1000 MT Desktop Adapter 
 		8086 001e  PRO/1000 MT Desktop Adapter
 		8086 002e  PRO/1000 MT Desktop Adapter
 	100f  82545EM Gigabit Ethernet Controller (Copper)
+		1014 0269  iSeries 1000/100/10 Ethernet Adapter
+		1014 028e  PRO/1000 MT Network Connection
+		8086 1000  PRO/1000 MT Network Connection
 		8086 1001  PRO/1000 MT Server Adapter
 	1010  82546EB Gigabit Ethernet Controller (Copper)
+		1014 027c  PRO/1000 MT Dual Port Network Adapter
 		8086 1011  PRO/1000 MT Dual Port Server Adapter
+		8086 101a  PRO/1000 MT Dual Port Network Adapter
 	1011  82545EM Gigabit Ethernet Controller (Fiber)
+		1014 0268  iSeries Gigabit Ethernet Adapter
 		8086 1002  PRO/1000 MF Server Adapter
+		8086 1003  PRO/1000 MF Server Adapter (LX)
 	1012  82546EB Gigabit Ethernet Controller (Fiber)
 		8086 1012  PRO/1000 MF Dual Port Server Adapter
 	1015  82540EM Gigabit Ethernet Controller (LOM)
+	1016  82540EP Gigabit Ethernet Controller
+		1014 052C  PRO/1000 MT Mobile Connection
+		1179 0001  PRO/1000 MT Mobile Connection
+		8086 1016  PRO/1000 MT Mobile Connection
+	1017  82540EP Gigabit Ethernet Controller
+		8086 1017  PR0/1000 MT Desktop Connection
+	1018  82541EP Gigabit Ethernet Controller
+		8086 1018  PRO/1000 MT Desktop Adapter
+	1019  82547EI Gigabit Ethernet Controller
+		8086 1019  PRO/1000 CT Desktop Adapter
+	101d  82546EB Gigabit Ethernet Controller
+		8086 1000  PRO/1000 MT Quad Port Server Adapter
+	101e  82540EP Gigabit Ethernet Controller
+		1014 0549  PRO/1000 MT Mobile Connection
+		8086 101e  PRO/1000 MT Mobile Connection
+	1026  82545GM Gigabit Ethernet Controller
+		8086 1000  PRO/1000 MT Server Connection
+		8086 1001  PRO/1000 MT Server Adapter
+		8086 1002  PRO/1000 MT Server Adapter
+		8086 1026  PRO/1000 MT Server Connection
+	1027  82545GM Gigabit Ethernet Controller
+		8086 1001  PRO/1000 MF Server Adapter(LX)
+		8086 1002  PRO/1000 MF Server Adapter(LX)
+		8086 1003  PRO/1000 MF Server Adapter(LX)
+		8086 1027  PRO/1000 MF Server Adapter
+	1028  82545GM Gigabit Ethernet Controller
+		8086 1028  PRO/1000 MB Server Adapter
 	1029  82559 Ethernet Controller
 	1030  82559 InBusiness 10/100
 	1031  82801CAM (ICH3) PRO/100 VE (LOM) Ethernet Controller
@@ -6279,6 +6324,31 @@
 		8086 a01f  PRO/10GbE LR Server Adapter
 		8086 a11f  PRO/10GbE LR Server Adapter
 	1059  82551QM Ethernet Controller
+	1075  82547EI Gigabit Ethernet Controller
+		8086 0075  PRO/1000 CT Network Connection
+		8086 1075  PRO/1000 CT Network Connection
+	1076  82541EI Gigabit Ethernet Controller
+		8086 0076  PRO/1000 MT Network Connection
+		8086 1076  PRO/1000 MT Network Connection
+		8086 1176  PRO/1000 MT Desktop Adapter
+		8086 1276  PRO/1000 MT Network Adapter
+	1077  82541EI Gigabit Ethernet Controller
+		1179 0001  PRO/1000 MT Mobile Connection
+		8086 0077  PRO/1000 MT Mobile Connection
+		8086 1077  PRO/1000 MT Mobile Connection
+	1078  82541EI Gigabit Ethernet Controller
+		8086 1078  PRO/1000 MT Network Connection
+	1079  82546EB Gigabit Ethernet Controller
+		8086 0079  PRO/1000 MT Dual Port Network Connection
+		8086 1079  PRO/1000 MT Dual Port Network Connection
+		8086 1179  PRO/1000 MT Dual Port Server Adapter
+		8086 117a  PRO/1000 MT Dual Port Server Adapter
+	107a  82546EB Gigabit Ethernet Controller
+		8086 107a  PRO/1000 MF Dual Port Server Adapter
+		8086 127a  PRO/1000 MF Dual Port Server Adapter
+	107b  82546EB Gigabit Ethernet Controller
+		8086 007b  PRO/1000 MB Dual Port Server Connection
+		8086 107b  PRO/1000 MB Dual Port Server Connection
 	1130  82815 815 Chipset Host Bridge and Memory Controller Hub
 		1025 1016  Travelmate 612 TX
 		1043 8027  TUSL2-C Mainboard
