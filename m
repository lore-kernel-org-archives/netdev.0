From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/6] net: add team multiqueue support and do comple of thing on the way
Date: Fri, 20 Jul 2012 14:28:45 +0200
Message-ID: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, shemminger@vyatta.com,
	fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:57991 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298Ab2GTM26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 08:28:58 -0400
Received: by bkwj10 with SMTP id j10so3290591bkw.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 05:28:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset represents the way I walked when I was adding multiqueue support for
team driver.

Jiri Pirko (6):
  net: honour netif_set_real_num_tx_queues() retval
  rtnl: allow to specify different num for rx and tx queue count
  rtnl: allow to specify number of rx and tx queues on device creation
  net: rename bond_queue_mapping to slave_dev_queue_mapping
  bond_sysfs: use ream_num_tx_queues rather than params.tx_queue
  team: add multiqueue support

 drivers/net/bonding/bond_main.c  |   20 ++++++------
 drivers/net/bonding/bond_sysfs.c |    2 +-
 drivers/net/team/team.c          |   65 +++++++++++++++++++++++++++++++++++---
 include/linux/if_link.h          |    2 ++
 include/linux/if_team.h          |    8 +++++
 include/linux/netdevice.h        |    7 +++-
 include/net/rtnetlink.h          |   10 +++---
 include/net/sch_generic.h        |    2 +-
 net/core/rtnetlink.c             |   27 +++++++++++-----
 9 files changed, 114 insertions(+), 29 deletions(-)

-- 
1.7.10.4
