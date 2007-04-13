From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 0/3] [UPDATED]: Multiqueue network device support
Date: Thu, 12 Apr 2007 17:16:30 -0700
Message-ID: <20070413001630.18763.41107.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, cramerj@intel.com, auke-jan.h.kok@intel.com,
	christopher.leech@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1804 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753908AbXDMADp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 20:03:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a redesign and repost of the multiqueue network device support patches. The new API for base drivers allows multiqueue-capable devices to manage their
individual queues in the network stack.  The stack now handles both
non-multiqueue and multiqueue devices on the same codepath.  Also, allocation
and deallocation of the queues is handled by the kernel instead of the driver.

Fixes have been integrated into this patchset based on community feedback.  A
patched version of e1000 using the multiqueue API has also been included.  NOTE
that this version of e1000 is *only* for testing purposes, and is not intended
to be integrated into the kernel at this time.  It is only for demonstration
purposes.

The e1000 patch will only work with MAC types of 82571 and higher.

Documentation is also included describing in more detail how this works, as
well as how a base driver can use the API to implement multiple queues.

These patches can also be pulled from my git repository at:

        git-pull git://lost.foo-projects.org/~ppwaskie/git/net-2.6.22 mq

--
Peter P. Waskiewicz Jr.
<peter.p.waskiewicz.jr@intel.com>
