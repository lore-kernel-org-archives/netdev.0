From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 0/4] openvswitch tunneling preparation
Date: Wed, 12 Jun 2013 15:56:52 -0700
Message-ID: <1371077812-19640-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:44105 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758055Ab3FLW5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 18:57:04 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq13so4344228pab.11
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 15:56:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patches are required but not directly related to ovs tunneling.
So I am sending them as separate series. These cleanups are already
there in out of tree ovs module.

Pravin B Shelar (4):
  openvswitch: Unify vport error stats handling.
  openvswitch: Simplify interface ovs_flow_metadata_from_nlattrs()
  openvswitch: Fix struct comment.
  openvsiwtch: make skb->csum consistent with rest of networking stack.

 include/uapi/linux/openvswitch.h     |    1 -
 net/openvswitch/actions.c            |    4 ++++
 net/openvswitch/datapath.c           |    6 ++----
 net/openvswitch/flow.c               |   26 ++++++++++++++------------
 net/openvswitch/flow.h               |    4 ++--
 net/openvswitch/vport-internal_dev.c |    1 +
 net/openvswitch/vport-netdev.c       |    3 ++-
 net/openvswitch/vport.c              |    9 +++++++--
 net/openvswitch/vport.h              |   10 +++++++++-
 9 files changed, 41 insertions(+), 23 deletions(-)
