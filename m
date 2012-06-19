From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 00/19] team: couple of patches
Date: Tue, 19 Jun 2012 17:54:02 +0200
Message-ID: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12234 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753424Ab2FSPy0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The main impact is this patchset provides an implementation of userspace driven
TX loadbalancing for team driver.

Also couple of typos are fixed, minor issues fixes.

Jiri Pirko (19):
  team: make team_mode struct const
  team: for nomode use dummy struct team_mode
  team: add mode priv to port
  team: lb: push hash counting into separate function
  team: allow read/write-only options
  team: introduce array options
  team: comments: s/net\/drivers\/team/drivers\/net\/team/
  team: push array_index and port into separate structure
  team: allow async option changes
  team: fix error path in team_nl_fill_options_get()
  team: fix error path in team_nl_fill_port_list_get()
  team: allow to specify one option instance to be send to userspace
  team: pass NULL to __team_option_inst_add() instead of 0
  team: add port_[enabled/disabled] mode callbacks
  team: lb: introduce infrastructure for userspace driven tx
    loadbalancing
  team: implement multipart netlink messages for options transfers
  team: ensure correct order of netlink messages delivery
  team: allow to send multiple set events in one message
  team: use rcu_dereference_bh() in tx path

 drivers/net/team/team.c                   |  546 ++++++++++++++++++-----------
 drivers/net/team/team_mode_activebackup.c |    6 +-
 drivers/net/team/team_mode_loadbalance.c  |  536 ++++++++++++++++++++++++++--
 drivers/net/team/team_mode_roundrobin.c   |    4 +-
 include/linux/if_team.h                   |   22 +-
 5 files changed, 885 insertions(+), 229 deletions(-)

-- 
1.7.10.2
