From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 0/6] Calxeda xgmac performance fixes
Date: Fri, 12 Oct 2012 10:15:02 -0500
Message-ID: <1350054908-30646-1-git-send-email-robherring2@gmail.com>
Cc: jonathan@jonmasters.org, eric.dumazet@gmail.com,
	Mark Langsdorf <mark.langsdorf@calxeda.com>,
	Rob Herring <rob.herring@calxeda.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

This is a series of performance improvements to the xgmac driver. The most
significant changes are the alignment fixes to avoid alignment traps on
received frames and using relaxed i/o accessors.

Rob

Rob Herring (6):
  net: calxedaxgmac: enable operate on 2nd frame mode
  net: calxedaxgmac: remove explicit rx dma buffer polling
  net: calxedaxgmac: use relaxed i/o accessors in rx and tx paths
  net: calxedaxgmac: drop some unnecessary register writes
  net: calxedaxgmac: rework transmit ring handling
  net: calxedaxgmac: ip align receive buffers

 drivers/net/ethernet/calxeda/Kconfig |    2 +-
 drivers/net/ethernet/calxeda/xgmac.c |   57 +++++++++++++++-------------------
 2 files changed, 26 insertions(+), 33 deletions(-)

-- 
1.7.9.5
