From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 0/4] openvswitch tunneling preparation
Date: Thu, 13 Jun 2013 11:11:19 -0700
Message-ID: <1371147079-29139-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:40953 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751603Ab3FMSLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 14:11:24 -0400
Received: by mail-pb0-f43.google.com with SMTP id md12so9633388pbc.16
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 11:11:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches are required but not directly related to ovs tunneling.
So I am sending them as separate series. These cleanups are already
there in out of tree ovs module.

Since ovs tunneling series depends on this, I am sending all patches
again.

Pravin B Shelar (4):
  openvswitch: Unify vport error stats handling.
  openvswitch: Simplify interface ovs_flow_metadata_from_nlattrs()
  openvswitch: Fix struct comment.
  openvswitch: make skb->csum consistent with rest of networking stack.

 include/uapi/linux/openvswitch.h     |    1 -
 net/openvswitch/actions.c            |    4 ++++
 net/openvswitch/datapath.c           |    5 +----
 net/openvswitch/flow.c               |   25 +++++++++++++------------
 net/openvswitch/flow.h               |    4 ++--
 net/openvswitch/vport-internal_dev.c |    1 +
 net/openvswitch/vport-netdev.c       |    3 ++-
 net/openvswitch/vport.c              |    9 +++++++--
 net/openvswitch/vport.h              |   10 +++++++++-
 9 files changed, 39 insertions(+), 23 deletions(-)
