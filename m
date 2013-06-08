From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/3] team: couple of fixes
Date: Sat,  8 Jun 2013 15:00:52 +0200
Message-ID: <1370696455-12221-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:44654 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107Ab3FHNA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jun 2013 09:00:59 -0400
Received: by mail-ee0-f47.google.com with SMTP id e49so2092516eek.6
        for <netdev@vger.kernel.org>; Sat, 08 Jun 2013 06:00:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (3):
  team: check return value of team_get_port_by_index_rcu() for NULL
  team: move add to port list before port enablement
  team: fix checks in team_get_first_port_txable_rcu()

 drivers/net/team/team.c                 | 2 +-
 drivers/net/team/team_mode_random.c     | 2 ++
 drivers/net/team/team_mode_roundrobin.c | 2 ++
 include/linux/if_team.h                 | 4 ++--
 4 files changed, 7 insertions(+), 3 deletions(-)

-- 
1.7.11.7
