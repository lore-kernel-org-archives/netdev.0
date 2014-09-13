From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 0/4 linux-next] drivers/net: use container_of where possible
Date: Sat, 13 Sep 2014 22:38:25 +0200
Message-ID: <1410640709-18295-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, Fabian Frederick <fabf@skynet.be>,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	brcm80211-dev-list@broadcom.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Small patchset using container_of instead of casting on first structure member address.

Fabian Frederick (4):
  net: fec: use container_of to resolve bufdesc_ex from bufdesc
  bna: use container_of to resolve bufdesc_ex from bufdesc
  brcm80211: use container_of to resolve brcms_phy from brcms_phy_pub
  brcm80211: use container_of to resolve dma_info from dma_pub

 drivers/net/ethernet/brocade/bna/bna_enet.c        |   9 +-
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c       |   4 +-
 drivers/net/ethernet/freescale/fec_main.c          |   4 +-
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |  38 +++----
 .../net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c  | 122 ++++++++++-----------
 .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c  |   6 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |   8 +-
 7 files changed, 97 insertions(+), 94 deletions(-)

-- 
1.8.4.5
