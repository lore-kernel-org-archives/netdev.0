From: Pravin B Shelar <pshelar@nicira.com>
Subject: [GIT net-next v7] Open vSwitch
Date: Mon, 21 Jul 2014 23:29:33 -0700
Message-ID: <1406010573-1717-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:34105 "HELO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752346AbaGVG3k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 02:29:40 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so10882127pab.0
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 23:29:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches adds three features to OVS
1. Add fairness to upcall processing.
2. Hash action.
3. Enable Tunnel GSO features.
Rest of paches are general improvemnts in OVS.

v2 series changes first patch according to comment from Dave Miller.
v3 series changes first patch according to comment from Nikolay Aleksandrov.
v4 series chage recirc patch commit msg.
v5 series resolve conflict with net-next, updated recic action patch.
v6 series sends all patches.
v7 series drop recirc patches. 
----------------------------------------------------------------

The following changes since commit 575a19354c80fde236382755592256d30d2a27fb:

  net: mvpp2: Fix error return code in mvpp2_probe() (2014-07-20 22:26:58 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git net_next_ovs

for you to fetch changes up to d585f4e31fa44d77ec3b06022c20781bd7af18cb:

  openvswitch: Add skb_clone NULL check for the sampling action. (2014-07-21 20:15:15 -0700)

----------------------------------------------------------------
Alex Wang (1):
      openvswitch: Allow each vport to have an array of 'port_id's.

Andy Zhou (3):
      openvswitch: Add hash action
      openvswitch: Avoid memory corruption in queue_userspace_packet()
      openvswitch: Add skb_clone NULL check for the sampling action.

Pravin B Shelar (1):
      openvswitch: Enable tunnel GSO for OVS bridge.

Simon Horman (1):
      openvswitch: Sample action without side effects

 include/linux/netdev_features.h      |  8 +++
 include/uapi/linux/openvswitch.h     | 37 ++++++++++++--
 net/openvswitch/actions.c            | 69 +++++++++++++++++++++----
 net/openvswitch/datapath.c           | 24 ++++++---
 net/openvswitch/flow.h               |  1 +
 net/openvswitch/flow_netlink.c       | 27 +++++++++-
 net/openvswitch/vport-internal_dev.c |  5 +-
 net/openvswitch/vport.c              | 99 +++++++++++++++++++++++++++++++++++-
 net/openvswitch/vport.h              | 27 ++++++++--
 9 files changed, 267 insertions(+), 30 deletions(-)
