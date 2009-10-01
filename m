From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: correct the parameter description
Date: Wed, 30 Sep 2009 23:51:41 -0700
Message-ID: <20091001065140.13279.42634.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jiri Pirko <jpirko@redhat.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:43730 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753634AbZJAGv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 02:51:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>

ccffad25b5136958d4769ed6de5e87992dd9c65c changed parameters for function
ixgbe_update_uc_addr_list_generic but parameter description was not updated.
This patch corrects it.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_common.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 143b0fc..40ff120 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1355,9 +1355,7 @@ static void ixgbe_add_uc_addr(struct ixgbe_hw *hw, u8 *addr, u32 vmdq)
 /**
  *  ixgbe_update_uc_addr_list_generic - Updates MAC list of secondary addresses
  *  @hw: pointer to hardware structure
- *  @addr_list: the list of new addresses
- *  @addr_count: number of addresses
- *  @next: iterator function to walk the address list
+ *  @uc_list: the list of new addresses
  *
  *  The given list replaces any existing list.  Clears the secondary addrs from
  *  receive address registers.  Uses unused receive address registers for the

