From: David Miller <davem@davemloft.net>
Subject: Re: [net 0/6][pull request] Intel Wired LAN Driver Updates
Date: Tue, 26 Mar 2013 12:22:48 -0400 (EDT)
Message-ID: <20130326.122248.843863564164675668.davem@davemloft.net>
References: <1364294554-7967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40285 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934641Ab3CZQWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:22:50 -0400
In-Reply-To: <1364294554-7967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 26 Mar 2013 03:42:28 -0700

> This series contains updates to ixgbevf and igb.
> 
> The ixgbevf calls to pci_disable_msix() and to free the msix_entries
> memory should not occur if device open fails.  Instead they should be
> called during device driver removal to balance with the call to
> pci_enable_msix() and the call to allocate msix_entries memory
> during the device probe and driver load.
> 
> The remaining 4 of 5 igb patches are simple 1-3 line patches to fix
> several issues such as possible null pointer dereference, PHC stopping
> on max frequency, make sensor info static and SR-IOV initialization
> reordering.
> 
> The remaining igb patch to fix anti-spoofing config fixes a problem
> in i350 where anti spoofing configuration was written into a wrong
> register.
> 
> The following are changes since commit a79ca223e029aa4f09abb337accf1812c900a800:
>   ipv6: fix bad free of addrconf_init_net
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Pulled, thanks Jeff.
