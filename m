From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Thu, 28 Mar 2013 14:39:20 -0400 (EDT)
Message-ID: <20130328.143920.1051709214911993284.davem@davemloft.net>
References: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727Ab3C1SjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 14:39:23 -0400
In-Reply-To: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 28 Mar 2013 02:00:03 -0700

> This series contains updates to e1000e, ixgbe and ixgbevf.
> 
> Majority of the changes are against e1000e (from Bruce Allan).
> Bruce adds additional error handling on PHY register access, as
> well as improve slow performance on 82579 when connected to a
> 10Mbit hub.  In addition, fixes LED blink logic for cathode
> LED design.  Most notable is added EEE support which is enabled
> by default and the added support for LTR on I217/I218.
> 
> The ixgbe and ixgbevf from Greg Rose changes the VM so that if a user
> does not assign a MAC address, the MAC address is set to all zeros
> instead of a random MAC address.  This ensures that we always know when
> we have a random address and udev won't get upset about it.
> 
> The following are changes since commit 8b49a4c75965ed157e21450d23dcadd6b27c1aa3:
>   bnx2x: fix compilation without CONFIG_BNX2X_SRIOV
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks Jeff.
