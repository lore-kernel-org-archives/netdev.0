From: Byungho An <bh74.an@samsung.com>
Subject: [PATCH 0/3] net: sxgbe: Added dma related function and non-burst mode
 support
Date: Fri, 09 May 2014 11:03:43 +0900
Message-ID: <003a01cf6b2a$e7bf5bf0$b73e13d0$%an@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, "'ks.giri'" <ks.giri@samsung.com>,
	"'vipul.pandya'" <vipul.pandya@samsung.com>
To: 'netdev' <netdev@vger.kernel.org>,
	linux-samsung-soc@vger.kernel.org
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Content-language: ko
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series added 
- functions to update rx descriptor tail pointer 
- non burst mode support
- fixed dma channel feature.


Byungho An (3):
  net: sxgbe: Added condition for non fix_burst mode
  net: sxgbe: Added tail point update
  net: sxgbe: Fixed mtl and dma channel feature

 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.c  |   46 +++++++++++++++++++++--
 drivers/net/ethernet/samsung/sxgbe/sxgbe_dma.h  |    6 ++-
 drivers/net/ethernet/samsung/sxgbe/sxgbe_main.c |   21 ++++++++---
 3 files changed, 63 insertions(+), 10 deletions(-)

--
1.7.10.4
