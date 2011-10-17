From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/6 v2][pull request] Intel Wired LAN Driver Updates
Date: Mon, 17 Oct 2011 18:49:22 -0400 (EDT)
Message-ID: <20111017.184922.373702739993889767.davem@davemloft.net>
References: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47235 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414Ab1JQWtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 18:49:25 -0400
In-Reply-To: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon, 17 Oct 2011 05:20:56 -0700

> The following series contains updates to ixgbe, igbvf and igb.
> This version of the series contains the following changes:
> 
> - igb fix/add check if subordinate VFs are assigned to VM's
> - igbvf fix for trunk VLAN
> - ixgbe 2 fixes for ethtool and 1 endianess fix
> 
> -v2 update the igb patch to resolve a variable initialization warning
> 
> The following are changes since commit fd38f734cb8200529e281338514945fcbff2364b:
>   igbvf: convert to ndo_fix_features
> and are available in the git repository at
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git

Patch #5 adding timestamp offloading for ixgbe has some legitimate
pushback from Richard Cochran, why don't we defer that patch while that
discussion transpires?

I'm perfectly fine with the other patches in this series.

Please respin the remaining 5 patches into a pull request and I'll
take them into net-next, thanks Jeff!
