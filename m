From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH RESEND net-next 0/7] bonding: slight optimization for bonding
Date: Thu, 2 Jan 2014 09:12:50 +0800
Message-ID: <52C4BD12.8000502@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Joe Perches <joe@perches.com>,
	Julia Lawall <julia.lawall@lip6.fr>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This serious of patches will slight optimize the mac address compare
and xmit path for bonding, also make some cleanups.

Julia was using ether_addr_equal_64bits to instead of ether_addr_equal,
it is really a hard work and she may did not make patch for bonding yet,
so I have do it in this patchset and that she could miss the bonding drivers.

resend and add cc for Julia.

Regards
Ding

Ding Tianhong (7):
  bonding: use ether_addr_equal_unaligned for bond addr compare
  bonding: slight optimization for bond_3ad_xmit_xor()
  bonding: slight optimization for bond_alb_xmit()
  bonding: slight optimizztion for bond_slave_override()
  bonding: remove unwanted return value for bond_dev_queue_xmit()
  bonding: remove the return value for bond_3ad_bind_slave()
  bonding: use ether_addr_equal_64bits to instead of ether_addr_equal

 drivers/net/bonding/bond_3ad.c  | 120 ++++++++++++++++++++--------------------
 drivers/net/bonding/bond_3ad.h  |   2 +-
 drivers/net/bonding/bond_alb.c  |  12 ++--
 drivers/net/bonding/bond_main.c |  28 ++++------
 drivers/net/bonding/bonding.h   |   2 +-
 5 files changed, 77 insertions(+), 87 deletions(-)

-- 
1.8.0
