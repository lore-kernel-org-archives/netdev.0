From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [net-next PATCH v2 0/2] bridge: more efficient fdb dumping
Date: Tue, 24 Jun 2014 10:15:17 -0400
Message-ID: <1403619319-16131-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: davem@davemloft.net, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:63154 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753701AbaFXOPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 10:15:30 -0400
Received: by mail-ig0-f169.google.com with SMTP id c1so4766105igq.2
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 07:15:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Changes:
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
 net/bridge/br_fdb.c                              |   16 +++++
 net/bridge/br_private.h                          |    2 +-
 net/core/rtnetlink.c                             |   75 ++++++++++++++++++----
 7 files changed, 85 insertions(+), 18 deletions(-)

-- 
1.7.9.5
