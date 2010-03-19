From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/3] ixgbevf: Shorten up delay timer for watchdog task
Date: Fri, 19 Mar 2010 06:00:12 -0700
Message-ID: <20100319130011.9799.97156.stgit@localhost.localdomain>
References: <20100319125950.9799.70157.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:57268
	"EHLO qmta09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752202Ab0CSNAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 09:00:30 -0400
In-Reply-To: <20100319125950.9799.70157.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The recovery from PF reset works better when you shorten up the delay
until the watchdog task executes.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbevf/ixgbevf_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 43927e1..3de93ae 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -965,7 +965,7 @@ static irqreturn_t ixgbevf_msix_mbx(int irq, void *data)
 
 	if ((msg & IXGBE_MBVFICR_VFREQ_MASK) == IXGBE_PF_CONTROL_MSG)
 		mod_timer(&adapter->watchdog_timer,
-			  round_jiffies(jiffies + 10));
+			  round_jiffies(jiffies + 1));
 
 	return IRQ_HANDLED;
 }

