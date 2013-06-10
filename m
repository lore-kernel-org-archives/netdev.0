From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/3] team: remove sychronize_rcu() calls
Date: Mon, 10 Jun 2013 17:42:22 +0200
Message-ID: <1370878945-9718-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:61319 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132Ab3FJPmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 11:42:49 -0400
Received: by mail-ea0-f182.google.com with SMTP id d10so1670676eaj.13
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 08:42:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (3):
  team: remove synchronize_rcu() called during queue override change
  team: use kfree_rcu instead of synchronize_rcu in team_port_dev
  team: remove synchronize_rcu() called during port disable

 drivers/net/team/team.c                  | 84 ++++++++++++++++++++------------
 drivers/net/team/team_mode_loadbalance.c |  3 +-
 drivers/net/team/team_mode_roundrobin.c  |  3 +-
 include/linux/if_team.h                  | 11 +++++
 4 files changed, 66 insertions(+), 35 deletions(-)

-- 
1.8.1.4
