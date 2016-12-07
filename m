From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V3 0/2] net/sched: cls_flower: Add support for matching on dissection flags
Date: Wed,  7 Dec 2016 14:03:09 +0200
Message-ID: <1481112191-14115-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:37732 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752703AbcLGMDS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 07:03:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series add the UAPI to provide set of flags for matching, where the 
flags provided from user-space are mapped to flow-dissector flags.

The 1st flag allows to match on whether the packet is an
IP fragment and corresponds to the FLOW_DIS_IS_FRAGMENT flag.

Or

v2->v3:
  - replace BIT() with << (kbuild test robot)

v1->v2:
 - dropped the flow dissector patch (#1) as no changes are needed there (Jiri)
 - applied code review comments from Jiri to the flower patch

Or Gerlitz (2):
  net/sched: cls_flower: Add support for matching on flags
  net/mlx5e: Offload TC matching on packets being IP fragments

 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 12 ++++
 include/uapi/linux/pkt_cls.h                    |  7 +++
 net/sched/cls_flower.c                          | 76 +++++++++++++++++++++++++
 3 files changed, 95 insertions(+)

-- 
2.3.7
