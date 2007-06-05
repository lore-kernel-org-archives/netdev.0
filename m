From: Patrick McHardy <kaber@trash.net>
Subject: [RFC VLAN 00/10]: VLAN netlink support try 2
Date: Tue,  5 Jun 2007 16:36:51 +0200 (MEST)
Message-ID: <20070605143650.23717.91261.sendpatchset@localhost.localdomain>
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64412 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762931AbXFEOgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 10:36:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The last VLAN patchset was outdated, sorry about the mixup. These are the
correct patches. The iproute patch I posted was correct, so no repost of
that one.


 include/linux/if_link.h  |   25 ++
 include/linux/if_vlan.h  |    7 
 net/8021q/Makefile       |    2 
 net/8021q/vlan.c         |  537 +++++++++++++++++++++++------------------------
 net/8021q/vlan.h         |   21 +
 net/8021q/vlan_dev.c     |  170 +++++---------
 net/8021q/vlan_netlink.c |  209 ++++++++++++++++++
 net/8021q/vlanproc.c     |    4 
 8 files changed, 586 insertions(+), 389 deletions(-)

Patrick McHardy (10):
      [VLAN]: Fix off-by-ones in VLAN ID checks
      [VLAN]: Convert name-based configuration functions to struct netdevice *
      [VLAN]: Move some device intialization code to dev->init callback
      [VLAN]: Move vlan_group allocation to seperate function
      [VLAN]: Split up device checks
      [VLAN]: Move device registation to seperate function
      [VLAN]: Return proper error codes in register_vlan_device
      [VLAN]: Use 32 bit value for skb->priority mapping
      [VLAN]: Keep track of number of QoS mappings
      [VLAN]: Use rtnl_link API
