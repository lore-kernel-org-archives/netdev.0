From: Antonio Quartulli <ordex@autistici.org>
Subject: pull request: batman-adv 2012-07-01
Date: Mon,  2 Jul 2012 01:43:30 +0200
Message-ID: <1341186226-10549-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:23526 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233Ab2GAXng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 19:43:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this should be our last planned pull request intended for net-next/linux-3.6 :-)

In this batch you have patch 15/16 that fixes a variable declaration
in the ethtool support code; patch 16/16 that fixes a non-critical bug which
makes nodes send unicast packets with an uninitialised header field.
The rest is the last part of our namespace renaming operation plus a couple of
style fixes.

Please let me know if there are problems!

Thank you very much,
		Antonio

The following changes since commit a59a4d1921664da63d801ba477950114c71c88c9:

  phy: add the EEE support and the way to access to the MMD registers. (2012-07-01 03:34:50 -0700)

are available in the git repository at:

  git://git.open-mesh.org/linux-merge.git tags/batman-adv-for-davem

for you to fetch changes up to 162d549c6905485262635fe594db337efb2828b5:

  batman-adv: Don't leak information through uninitialized packet fields (2012-07-01 22:47:24 +0200)

----------------------------------------------------------------
Included changes:
- The last batch of patches aimed to clean the batman-adv namespace
- a couple of style fixes
- a fix for the ethtool support
- a fix to prevent sending unicast packets with an uninitialised header
  field

----------------------------------------------------------------
Marek Lindner (1):
      batman-adv: fix counter summary length

Sven Eckelmann (15):
      batman-adv: Prefix gateway enum with BATADV_
      batman-adv: Prefix hard-interface enum with BATADV_
      batman-adv: Prefix types enum with BATADV_
      batman-adv: Prefix packet enum with BATADV_
      batman-adv: Prefix main enum with BATADV_
      batman-adv: Prefix local debugfs structs with batadv_
      batman-adv: Prefix hash struct and typedef with batadv_
      batman-adv: Prefix local sysfs struct with batadv_
      batman-adv: Prefix packet structs with batadv_
      batman-adv: Prefix types structs with batadv_
      batman-adv: Transform BATADV_LOG_BUFF(idx) into function
      batman-adv: Remove bat_ prefix from bat_{debugfs, sysfs}.{c, h}
      batman-adv: Remove space before semicolon
      batman-adv: Fix alignment after opened parentheses
      batman-adv: Don't leak information through uninitialized packet fields

 net/batman-adv/Makefile                     |    4 +-
 net/batman-adv/bat_iv_ogm.c                 |  459 +++++++--------
 net/batman-adv/bitarray.c                   |    6 +-
 net/batman-adv/bridge_loop_avoidance.c      |  302 +++++-----
 net/batman-adv/bridge_loop_avoidance.h      |   48 +-
 net/batman-adv/{bat_debugfs.c => debugfs.c} |   76 ++-
 net/batman-adv/{bat_debugfs.h => debugfs.h} |    0
 net/batman-adv/gateway_client.c             |  127 +++--
 net/batman-adv/gateway_client.h             |   24 +-
 net/batman-adv/gateway_common.c             |    2 +-
 net/batman-adv/gateway_common.h             |    8 +-
 net/batman-adv/hard-interface.c             |  125 +++--
 net/batman-adv/hard-interface.h             |   28 +-
 net/batman-adv/hash.c                       |   12 +-
 net/batman-adv/hash.h                       |   33 +-
 net/batman-adv/icmp_socket.c                |   81 +--
 net/batman-adv/icmp_socket.h                |    4 +-
 net/batman-adv/main.c                       |   82 +--
 net/batman-adv/main.h                       |   63 ++-
 net/batman-adv/originator.c                 |  151 ++---
 net/batman-adv/originator.h                 |   37 +-
 net/batman-adv/packet.h                     |  132 ++---
 net/batman-adv/routing.c                    |  300 +++++-----
 net/batman-adv/routing.h                    |   52 +-
 net/batman-adv/send.c                       |   75 +--
 net/batman-adv/send.h                       |   12 +-
 net/batman-adv/soft-interface.c             |   55 +-
 net/batman-adv/soft-interface.h             |    2 +-
 net/batman-adv/{bat_sysfs.c => sysfs.c}     |  134 +++--
 net/batman-adv/{bat_sysfs.h => sysfs.h}     |    6 +-
 net/batman-adv/translation-table.c          |  808 ++++++++++++++-------------
 net/batman-adv/translation-table.h          |   43 +-
 net/batman-adv/types.h                      |  154 ++---
 net/batman-adv/unicast.c                    |   95 ++--
 net/batman-adv/unicast.h                    |   19 +-
 net/batman-adv/vis.c                        |  284 +++++-----
 net/batman-adv/vis.h                        |   12 +-
 37 files changed, 2011 insertions(+), 1844 deletions(-)
 rename net/batman-adv/{bat_debugfs.c => debugfs.c} (81%)
 rename net/batman-adv/{bat_debugfs.h => debugfs.h} (100%)
 rename net/batman-adv/{bat_sysfs.c => sysfs.c} (85%)
 rename net/batman-adv/{bat_sysfs.h => sysfs.h} (89%)
