From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 0/2] drivers: net: add const to mii_phy_ops structures
Date: Thu,  8 Jun 2017 11:30:56 +0530
Message-ID: <1496901658-6476-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The object references of mii_phy_ops structures are only stored
in the ops field of a mii_phy_def structure. This ops field is of type
const. So, mii_phy_ops structures having similar properties can be
declared as const.

Bhumika Goyal (2):
  drivers/net/sungem: add const to mii_phy_ops structures
  drivers: net: emac: add const to mii_phy_ops structures

 drivers/net/ethernet/ibm/emac/phy.c | 12 ++++++------
 drivers/net/sungem_phy.c            | 26 +++++++++++++-------------
 2 files changed, 19 insertions(+), 19 deletions(-)

-- 
2.7.4
