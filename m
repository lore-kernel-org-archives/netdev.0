From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH next] r8169: select MII in Kconfig
Date: Mon, 8 Sep 2008 21:49:01 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0809082145440.2050@blonde.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from extu-mxob-2.symantec.com ([216.10.194.135]:58693 "EHLO
	extu-mxob-2.symantec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081AbYIHUtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 16:49:04 -0400
Received: from [172.19.65.1]([172.19.65.1]) (1163 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m1KcnfQ-0001XJC@megami.veritas.com>
	for <netdev@vger.kernel.org>; Mon, 8 Sep 2008 13:49:00 -0700 (PDT)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/built-in.o: In function `rtl8169_gset_xmii':
r8169.c:(.text+0x82259): undefined reference to `mii_ethtool_gset'
suggests that R8169 now needs to select MII.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 drivers/net/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- 2.6.27-rc5-mm1/drivers/net/Kconfig	2008-09-05 10:07:55.000000000 +0100
+++ linux/drivers/net/Kconfig	2008-09-05 15:20:08.000000000 +0100
@@ -2034,6 +2034,7 @@ config R8169
 	tristate "Realtek 8169 gigabit ethernet support"
 	depends on PCI
 	select CRC32
+	select MII
 	---help---
 	  Say Y here if you have a Realtek 8169 PCI Gigabit Ethernet adapter.
 
