From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 0/4] Calxeda xgmac fixes and performance improvements
Date: Mon,  9 Jul 2012 19:16:06 -0500
Message-ID: <1341879370-23385-1-git-send-email-robherring2@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Rob Herring <rob.herring@calxeda.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

A few fixes and performance improvements for the Calxeda xgmac driver for
3.6. It would be nice to get the 2 fixes into 3.5, but since it is a bit
late in the cycle they can wait.

Rob

Rob Herring (4):
  net: calxedaxgmac: fix net timeout recovery
  net: calxedaxgmac: fix hang on rx refill
  net: calxedaxgmac: set outstanding AXI bus transactions to 8
  net: calxedaxgmac: enable rx cut-thru mode

 drivers/net/ethernet/calxeda/xgmac.c |   35 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 18 deletions(-)

-- 
1.7.9.5
