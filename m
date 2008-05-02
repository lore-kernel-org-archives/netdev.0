From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [ANNOUNCE] ixgbe: Data Center Bridging (DCB) support for ixgbe
Date: Thu, 01 May 2008 17:42:54 -0700
Message-ID: <20080502004254.14392.7599.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:6552 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752865AbYEBHlj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 03:41:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

This patchset introduces Data Center Bridging, a scheduling technology
supported by Intel's 82598 silicon.  The technology uses 802.1p VLAN priority
tags to schedule and control traffic rates across an entire network.  It
also uses IEEE 802.1Qaz (priority grouping) and IEEE 802.1Qbb (priority
flow control) technologies, in order to physically separate traffic flows
that coexist on the same physical link.

The technology is initially targeting storage traffic and regular LAN traffic
on the same physical connection.  Using priority flow control, one flow can
be paused at the MAC level (same as 802.3 flow control) while not affecting
other flows running at different priorities.

The first patchset introduces a netlink interface for ixgbe, which is used
to configure all the DCB parameters that come either from userspace, or from
DCB-capable switch negotiation.

The second patchset introduces the hardware initialization code to turn this
whole technology on in the device.

The third patchset implements the netlink interface and hardware init code,
and enables DCB support in the driver.

Thanks,
-- 
PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
