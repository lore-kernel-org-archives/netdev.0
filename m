From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next 0/2] cleanup for ieee802154 and mac802154
Date: Wed,  9 Jul 2014 09:14:03 +0530
Message-ID: <1404877445-2757-1-git-send-email-varkab@cdac.in>
Cc: alex.aring@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:58170 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbaGIDp0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 23:45:26 -0400
Received: by mail-pa0-f54.google.com with SMTP id et14so8503159pad.13
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2014 20:45:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series remove the unwanted headerfiles for ieee802154 and mac802154

Varka Bhadram (2):
  ieee802154: removed unwanted header files
  mac802154: removed unwanted header files

 net/ieee802154/6lowpan_iphc.c  |    4 ----
 net/ieee802154/6lowpan_rtnl.c  |    7 -------
 net/ieee802154/af_ieee802154.c |   11 -----------
 net/ieee802154/dgram.c         |    6 ------
 net/ieee802154/header_ops.c    |    1 -
 net/ieee802154/netlink.c       |    2 --
 net/ieee802154/nl-mac.c        |    8 --------
 net/ieee802154/nl-phy.c        |    4 ----
 net/ieee802154/nl_policy.c     |    1 -
 net/ieee802154/raw.c           |    5 -----
 net/ieee802154/reassembly.c    |   11 -----------
 net/ieee802154/wpan-class.c    |    4 ----
 net/mac802154/ieee802154_dev.c |    5 -----
 net/mac802154/llsec.c          |    7 -------
 net/mac802154/llsec.h          |    4 ----
 net/mac802154/mac802154.h      |    2 --
 net/mac802154/mac_cmd.c        |    3 ---
 net/mac802154/mib.c            |    2 --
 net/mac802154/monitor.c        |    4 ----
 net/mac802154/rx.c             |    7 -------
 net/mac802154/tx.c             |    5 -----
 net/mac802154/wpan.c           |    6 ------
 22 files changed, 109 deletions(-)

-- 
1.7.9.5
