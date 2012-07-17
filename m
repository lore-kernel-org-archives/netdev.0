From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/2] team: add netpoll support
Date: Tue, 17 Jul 2012 17:22:34 +0200
Message-ID: <1342538556-22601-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35245 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754163Ab2GQPWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 11:22:41 -0400
Received: by bkwj10 with SMTP id j10so481895bkw.19
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 08:22:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also contains a little change to netpoll core.

Jiri Pirko (2):
  netpoll: move np->dev and np->dev_name init into __netpoll_setup()
  team: add netpoll support

 drivers/net/bonding/bond_main.c           |    4 +-
 drivers/net/team/team.c                   |  113 +++++++++++++++++++++++++++++
 drivers/net/team/team_mode_activebackup.c |    3 +-
 drivers/net/team/team_mode_broadcast.c    |    7 +-
 drivers/net/team/team_mode_loadbalance.c  |    3 +-
 drivers/net/team/team_mode_roundrobin.c   |    3 +-
 include/linux/if_team.h                   |   33 +++++++++
 include/linux/netpoll.h                   |    2 +-
 net/8021q/vlan_dev.c                      |    5 +-
 net/bridge/br_device.c                    |    5 +-
 net/core/netpoll.c                        |   10 +--
 11 files changed, 161 insertions(+), 27 deletions(-)

-- 
1.7.10.4
