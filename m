From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/14][pull request] Intel Wired LAN Driver Updates
Date: Mon, 28 Jan 2013 18:18:37 -0500 (EST)
Message-ID: <20130128.181837.967229763220951315.davem@davemloft.net>
References: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751757Ab3A1XSi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 18:18:38 -0500
In-Reply-To: <1359363869-32391-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 28 Jan 2013 01:04:15 -0800

> This series contains updates to e1000e, ixgbevf, igb and igbvf.
> Majority of the patches are code cleanups of e1000e where code
> is removed (Yeah!).  The other two e1000e patches are fixes.  The
> first is to fix the maximum frame size for 82579 devices.  The second
> fix is to resolve an issue with devices other than 82579 that suffer
> from dropped transactions on platforms with deep C-states when
> jumbo frames are enabled.
> 
> The ixgbevf patch is to ensure that the driver fetches the correct,
> refreshed value for link status and speed when the values have changed.
> 
> The igb and igbvf patches are a solution to an issue Stefan Assmann
> reported, where when the PF is up and igbvf is loaded, the MAC address
> is not generated using eth_hw_addr_random().
> 
> The following are changes since commit a1b1add07fa794974573d93483d68e373edfe7bd:
>   gro: Fix kcalloc argument order
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks Jeff.
