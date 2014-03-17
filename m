From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/2] bonding: support QinQ for bond arp interval
Date: Mon, 17 Mar 2014 20:06:13 +0800
Message-ID: <1395057975-19084-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:61061 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932752AbaCQMGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 08:06:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ding Tianhong (2):
  vlan: make a new function  vlan_dev_vlan_proto() and export
  bonding: support QinQ for bond arp interval

 drivers/net/bonding/bond_main.c | 61 ++++++++++++++++++++++++++++++-----------
 drivers/net/bonding/bonding.h   |  5 ++++
 include/linux/if_vlan.h         |  7 +++++
 net/8021q/vlan_core.c           |  6 ++++
 4 files changed, 63 insertions(+), 16 deletions(-)

-- 
1.8.0
