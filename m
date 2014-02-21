From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/4] bonding: Fix some minor issues for bonding.
Date: Fri, 21 Feb 2014 16:08:51 +0800
Message-ID: <1392970135-11904-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:37862 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494AbaBUIMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 03:12:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong (4):
  bonding: netpoll: remove unwanted slave_dev_support_netpoll()
  bonding: use rcu_dereference() to access curr_active_slave
  bonding: remove no longer needed lock for bond_xxx_info_query()
  bonding: don't ensalve loopback device

 drivers/net/bonding/bond_main.c   | 19 ++++++-------------
 drivers/net/bonding/bond_procfs.c |  4 +---
 2 files changed, 7 insertions(+), 16 deletions(-)

-- 
1.8.0
