From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 0/8] Preparation for VLAN_TAG_PRESENT cleanup, drivers part
Date: Wed,  4 Jan 2017 01:24:25 +0100 (CET)
Message-ID: <cover.1483488960.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:37466 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966926AbdADAY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 19:24:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cleanups needed before enabling passing of VLAN.CFI.
Those patches depend on '*** SUBJECT HERE ***' patchset, but
are otherwise independent of each other.

Michał Mirosław (8):
  benet: use __vlan_hwaccel helpers
  benet: use skb_vlan_tag_get_prio()
  sky2: use __vlan_hwaccel helpers
  net/core: use __vlan_hwaccel helpers
  bridge: use __vlan_hwaccel helpers
  8021q: use __vlan_hwaccel helpers
  ipv4/tunnel: use __vlan_hwaccel helpers
  OVS: remove use of VLAN_TAG_PRESENT

 drivers/net/ethernet/emulex/benet/be_main.c | 15 ++++++++++-----
 drivers/net/ethernet/marvell/sky2.c         |  6 ++----
 net/8021q/vlan_core.c                       |  2 +-
 net/bridge/br_netfilter_hooks.c             | 15 +++++++++------
 net/bridge/br_private.h                     |  2 +-
 net/bridge/br_vlan.c                        |  6 +++---
 net/core/dev.c                              |  8 +++++---
 net/core/skbuff.c                           |  2 +-
 net/ipv4/ip_tunnel_core.c                   |  2 +-
 net/openvswitch/actions.c                   | 13 +++++++++----
 net/openvswitch/flow.c                      |  4 ++--
 net/openvswitch/flow.h                      |  2 +-
 net/openvswitch/flow_netlink.c              | 22 +++++++++++-----------
 net/sched/act_vlan.c                        |  2 +-
 14 files changed, 57 insertions(+), 44 deletions(-)

-- 
2.11.0
