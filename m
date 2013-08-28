From: Joe Perches <joe@perches.com>
Subject: Re: [net-next  06/10] ixgbe: cleanup some log messages
Date: Wed, 28 Aug 2013 07:49:28 -0700
Message-ID: <1377701368.1928.10.camel@joe-AO722>
References: <1377686028-30747-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377686028-30747-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Don Skidmore <donald.c.skidmore@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54116 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752956Ab3H1Otq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Aug 2013 10:49:46 -0400
In-Reply-To: <1377686028-30747-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-28 at 03:33 -0700, Jeff Kirsher wrote:
> From: Don Skidmore <donald.c.skidmore@intel.com>

> Some minor log messages cleanup, changing the level one message is logged,
> adding a bit of detail to another and put all the text on one line.

Not a comment about this patch but:

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
[]
> @@ -1282,7 +1282,7 @@ s32 ixgbe_identify_qsfp_module_generic(struct ixgbe_hw *hw)
>  				status = 0;
>  			} else {
>  				if (hw->allow_unsupported_sfp == true) {

At some point it might be nice to remove the
remaining bool direct comparisons to true/false

$ git grep -E -n "(==|!=)\s*(true|false)" drivers/net/ethernet/intel
drivers/net/ethernet/intel/e1000e/netdev.c:4871:			    (hw->mac.autoneg == true) &&
drivers/net/ethernet/intel/e1000e/phy.c:2651: *  Assumes semaphore is already acquired.  When page_set==true, assumes
drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c:763:	if (hw->phy.reset_disable == false) {
drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c:819:	if (hw->mac.orig_link_settings_stored == false) {
drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c:954:			    (hw->phy.smart_speed_active == false))
drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c:1099:	if (hw->phy.reset_disable == false && hw->phy.ops.reset != NULL)
drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c:1167:	if (hw->mac.orig_link_settings_stored == false) {
drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c:2371:	if (hw->phy.qsfp_shared_i2c_bus == true) {
drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c:2397:	if (hw->phy.qsfp_shared_i2c_bus == true) {
drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c:2424:	if (hw->phy.qsfp_shared_i2c_bus == true) {
drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c:2450:	if (hw->phy.qsfp_shared_i2c_bus == true) {
drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c:1273:				if (hw->allow_unsupported_sfp == true) {
