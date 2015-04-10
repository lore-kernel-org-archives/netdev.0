From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
 2015-04-10
Date: Fri, 10 Apr 2015 12:49:51 -0700 (PDT)
Message-ID: <20150410.124951.2151370482759011881.davem@davemloft.net>
References: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59629 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbbDJTkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 15:40:41 -0400
In-Reply-To: <1428652398-10147-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 10 Apr 2015 00:53:09 -0700

> This series contains updates to ixgbe and documentation for igb,
> ixgbe and ixgb.
> 
> Stephen cleans up documentation to igb, ixgbe and ixgb.
> 
> Don updates how bridge mode is stored to minimize obfuscation and
> makes updates for future silicon easier.  Adds a new bridge mode
> support function which gathers all the logic needed to configure
> bridge modes.  Adds Source Address Prunning for VEPA bridge mode
> for x550 devices.
> 
> Vasu adds specific FCoE offloads for x550 for DDP context programming
> and increased DDP exchanges.
> 
> Alex Duyck cleans up the use of HW_VLAN_CTAG_FILTER in hw_features,
> where the driver was actually ignoring the value of the bit and was
> just assuming it was always set.  Also cleans up the use of rcu_barrier()
> since the driver has not used call_rcu() to free the rings for some
> time now.

Pulled, thanks Jeff.
