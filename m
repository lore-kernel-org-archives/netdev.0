From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Fix IP1000 config dependencies.
Date: Tue, 30 Oct 2007 20:59:05 -0700 (PDT)
Message-ID: <20071030.205905.75927379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55846
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751944AbXJaD7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2007 23:59:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Noticed during some randconfig runs.

[NET]: IP1000 driver needs MII.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 86b8641..895936a 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -168,6 +168,7 @@ config NET_SB1000
 config IP1000
        tristate "IP1000 Gigabit Ethernet support"
        depends on PCI && EXPERIMENTAL
+       select MII
        ---help---
          This driver supports IP1000 gigabit Ethernet cards.
 
-- 
1.5.2.5

