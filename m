From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [RFC PATCH 0/3] e1000/e1000e/igb MDI-X control implementation
Date: Wed, 17 Nov 2010 15:29:05 -0800
Message-ID: <20101117232645.3513.20655.stgit@jbrandeb-ich9b.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35477 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751369Ab0KQX3G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Nov 2010 18:29:06 -0500
Received: from jbrandeb-ich9b.jf.intel.com (localhost.localdomain [127.0.0.1])
	by jbrandeb-ich9b.jf.intel.com (8.14.4/8.14.4) with ESMTP id oAHNT52v003545
	for <netdev@vger.kernel.org>; Wed, 17 Nov 2010 15:29:05 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this patch series is RFC for implemenation, I've briefly tested
it to make sure I still get link after setting MDI-X and I see
the status change in ethtool.

The basic idea is to fill out the MDI-X read functionality with
some write functionality.

the e1000e patch is actually what drove this change as some users
have found wonky switches that must have MDI/MDI-X forced.

---

Jesse Brandeburg (3):
      e1000: configure and read mdix settings
      igb: update to allow reading/setting mdix
      e1000e: implement MDI-X control


 drivers/net/e1000/e1000.h         |    1 -
 drivers/net/e1000/e1000_ethtool.c |   13 +++++++++++++
 drivers/net/e1000/e1000_main.c    |    2 +-
 drivers/net/e1000e/e1000.h        |    1 -
 drivers/net/e1000e/ethtool.c      |    4 ++++
 drivers/net/e1000e/netdev.c       |    2 +-
 drivers/net/igb/igb.h             |    1 -
 drivers/net/igb/igb_ethtool.c     |   14 ++++++++++++++
 drivers/net/igb/igb_main.c        |    2 +-
 9 files changed, 34 insertions(+), 6 deletions(-)

-- 
jesse.brandeburg@intel.com
