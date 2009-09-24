From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] ixgbe: correct the parameter description
Date: Thu, 24 Sep 2009 16:36:28 +0200
Message-ID: <20090924143627.GD2919@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3800 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751837AbZIXOg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2009 10:36:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ccffad25b5136958d4769ed6de5e87992dd9c65c changed parameters for function
ixgbe_update_uc_addr_list_generic but parameter description was not updated.
This patch corrects it.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 6621e17..2c7db17 100644
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
