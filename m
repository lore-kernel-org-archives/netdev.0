From: Ralph Roesler <rroesler@syskonnect.de>
Subject: modified pci.ids file
Date: 25 Oct 2004 08:59:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1098687547.2237.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-v7QpnGEpyMiv7o+C4qKR"
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pci-ids@ucw.cz
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-v7QpnGEpyMiv7o+C4qKR
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi *,

here is the list of pci-device id that are supported
by the Marvell/SysKonnect sk98lin driver.

Is it possible for you to the new information into 
the latest 2.6 kernel tree? I made the patch against
version 2.6.10-rc1-bk2 (the most recent one while
writing this mail).

Thanks a lot for your help!

-Ralph.


-- 
The debugger isn't a substitute for good thinking.
But, in some cases, thinking isn't a substitute for
a good debugger either.
The most effective combination is good thinking
and a good debugger.

   -Steve McConnell, Code Complete

--=-v7QpnGEpyMiv7o+C4qKR
Content-Disposition: attachment; filename=patch-pci.ids-rc1-bk2
Content-Type: text/plain; name=patch-pci.ids-rc1-bk2; charset=UTF-8
Content-Transfer-Encoding: 7bit

--- drivers/pci/pci.ids	2004-10-25 09:07:38.000000000 +0100
+++ pci.ids	2004-10-25 09:14:21.000000000 +0100
@@ -2769,6 +2769,7 @@
 	7940  3c803 FDDILink UTP Controller
 	7980  3c804 FDDILink SAS Controller
 	7990  3c805 FDDILink DAS Controller
+	80eb  3c940B 10/100/1000Base-T 
 	8811  Token ring
 	9000  3c900 10BaseT [Boomerang]
 	9001  3c900 10Mbps Combo [Boomerang]
@@ -4048,7 +4049,8 @@
 	f015  NinjaSCSI-32 Melco
 1146  Force Computers
 1147  Interface Corp
-1148  Syskonnect (Schneider & Koch)
+# Formerly (Schneider $ Koch)
+1148  SysKonnect
 	4000  FDDI Adapter
 		0e11 b03b  Netelligent 100 FDDI DAS Fibre SC
 		0e11 b03c  Netelligent 100 FDDI SAS Fibre SC
@@ -4106,6 +4108,14 @@
 		1148 9521  SK-9521 10/100/1000Base-T Adapter
 	4400  SK-9Dxx Gigabit Ethernet Adapter
 	4500  SK-9Mxx Gigabit Ethernet Adapter
+	9E00  SK-9Exx 10/100/1000Base-T Adapter
+		1148 2100  SK-9E21 Server Adapter
+		1148 21D0  SK-9E21D 10/100/1000Base-T Adapter
+		1148 2200  SK-9E22 Server Adapter
+		1148 8100  SK-9E81 Server Adapter
+		1148 8200  SK-9E82 Server Adapter
+		1148 9100  SK-9E91 Server Adapter
+		1148 9200  SK-9E92 Server Adapter
 1149  Win System Corporation
 114a  VMIC
 	5579  VMIPCI-5579 (Reflective Memory Card)
@@ -4352,6 +4362,7 @@
 	3b05  DWL-G650+ CardBus PC Card
 	4000  DL2000-based Gigabit Ethernet
 	4c00  Gigabit Ethernet Adapter
+		1186 4c00  DGE-530T Gigabit Ethernet Adapter
 	8400  D-Link DWL-650+ CardBus PC Card
 1187  Advanced Technology Laboratories, Inc.
 1188  Shima Seiki Manufacturing Ltd.
@@ -4434,9 +4445,119 @@
 	0146  GT-64010/64010A System Controller
 	1fa6  Marvell W8300 802.11 Adapter
 	4320  Yukon Gigabit Ethernet 10/100/1000Base-T Adapter
