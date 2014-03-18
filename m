From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 0/3] bonding: support QinQ for bond arp interval
Date: Tue, 18 Mar 2014 18:43:50 +0800
Message-ID: <1395139433-19576-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:10234 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754933AbaCRKo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 06:44:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v1->v2: remvoe the comment "TODO: QinQ?".
	convert pr_xxx() to pr_xxx_ratelimited() for arp interval.

Ding Tianhong (3):
  vlan: make a new function vlan_dev_vlan_proto() and export
  bonding: support QinQ for bond arp interval
  bonding: convert pr_xxx() to pr_xxx_ratelimited() for arp interval

 drivers/net/bonding/bond_main.c | 81 ++++++++++++++++++++++++++++-------------
 drivers/net/bonding/bonding.h   |  5 +++
 include/linux/if_vlan.h         |  7 ++++
 net/8021q/vlan_core.c           |  6 +++
 4 files changed, 73 insertions(+), 26 deletions(-)

-- 
1.8.0
