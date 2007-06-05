From: Patrick McHardy <kaber@trash.net>
Subject: [RFC VLAN 00/08]: VLAN netlink support
Date: Tue,  5 Jun 2007 16:23:28 +0200 (MEST)
Message-ID: <20070605142327.20372.18108.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64160 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762802AbXFEOXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:23:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches convert VLAN to the rtnl_link API as a more complex example.
The patches need some more work, not all VLAN features are supported yet.

 include/linux/if_link.h   |   25 +
 include/linux/if_vlan.h   |    8 
 include/linux/rtnetlink.h |    3 
 net/8021q/Makefile        |    2 
 net/8021q/vlan.c          |  698 +++++++++++++++++++++-------------------------
 net/8021q/vlan.h          |   22 +
 net/8021q/vlan_dev.c      |  170 +++--------
 net/8021q/vlan_netlink.c  |  194 ++++++++++++
 net/8021q/vlanproc.c      |    4 
 9 files changed, 627 insertions(+), 499 deletions(-)

Patrick McHardy (8):
      [VLAN]: Move device lookup to ioctl handler
      [VLAN]: Remove unregister_vlan_dev wrapper
      [VLAN]: Add device init callback
      [VLAN]: Move vlan_group allocation to seperate function
      [VLAN]: Split up device creation
      [VLAN]: Use 32 bit value for skb->priority mapping
      [VLAN]: Keep track of number of QoS mappings
      [VLAN]: Use rtnl_link API
