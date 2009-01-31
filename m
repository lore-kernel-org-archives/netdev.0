From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Sat, 31 Jan 2009 01:06:32 -0800 (PST)
Message-ID: <20090131.010632.79644071.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59957
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751149AbZAaJGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 04:06:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I would have waited another day on this one but I wanted to get the
IPV6 allmodconfig build fix from Dave Jones to you as fast as
possible.

I mean, having the allmodconfig build failing on superbowl sunday,
isn't that against the law or something?

1) AF_PACKET deadlock fix from Herbert Xu.

2) IPV6 build fix from Dave Jones.

3) SFC driver bug fixes from Ben Hutchings and Steve Hodgson.

4) Intel IGB bug fixes from Alexander Duyck.

Please pull, thanks a lot!

The following changes since commit f99ec0649accb581cf3e8fcfeea796e82d05f4ea:
  Philippe De Muyter (1):
        tulip: fix 21142 with 10Mbps without negotiation

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alexander Duyck (3):
      igb: Fix DCA errors and do not use context index for 82576
      igb: prevent skb_over panic w/ mtu smaller than 1K
      igb: fix link reporting when using sgmii

Alexey Dobriyan (1):
      sky2: fix hard hang with netconsoling and iface going up

Ben Hutchings (5):
      sfc: SFN4111T: Fix GPIO sharing between I2C and FLASH_CFG_1
      sfc: Update board info for hardware monitor on SFN4111T-R5 and later
      sfc: SFT9001: Always enable XNP exchange on SFT9001 rev B
      sfc: SFX7101/SFT9001: Fix AN advertisements
      sfc: Replace stats_enabled flag with a disable count

Dave Jones (1):
      ipv6: compile fix for ip6mr.c

Herbert Xu (1):
      packet: Avoid lock_sock in mmap handler

Steve Hodgson (6):
      sfc: SFT9001: Enable robust link training
      sfc: SFX7101: Remove workaround for bad link training
      sfc: SFT9001: Fix speed reporting in 1G PHY loopback
      sfc: Fix post-reset MAC selection
      sfc: Reinitialise the PHY completely in case of a PHY or NIC reset
      sfc: Test for PHYXS faults whenever we cannot test link state bits

 drivers/net/igb/e1000_82575.c |   11 ++-
 drivers/net/igb/igb.h         |    9 +-
 drivers/net/igb/igb_main.c    |   24 ++---
 drivers/net/sfc/efx.c         |   59 ++++++++----
 drivers/net/sfc/efx.h         |    9 +-
 drivers/net/sfc/ethtool.c     |    3 -
 drivers/net/sfc/falcon.c      |   32 ++++---
 drivers/net/sfc/mdio_10g.c    |  191 +++++++++++++++++--------------------
 drivers/net/sfc/mdio_10g.h    |    3 +-
 drivers/net/sfc/net_driver.h  |    9 +-
 drivers/net/sfc/phy.h         |    1 -
 drivers/net/sfc/selftest.c    |    7 +-
 drivers/net/sfc/sfe4001.c     |   42 +++++++--
 drivers/net/sfc/tenxpress.c   |  213 +++++++++++++++--------------------------
 drivers/net/sfc/workarounds.h |   12 +--
 drivers/net/sky2.c            |    6 +-
 net/ipv6/ip6mr.c              |    1 +
 net/packet/af_packet.c        |    9 ++-
 18 files changed, 313 insertions(+), 328 deletions(-)
