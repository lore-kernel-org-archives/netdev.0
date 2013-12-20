From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/3] bonding: add lp_interval option support and
 simplify the code
Date: Fri, 20 Dec 2013 13:10:49 +0800
Message-ID: <52B3D159.9030906@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:30337 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988Ab3LTFMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 00:12:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The option lp_interval could only be set by sysfs, so add support for loading module.
and update the Documentation/networking/bonding.txt for this option.

Use micro BOND_NO_USE_ARP to simplify the code for mode check.

Ding Tianhong (3):
  bonding: add option lp_interval for loading module
  bonding: ust micro BOND_NO_USE_ARP to simplify the mode check
  bonding: update Documentation/networking/bonding.txt for option
    lp_interval

 Documentation/networking/bonding.txt | 10 ++++++++++
 drivers/net/bonding/bond_main.c      | 29 +++++++++++++++--------------
 2 files changed, 25 insertions(+), 14 deletions(-)

-- 
1.8.0
