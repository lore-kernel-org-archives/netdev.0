From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 4/9] ixgbe: feature - driver to default with FC on.
Date: Wed, 01 Apr 2009 00:33:44 -0700
Message-ID: <20090401073343.3749.23654.stgit@lost.foo-projects.org>
References: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:48763
	"EHLO QMTA11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758863AbZDAHeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 03:34:08 -0400
In-Reply-To: <20090401073241.3749.36391.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

In the past flow control wasn't enabled by default under the
incorrect assumption that this opened up us to a denial of
service attack.  However since any switch that forwarded flow
control would be extremely msiconfigured and/or buggy, this
concern no longer out weighs the preformance gains from
having FC enabled.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fd27513..8f6e263 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3169,7 +3169,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 #endif
 
 	/* default flow control settings */
-	hw->fc.requested_mode = ixgbe_fc_none;
+	hw->fc.requested_mode = ixgbe_fc_full;
 	hw->fc.high_water = IXGBE_DEFAULT_FCRTH;
 	hw->fc.low_water = IXGBE_DEFAULT_FCRTL;
 	hw->fc.pause_time = IXGBE_DEFAULT_FCPAUSE;

