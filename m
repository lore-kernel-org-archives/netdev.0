From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] team: introduce random mode
Date: Fri,  1 Mar 2013 11:26:04 +0100
Message-ID: <1362133566-1382-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:46651 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907Ab3CAK0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 05:26:13 -0500
Received: by mail-ea0-f178.google.com with SMTP id a14so308611eaa.23
        for <netdev@vger.kernel.org>; Fri, 01 Mar 2013 02:26:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (2):
  team: introduce two default team_modeop functions and use them in
    modes
  team: introduce random mode

 drivers/net/team/Kconfig                | 12 ++++++
 drivers/net/team/Makefile               |  1 +
 drivers/net/team/team.c                 | 19 +++++++--
 drivers/net/team/team_mode_broadcast.c  | 14 +------
 drivers/net/team/team_mode_random.c     | 71 +++++++++++++++++++++++++++++++++
 drivers/net/team/team_mode_roundrobin.c | 36 ++---------------
 include/linux/if_team.h                 | 25 +++++++++++-
 7 files changed, 129 insertions(+), 49 deletions(-)
 create mode 100644 drivers/net/team/team_mode_random.c

-- 
1.8.1.2
