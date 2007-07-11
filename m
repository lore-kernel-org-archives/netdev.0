From: Patrick McHardy <kaber@trash.net>
Subject: [RTNETLINK 00/04]: rtnl_link improvements
Date: Wed, 11 Jul 2007 19:38:13 +0200 (MEST)
Message-ID: <20070711173812.18369.47109.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, greearb@candelatech.com,
	Patrick McHardy <kaber@trash.net>, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58334 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755606AbXGKRiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 13:38:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches simplify the rtnl_link API and add support for specifying
the initial device address. The rtnl_link patches depend on the VLAN fix
because I didn't want to build on top of the broken address handling.

Please apply, thanks.


 drivers/net/dummy.c      |   61 ++++++++------------------------------------
 drivers/net/ifb.c        |   62 ++++++++++----------------------------------
 include/linux/if_vlan.h  |    1 +
 net/8021q/vlan.c         |   64 ++++++++++++++++++++++++++--------------------
 net/8021q/vlan.h         |    1 -
 net/8021q/vlan_dev.c     |   57 +++++++++++++----------------------------
 net/8021q/vlan_netlink.c |    7 +++++
 net/core/rtnetlink.c     |   27 +++++++++++++++----
 net/ethernet/eth.c       |    3 ++
 9 files changed, 111 insertions(+), 172 deletions(-)

Patrick McHardy (4):
      [ETH]: Validate address in eth_mac_addr
      [VLAN]: Fix MAC address handling
      [RTNETLINK]: rtnl_link API simplification
      [RTNETLINK]: rtnl_link: allow specifying initial device address
