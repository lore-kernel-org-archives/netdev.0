From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 0/5] team: add some features and fixes
Date: Tue, 10 Apr 2012 17:15:41 +0200
Message-ID: <1334070946-7704-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32231 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758892Ab2DJPPw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Apr 2012 11:15:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (5):
  team: add support for per-port options
  team: add bool option type
  team: add user_linkup and user_linkup_enabled per-port option
  team: ab: walk through port list non-rcu
  team: add missed "statics"

 drivers/net/team/team.c                   |  402 +++++++++++++++++++++++------
 drivers/net/team/team_mode_activebackup.c |   20 +-
 drivers/net/team/team_mode_loadbalance.c  |   32 +--
 include/linux/if_team.h                   |   58 +++--
 4 files changed, 387 insertions(+), 125 deletions(-)

-- 
1.7.9.1
