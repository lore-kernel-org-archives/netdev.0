From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/10][pull request] Intel Wired LAN Driver
 Updates 2013.02.15
Date: Fri, 15 Feb 2013 15:33:55 -0500 (EST)
Message-ID: <20130215.153355.844583776311725221.davem@davemloft.net>
References: <1360922649-3388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44377 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784Ab3BOUd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 15:33:57 -0500
In-Reply-To: <1360922649-3388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 15 Feb 2013 02:03:59 -0800

> This series contains updates to igb and ixgbe.  Most of the changes
> are against igb, except for one patch against ixgbe.
> 
> There are 3 igb fixes from Carolyn which were reported by Dan
> Carpenter which resolve issues found in the get_i2c_client().  Alex
> does some cleanup of the igb driver to match similar functionality
> in ixgbe on transmit.  Alex also makes it so that we can enable the use
> of build_skb for cases where jumbo frames are disabled.  The advantage
> to this is that we do not have to perform a memcpy to populate the header
> and as a result we see a significant performance improvement.
> 
> Akeem provides 4 patches to initialize function pointers and do a
> re-factoring of the function pointers in igb_get_variants() to assist
> with driver debugging.
> 
> The ixgbe patch comes from Emil to reshuffle the switch/case structure
> of the flag assignment to allow for the flags to be set for each MAC
> type separately. This is needed for new hardware that does not have feature
> parity with older hardware.
> 
> v2: updated patches 4 & 5 based on feedback from Ben Hutchings and Eric
>     Dumazet
> 
> The following are changes since commit 9754e293491e3a4e6c1ac020d25140b1ed3d9cd2:
>   net: Don't write to current task flags on every packet received.
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks Jeff.
