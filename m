From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 0/3] bonding: add lp_interval option support and
 simplify the code
Date: Sat, 21 Dec 2013 14:39:47 +0800
Message-ID: <52B537B3.3060504@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:19988 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751043Ab3LUGk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 01:40:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The option lp_interval could only be set by sysfs, so add support for loading module.
and update the Documentation/networking/bonding.txt for this option.

Use micro BOND_NO_USE_ARP to simplify the code for mode check.

v2: according to the networking coding style, the patch 01/03 need to cleanup the
    style problem, thanks scott for his advice. The bond_check_param() have too
    many duplicated code with bond sysfs, so I think when scott finish the bond_option_xxx_set(),
    the bond_check_param() should be modify to use the bond_option_xxx_set() function
    to simplify the code.

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
