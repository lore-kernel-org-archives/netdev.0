From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 0/2] openvswitch: add IPv6 tunneling support
Date: Tue, 29 Sep 2015 19:52:24 +0200
Message-ID: <cover.1443548447.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53263 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753788AbbI2Rwr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2015 13:52:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This builds on the previous work that added IPv6 support to lwtunnels and
adds IPv6 tunneling support to ovs; it is now pretty straightforward. 

To use IPv6 tunneling, there needs to be a metadata based tunnel net_device
created and added to the ovs bridge. Currently, only vxlan is supported by
the kernel, with geneve to follow shortly. There's no need nor intent to add
a support for this into the vport-vxlan compat layer.

Jiri Benc (2):
  openvswitch: add tunnel protocol to sw_flow_key
  openvswitch: netlink attributes for IPv6 tunneling

 include/uapi/linux/openvswitch.h |   2 +
 net/openvswitch/flow.c           |   4 +-
 net/openvswitch/flow.h           |   1 +
 net/openvswitch/flow_netlink.c   | 125 +++++++++++++++++++++++++++------------
 net/openvswitch/flow_table.c     |   2 +-
 5 files changed, 93 insertions(+), 41 deletions(-)

-- 
1.8.3.1