+	4320  Gigabit Ethernet Controller
+		1019 0f38  Marvell 88E8001 Gigabit Ethernet Controller (ECS)
+		1019 8001  Marvell 88E8001 Gigabit Ethernet Controller (ECS)
+		1043 173c  Marvell 88E8001 Gigabit Ethernet Controller (Asus)
+		1043 811a  Marvell 88E8001 Gigabit Ethernet Controller (Asus)
+		105b 0c19  Marvell 88E8001 Gigabit Ethernet Controller (Foxconn)
+		10b8 b452  SMC EZ Card 1000 (SMC9452TXV.2)
+		11ab 0121  Marvell RDK-8001 
+		11ab 0321  Marvell RDK-8003 
+		11ab 1021  Marvell RDK-8010 
+		11ab 5021  Marvell Yukon Gigabit Ethernet 10/100/1000Base-T Controller (64 bit)
+		11ab 9521  Marvell Yukon Gigabit Ethernet 10/100/1000Base-T Controller (32 bit)
+		1458 e000  Marvell 88E8001 Gigabit Ethernet Controller (Gigabyte)
+		147b 1406  Marvell 88E8001 Gigabit Ethernet Controller (Abit)
+		15d4 0047  Marvell 88E8001 Gigabit Ethernet Controller (Iwill)
+		1695 9025  Marvell 88E8001 Gigabit Ethernet Controller (Epox)
+		17f2 1c03  Marvell 88E8001 Gigabit Ethernet Controller (Albatron)
+		270f 2803  Marvell 88E8001 Gigabit Ethernet Controller (Chaintech)
+	4350  Fast Ethernet Controller
+		1179 0001  Marvell 88E8035 Fast Ethernet Controller (Toshiba)
+		11ab 3521  Marvell RDK-8035 
+		1854 000d  Marvell 88E8035 Fast Ethernet Controller (LGE)
+		1854 000e  Marvell 88E8035 Fast Ethernet Controller (LGE)
+		1854 000f  Marvell 88E8035 Fast Ethernet Controller (LGE)
+		1854 0011  Marvell 88E8035 Fast Ethernet Controller (LGE)
+		1854 0012  Marvell 88E8035 Fast Ethernet Controller (LGE)
+		1854 0016  Marvell 88E8035 Fast Ethernet Controller (LGE)
+		1854 0017  Marvell 88E8035 Fast Ethernet Controller (LGE)
+		1854 0018  Marvell 88E8035 Fast Ethernet Controller (LGE)
+		1854 0019  Marvell 88E8035 Fast Ethernet Controller (LGE)
+		1854 001c  Marvell 88E8035 Fast Ethernet Controller (LGE)
+		1854 001e  Marvell 88E8035 Fast Ethernet Controller (LGE)
+		1854 0020  Marvell 88E8035 Fast Ethernet Controller (LGE)
+	4351  Fast Ethernet Controller
+		107b 4009  Marvell 88E8036 Fast Ethernet Controller (Wistron)
+		10f7 8338  Marvell 88E8036 Fast Ethernet Controller (Panasonic)
+		1179 0001  Marvell 88E8036 Fast Ethernet Controller (Toshiba)
+		1179 ff00  Marvell 88E8036 Fast Ethernet Controller (Compal)
+		1179 ff10  Marvell 88E8036 Fast Ethernet Controller (Inventec)
+		11ab 3621  Marvell RDK-8036 
+		13d1 ac12  Abocom EFE3K - 10/100 Ethernet Expresscard
+		161f 203d  Marvell 88E8036 Fast Ethernet Controller (Arima)
+		1854 000d  Marvell 88E8036 Fast Ethernet Controller (LGE)
+		1854 000e  Marvell 88E8036 Fast Ethernet Controller (LGE)
+		1854 000f  Marvell 88E8036 Fast Ethernet Controller (LGE)
+		1854 0011  Marvell 88E8036 Fast Ethernet Controller (LGE)
+		1854 0012  Marvell 88E8036 Fast Ethernet Controller (LGE)
+		1854 0016  Marvell 88E8036 Fast Ethernet Controller (LGE)
+		1854 0017  Marvell 88E8036 Fast Ethernet Controller (LGE)
+		1854 0018  Marvell 88E8036 Fast Ethernet Controller (LGE)
+		1854 0019  Marvell 88E8036 Fast Ethernet Controller (LGE)
+		1854 001c  Marvell 88E8036 Fast Ethernet Controller (LGE)
+		1854 001e  Marvell 88E8036 Fast Ethernet Controller (LGE)
+		1854 0020  Marvell 88E8036 Fast Ethernet Controller (LGE)
+	4360  Gigabit Ethernet Controller
+		1043 8134  Marvell 88E8052 Gigabit Ethernet Controller (Asus)
+		107b 4009  Marvell 88E8052 Gigabit Ethernet Controller (Wistron)
+		11ab 5221  Marvell RDK-8052 
+		1458 e000  Marvell 88E8052 Gigabit Ethernet Controller (Gigabyte)
+		1462 052c  Marvell 88E8052 Gigabit Ethernet Controller (MSI)
+		1849 8052  Marvell 88E8052 Gigabit Ethernet Controller (ASRock)
+		1940 e000  Marvell 88E8052 Gigabit Ethernet Controller (Gigabyte)
+		a0a0 0509  Marvell 88E8052 Gigabit Ethernet Controller (Aopen)
+	4361  Gigabit Ethernet Controller
+		107b 3015  Marvell 88E8050 Gigabit Ethernet Controller (Gateway)
+		11ab 5021  Marvell 88E8050 Gigabit Ethernet Controller (Intel)
+	4362  Gigabit Ethernet Controller
+		103c 2a0d  Marvell 88E8053 Gigabit Ethernet Controller (Asus)
+		1043 8142  Marvell 88E8053 Gigabit Ethernet Controller (Asus)
+		109f 3197  Marvell 88E8053 Gigabit Ethernet Controller (Trigem)
+		10f7 8338  Marvell 88E8053 Gigabit Ethernet Controller (Panasonic)
+		10fd a430  Marvell 88E8053 Gigabit Ethernet Controller (SOYO)
+		1179 0001  Marvell 88E8053 Gigabit Ethernet Controller (Toshiba)
+		1179 ff00  Marvell 88E8053 Gigabit Ethernet Controller (Compal)
+		1179 ff10  Marvell 88E8053 Gigabit Ethernet Controller (Inventec)
+		11ab 5321  Marvell RDK-8053 
+		1297 c240  Marvell 88E8053 Gigabit Ethernet Controller (Shuttle)
+		1297 c241  Marvell 88E8053 Gigabit Ethernet Controller (Shuttle)
+		1297 c242  Marvell 88E8053 Gigabit Ethernet Controller (Shuttle)
+		1297 c243  Marvell 88E8053 Gigabit Ethernet Controller (Shuttle)
+		1297 c244  Marvell 88E8053 Gigabit Ethernet Controller (Shuttle)
+		13d1 ac11  Abocom EGE5K - Giga Ethernet Expresscard
+		1458 e000  Marvell 88E8053 Gigabit Ethernet Controller (Gigabyte)
+		1462 058c  Marvell 88E8053 Gigabit Ethernet Controller (MSI)
+		14c0 0012  Marvell 88E8053 Gigabit Ethernet Controller (Compal)
+		1558 04a0  Marvell 88E8053 Gigabit Ethernet Controller (Clevo)
+		15bd 1003  Marvell 88E8053 Gigabit Ethernet Controller (DFI)
+		161f 203c  Marvell 88E8053 Gigabit Ethernet Controller (Arima)
+		161f 203d  Marvell 88E8053 Gigabit Ethernet Controller (Arima)
+		1695 9029  Marvell 88E8053 Gigabit Ethernet Controller (Epox)
+		17f2 2c08  Marvell 88E8053 Gigabit Ethernet Controller (Albatron)
+		17ff 0585  Marvell 88E8053 Gigabit Ethernet Controller (Quanta)
+		1849 8053  Marvell 88E8053 Gigabit Ethernet Controller (ASRock)
+		1854 000b  Marvell 88E8053 Gigabit Ethernet Controller (LGE)
+		1854 000c  Marvell 88E8053 Gigabit Ethernet Controller (LGE)
+		1854 0010  Marvell 88E8053 Gigabit Ethernet Controller (LGE)
+		1854 0013  Marvell 88E8053 Gigabit Ethernet Controller (LGE)
+		1854 0014  Marvell 88E8053 Gigabit Ethernet Controller (LGE)
+		1854 0015  Marvell 88E8053 Gigabit Ethernet Controller (LGE)
+		1854 001a  Marvell 88E8053 Gigabit Ethernet Controller (LGE)
+		1854 001b  Marvell 88E8053 Gigabit Ethernet Controller (LGE)
+		1854 001d  Marvell 88E8053 Gigabit Ethernet Controller (LGE)
+		1854 001f  Marvell 88E8053 Gigabit Ethernet Controller (LGE)
+		1854 0021  Marvell 88E8053 Gigabit Ethernet Controller (LGE)
+		1854 0022  Marvell 88E8053 Gigabit Ethernet Controller (LGE)
+		1940 e000  Marvell 88E8053 Gigabit Ethernet Controller (Gigabyte)
+		270f 2801  Marvell 88E8053 Gigabit Ethernet Controller (Chaintech)
+		a0a0 0506  Marvell 88E8053 Gigabit Ethernet Controller (Aopen)
 	4611  GT-64115 System Controller
 	4620  GT-64120/64120A/64121A System Controller
 	4801  GT-48001
+	5005  Belkin
+		1799 5005  Belkin Gigabit Desktop Card 10/100/1000Base-T Adapter, Copper RJ-45
 	5040  MV88SX5040 4-port SATA I PCI-X Controller
 	5041  MV88SX5041 4-port SATA I PCI-X Controller
 	5080  MV88SX5080 8-port SATA I PCI-X Controller
@@ -5735,6 +5856,7 @@
 1370  ATL Products
 1371  CNet Technology Inc
 	434e  GigaCard Network Adapter
+		1371 434e  N-Way PCI-Bus Giga-Card 1000/100/10Mbps(L)
 1373  Silicon Vision Inc
 1374  Silicom Ltd
 1375  Argosystems Inc

--=-v7QpnGEpyMiv7o+C4qKR--
