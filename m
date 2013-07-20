From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/3] add support for peer notifications and igmp rejoins for team
Date: Sat, 20 Jul 2013 12:13:51 +0200
Message-ID: <1374315234-7096-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net,
	kaber@trash.net, stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:63240 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753329Ab3GTKOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jul 2013 06:14:00 -0400
Received: by mail-ee0-f49.google.com with SMTP id b57so2790318eek.8
        for <netdev@vger.kernel.org>; Sat, 20 Jul 2013 03:13:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The middle patch adjusts core infrastructure so the bonding code can be
generalized and reused by team.

v1->v2: using msecs_to_jiffies() as suggested by Eric

Jiri Pirko (3):
  team: add peer notification
  net: convert resend IGMP to notifier event
  team: add support for sending multicast rejoins

 drivers/net/bonding/bond_main.c |  44 ++--------
 drivers/net/team/team.c         | 176 ++++++++++++++++++++++++++++++++++++++++
 include/linux/if_team.h         |  14 +++-
 include/linux/igmp.h            |   1 -
 include/linux/netdevice.h       |   1 +
 net/8021q/vlan.c                |   1 +
 net/bridge/br_notify.c          |   5 ++
 net/ipv4/igmp.c                 |  46 +++++++++--
 8 files changed, 245 insertions(+), 43 deletions(-)

-- 
1.8.1.4
