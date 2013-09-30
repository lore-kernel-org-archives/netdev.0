From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 0/3] calxedaxgmac: fixes for xgmac_set_rx_mode
Date: Mon, 30 Sep 2013 15:12:14 -0500
Message-ID: <1380571937-23439-1-git-send-email-robherring2@gmail.com>
Cc: Rob Herring <rob.herring@calxeda.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

This is a couple of fixes related to xgmac_set_rx_mode. The changes are
necessary for "bridge fdb add" to work correctly.

Rob

Rob Herring (3):
  net: calxedaxgmac: fix clearing of old filter addresses
  net: calxedaxgmac: add uc and mc filter addresses in promiscuous mode
  net: calxedaxgmac: determine number of address filters at runtime

 drivers/net/ethernet/calxeda/xgmac.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

-- 
1.8.1.2
