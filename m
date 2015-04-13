From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/2] switchdev: unify naming prefix
Date: Mon, 13 Apr 2015 23:25:02 +0200
Message-ID: <1428960304-11497-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, roopa@cumulusnetworks.com,
	f.fainelli@gmail.com, gospo@cumulusnetworks.com,
	sridhar.samudrala@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:33823 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020AbbDMVZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 17:25:09 -0400
Received: by wgso17 with SMTP id o17so95614011wgs.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 14:25:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turned out that "switchdev" sticks. So just unify all releated terms to
use this prefix.

Jiri Pirko (2):
  switchdev: s/netdev_switch_/switchdev_/ and
    s/NETDEV_SWITCH_/SWITCHDEV_/
  switchdev: s/swdev_/switchdev_/

 drivers/net/bonding/bond_main.c      |   4 +-
 drivers/net/ethernet/rocker/rocker.c |  47 +++++-----
 drivers/net/team/team.c              |   4 +-
 include/linux/netdevice.h            |   2 +-
 include/net/switchdev.h              | 140 ++++++++++++++--------------
 net/bridge/br.c                      |  22 ++---
 net/bridge/br_netlink.c              |   6 +-
 net/bridge/br_stp.c                  |   2 +-
 net/core/net-sysfs.c                 |   2 +-
 net/core/rtnetlink.c                 |   2 +-
 net/dsa/slave.c                      |   8 +-
 net/ipv4/fib_trie.c                  |  40 ++++----
 net/switchdev/switchdev.c            | 174 +++++++++++++++++------------------
 13 files changed, 224 insertions(+), 229 deletions(-)

-- 
1.9.3
