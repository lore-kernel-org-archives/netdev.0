From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [net-next-2.6 RFC PATCH v2 00/13] ethtool: allow custom interval for
Date: Wed, 13 Apr 2011 12:58:46 -0700
Message-ID: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51969 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758402Ab1DMT6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 15:58:47 -0400
Received: from gitlad.jf.intel.com (gitlad.jf.intel.com [127.0.0.1])
	by gitlad.jf.intel.com (8.14.2/8.14.2) with ESMTP id p3DJwkrG025997
	for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 12:58:46 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

physical identification

The following series changes the recently added ethtool set_phys_id
functions to allow drivers to provide a frequency at which to cycle
through an on/off identifier via software if/when the capability is
not provided by hardware.

---

Bruce Allan (13):
      tg3: set ethtool set_phys_id on/off cycle frequency to 1/sec
      sky2: set ethtool set_phys_id on/off cycle frequency to 1/sec
      skge: set ethtool set_phys_id on/off cycle frequency to 2/sec
      sfc: set ethtool set_phys_id on/off cycle frequency to 1/sec
      s2io: set ethtool set_phys_id on/off cycle frequency to 1/sec
      pcnet32: set ethtool set_phys_id on/off cycle frequency to 2/sec
      niu: set ethtool set_phys_id on/off cycle frequency to 1/sec
      ewrk3: set ethtool set_phys_id on/off cycle frequency to 2/sec
      cxgb3: set ethtool set_phys_id on/off cycle frequency to 1/sec
      bnx2x: set ethtool set_phys_id on/off cycle frequency to 1/sec
      bnx2: set ethtool set_phys_id on/off cycle frequency to 1/sec
      benet: set ethtool set_phys_id on/off cycle frequency to 1/sec
      ethtool: allow custom interval for physical identification


 drivers/net/benet/be_ethtool.c    |    2 +-
 drivers/net/bnx2.c                |    2 +-
 drivers/net/bnx2x/bnx2x_ethtool.c |    2 +-
 drivers/net/cxgb3/cxgb3_main.c    |    2 +-
 drivers/net/ewrk3.c               |    2 +-
 drivers/net/niu.c                 |    2 +-
 drivers/net/pcnet32.c             |    2 +-
 drivers/net/s2io.c                |    2 +-
 drivers/net/sfc/ethtool.c         |    6 +++---
 drivers/net/skge.c                |    2 +-
 drivers/net/sky2.c                |    2 +-
 drivers/net/tg3.c                 |    2 +-
 include/linux/ethtool.h           |    6 ++++--
 net/core/ethtool.c                |   13 ++++++++-----
 14 files changed, 26 insertions(+), 21 deletions(-)

-- 
Thanks,
Bruce.
