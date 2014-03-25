From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 0/3] bonding: support QinQ for bond arp interval
Date: Tue, 25 Mar 2014 11:21:34 +0800
Message-ID: <1395717697-11876-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<joe@perches.com>, <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:46723 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbaCYDX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 23:23:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1->v2: remvoe the comment "TODO: QinQ?".
	convert pr_xxx() to pr_xxx_ratelimited() for arp interval.

v2->v3: remove the unnecessary log for arp interval and add net ratelimit to
	avoid spam log.

Ding Tianhong (3):
  vlan: make a new function vlan_dev_vlan_proto() and export
  bonding: support QinQ for bond arp interval
  bonding: add net_ratelimt to avoid spam in arp interval

 drivers/net/bonding/bond_main.c | 80 +++++++++++++++++++++++++++--------------
 drivers/net/bonding/bonding.h   |  5 +++
 include/linux/if_vlan.h         |  7 ++++
 net/8021q/vlan_core.c           |  6 ++++
 4 files changed, 72 insertions(+), 26 deletions(-)

-- 
1.8.0
