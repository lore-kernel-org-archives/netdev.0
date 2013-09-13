From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/6][pull request] Intel Wired LAN Driver Updates
Date: Fri, 13 Sep 2013 19:37:20 -0400 (EDT)
Message-ID: <20130913.193720.773478973072153473.davem@davemloft.net>
References: <1379106730-14994-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755295Ab3IMXhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 19:37:24 -0400
In-Reply-To: <1379106730-14994-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 13 Sep 2013 14:12:04 -0700

> This series contains updates to ixgbe and e1000e.
> 
> Jacob provides a ixgbe patch to fix the configure_rx patch to properly
> disable RSC hardware logic when a user disables it.  Previously we only
> disabled RSC in the queue settings, but this does not fully disable
> hardware RSC logic which can lead to unexpected performance issues.
> 
> Emil provides three fixes for ixgbe.  First fixes the ethtool loopback
> test when DCB is enabled, where the frames may be modified on Tx
> (by adding VLAN tag) which will fail the check on receive.  Then a fix
> for QSFP+ modules, limit the speed setting to advertise only one speed
> at a time since the QSFP+ modules do not support auto negotiation.
> Lastly, resolve an issue where the driver will display incorrect info
> for QSFP+ modules that were inserted after the driver has been loaded.
> 
> David Ertman provides to fixes for e1000e, one removes a comparison to
> the boolean value true where evaluating the lvalue will produce the
> same result.  The other fixes an error in the calculation of the
> rar_entry_count, which causes a write of unkown/undefined register
> space in the MAC to unknown/undefined register space in the PHY.

Pulled, thanks Jeff.
