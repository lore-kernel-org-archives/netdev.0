From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/5] ixgbe: properly toggling netdev
 feature flags when disabling FCoE
Date: Mon, 19 Jul 2010 20:24:22 -0700 (PDT)
Message-ID: <20100719.202422.139128049.davem@davemloft.net>
References: <20100719235831.14112.14175.stgit@localhost.localdomain>
	<20100719235949.14112.48380.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37860
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758162Ab0GTDYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jul 2010 23:24:07 -0400
In-Reply-To: <20100719235949.14112.48380.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 19 Jul 2010 16:59:52 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> When FCoE is disabled, there is a race condition that FCoE offload is
> turned off but the FCoE protocol driver is still queuing I/O thinking
> offload support still exists. This patch toggles off corresponding FCoE
> netdev feature flags and notify the FCoE stack first, allowing FCoE
> protocol stack driver to update its flags upon NETDEV_FEAT_CHANGE so no
> I/O will be using offload.
> 
> Also, indicate FCoE offload flags in vlan_features in ixgbe_probe once
> and do not toggle them in ixgbe_fcoe_enable/disable so when FCoE is
> created on the VLAN interface, vlan_transfer_features() would properly
> update the VLAN netdev features flag and notify the FCoE protocol driver
> for NETDEV_FEAT_CHANGE.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
