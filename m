From: Antonio Quartulli <a@unstable.cc>
Subject: pull request: batman-adv 20160504
Date: Wed,  4 May 2016 06:23:35 +0800
Message-ID: <1462314230-16257-1-git-send-email-a__43975.0489582822$1462314284$gmane$org@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:13159 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756519AbcECWYZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 18:24:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request intended for net-next.

In this batch you don't have any patch that depends on our fixes,
therefore you can safely merge it even if the net tree has not been
merged yet.

In this patchset you basically have some cleanup work, code refactoring,
style fixes and two updates for the MAINTAINERS file.

Please pull or let me know of any problem!

Thanks a lot,
	Antonio


The following changes since commit e03179fe78d5b39dbf3e8b0b50f7c406514b15c7:

  net: ethernet: fec_mpc52xx: move to new ethtool api {get|set}_link_ksettings (2016-05-03 13:03:53 -0400)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 64ae74455371a40bc9f9c8325eb4c37f2978c95f:

  batman-adv: Split batadv_iv_ogm_orig_del_if function (2016-05-04 02:22:03 +0800)

----------------------------------------------------------------
In this pull request you have:
- two changes to the MAINTAINERS file where one marks our mailing list
  as moderated and the other adds a missing documentation file
- kernel-doc fixes
- code refactoring and various cleanups

----------------------------------------------------------------
Antonio Quartulli (2):
      batman-adv: use static string for table headers
      batman-adv: fix wrong names in kerneldoc

Geliang Tang (2):
      batman-adv: use list_for_each_entry_safe
      batman-adv: use to_delayed_work

Simon Wunderlich (4):
      batman-adv: Start new development cycle
      batman-adv: fix debuginfo macro style issue
      batman-adv: move and restructure batadv_v_ogm_forward
      batman-adv: Merge batadv_v_ogm_orig_update into batadv_v_ogm_route_update

Sven Eckelmann (7):
      MAINTAINERS: Mark BATMAN ADVANCED mailing list as moderated
      MAINTAINERS: Add BATMAN ADVANCED documentation files
      batman-adv: Fix checkpatch warning about 'unsigned' type
      batman-adv: Fix kerneldoc for batadv_compare_claim
      batman-adv: Add kernel-doc for batadv_interface_rx
      batman-adv: Fix function names on new line starting with '*'
      batman-adv: Split batadv_iv_ogm_orig_del_if function

 MAINTAINERS                            |   5 +-
 net/batman-adv/bat_iv_ogm.c            | 123 +++++++++++++-------
 net/batman-adv/bat_v.c                 |   9 +-
 net/batman-adv/bat_v_ogm.c             | 205 ++++++++++++++++-----------------
 net/batman-adv/bridge_loop_avoidance.c |  19 ++-
 net/batman-adv/debugfs.c               |  19 +--
 net/batman-adv/distributed-arp-table.c |   8 +-
 net/batman-adv/fragmentation.c         |  12 +-
 net/batman-adv/icmp_socket.c           |  24 ++--
 net/batman-adv/main.c                  |   8 +-
 net/batman-adv/main.h                  |   5 +-
 net/batman-adv/multicast.c             |  11 +-
 net/batman-adv/network-coding.c        |  20 ++--
 net/batman-adv/originator.c            |   4 +-
 net/batman-adv/packet.h                |   2 +-
 net/batman-adv/send.c                  |   4 +-
 net/batman-adv/soft-interface.c        |  20 +++-
 net/batman-adv/translation-table.c     |  11 +-
 18 files changed, 277 insertions(+), 232 deletions(-)
