From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next-2.6 PATCH v6 0/2] bridge: fdb dumping takes a filter device
Date: Fri,  4 Jul 2014 07:57:59 -0400
Message-ID: <1404475081-8611-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com, eric.dumazet@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:61182 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbaGDL6a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jul 2014 07:58:30 -0400
Received: by mail-ig0-f172.google.com with SMTP id hn18so8677610igb.11
        for <netdev@vger.kernel.org>; Fri, 04 Jul 2014 04:58:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Changes

v6:
Missed checkpatch > 80 chars lines found by Varka Bhadram 

v5:
 Embarassing qlnic compile failure found by DaveM

v4:
 Request from DaveM to use proper comment tagging and remove if-stmnt braces

V3:
 Suggestion from Eric D. to use for_each_netdev
 Suggestion from Stephen H. to reduce level of indentation

V2:
Suggestions from Vlad
 Get rid of rcu read lock since rtnl_lock is being held
 simplify for readability


Jamal Hadi Salim (2):
  bridge: fdb dumping takes a filter device
  bridge: netlink dump interface at par with brctl

 drivers/net/ethernet/intel/i40e/i40e_main.c      |    3 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    7 +-
 include/linux/netdevice.h                        |    1 +
 include/linux/rtnetlink.h                        |    1 +
 net/bridge/br_fdb.c                              |   14 ++++
 net/bridge/br_private.h                          |    2 +-
 net/core/rtnetlink.c                             |   75 +++++++++++++++++-----
 7 files changed, 83 insertions(+), 20 deletions(-)

-- 
1.7.9.5
