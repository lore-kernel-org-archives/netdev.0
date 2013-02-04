From: Amir Vadai <amirv@mellanox.com>
Subject: [PATH net-next v1 0/2] Mellanox Ethernet driver updates 2013-02-04
Date: Mon,  4 Feb 2013 15:01:19 +0200
Message-ID: <1359982881-10139-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:52782 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753996Ab3BDNBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 08:01:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Please pull those two fixes. First is a fix of error propagation for an ethtool
helper function, and second is a fix to compilation error  introduced by commit
f90a367: "Fix ip/udp steering rules multicast mac when attached via ethtool"

Patches done against net-next commit 4f46385: "stmmac: don't return zero on
failure path in stmmac_pci_probe()"

Changes from V0:
- Split into 2 patches

Hadar Hen Zion (2):
  net/mlx4_en: Fix error propagation for ethtool helper function
  net/mlx4_en: Fix compilation error when CONFIG_INET isn't defined

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   56 +++++++++++++++-------
 1 files changed, 38 insertions(+), 18 deletions(-)

-- 
1.7.8.2
