From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 3/3] ixgbe: add a refcnt when turning
 on/off FCoE offload capability
Date: Thu, 21 Oct 2010 03:56:12 -0700 (PDT)
Message-ID: <20101021.035612.02273208.davem@davemloft.net>
References: <20101021085740.12059.20577.stgit@localhost.localdomain>
	<20101021090027.12059.44871.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	yi.zou@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43029
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756860Ab0JUKzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:55:50 -0400
In-Reply-To: <20101021090027.12059.44871.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 21 Oct 2010 02:00:30 -0700

> From: Yi Zou <yi.zou@intel.com>
> 
> The FCoE offload is enabled/disabled per adapter, but upper FCoE protocol
> stack could have multiple FCoE instances created on the same physical network
> interface, e.g., FCoE on multiple VLAN interfaces on the same physical
> network interface. In this case we want to turn on FCoE offload at the first
> request from ndo_fcoe_enable() but only turn off FCoE offload at the very last
> call to ndo_fcoe_disable(). This is fixed by adding a refcnt in the per adapter
> FCoE structure and tear down FCoE offload when refcnt decrements to zero.
> 
> Signed-off-by: Yi Zou <yi.zou@intel.com>
> Tested-by: Ross Brattain <ross.b.brattain@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
