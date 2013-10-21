From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/5] bonding: patchset for rcu use in bonding
Date: Mon, 21 Oct 2013 16:58:36 +0800
Message-ID: <5264ECBC.2090208@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:7367 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619Ab3JUJCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 05:02:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

The Patch Set will remove the invalid lock for bond work queue and replace it
with rtnl lock, as read lock for bond could not protect slave list any more.

Ding Tianhong (5):
  bonding: remove bond read lock for bond_mii_monitor()
  bonding: remove bond read lock for bond_alb_monitor()
  bonding: remove bond read lock for bond_loadbalance_arp_mon()
  bonding: remove bond read lock for bond_activebackup_arp_mon()
  bonding: remove bond read lock for bond_3ad_state_machine_handler()

 drivers/net/bonding/bond_3ad.c  |   9 ++--
 drivers/net/bonding/bond_alb.c  |  20 ++------
 drivers/net/bonding/bond_main.c | 100 +++++++++++++---------------------------
 3 files changed, 40 insertions(+), 89 deletions(-)

-- 
1.8.2.1
