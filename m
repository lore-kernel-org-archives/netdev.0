From: Pravin B Shelar <pshelar@nicira.com>
Subject: [GIT net-next v9] Open vSwitch
Date: Thu, 24 Jul 2014 14:39:16 -0700
Message-ID: <1406237956-1601-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog116.obsmtp.com ([74.125.149.240]:50164 "HELO
	na3sys009aog116.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S933349AbaGXVjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 17:39:31 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so4646515pab.26
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 14:39:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches adds three features to OVS
1. Add fairness to upcall processing.
2. Hash action.
3. Enable Tunnel GSO features.
Rest of patches are bug fixes related to patches from same series.

v2 series changes first patch according to comment from Dave Miller.
v3 series changes first patch according to comment from Nikolay Aleksandrov.
v4 series update recirc patch commit msg.
v5 series resolve conflict with net-next, updated recic action patch.
v6 series sends all patches.
v7 series drop recirc patches.
v8 series checkpatch fix 
v9 series drop HASH action patch. update sample action commit msg.
----------------------------------------------------------------

The following changes since commit f6e675324481c56b358091ddb446b2c95a8e047b:

  Merge branch 'filter-move' (2014-07-23 21:06:30 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/pshelar/openvswitch.git net_next_ovs

for you to fetch changes up to d9e0ecb81417c34ef8c02a6880d23c362300cda0:

  openvswitch: Add skb_clone NULL check for the sampling action. (2014-07-24 09:37:22 -0700)

----------------------------------------------------------------
Alex Wang (1):
      openvswitch: Allow each vport to have an array of 'port_id's.

Andy Zhou (2):
      openvswitch: Avoid memory corruption in queue_userspace_packet()
      openvswitch: Add skb_clone NULL check for the sampling action.

Pravin B Shelar (1):
      openvswitch: Enable tunnel GSO for OVS bridge.

Simon Horman (1):
      openvswitch: Sample action without side effects

 include/linux/netdev_features.h      |   8 +++
 include/uapi/linux/openvswitch.h     |  13 +++--
 net/openvswitch/actions.c            |  50 +++++++++++++----
 net/openvswitch/datapath.c           |  26 ++++++---
 net/openvswitch/vport-internal_dev.c |   5 +-
 net/openvswitch/vport.c              | 101 ++++++++++++++++++++++++++++++++++-
 net/openvswitch/vport.h              |  27 ++++++++--
 7 files changed, 201 insertions(+), 29 deletions(-)
