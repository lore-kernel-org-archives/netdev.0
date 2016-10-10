From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net 0/3] openvswitch: vlan fixes
Date: Mon, 10 Oct 2016 17:02:41 +0200
Message-ID: <cover.1476111550.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54864 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752895AbcJJPDD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Oct 2016 11:03:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix three issues introduced by the 802.1AD patchset.

Jiri Benc (3):
  openvswitch: vlan: remove wrong likely statement
  openvswitch: fix vlan subtraction from packet length
  openvswitch: add NETIF_F_HW_VLAN_STAG_TX to internal dev

 net/openvswitch/flow.c               | 2 +-
 net/openvswitch/vport-internal_dev.c | 2 +-
 net/openvswitch/vport.c              | 3 ++-
 3 files changed, 4 insertions(+), 3 deletions(-)

-- 
1.8.3.1
