From: Antonio Quartulli <a@unstable.cc>
Subject: pull request [net-next]: batman-adv 20160223
Date: Tue, 23 Feb 2016 14:08:03 +0800
Message-ID: <1456207703-903-1-git-send-email-a__10923.719025641$1456207859$gmane$org@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:45712 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751214AbcBWGKq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:10:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

thanks for notifying me about the merge !

This is another pull request intended for net-next and it is
basically all cleanup work, mostly by Sven Eckelmann.

First the BATADV_BONDING_TQ_THRESHOLD
constant gets removed as it was defined but not used anywhere,
then all our *_free_ref functions are renamed to *_put in order
to follow the kernel naming convention.

Please pull or let me know of any problem!
Thanks a lot,
	Antonio


The following changes since commit b633353115e352d3c31c12d4c61978c810f05ea1:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2016-02-23 00:09:14 -0500)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 7e2366c6267d4ea257c4d0deb2fcf0744749de5f:

  batman-adv: Rename batadv_tt_orig_list_entry *_free_ref function to *_put (2016-02-23 13:51:01 +0800)

----------------------------------------------------------------
This is a cleanup patchset: first the BATADV_BONDING_TQ_THRESHOLD
constant gets removed as it was defined but not used anywhere,
then all our *_free_ref functions are renamed to *_put in order
to follow the kernel naming convention by Sven Eckelmann.

----------------------------------------------------------------
Antonio Quartulli (1):
      batman-adv: remove unused BATADV_BONDING_TQ_THRESHOLD constant

Sven Eckelmann (19):
      batman-adv: Rename batadv_orig_node *_free_ref function to *_put
      batman-adv: Rename batadv_hardif *_free_ref function to *_put
      batman-adv: Rename batadv_neigh_node *_free_ref function to *_put
      batman-adv: Rename batadv_neigh_ifinfo *_free_ref function to *_put
      batman-adv: Rename batadv_orig_ifinfo *_free_ref function to *_put
      batman-adv: Rename batadv_hardif_neigh *_free_ref function to *_put
      batman-adv: Rename batadv_backbone_gw *_free_ref function to *_put
      batman-adv: Rename batadv_claim *_free_ref function to *_put
      batman-adv: Rename batadv_dat_entry *_free_ref function to *_put
      batman-adv: Rename batadv_gw_node *_free_ref function to *_put
      batman-adv: Rename batadv_tvlv_handler *_free_ref function to *_put
      batman-adv: Rename batadv_tvlv_container *_free_ref function to *_put
      batman-adv: Rename batadv_softif_vlan *_free_ref function to *_put
      batman-adv: Rename batadv_nc_node *_free_ref function to *_put
      batman-adv: Rename batadv_nc_path *_free_ref function to *_put
      batman-adv: Rename batadv_orig_node_vlan *_free_ref function to *_put
      batman-adv: Rename batadv_tt_local_entry *_free_ref function to *_put
      batman-adv: Rename batadv_tt_global_entry *_free_ref function to *_put
      batman-adv: Rename batadv_tt_orig_list_entry *_free_ref function to *_put

 net/batman-adv/bat_iv_ogm.c            |  72 +++++++++---------
 net/batman-adv/bridge_loop_avoidance.c |  63 ++++++++--------
 net/batman-adv/distributed-arp-table.c |  24 +++---
 net/batman-adv/fragmentation.c         |   6 +-
 net/batman-adv/gateway_client.c        |  73 +++++++++---------
 net/batman-adv/hard-interface.c        |  20 ++---
 net/batman-adv/hard-interface.h        |   4 +-
 net/batman-adv/icmp_socket.c           |   6 +-
 net/batman-adv/main.c                  |  27 ++++---
 net/batman-adv/main.h                  |   5 --
 net/batman-adv/network-coding.c        |  38 +++++-----
 net/batman-adv/originator.c            |  76 +++++++++----------
 net/batman-adv/originator.h            |  12 +--
 net/batman-adv/routing.c               |  48 ++++++------
 net/batman-adv/send.c                  |  12 +--
 net/batman-adv/soft-interface.c        |  20 ++---
 net/batman-adv/soft-interface.h        |   2 +-
 net/batman-adv/sysfs.c                 |  12 +--
 net/batman-adv/translation-table.c     | 132 ++++++++++++++++-----------------
 19 files changed, 322 insertions(+), 330 deletions(-)
