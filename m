From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 0/2] Multiqueue network device support
Date: Tue, 24 Apr 2007 18:33:31 -0700
Message-ID: <20070425013331.6010.38587.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, cramerj@intel.com, auke-jan.h.kok@intel.com,
	christopher.leech@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1877 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161568AbXDYBWr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 21:22:47 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a redesign and repost of the multiqueue network device support patches.
The new API for base drivers allows multiqueue-capable devices to manage their
individual queues in the network stack.  The stack now handles both
non-multiqueue and multiqueue devices on the same codepath.  Also, allocation
and deallocation of the queues is handled by the kernel instead of the driver.

The PRIO qdisc is now modified to run in single-queue mode on multiqueue
devices by default.  A modification to tc is in another patchset being sent
that allows multiqueue behavior to be turned on for PRIO.

Documentation is also included describing in more detail how this works, as wellas how a base driver can use the API to implement multiple queues.

These patches can also be pulled from my git repository at:

        git-pull git://lost.foo-projects.org/~ppwaskie/git/netdev-2.6.22 mq

--
Peter P. Waskiewicz Jr.
<peter.p.waskiewicz.jr@intel.com>
