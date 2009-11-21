From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 07/23] e1000e: improper return code signage
Date: Sat, 21 Nov 2009 01:23:53 -0800
Message-ID: <20091121092352.5715.40083.stgit@localhost.localdomain>
References: <20091121092126.5715.41618.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:50375
	"EHLO QMTA14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752508AbZKUJYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 04:24:04 -0500
In-Reply-To: <20091121092126.5715.41618.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The e1000_get_cable_length_82577() should return a negative value upon
error.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/phy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 03175b3..95a8196 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -3137,7 +3137,7 @@ s32 e1000_get_cable_length_82577(struct e1000_hw *hw)
 	         I82577_DSTATUS_CABLE_LENGTH_SHIFT;
 
 	if (length == E1000_CABLE_LENGTH_UNDEFINED)
-		ret_val = E1000_ERR_PHY;
+		ret_val = -E1000_ERR_PHY;
 
 	phy->cable_length = length;
 

