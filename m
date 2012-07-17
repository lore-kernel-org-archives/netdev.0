From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/8][pull request] Intel Wired LAN Driver Updates
Date: Tue, 17 Jul 2012 03:22:11 -0700 (PDT)
Message-ID: <20120717.032211.1185174685338013597.davem@davemloft.net>
References: <1342519759-25137-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448Ab2GQKWM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 06:22:12 -0400
In-Reply-To: <1342519759-25137-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 17 Jul 2012 03:09:11 -0700

> This series contains updates to ixgbevf.
> 
> The following are changes since commit 282f23c6ee343126156dd41218b22ece96d747e3:
>   tcp: implement RFC 5961 3.2
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master
> 
> Alexander Duyck (8):
>   ixgbevf: Drop all dead or unnecessary code
>   ixgbevf: Drop netdev_registered value since that is already stored in
>     netdev
>   ixgbevf: Make use of NETIF_F_RXCSUM instead of keeping our own flag
>   ixgbevf: Drop use of eitr_low and eitr_high for hard coded values
>   ixgbevf: Cleanup accounting for space needed at start of xmit_frame
>   ixgbevf: Update q_vector to contain ring pointers instead of bitmaps
>   ixgbevf: Move Tx clean-up into NAPI context
>   ixgbevf: Use igb style interrupt masks instead of ixgbe style

Pulled, thanks Jeff.
