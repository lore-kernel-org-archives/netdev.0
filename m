From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v3 00/29][pull request] Intel Wired LAN Driver
 Updates 2014-09-23
Date: Fri, 26 Sep 2014 16:25:57 -0400 (EDT)
Message-ID: <20140926.162557.1753267622152632380.davem@davemloft.net>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50908 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259AbaIZU0G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 16:26:06 -0400
In-Reply-To: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 23 Sep 2014 04:16:28 -0700

> This patch series adds support for the FM10000 Ethernet switch host
> interface.  The Intel FM10000 Ethernet Switch is a 48-port Ethernet switch
> supporting both Ethernet ports and PCI Express host interfaces.  The fm10k
> driver provides support for the host interface portion of the switch, both
> PF and VF.
> 
> As the host interfaces are directly connected to the switch this results in
> some significant differences versus a standard network driver.  For example
> there is no PHY or MII on the device.  Since packets are delivered directly
> from the switch to the host interface these are unnecessary.  Otherwise most
> of the functionality is very similar to our other network drivers such as
> ixgbe or igb.  For example we support all the standard network offloads,
> jumbo frames, SR-IOV (64 VFS), PTP, and some VXLAN and NVGRE offloads.
> 
> v2: converted dev_consume_skb_any() to dev_kfree_skb_any()
>     fix up PTP code based on feedback from the community
> v3: converted the use of smb_mb__before_clear_bit() to smb_mb__before_atomic()
>     added vmalloc header to patch 15
>     added prefetch header to patch 16
> 
> The following are changes since commit b749fc9bff50013182edf2371d7f6c6796aed808:
>   net: fec: fix code identation
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks everyone.
