From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Fri, 08 Mar 2013 12:25:55 -0500 (EST)
Message-ID: <20130308.122555.2082048997115962770.davem@davemloft.net>
References: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56865 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934260Ab3CHRZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 12:25:57 -0500
In-Reply-To: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri,  8 Mar 2013 02:07:02 -0800

> This series contains updates to ixgbevf and e1000e.
> 
> Alex's ixgbevf patch is meant to address several race issues that become
> possible because next_to_watch could possibly be set to a value that shows
> that the descriptor is done when it is not.  In order to correct that we
> instead make next_to_watch a pointer that is set to NULL during cleanup,
> and set to the eop_desc after the descriptor rings have been written.
> 
> Stephen's ixgbevf patch makes the PCI id table a const and reformats the
> table to match what the ixgbe driver does.
> 
> The remaining 13 patches from Bruce are cleanup patches for e1000e to
> resolve checkpatch.pl warnings/errors, removing blank lines where
> necessary and fix code formatting.
> 
> The following are changes since commit 7f0e44ac9f7f12a2519bfed9ea4df3c1471bd8bb:
>   ipv6 flowlabel: add __rcu annotations
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks Jeff.
