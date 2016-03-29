From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: [PATCH 00/16] Misc wcn36xx fixes
Date: Mon, 28 Mar 2016 23:06:17 -0700
Message-ID: <1459231593-360-1-git-send-email-bjorn.andersson@linaro.org>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eugene Krasnikov <k.eugene.e@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As I was debugging some issues with the wcn36xx driver I found a series of
patches that exists in Eugene's github tree but not in mainline.

Noteworthy is the long requested feature of having working ARP support.

Please apply these rebased and relocated patches.

Jason Mobarak (1):
  wcn36xx: don't pad beacons for mesh

Pontus Fuchs (15):
  wcn36xx: Clean up wcn36xx_smd_send_beacon
  wcn36xx: Pad TIM PVM if needed
  wcn36xx: Add helper macros to cast vif to private vif and vice versa
  wcn36xx: Use consistent name for private vif
  wcn36xx: Use define for invalid index and fix typo
  wcn36xx: Fetch private sta data from sta entry instead of from vif
  wcn36xx: Add helper macros to cast sta to priv
  wcn36xx: Remove sta pointer in private vif struct
  wcn36xx: Parse trigger_ba response properly
  wcn36xx: Copy all members in config_sta v1 conversion
  wcn36xx: Use allocated self sta index instead of hard coded
  wcn36xx: Clear encrypt_type when deleting bss key
  wcn36xx: Track association state
  wcn36xx: Implement multicast filtering
  wcn36xx: Use correct command struct for EXIT_BMPS_REQ

 drivers/net/wireless/ath/wcn36xx/debug.c   |  12 +-
 drivers/net/wireless/ath/wcn36xx/hal.h     |  18 ++-
 drivers/net/wireless/ath/wcn36xx/main.c    |  91 +++++++++----
 drivers/net/wireless/ath/wcn36xx/pmc.c     |   4 +-
 drivers/net/wireless/ath/wcn36xx/smd.c     | 205 +++++++++++++++++++++--------
 drivers/net/wireless/ath/wcn36xx/smd.h     |   3 +
 drivers/net/wireless/ath/wcn36xx/txrx.c    |   8 +-
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h |  20 ++-
 8 files changed, 257 insertions(+), 104 deletions(-)

-- 
2.5.0
