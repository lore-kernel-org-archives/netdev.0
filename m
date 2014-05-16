From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 02/11] mac802154: update Kconfig
Date: Fri, 16 May 2014 17:46:36 +0200
Message-ID: <1400255205-9031-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:39840 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751039AbaEPPrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 11:47:04 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s4GFl09N031615
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 16 May 2014 17:47:00 +0200
In-Reply-To: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Link-layer security requires AES CCM for authenticated modes and AES CTR
for the unauthenticated encryption mode.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 net/mac802154/Kconfig |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/mac802154/Kconfig b/net/mac802154/Kconfig
index b33dd76..1818a99 100644
--- a/net/mac802154/Kconfig
+++ b/net/mac802154/Kconfig
@@ -2,6 +2,10 @@ config MAC802154
 	tristate "Generic IEEE 802.15.4 Soft Networking Stack (mac802154)"
 	depends on IEEE802154
 	select CRC_CCITT
+	select CRYPTO_AUTHENC
+	select CRYPTO_CCM
+	select CRYPTO_CTR
+	select CRYPTO_AES
 	---help---
 	  This option enables the hardware independent IEEE 802.15.4
 	  networking stack for SoftMAC devices (the ones implementing
-- 
1.7.9.5
