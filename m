From: Sven Eckelmann <sven@narfation.org>
Subject: pull request: batman-adv 2011-05-01
Date: Sun,  1 May 2011 23:10:30 +0200
Message-ID: <1304284234-27338-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:40381 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753993Ab1EAVLH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 May 2011 17:11:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like to propose following patches for net-next-2.6/2.6.40. Marek
Lindner continued to convert different datastructures to use RCU. Antonio
Quartulli fixed an important bug introduced in the last patchset related to the
update of the current gateway. He also did some minor cleanup work.

I've removed the patch "net: batman-adv: remove rx_csum ethtool_ops" again
because you already applied it in your branch.

thanks,
	Sven

The following changes since commit af20b710479ae662829cf739b521390daa7fcbcb:

  batman-adv: Set the txqueuelen to zero when creating soft interface (2011-04-17 21:11:02 +0200)

are available in the git repository at:
  git://git.open-mesh.org/ecsv/linux-merge.git batman-adv/next

Antonio Quartulli (3):
      batman-adv: orig_hash_find() manages rcu_lock/unlock internally
      batman-adv: Move definition of atomic_dec_not_zero() into main.h
      batman-adv: fix gw_node_update() and gw_election()

Marek Lindner (1):
      batman-adv: Make bat_priv->primary_if an rcu protected pointer

 net/batman-adv/aggregation.c       |    1 -
 net/batman-adv/gateway_client.c    |   45 ++++++++++++--------
 net/batman-adv/hard-interface.c    |   83 ++++++++++++++++++++++++-----------
 net/batman-adv/hard-interface.h    |   18 ++++++++
 net/batman-adv/icmp_socket.c       |   19 ++++++--
 net/batman-adv/main.h              |    2 +
 net/batman-adv/originator.c        |   34 +++++++++------
 net/batman-adv/routing.c           |   34 ++++++---------
 net/batman-adv/send.c              |   18 ++++++--
 net/batman-adv/soft-interface.c    |   64 +++++++++++++++++++--------
 net/batman-adv/translation-table.c |   57 ++++++++++++++++++------
 net/batman-adv/types.h             |    2 +-
 net/batman-adv/unicast.c           |   16 +++++--
 net/batman-adv/vis.c               |   37 +++++++++++-----
 14 files changed, 292 insertions(+), 138 deletions(-)
