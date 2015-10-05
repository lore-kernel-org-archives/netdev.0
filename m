From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v3 0/2] openvswitch: add IPv6 tunneling support
Date: Mon,  5 Oct 2015 13:09:45 +0200
Message-ID: <cover.1444041801.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58892 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750821AbbJELJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2015 07:09:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This builds on the previous work that added IPv6 support to lwtunnels and
adds IPv6 tunneling support to ovs.

To use IPv6 tunneling, there needs to be a metadata based tunnel net_device
created and added to the ovs bridge. Currently, only vxlan is supported by
the kernel, with geneve to follow shortly. There's no need nor intent to add
a support for this into the vport-vxlan (etc.) compat layer.
---

v3: dropped the last two patches added in v2.

Jiri Benc (2):
  openvswitch: add tunnel protocol to sw_flow_key
  openvswitch: netlink attributes for IPv6 tunneling

 include/uapi/linux/openvswitch.h |   2 +
 net/openvswitch/flow.c           |   4 +-
 net/openvswitch/flow.h           |   1 +
 net/openvswitch/flow_netlink.c   | 129 +++++++++++++++++++++++++++------------
 net/openvswitch/flow_table.c     |   2 +-
 5 files changed, 97 insertions(+), 41 deletions(-)

-- 
1.8.3.1
