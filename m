From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/4] add support for dissection and matching on ip tos and ttl
Date: Thu, 25 May 2017 16:24:35 +0300
Message-ID: <1495718679-20693-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53782 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751794AbdEYNYq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 09:24:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

The 1st two patches enable matching/classifying on ip tos and ttl by 
the flow dissector and flower. The other two patches offload matching 
on tcp flags and ip tos in mlx5. 

The mlx5 patches touch single file/function and not interfere with
other inflight mlx5 submissions.

Or.


Or Gerlitz (4):
  net/flow_dissector: add support for dissection of misc ip header fields
  net/sched: cls_flower: add support for matching on ip tos and ttl
  net/mlx5e: Offload TC matching on tcp flags
  net/mlx5e: Offload TC matching on ip tos / traffic-class

 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c | 46 ++++++++++++++++++++++++-
 include/net/flow_dissector.h                    | 11 ++++++
 include/uapi/linux/pkt_cls.h                    |  5 +++
 net/core/flow_dissector.c                       | 40 +++++++++++++++++++++
 net/sched/cls_flower.c                          | 39 +++++++++++++++++++--
 5 files changed, 138 insertions(+), 3 deletions(-)

-- 
2.3.7
