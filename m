From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/12][pull request] Intel Wired LAN Driver Updates
Date: Sun, 28 Jul 2013 13:21:05 -0700 (PDT)
Message-ID: <20130728.132105.1045846024944164783.davem@davemloft.net>
References: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34691 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882Ab3G1UVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jul 2013 16:21:06 -0400
In-Reply-To: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Sun, 28 Jul 2013 04:41:04 -0700

> This series contains updates to e100 and e1000e.
> 
> The e100 patch from Andy simply updates the netif_printk() to use
> %*ph to dump small buffers.
> 
> The changes to e1000e include a fix from Dean Nelson to resolve a
> issue where a pci_clear_master() was accidentally dropped during a
> conflict resolution. Wei Young provides 2 patches, one removes an
> assignment of the default ring size because it was a duplicate. The
> second changes the packet split receive structure to use
> PS_PAGE_BUFFERS macro for the length so that problems won't occur
> when the length is changed.
> 
> The remaining patches for e1000e are from Bruce Allan, where he
> provides a number of fixes and updates for I218.  In addition, a
> fix for 82583 which can disappear off the PCIe bus, to resolve this,
> disable ASPM L1.  Bruce also provides a fix to a previous commit
> (commit e60b22c5b7 e1000e: fix accessing to suspended device) so that
> devices are only taken out of runtime power management for those
> ethtool operations that must access device registers.
> 
> The following are changes since commit dcfe8048de66c3468060c8a2ec2c04ae3725d002:
>   bonding: remove bond_resend_igmp_join_requests read_unlock leftover
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks a lot Jeff.
