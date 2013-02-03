From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/11][pull request] Intel Wired LAN Driver
 Updates 2013.01.31
Date: Sat, 02 Feb 2013 22:55:50 -0500 (EST)
Message-ID: <20130202.225550.577854925600607173.davem@davemloft.net>
References: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993Ab3BCDzy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2013 22:55:54 -0500
In-Reply-To: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 31 Jan 2013 23:53:20 -0800

> This series contains updates to ixgbe and e1000e.  The ixgbe patches are
> a mix of fixes, cleanup and added functionality.  The first fix is for
> traffic classes, where if the mapping has changed reset the NIC.  The other
> ixgbe fix resolves an issue where the device lookup neglected to do a
> pci_dev_put() to decrement the device reference count.
> 
> The ixgbe cleanup was done by Josh, where the auto-negotiation variables
> were renamed/cleaned up and refactored.
> 
> The remaining patches are from Bruce to do additional cleanup on e1000e as
> well as bump the driver version.  Most notably is the cleanup to use the
> kernel IEEE MII definitions where possible instead of the local MII
> definitions.
> 
> v2- Dropped the Tx encapsulation patches from the series

Pulled, thanks Jeff.
