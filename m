From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/3] add support for peer notifications and igmp rejoins for team
Date: Fri, 19 Jul 2013 15:40:19 +0200
Message-ID: <1374241222-9683-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net,
	kaber@trash.net, stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:63426 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755360Ab3GSNk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 09:40:28 -0400
Received: by mail-ee0-f42.google.com with SMTP id c4so2366825eek.15
        for <netdev@vger.kernel.org>; Fri, 19 Jul 2013 06:40:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The middle patch adjusts core infrastructure for the bonding code can be
generalized and reused by team.

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
