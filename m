From: David Miller <davem@davemloft.net>
Subject: Re: [net v2 0/8][pull request] Intel Wired LAN Driver Updates
Date: Thu, 09 Feb 2012 13:29:24 -0500 (EST)
Message-ID: <20120209.132924.1417066410996276149.davem@davemloft.net>
References: <1328780061-25000-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57045 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752559Ab2BIS3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2012 13:29:30 -0500
In-Reply-To: <1328780061-25000-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  9 Feb 2012 01:34:13 -0800

> The following series contains fixes to e1000, igb and ixgbe.
> The e1000 fix comes from Red Hat, where a previous commit removed
> code which broke WoL and this patch rectifies that. The igb patch
> fixes an issue with VF lookup.  The remaining patches in the series
> are against ixgbe and fix the following:
>  - VF lookup and Tx hang with 32 VFs
>  - broken dependency on MAX_SKB_FRAGS
>  - ethtool buffer overrun in stats
>  - DCB fix for up2tc mapping being lost on disable/enable
> 
> v2- fix the formatting in the "ixgbe: fix vf lookup" patch.
> 
> The following are changes since commit 64db880e7488a6d31363ad17c4c0590f27fd48e5:
>   Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Pulled, thanks Jeff.
