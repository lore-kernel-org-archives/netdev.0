From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/4] add support for queue override by setting queue_id for port
Date: Fri, 27 Jul 2012 18:28:51 +0200
Message-ID: <1343406535-22388-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:45897 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab2G0Q3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 12:29:00 -0400
Received: by wibhq12 with SMTP id hq12so789617wib.1
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 09:28:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko (4):
  netlink: add signed types
  team: add signed 32-bit team option type
  team: add per port priority option
  team: add support for queue override by setting queue_id for port

 drivers/net/team/team.c |  200 ++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/if_team.h |    7 ++
 include/net/netlink.h   |   98 +++++++++++++++++++++++
 3 files changed, 303 insertions(+), 2 deletions(-)

-- 
1.7.10.4
