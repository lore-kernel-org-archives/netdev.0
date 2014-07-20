From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 03/30] brcm80211: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:16:11 +0200
Message-ID: <1405865801-18806-4-git-send-email-fabf@skynet.be>
References: <1405865801-18806-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405865801-18806-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c       | 1 -
 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
index f3445ac..c563c65 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
@@ -2364,7 +2364,6 @@ int brcmf_p2p_del_vif(struct wiphy *wiphy, struct wireless_dev *wdev)
 		return 0;
 	default:
 		return -ENOTSUPP;
-		break;
 	}
 
 	clear_bit(BRCMF_P2P_STATUS_GO_NEG_PHASE, &p2p->status);
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
index 3e9f5b2..93869e8 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
@@ -22916,7 +22916,6 @@ static void wlc_phy_rssi_cal_nphy_rev2(struct brcms_phy *pi, u8 rssi_type)
 		break;
 	default:
 		return;
-		break;
 	}
 
 	classif_state = wlc_phy_classifier_nphy(pi, 0, 0);
-- 
1.9.1
