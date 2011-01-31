From: Sven Eckelmann <sven@narfation.org>
Subject: pull request: batman-adv 2011-01-31
Date: Mon, 31 Jan 2011 16:20:42 +0100
Message-ID: <1296487251-12552-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:42645 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746Ab1AaPVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 10:21:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like to propose some changes for net-next-2.6.git. These include two
bugfixes for the fragmentation handling which were not accepted in net-2.6. The
last seven changes are only cleanups and non-functionality changes.

No included change has any hard dependencies to the oops fixes which were
pulled by you into net-2.6 yesterday.

thanks,
	Sven

The following changes since commit 1bae4ce27c9c90344f23c65ea6966c50ffeae2f5:

  Linux 2.6.38-rc2 (2011-01-21 19:01:34 -0800)

are available in the git repository at:
  git://git.open-mesh.org/ecsv/linux-merge.git batman-adv/next

Simon Wunderlich (1):
      batman-adv: remove unused parameters

Sven Eckelmann (8):
      batman-adv: Create roughly equal sized fragments
      batman-adv: Calculate correct size for merged packets
      batman-adv: Remove dangling declaration of hash_remove_element
      batman-adv: Remove unused definitions
      batman-adv: Remove declaration of batman_skb_recv
      batman-adv: Remove unused variables
      batman-adv: Update copyright years
      batman-adv: Merge README of v2011.0.0 release

 Documentation/networking/batman-adv.txt |   16 ++++++++--------
 net/batman-adv/Makefile                 |    2 +-
 net/batman-adv/aggregation.c            |    2 +-
 net/batman-adv/aggregation.h            |    2 +-
 net/batman-adv/bat_debugfs.c            |    6 ++----
 net/batman-adv/bat_debugfs.h            |    2 +-
 net/batman-adv/bat_sysfs.c              |    2 +-
 net/batman-adv/bat_sysfs.h              |    2 +-
 net/batman-adv/bitarray.c               |    2 +-
 net/batman-adv/bitarray.h               |    2 +-
 net/batman-adv/gateway_client.c         |    2 +-
 net/batman-adv/gateway_client.h         |    2 +-
 net/batman-adv/gateway_common.c         |    2 +-
 net/batman-adv/gateway_common.h         |    2 +-
 net/batman-adv/hard-interface.c         |   13 ++++++++++---
 net/batman-adv/hard-interface.h         |    6 +-----
 net/batman-adv/hash.c                   |    2 +-
 net/batman-adv/hash.h                   |    7 +------
 net/batman-adv/icmp_socket.c            |    2 +-
 net/batman-adv/icmp_socket.h            |    2 +-
 net/batman-adv/main.c                   |    2 +-
 net/batman-adv/main.h                   |   17 +----------------
 net/batman-adv/originator.c             |    4 ++--
 net/batman-adv/originator.h             |    2 +-
 net/batman-adv/packet.h                 |    3 ++-
 net/batman-adv/ring_buffer.c            |    2 +-
 net/batman-adv/ring_buffer.h            |    2 +-
 net/batman-adv/routing.c                |   26 ++++++++------------------
 net/batman-adv/routing.h                |    5 ++---
 net/batman-adv/send.c                   |    6 +++---
 net/batman-adv/send.h                   |    2 +-
 net/batman-adv/soft-interface.c         |    2 +-
 net/batman-adv/soft-interface.h         |    2 +-
 net/batman-adv/translation-table.c      |    2 +-
 net/batman-adv/translation-table.h      |    2 +-
 net/batman-adv/types.h                  |    2 +-
 net/batman-adv/unicast.c                |   15 ++++++++++-----
 net/batman-adv/unicast.h                |   25 ++++++++++++++++++++++++-
 net/batman-adv/vis.c                    |    2 +-
 net/batman-adv/vis.h                    |    2 +-
 40 files changed, 101 insertions(+), 102 deletions(-)
