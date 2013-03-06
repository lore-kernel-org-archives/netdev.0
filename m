From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next,repost 0/2] team: introduce random mode
Date: Wed,  6 Mar 2013 12:31:11 +0100
Message-ID: <1362569473-4310-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:60815 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757210Ab3CFLbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 06:31:17 -0500
Received: by mail-we0-f172.google.com with SMTP id d46so3547734wer.31
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 03:31:16 -0800 (PST)
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
