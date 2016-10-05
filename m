From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2 0/3] openvswitch: make vlan handling consistent
Date: Wed,  5 Oct 2016 15:07:25 +0200
Message-ID: <cover.1475672568.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45932 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754139AbcJENHl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 09:07:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Always keep the first vlan tag "accelerated", i.e. in skb->vlan_tci. This
simplifies things considerably.

v2: added the first patch

Jiri Benc (3):
  openvswitch: normalize vlan rx path
  openvswitch: remove unreachable code in vlan parsing
  openvswitch: fix vlan subtraction from packet length

 net/openvswitch/datapath.c | 10 ++++++++++
 net/openvswitch/flow.c     | 28 ++++++++--------------------
 net/openvswitch/vport.c    | 10 +++-------
 3 files changed, 21 insertions(+), 27 deletions(-)

-- 
1.8.3.1
