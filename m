From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/3] bonding: support 802.1ad vlan protocol
Date: Tue, 11 Mar 2014 11:43:39 +0800
Message-ID: <1394509422-8704-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <fubar@us.ibm.com>, <vfalico@redhat.com>, <andy@greyhouse.net>,
	<kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:37757 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754126AbaCKDom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 23:44:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bonding could only use vlan proto 802.1q regardless the vlan dev is
802.1ad or 802.1q, so add new interface to get vlan proto by vlan dev and
use it to send packages by correct vlan protocol.

Ding Tianhong (3):
  vlan: make a new function  vlan_dev_vlan_proto() and export
  bonding: support different vlan proto for bond_arp_send()
  bonding: choose the correct vlan proto for alb_send_learning_packets

 drivers/net/bonding/bond_alb.c  |  7 ++++---
 drivers/net/bonding/bond_main.c | 23 +++++++++++++++--------
 include/linux/if_vlan.h         |  7 +++++++
 net/8021q/vlan_core.c           |  6 ++++++
 4 files changed, 32 insertions(+), 11 deletions(-)

-- 
1.8.0
