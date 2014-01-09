From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/4] bonding: update the primary for bonding and
 fix some slight problem
Date: Thu, 9 Jan 2014 19:20:33 +0800
Message-ID: <52CE8601.7010908@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:8745 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbaAILYD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 06:24:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the primary_slave's name changed, but the bond->prams.primay was
still using the old name, it is conflict with the meaning of the
primary, so update the primary when the slave change its name.

Do not save the primary when the device is not exist for bonding.

Modify some description for primary in bonding.txt.

Ding Tianhong (4):
  bonding: update the primary when slave name changed
  bonding: do not save non-existent device to bond primary in check params
  bonding: do not save non-existent device to bond primary in sysfs
  bonding: update bonding.txt for primary description.

 Documentation/networking/bonding.txt |  3 ++-
 drivers/net/bonding/bond_main.c      | 34 +++++++++++++++++++++++++---------
 drivers/net/bonding/bond_options.c   |  6 ++++++
 3 files changed, 33 insertions(+), 10 deletions(-)

-- 
1.8.0
