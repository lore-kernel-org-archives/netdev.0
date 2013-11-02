From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/6][pull request] Intel Wired LAN Driver Updates
Date: Sat, 02 Nov 2013 01:17:37 -0400 (EDT)
Message-ID: <20131102.011737.1955492435748210229.davem@davemloft.net>
References: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33716 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729Ab3KBFRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Nov 2013 01:17:39 -0400
In-Reply-To: <1383314210-24289-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri,  1 Nov 2013 06:56:44 -0700

> This series contains updates to e1000, igb, ixgbe and ixgbevf.
> 
> Hong Zhiguo provides a fix for e1000 where tx_ring and adapter->tx_ring
> are already of type "struct e1000_tx_ring" so no need to divide by
> e1000_tx_ring size in the idx calculation.
> 
> Emil provides a fix for ixgbevf to remove a redundant workaround related
> to header split and a fix for ixgbe to resolve an issue where the MTA table
> can be cleared when the interface is reset while in promisc mode.
> 
> Todd provides a fix for igb to prevent ethtool from writing to the iNVM
> in i210/i211 devices.  This issue was reported by Marek Vasut <marex@denx.de>.
> 
> Anton Blanchard provides a fix for ixgbe to reduce memory consumption
> with larger page sizes, seen on PPC.
> 
> Don provides a cleanup in ixgbe to replace the IXGBE_DESC_UNUSED macro with
> the inline function ixgbevf_desc_unused() to make the logic a bit more
> readable.

Pulled, thanks a lot Jeff.
