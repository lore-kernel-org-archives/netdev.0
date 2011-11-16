From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 0/3] team: bug fixes
Date: Wed, 16 Nov 2011 22:09:06 +0100
Message-ID: <1321477749-1877-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23426 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753334Ab1KPVJR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 16:09:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (3):
  team: Do not hold rcu_read_lock when running netlink cmds
  team: convert overall spinlock to mutex
  team: replicate options on register

 drivers/net/team/team.c                   |  120 +++++++++++++++++++++--------
 drivers/net/team/team_mode_activebackup.c |    5 +-
 include/linux/if_team.h                   |   10 +-
 3 files changed, 93 insertions(+), 42 deletions(-)

-- 
1.7.6
