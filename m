From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/4] ixgbe: fix issues with failing to detect
 insert of unsupported module
Date: Fri, 03 Jul 2009 19:12:00 -0700 (PDT)
Message-ID: <20090703.191200.136944764.davem@davemloft.net>
References: <20090702225012.22746.57218.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36287
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756606AbZGDCLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2009 22:11:54 -0400
In-Reply-To: <20090702225012.22746.57218.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 02 Jul 2009 15:50:12 -0700

> From: Don Skidmore <donald.c.skidmore@intel.com>
> 
> Several small fixes around negative test case of the insertion of a
> IXGBE_ERR_NOT_SUPPORTED module.
> 
> - mdio45_probe call was always failing due to mdio.prtad not being
> set.  The function set to mdio.mdio_read was still working as we just
> happen to always be at prtad == 0.  This will allow us to set the phy_id
> and phy.type correctly now.
> 
> - There was timing issue with i2c calls when initiated from a tasklet.
> A small delay was added to allow the electrical oscillation to calm down.
> 
> - Logic change in ixgbe_sfp_task that allows NOT_SUPPORTED condition
> to be recognized.
> 
> Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
