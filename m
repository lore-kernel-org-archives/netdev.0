From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 0/2] openvswitch: vlan fixes
Date: Tue,  4 Oct 2016 14:30:00 +0200
Message-ID: <cover.1475583870.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33044 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753298AbcJDMaQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 08:30:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a bug and inefficiency in the vlan handling code introduced by the
802.1AD set. Strictly speaking, both were present even before that set
but it made them more prominent.

Jiri Benc (2):
  openvswitch: remove nonreachable code in vlan parsing
  openvswitch: fix vlan subtraction from packet length

 net/openvswitch/flow.c  | 28 ++++++++--------------------
 net/openvswitch/vport.c | 10 +++-------
 2 files changed, 11 insertions(+), 27 deletions(-)

-- 
1.8.3.1
