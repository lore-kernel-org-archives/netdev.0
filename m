From: Antonio Quartulli <a@unstable.cc>
Subject: pull request: batman-adv 20160109
Date: Sat,  9 Jan 2016 21:20:05 +0800
Message-ID: <1452345621-15908-1-git-send-email-a__42885.9757878401$1452345750$gmane$org@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:42793 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754490AbcAINWL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 08:22:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here you have a late batch of patches intended for net-next.

Most of the changes are about kerneldoc and other minor cleanups
introduced by Sven Eckelmann and Marek Lindner.

Other than those you have the number of BLA wait periods increased
to 6 to reduce the probability of temporary LAN loops by Simon
Wunderlich.

Several useless NULL checks have been removed by Markus Elfring in
order to make the code simpler and slimmer.

Another change by Simon Wunderlich makes sure that the function
consuming the value written in a sysfs file is executed only when
such value was really changed to a new value.


Please pull or let me know of any problem!
Thanks a lot,
	Antonio


The following changes since commit d86cdfcd5d7e1179e695977b7088882822f365c4:

  Merge branch 'r8152-adjustments' (2016-01-08 21:57:26 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to ed21d170e878b6b067a3216040b7b935c8007196:

  batman-adv: Add kerneldoc for batadv_neigh_node::refcount (2016-01-09 20:56:00 +0800)

----------------------------------------------------------------
Included changes:
- increase internal module version
- increase BLA wait periods to 6
- purge BLA backbone table when it is disabled
- make sure post function is invoked only if sysfs value is changed
- simplify code by removing useless NULL checks
- various corrections to existing kerneldoc
- minor cleanups

----------------------------------------------------------------
Marek Lindner (1):
      batman-adv: remove leftovers of unused BATADV_PRIMARIES_FIRST_HOP flag

Markus Elfring (4):
      batman-adv: Delete unnecessary checks before the function call "kfree_skb"
      batman-adv: Less checks in batadv_tvlv_unicast_send()
      batman-adv: Delete an unnecessary check before the function call "batadv_softif_vlan_free_ref"
      batman-adv: Split a condition check

Simon Wunderlich (4):
      batman-adv: Start new development cycle
      batman-adv: purge bridge loop avoidance when its disabled
      batman-adv: increase BLA wait periods to 6
      batman-adv: only call post function if something changed

Sven Eckelmann (7):
      batman-adv: Fix lockdep annotation of batadv_tlv_container_remove
      batman-adv: Add function to convert string to batadv throughput
      batman-adv: Change ifconfig examples to iproute2
      batman-adv: Fix kernel-doc parsing of main structs
      batman-adv: Fix kerneldoc member names in for main structs
      batman-adv: Remove kerneldoc for missing struct members
      batman-adv: Add kerneldoc for batadv_neigh_node::refcount

 Documentation/networking/batman-adv.txt |   9 ++-
 net/batman-adv/bat_iv_ogm.c             |   3 -
 net/batman-adv/bridge_loop_avoidance.c  |  20 ++++++
 net/batman-adv/bridge_loop_avoidance.h  |   2 +
 net/batman-adv/gateway_common.c         | 117 +++++++++++++-------------------
 net/batman-adv/main.c                   |  17 ++---
 net/batman-adv/main.h                   |   4 +-
 net/batman-adv/network-coding.c         |   4 +-
 net/batman-adv/packet.h                 |   3 +-
 net/batman-adv/send.c                   |   3 +-
 net/batman-adv/sysfs.c                  |  16 +++--
 net/batman-adv/translation-table.c      |   8 ++-
 net/batman-adv/types.h                  |  32 +++++----
 13 files changed, 122 insertions(+), 116 deletions(-)
