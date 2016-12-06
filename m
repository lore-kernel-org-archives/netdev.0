From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/3] net/sched: cls_flower: Add support for matching on dissection flags
Date: Tue,  6 Dec 2016 14:32:56 +0200
Message-ID: <1481027579-23195-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:41019 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752600AbcLFMdK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 07:33:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series add the UAPI to provide set of flags for matching, where the 
flags provided from user-space are mapped to flow-dissector flags.

The 1st flag allows to match on whether the packet is an
IP fragment and corresponds to the FLOW_DIS_IS_FRAGMENT flag.

Or

Or Gerlitz (3):
  net/flow_dissector: Enable matching on flags for TC filter consumers
  net/sched: cls_flower: Add support for matching on flags
  net/mlx5e: Offload TC matching on packets being IP fragments

 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 12 ++++
 include/net/flow_dissector.h                    |  2 +-
 include/uapi/linux/pkt_cls.h                    |  7 +++
 net/sched/cls_flower.c                          | 83 +++++++++++++++++++++++++
 4 files changed, 103 insertions(+), 1 deletion(-)

-- 
2.3.7
