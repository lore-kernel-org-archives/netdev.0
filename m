From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/14][pull request] Intel Wired LAN Driver
 Updates
Date: Thu, 25 Apr 2013 01:08:31 -0400 (EDT)
Message-ID: <20130425.010831.648226192644075247.davem@davemloft.net>
References: <1366862927-1855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47891 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751246Ab3DYFId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:08:33 -0400
In-Reply-To: <1366862927-1855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 24 Apr 2013 21:08:33 -0700

> This series contains updates to ixgbe, igb and pci.
> 
> The ixgbe changes contains a fix to a possible divide by zero by bailing
> out of the ixgbe_update_itr() function if the last interrupt timeslice is
> zero.  In addition, support is added for the new OCP x520 adapter as well
> as LX support for 82599 devices.  Jacob provides a patch to change
> variable wol_supported to wol_enabled to better reflect what the code
> is actually doing (i.e. checking if WoL is enabled).
> 
> Alex adds SRIOV helper function to pci that will determine if a PF
> has any VFs that are currently assigned to a guest.
> 
> The remaining 8 patches are against igb and contain the following changes:
> * implement SERDES loopback configuration for i210 devices by unsetting
>   sigdetect bit, so as to fix Ethtool loopback test failure
> * add support for the SMBI semaphore for I210/I211 devices
> * implement the new generic pci_vfs_assigned helper function (Alex's PCI
>   helper function)
> * display warning when link speed is downgraded due to Smartspeed
> * ensure that VLAN hardware filtering remains enabled when the device is
>   in promiscuous mode and VT mode simultaneously
> * cleanup dead code in igb
> * bump the driver version
> 
> v2: updated the PCI patch to add SRIOV helper function to remove extern
>     from the declaration of pci_vfs_assigned in pci.h and return 0 if
>     SR-IOV is disabled which is inline with other PCI SR-IOV functions

Pulled, thanks for getting the PCI review resolved.
