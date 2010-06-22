From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-06-22
Date: Tue, 22 Jun 2010 13:41:37 -0400
Message-ID: <20100622174136.GC2583@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Just a single fix this time, a patch for ath5k to avoid a null pointer
dereference that can happen when executing certain operations against a
newly created interface.  This is, of course, intended for 2.6.35.

Please let me know if there are problems!

Thanks,

John


---

The following changes since commit 25442e06d20aaba7d7b16438078a562b3e4cf19b:
  stephen hemminger (1):
        bridge: fdb cleanup runs too often

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bob Copeland (1):
      ath5k: initialize ah->ah_current_channel

 drivers/net/wireless/ath/ath5k/attach.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/attach.c b/drivers/net/wireless/ath/ath5k/attach.c
index e0c244b..31c0080 100644
--- a/drivers/net/wireless/ath/ath5k/attach.c
+++ b/drivers/net/wireless/ath/ath5k/attach.c
@@ -126,6 +126,7 @@ int ath5k_hw_attach(struct ath5k_softc *sc)
 	ah->ah_ant_mode = AR5K_ANTMODE_DEFAULT;
 	ah->ah_noise_floor = -95;	/* until first NF calibration is run */
 	sc->ani_state.ani_mode = ATH5K_ANI_MODE_AUTO;
+	ah->ah_current_channel = &sc->channels[0];
 
 	/*
 	 * Find the mac version
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
