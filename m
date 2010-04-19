From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 0/2] iovnl netlink ops + enic dynamic vnics
Date: Mon, 19 Apr 2010 12:18:02 -0700
Message-ID: <20100419191425.10423.88005.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:10548 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344Ab0DSTSF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 15:18:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1/2 adds new I/O Virtualization netlink ops:

  IOV netlink (IOVNL) adds I/O Virtualization control support to a master
  device (MD) netdev interface.  The MD (e.g. SR-IOV PF) will set/get
  control settings on behalf of a slave netdevice (e.g. SR-IOV VF).  The
  design allows for the case where master and slave are the
  same netdev interface.

  The ops currently defined are:
  	set_mac_vlan: set mac+vlan on VF
	set_port_profile: set port-profile on VF
	unset_port_profile: unset port-profile on VF

Patch 2/2 adds IOV netlink ops support to enic dynamic vnics:

  Add enic iovnl ops to support setting port-profile for dynamic vnics.  Enic
  dynamic vnics are just like normal enic eth vnics except dynamic vnics require
  an extra configuration step to assign a port-profile identifier to the
  interface before the interface is useable. Once assigned, link comes up
  on the interface and is ready for I/O.  The port-profile is used to configure
  the network port assigned to the interface.  The network port configuration
  includes VLAN membership, QoS policies, and port security settings typical
  of a data center network.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu<roprabhu@cisco.com>
