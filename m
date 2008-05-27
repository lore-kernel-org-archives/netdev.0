From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] NET: DCB generic netlink interface
Date: Tue, 27 May 2008 07:13:39 -0700
Message-ID: <20080527141339.12851.98781.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:36531 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756576AbYE0VNb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2008 17:13:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds the initial DCB generic netlink interface to the kernel.
It adds the layer as a generic interface for any DCB-capable device through
the netdevice.

This patchset also includes an implementation using this interface in the
ixgbe driver.  It adds the hardware-specific code to turn the interface on,
and includes the netlink callbacks in the driver to perform the requested
operations.

These patches are targeted at the net-next-2.6 tree, for 2.6.27.  The patch
series is as follows:

patch 1: DCB netlink interface in-kernel
patch 2: ixgbe DCB hardware-specific patches
patch 3: enable DCB in ixgbe

Thanks,
-- 
PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
