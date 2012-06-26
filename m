From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 0/3] team: couple of fixes
Date: Tue, 26 Jun 2012 18:52:44 +0200
Message-ID: <1340729567-3164-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, brouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35482 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758126Ab2FZRFk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 13:05:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (3):
  team: fix team_adjust_ops with regard to enabled ports
  team: do not allow to map disabled ports
  team: remove unuset rcu_head field from team_port struct

 drivers/net/team/team.c                  |   35 ++++++++++++++++++------------
 drivers/net/team/team_mode_loadbalance.c |    3 ++-
 include/linux/if_team.h                  |    3 ++-
 3 files changed, 25 insertions(+), 16 deletions(-)

-- 
1.7.10.4
