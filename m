From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 00/18]: Vlan update
Date: Sun, 20 Jan 2008 18:11:17 +0100 (MET)
Message-ID: <20080120171117.7980.67072.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62336 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754310AbYATRLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 12:11:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

the following patches contain a VLAN update for 2.6.25, consisting mainly
of minor cleanups removing duplicate code, avoiding forward declarations,
makeing functions static etc. Next I'll look into the skb->cb issues
with VLAN.

Please apply, thanks.


 drivers/net/cxgb3/l2t.c      |    2 +-
 drivers/s390/net/qeth_main.c |    4 +-
 include/linux/if_ether.h     |    1 +
 include/linux/if_vlan.h      |   61 +++---
 net/8021q/vlan.c             |  437 ++++++++++----------------------------
 net/8021q/vlan.h             |   42 +----
 net/8021q/vlan_dev.c         |  484 ++++++++++++++++++++----------------------
 net/8021q/vlan_netlink.c     |   17 +-
 net/8021q/vlanproc.c         |  107 ++++------
 net/8021q/vlanproc.h         |   11 +-
 10 files changed, 436 insertions(+), 730 deletions(-)

Patrick McHardy (17):
      [VLAN]: Remove unnecessary structure declarations
      [VLAN]: Clean up vlan_hdr/vlan_ethhdr structs
      [VLAN]: Kill useless VLAN_NAME define
      [VLAN]: Use dev->stats
      [VLAN]: Move device setup to vlan_dev.c
      [VLAN]: Kill useless check
      [ETHER]: Bring back MAC_FMT
      [VLAN]: Clean up debugging and printks
      [VLAN]: Remove non-implemented ioctls
      [VLAN]: Clean up initialization code
      [VLAN]: Clean up unregister_vlan_dev
      [VLAN]: Simplify vlan unregistration
      [VLAN]: Turn VLAN_DEV_INFO into inline function
      [VLAN]: Turn __constant_htons into htons where possible
      [VLAN]: checkpatch cleanups
      [VLAN]: Update list address
      [VLAN]: Clean up vlan_skb_recv()

Pavel Emelyanov (1):
      [VLAN]: Move protocol determination to seperate function
