From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: [net-next PATCH v2 0/3] Broadcast/Multicast rate limit via Ethtool Coalesce
Date: Wed, 9 Jul 2014 12:44:07 +0530
Message-ID: <1404890050-4020-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A system/cpu can be loaded by a hacker with flooding of broadcast or
multicast packets, to prevent this some Ethernet controllers like CPSW
provide a mechanism to limit the broadcast/multicast packet rate via
hardware limiters. This patch series enables this feature via
Ethtool Coalesce.

Mugunthan V N (3):
  net: ethtool: Add Multicast and broadcast rate limit coalescing
    feature
  drivers: net: cpsw: remove redundancy check
  drivers: net: cpsw: Add support for multicast/broadcast rate limit

 drivers/net/ethernet/ti/cpsw.c | 83 +++++++++++++++++++++++++++++++++++++++---
 include/uapi/linux/ethtool.h   |  4 ++
 2 files changed, 82 insertions(+), 5 deletions(-)

-- 
2.0.0.390.gcb682f8
