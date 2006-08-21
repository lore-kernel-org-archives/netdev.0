From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 06/14] ipw2100: Make ipw2100 depends on known working platforms
Date: Mon, 21 Aug 2006 11:37:49 +0800
Message-ID: <20060821033748.GA5371@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44137 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932583AbWHUDjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:39:43 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ipw2100 driver doesn't support big endian by now.

Signed-off-by: Karol Lewandowski <kl@jasmine.eu.org>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

97b35942893f7999dadcd18d8801ac460f65ce67
diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
index a8ffd78..513bfc3 100644
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -146,7 +146,7 @@ comment "Wireless 802.11b ISA/PCI cards 
 
 config IPW2100
 	tristate "Intel PRO/Wireless 2100 Network Connection"
-	depends on NET_RADIO && PCI
+	depends on NET_RADIO && PCI && (X86 || X86_64 || IA64 || BROKEN)
 	select FW_LOADER
 	select IEEE80211
 	---help---
-- 
1.2.6
