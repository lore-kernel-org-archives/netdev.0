From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: [PATCH  kernel 2.6.37-rc1]ipg.c: remove id [SUNDANCE, 0x1021]
Date: Sun, 14 Nov 2010 08:42:08 +0900
Message-ID: <20101114084208.b3ee991d.ken_kawasaki@spring.nifty.jp>
References: <20090405094907.5f6a5fea.ken_kawasaki@spring.nifty.jp>
	<20090419084444.4ee7ddee.ken_kawasaki@spring.nifty.jp>
	<20090426162929.3d036f26.ken_kawasaki@spring.nifty.jp>
	<20090913172257.6c1976ec.ken_kawasaki@spring.nifty.jp>
	<20091004073257.52a6624b.ken_kawasaki@spring.nifty.jp>
	<20091221205849.dae4e929.ken_kawasaki@spring.nifty.jp>
	<20091223171004.77316fa5.ken_kawasaki@spring.nifty.jp>
	<20100123065625.db751a12.ken_kawasaki@spring.nifty.jp>
	<20100228083420.9ca8e285.ken_kawasaki@spring.nifty.jp>
	<20100612191728.2d272cc1.ken_kawasaki@spring.nifty.jp>
	<20100620102427.77d2c7d3.ken_kawasaki@spring.nifty.jp>
	<20100706202243.95319ab4.ken_kawasaki@spring.nifty.jp>
	<20100710201813.a3e5c79c.ken_kawasaki@spring.nifty.jp>
	<20100829074501.946ebcb8.ken_kawasaki@spring.nifty.jp>
	<20101030071751.63611ede.ken_kawasaki@spring.nifty.jp>
	<20101107001124.7d8ef6c4.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userg506.nifty.com ([202.248.238.86]:55820 "EHLO
	userg506.nifty.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754156Ab0KMXnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Nov 2010 18:43:11 -0500
Received: from localhost.localdomain (eaoska105173.adsl.ppp.infoweb.ne.jp [218.226.24.173])by userg506.nifty.com with SMTP id oADNh1b3009650
	for <netdev@vger.kernel.org>; Sun, 14 Nov 2010 08:43:01 +0900
In-Reply-To: <20101107001124.7d8ef6c4.ken_kawasaki@spring.nifty.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ipg.c:
  The id [SUNDANCE, 0x1021] (=[0x13f0, 0x1021]) is defined
  at dl2k.h and ipg.c.
  But this device works better with dl2k driver.
  
  This problem is similar with the commit 
  [25cca5352712561fba97bd37c495593d641c1d39
  ipg: Remove device claimed by dl2k from pci id table]
  at 11 Feb 2010.

Signed-off-by: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>

---

--- linux-2.6.37-rc1/drivers/net/ipg.c.orig	2010-11-13 19:54:53.000000000 +0900
+++ linux-2.6.37-rc1/drivers/net/ipg.c	2010-11-13 19:57:03.000000000 +0900
@@ -88,16 +88,14 @@ static const char *ipg_brand_name[] = {
 	"IC PLUS IP1000 1000/100/10 based NIC",
 	"Sundance Technology ST2021 based NIC",
 	"Tamarack Microelectronics TC9020/9021 based NIC",
-	"Tamarack Microelectronics TC9020/9021 based NIC",
 	"D-Link NIC IP1000A"
 };
 
 static DEFINE_PCI_DEVICE_TABLE(ipg_pci_tbl) = {
 	{ PCI_VDEVICE(SUNDANCE,	0x1023), 0 },
 	{ PCI_VDEVICE(SUNDANCE,	0x2021), 1 },
-	{ PCI_VDEVICE(SUNDANCE,	0x1021), 2 },
-	{ PCI_VDEVICE(DLINK,	0x9021), 3 },
-	{ PCI_VDEVICE(DLINK,	0x4020), 4 },
+	{ PCI_VDEVICE(DLINK,	0x9021), 2 },
+	{ PCI_VDEVICE(DLINK,	0x4020), 3 },
 	{ 0, }
 };
 
