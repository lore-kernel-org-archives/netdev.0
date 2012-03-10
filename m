From: "Luis R. Rodriguez" <mcgrof@frijolero.org>
Subject: [ANN] compat-wireless released based on 3.3-rc6
Date: Fri, 9 Mar 2012 17:03:36 -0800
Message-ID: <CAB=NE6W98XLxHq-Uom4g0q_bFKaNGJ4WN11x9_9oqWDZFXOy0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	linux-bluetooth <linux-bluetooth@vger.kernel.org>,
	netdev@vger.kernel.org,
	lf_driver_backport@lists.linux-foundation.org,
	Felix Fietkau <nbd@openwrt.org>,
	Kathy Giori <kgiori@qca.qualcomm.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We chug along and are now at 3.3-rc6. We're close to the final release
so we push out the first Wireless / Bluetooth / Ethernet backport rc
release based on rc6. We have two releases for this update, a vanilla
one [0] and a -n release [1] which has 14 patches cherry picked from
linux-next.git as suggested by nbd as listed below. These additional
patches are patches which have been deemed as non-critical-fix but
important for AP mode users at least. As explained previously, we have
directories to help with coping with "emergency" fixes or "extra
fixes" or "hot fixes" or whatever your favorite PHB wants to call it
[2], we categorize these patches accordingly to help ensure we keep
patches in route upstream. If you want patches merged into these
releases that fit those descriptions just send me a patch!

For complete details of this release you can read the
ChangeLog-3.3-wireless file [3]. And yes, I should clarify this is not
just a release for wireless, it includes wireless, bluetooth and
ethernet. They all use the shared compat module [4] but
compat-wireless [5] is the framework that pulls them all together.
What's new now is we have a shiny web page for the compat module [4].
If you're curious about hacking on compat-wireless see the hacking
page [6] and if you want to help as a student go check out the Google
Summer of Code project [7]

Please report any issues you see with this release.

mcgrof@tux ~/devel/compat-wireless (git::linux-3.3.y)$ ls -1
linux-next-cherry-picks/
0001-mac80211-Fix-incorrect-num_sta_ps-decrement-in-__sta.patch
0002-mac80211-Fix-incorrect-num_sta_ps-decrement-in-ap_st.patch
0003-mac80211-Move-num_sta_ps-counter-decrement-after-syn.patch
0004-ath9k-Initialize-NF-values-properly.patch
0005-ath9k-Fix-programming-SYNTH4-for-AR9462.patch
0006-ath9k-Fix-descriptor-length-for-AR9462.patch
0007-mac80211-handle-non-bufferable-MMPDUs-correctly.patch
0008-Revert-ath9k_hw-Fix-false-tx-hung-detection-in-AR900.patch
0009-ath9k-do-not-call-ath9k_hw_txprocdesc-on-AR9003-outs.patch
0010-ath9k_hw-enable-interrupts-for-beacon-tx-completion-.patch
0011-ath9k-fix-drv_tx_last_beacon-on-AR9003-by-processing.patch
0012-ath9k_hw-use-cold-instead-of-warm-reset-on-AR9280.patch
0013-mac80211-add-an-rx-flag-for-ignoring-a-packet-s-sign.patch
0014-ath9k-fix-signal-strength-reporting-issues.patch

[0] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.3/compat-wireless-3.3-rc6-1.tar.bz2
[1] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.3/compat-wireless-3.3-rc6-1-n.tar.bz2
[2] http://wireless.kernel.org/en/users/Download/stable/#Additional_patches_to_stable_releases
[3] http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.3/ChangeLog-3.3-wireless
[4] http://mcgrof.github.com/compat/
[5] http://wireless.kernel.org/en/users/Download/
[6] http://wireless.kernel.org/en/users/Download/hacking
[7] https://www.linuxfoundation.org/collaborate/workgroups/gsoc/2012-gsoc-driver-backports

  Luis
