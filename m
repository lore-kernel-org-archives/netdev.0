From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 0/3] team: couple of patches
Date: Wed, 11 Jul 2012 17:34:01 +0200
Message-ID: <1342020844-3547-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51486 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755896Ab2GKPeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 11:34:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (3):
  team: use function team_port_txable() for determing enabled and up
    port
  team: add broadcast mode
  team: make team_port_enabled() and team_port_txable() static inline

 drivers/net/team/Kconfig                |   13 ++++-
 drivers/net/team/Makefile               |    1 +
 drivers/net/team/team.c                 |    6 ---
 drivers/net/team/team_mode_broadcast.c  |   88 +++++++++++++++++++++++++++++++
 drivers/net/team/team_mode_roundrobin.c |    6 +--
 include/linux/if_team.h                 |   10 +++-
 6 files changed, 113 insertions(+), 11 deletions(-)
 create mode 100644 drivers/net/team/team_mode_broadcast.c

-- 
1.7.10.4
