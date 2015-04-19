From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Subject: [PATCH 0/2] checkpatch: new ethernet address manipulation checks
Date: Sun, 19 Apr 2015 21:04:04 +0200
Message-ID: <1429470246-15988-1-git-send-email-mateusz.kulikowski@gmail.com>
Cc: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com, apw@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add 3 new warnings to checkpatch:
1) PREFER_ETHER_ADDR_EQUAL 
Replace memcmp(foo, bar, ETH_ALEN) with ether_addr_equal*()
2) PREFER_ETH_ZERO_ADDR
Replace memset(foo, 0, ETH_ALEN) with eth_zero_addr()
3) PREFER_ETH_BROADCAST_ADDR
Replace memset(foo, 0xFF, ETH_ALEN) with eth_broadcast_addr()

Mateusz Kulikowski (2):
  checkpatch: suggest using ether_addr_equal*()
  checkpatch: suggest using eth_zero_addr() and eth_broadcast_addr()

 scripts/checkpatch.pl | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

-- 
1.8.4.1
