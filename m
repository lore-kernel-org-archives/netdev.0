From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v4 0/3] bonding: support QinQ for bond arp interval
Date: Tue, 25 Mar 2014 17:44:41 +0800
Message-ID: <1395740684-12224-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<joe@perches.com>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:45367 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbaCYJrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 05:47:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1->v2: remvoe the comment "TODO: QinQ?".
	convert pr_xxx() to pr_xxx_ratelimited() for arp interval.

v2->v3: remove the unnecessary log for arp interval and add net ratelimit to
	avoid spam log.

v3->v4: Add ratelimit for debugging is not a good idea, it will miss some message
	if the user turns the debugging on, so don't add ratelimited on debugging.

Ding Tianhong (3):
  vlan: make a new function vlan_dev_vlan_proto() and export
  bonding: support QinQ for bond arp interval
  bonding: add net_ratelimt to avoid spam in arp interval

 drivers/net/bonding/bond_main.c | 73 ++++++++++++++++++++++++++++-------------
 drivers/net/bonding/bonding.h   |  5 +++
 include/linux/if_vlan.h         |  7 ++++
 net/8021q/vlan_core.c           |  6 ++++
 4 files changed, 69 insertions(+), 22 deletions(-)

-- 
1.8.0
