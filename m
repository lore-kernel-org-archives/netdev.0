From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net 0/2] Fix spinlock usage in HWBM
Date: Tue, 24 May 2016 18:03:24 +0200
Message-ID: <1464105806-439-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Jean-Jacques Hiblot <jjhiblot@traphandler.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

these two patches fix spinlock related issues introduced in v4.6. They
have been reported by Russell King and Jean-Jacques Hiblot.

Thanks to them,

Gregory

Gregory CLEMENT (2):
  net: mvneta: Fix lacking spinlock initialization
  net: hwbm: Fix unbalanced spinlock in error case

 drivers/net/ethernet/marvell/mvneta_bm.c | 1 +
 net/core/hwbm.c                          | 3 +++
 2 files changed, 4 insertions(+)

-- 
2.5.0
