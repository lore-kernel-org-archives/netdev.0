From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 0/9][pull request] Intel Wired LAN Driver Updates
Date: Thu, 18 Apr 2013 15:01:20 -0400 (EDT)
Message-ID: <20130418.150120.1972637726093535335.davem@davemloft.net>
References: <1366266841-12466-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55535 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932233Ab3DRTBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 15:01:23 -0400
In-Reply-To: <1366266841-12466-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 17 Apr 2013 23:33:52 -0700

> This series contains updates to ixgbe only.
> 
> v2- Dropped the following 2 patches from the series:
>  ixgbe: Support using build_skb in the case that jumbo frames are disabled
>  ixgbe: walk pci-e bus to find minimum width
> 
> Ben Hutchings found a bug with Alex's patch, so that patch was dropped
> permanently.  Jacob's "walk PCIe bus" patch is being re-worked for
> a more generic solution so that other drivers can benefit.
> 
> In the remaining patches...
> Alex provides a fix where we were incorrectly checking the entire frag_off
> field when we only wanted the fragment offset.  Alex also cleans up
> the check for PAGE_SIZE, since the default configuration allocates 32K
> for all buffers.
> 
> Emil provides a change to the calculation of eerd so that it is consistent
> between the read and write functions by using | instead of +.
> 
> Jacob adds support for displaying PCIe Gen3 link speed, which was
> previously missing from the ixgbe driver.  He also provides a patch
> to clean up ixgbe_get_bus_info_generic to call some conversion
> functions, which are used also in another patch provided by Jacob.
> Jacob modifies the driver to enable certain devices (which have an
> internal switch) to read from the physical slot rather than reading
> data from the internal switch.
> 
> Don provides a couple of fixes (which are more appropriate for net-next),
> one of which resolves an issue where ixgbe was only turning on the laser
> when the adapter was up which caused issues for those who wanted to
> access the MNG firmware while the port was in a down state.  The other
> fix is for WoL when currently linked at 1G.  Lastly Don bumps the driver
> version keep the in-kernel driver up to date with the current functionality.
> 
> The following are changes since commit 2551c405e886c4ce4732bedaa8559a110a6f373f:
>   Merge branch 'tipc-ipoib'
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks Jeff.
