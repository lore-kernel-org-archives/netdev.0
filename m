From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [net-next  06/10] ixgbe: cleanup some log messages
Date: Wed, 28 Aug 2013 16:19:55 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF222866466FD4530B@ORSMSX110.amr.corp.intel.com>
References: <1377686028-30747-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377686028-30747-7-git-send-email-jeffrey.t.kirsher@intel.com>
 <1377701368.1928.10.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Joe Perches <joe@perches.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10295 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752111Ab3H1QT4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 12:19:56 -0400
In-Reply-To: <1377701368.1928.10.camel@joe-AO722>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> Sent: Wednesday, August 28, 2013 7:49 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Skidmore, Donald C; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 06/10] ixgbe: cleanup some log messages
> 
> On Wed, 2013-08-28 at 03:33 -0700, Jeff Kirsher wrote:
> > From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> > Some minor log messages cleanup, changing the level one message is
> > logged, adding a bit of detail to another and put all the text on one line.
> 
> Not a comment about this patch but:
> 
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
> > b/drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c
> []
> > @@ -1282,7 +1282,7 @@ s32 ixgbe_identify_qsfp_module_generic(struct
> ixgbe_hw *hw)
> >  				status = 0;
> >  			} else {
> >  				if (hw->allow_unsupported_sfp == true) {
> 
> At some point it might be nice to remove the remaining bool direct
> comparisons to true/false
> 
> $ git grep -E -n "(==|!=)\s*(true|false)" drivers/net/ethernet/intel
> drivers/net/ethernet/intel/e1000e/netdev.c:4871:
> (hw->mac.autoneg == true) &&
> drivers/net/ethernet/intel/e1000e/phy.c:2651: *  Assumes semaphore is
> already acquired.  When page_set==true, assumes
> drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c:763:	if (hw-
> >phy.reset_disable == false) {
> drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c:819:	if (hw-
> >mac.orig_link_settings_stored == false) {
> drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c:954:
> (hw->phy.smart_speed_active == false))
> drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c:1099:	if (hw-
> >phy.reset_disable == false && hw->phy.ops.reset != NULL)
> drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c:1167:	if (hw-
> >mac.orig_link_settings_stored == false) {
> drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c:2371:	if (hw-
> >phy.qsfp_shared_i2c_bus == true) {
> drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c:2397:	if (hw-
> >phy.qsfp_shared_i2c_bus == true) {
> drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c:2424:	if (hw-
> >phy.qsfp_shared_i2c_bus == true) {
> drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c:2450:	if (hw-
> >phy.qsfp_shared_i2c_bus == true) {
> drivers/net/ethernet/intel/ixgbe/ixgbe_phy.c:1273:
> 	if (hw->allow_unsupported_sfp == true) {
> 

Thanks for pointing this out Joe. 

 I'll work on a patch to do that for ixgbe and talk with the e1000e owner about doing it with their driver.
