From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/14][pull request] 10GbE Intel Wired LAN Driver
 Updates 2017-02-16
Date: Thu, 16 Feb 2017 21:22:46 -0500 (EST)
Message-ID: <20170216.212246.514236148228835224.davem@davemloft.net>
References: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34458 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753181AbdBQCWx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 21:22:53 -0500
In-Reply-To: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 16 Feb 2017 04:50:27 -0800

> This series contains updates to ixgbe only.
> 
> Tony updates the driver to advertise 2.5Gb and 5.0Gb if the adapter
> supports it.
> 
> Stephen Hemminger renames our dcbnl_ops since it is global to
> ixgbe_dcbnl_ops to avoid namespace issues.
> 
> Mark updates the driver version based on the recent changes.
> 
> Alex has the remainder of the changes, starting with consolidating
> functions that represent logical steps in the receive process so we can
> later update them more easily (and align with igb).  Modify the receive
> path to only synchronize the length of the frame versus the entire buffer.
> Provided performance improvements by adding support for
> DMA_ATTR_SKIP_CPU_SYNC and DMA_ATTR_WEAK_ORDERING.  Also made additional
> performance gains by batching the page count updates instead of doing
> them one at a time.  Adjusted the receive path to use 3k buffers with
> 8k backing them in order to support build_skb with jumbo frames.  Made
> additional driver improvements by using the length of the packet instead
> of the DD status to determine if a new descriptor is ready to be
> processed, which cuts down on reads.  To reduce code duplication, pulled
> apart the receive path into separate functions.  Added support for
> providing a buffer with headroom and tailroom to allow for shared info
> for NET_SKB_PAD and NET_IP_ALIGN.
> 
> The following are changes since commit b973154a2278c6af0b0efefafb222e0189959659:
>   atm: idt77252, use setup_timer and mod_timer
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 10GbE

Pulled, thanks Jeff.
