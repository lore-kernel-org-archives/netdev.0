From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next-2.6 PATCH v7 0/2] bridge: fdb dumping takes a filter device
Date: Thu, 10 Jul 2014 07:01:57 -0400
Message-ID: <1404990119-16968-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com, eric.dumazet@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:39362 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015AbaGJLCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 07:02:12 -0400
Received: by mail-ie0-f180.google.com with SMTP id at20so780461iec.25
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 04:02:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

v7:
Vxlan driver was not updated with new API. Found by DaveM

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
 drivers/net/vxlan.c                              |    3 +-
 include/linux/netdevice.h                        |    4 +-
 include/linux/rtnetlink.h                        |    1 +
 net/bridge/br_fdb.c                              |   14 ++++
 net/bridge/br_private.h                          |    2 +-
 net/core/rtnetlink.c                             |   75 +++++++++++++++++-----
 8 files changed, 87 insertions(+), 22 deletions(-)

-- 
1.7.9.5
