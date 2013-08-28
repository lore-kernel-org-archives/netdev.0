From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 0/5] bonding: Patchset for rcu use in bonding
Date: Wed, 28 Aug 2013 12:20:51 +0800
Message-ID: <521D7AA3.6030205@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:13771 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633Ab3H1EVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 00:21:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

The Patch Set convert the xmit of 3ad and alb mode to use rcu lock.
replace and add more rcu list function.
fix a bug to protect bonding_store_xmit_hash().

I test well and no problems found till now.

Ding Tianhong (3):
Wang Yufen (1):
Yang Yingliang (1):
  bonding: simplify and use RCU protection for 3ad xmit path
  bonding: replace read_lock to rcu_read_lock for
  bond_3ad_get_active_agg_info()
  bonding: add rtnl lock for bonding_store_xmit_hash
  bonding: restructure and simplify bond_for_each_slave_next()
  bonding: use RCU protection for alb xmit path

 drivers/net/bonding/bond_3ad.c   | 35 +++++++++++++++-------------------
 drivers/net/bonding/bond_alb.c   | 23 ++++++++++------------
 drivers/net/bonding/bond_main.c  |  6 ++----
 drivers/net/bonding/bond_sysfs.c |  4 ++++
 drivers/net/bonding/bonding.h    | 41 ++++++++++++++++++++++++++++++++++++----
 5 files changed, 68 insertions(+), 41 deletions(-)

-- 
1.8.2.1
