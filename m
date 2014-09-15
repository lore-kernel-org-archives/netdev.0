From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH 0/2] DSA Cleanups
Date: Mon, 15 Sep 2014 12:59:14 -0400
Message-ID: <20140915165543.1261.2520.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, kernel@wantstofly.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38683 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753817AbaIORI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 13:08:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series does two things, first it cleans up the tag_protocol and
protocol ops being configured seperately.  Second it addresses the desire
to split DSA away from relying on a MII bus.

---

Alexander Duyck (2):
      dsa: Split ops up, and avoid assigning tag_protocol and receive separately
      dsa: Replace mii_bus with a generic host device


 arch/arm/plat-orion/common.c      |    2 +
 drivers/net/dsa/bcm_sf2.c         |    2 +
 drivers/net/dsa/mv88e6060.c       |   13 ++++++---
 drivers/net/dsa/mv88e6123_61_65.c |    6 +++-
 drivers/net/dsa/mv88e6131.c       |    6 +++-
 drivers/net/dsa/mv88e6171.c       |    6 +++-
 drivers/net/dsa/mv88e6xxx.c       |    4 +--
 include/linux/netdevice.h         |    7 -----
 include/net/dsa.h                 |   19 +++++++------
 net/dsa/dsa.c                     |   56 ++++++++++++++++++++++++-------------
 net/dsa/dsa_priv.h                |   11 +++++++
 net/dsa/slave.c                   |   39 +++++++++++---------------
 net/dsa/tag_brcm.c                |    1 -
 net/dsa/tag_dsa.c                 |    1 -
 net/dsa/tag_edsa.c                |    1 -
 net/dsa/tag_trailer.c             |    1 -
 16 files changed, 101 insertions(+), 74 deletions(-)

-- 
