From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH v3 0/2] bridge: more efficient fdb dumping
Date: Wed, 25 Jun 2014 06:21:21 -0400
Message-ID: <1403691683-14290-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com, eric.dumazet@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:48581 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569AbaFYKVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 06:21:39 -0400
Received: by mail-pa0-f50.google.com with SMTP id bj1so1535651pad.23
        for <netdev@vger.kernel.org>; Wed, 25 Jun 2014 03:21:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Changes:
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
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    5 +-
 include/linux/netdevice.h                        |    1 +
 include/linux/rtnetlink.h                        |    1 +
 net/bridge/br_fdb.c                              |   14 ++++
 net/bridge/br_private.h                          |    2 +-
 net/core/rtnetlink.c                             |   77 +++++++++++++++++-----
 7 files changed, 84 insertions(+), 19 deletions(-)

-- 
1.7.9.5
