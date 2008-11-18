From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 1/3] igb: update name to reflect new hardware
Date: Mon, 17 Nov 2008 18:05:10 -0800
Message-ID: <20081118020510.10912.94106.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:58550
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751620AbYKRCFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 21:05:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds the 82576 device to the description for igb in Kconfig.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 732ea83..afa2065 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1982,10 +1982,10 @@ config IP1000
 	  will be called ipg.  This is recommended.
 
 config IGB
-       tristate "Intel(R) 82575 PCI-Express Gigabit Ethernet support"
+       tristate "Intel(R) 82575/82576 PCI-Express Gigabit Ethernet support"
        depends on PCI
        ---help---
-         This driver supports Intel(R) 82575 gigabit ethernet family of
+         This driver supports Intel(R) 82575/82576 gigabit ethernet family of
          adapters.  For more information on how to identify your adapter, go
          to the Adapter & Driver ID Guide at:
 

