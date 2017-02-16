From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2017-02-17
Date: Thu, 16 Feb 2017 15:41:13 +0200
Message-ID: <87wpcql0cm.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

few -next patches I'm still hoping to get to 4.11 to keep my backlog
short, nothing major here. Please let me know if there are any problems.

Kalle

The following changes since commit 3b03cc0783b03ddd668ff3f86419bc67d0664e89:

  net: natsemi: ns83820: use new api ethtool_{get|set}_link_ksettings (2017=
-02-12 22:32:17 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next=
.git tags/wireless-drivers-next-for-davem-2017-02-16

for you to fetch changes up to b065d3f59ff1905922194bd17c79543289317fc7:

  Merge ath-next from git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/a=
th.git (2017-02-15 16:01:04 +0200)

----------------------------------------------------------------
wireless-drivers-next patches for 4.11

Mostly small fixes, not really any new features.

Major changes:

ath10k

* when trying older firmware versions don't confuse user with error messages

ath9k

* fix crash in AP mode (regression)
* fix relayfs crash (regression)
* fix initialisation with AR9340 and AR9550

----------------------------------------------------------------
Amadeusz S=C5=82awi=C5=84ski (3):
      ath10k: remove ath10k_vif_to_arvif()
      ath10k: use size_t for len variables
      ath10k: fix comment

Arnd Bergmann (1):
      rt2500usb: don't mark register accesses as inline

Brian Norris (1):
      mwifiex: don't enable/disable IRQ 0 during suspend/resume

Christian Lamparter (1):
      ath9k: use correct OTP register offsets for the AR9340 and AR9550

Erik Stromdahl (1):
      ath10k: fetch firmware images in a loop

Felix Fietkau (1):
      ath9k: clean up and fix ath_tx_count_airtime

Iain Hunter (1):
      wlcore: disable multicast filter in AP mode

Julia Lawall (1):
      rtlwifi: btcoexist: fix semicolon.cocci warnings

Kalle Valo (4):
      ath10k: fix napi crash during rmmod when probe firmware fails
      ath10k: add directory to board data error message
      ath10k: convert warning about non-existent OTP board id to debug mess=
age
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Larry Finger (3):
      rtlwifi: btcoexist: Fix if =3D=3D else warnings in halbtc8821a2ant.c
      rtlwifi: btcoexist: Fix if =3D=3D else warnings in halbtc8821a1ant.c
      rtlwifi: btcoexist: Fix if =3D=3D else warnings in halbtc8723b1ant.c

Michal Kazior (1):
      ath10k: silence firmware file probing warnings

Ryan Hsu (1):
      ath10k: fix the garage chars in board file name creation

Sven Eckelmann (1):
      ath9k: Access rchan::buf only with per_cpu helper

Tobias Klauser (3):
      ath6kl: Use net_device_stats from struct net_device
      orinoco: Use net_device_stats from struct net_device
      brcmfmac: Use net_device_stats from struct net_device

 drivers/net/wireless/ath/ath10k/core.c             |  72 ++++----
 drivers/net/wireless/ath/ath10k/debug.c            |  49 +++---
 drivers/net/wireless/ath/ath10k/hw.h               |   4 +
 drivers/net/wireless/ath/ath10k/mac.c              |  68 ++++----
 drivers/net/wireless/ath/ath10k/mac.h              |   7 +-
 drivers/net/wireless/ath/ath10k/p2p.c              |   2 +-
 drivers/net/wireless/ath/ath10k/pci.c              |   3 +-
 drivers/net/wireless/ath/ath10k/spectral.c         |   7 +-
 drivers/net/wireless/ath/ath10k/testmode.c         |   5 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |   2 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |   2 +-
 drivers/net/wireless/ath/ath6kl/core.h             |   1 -
 drivers/net/wireless/ath/ath6kl/main.c             |   8 -
 drivers/net/wireless/ath/ath6kl/txrx.c             |  22 +--
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |   4 +-
 drivers/net/wireless/ath/ath9k/common-spectral.c   |   2 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |  52 ++----
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |  26 +--
 .../wireless/broadcom/brcm80211/brcmfmac/core.h    |   2 -
 drivers/net/wireless/intersil/orinoco/main.c       |  27 +--
 drivers/net/wireless/intersil/orinoco/orinoco.h    |   2 -
 .../net/wireless/intersil/orinoco/orinoco_usb.c    |   6 +-
 drivers/net/wireless/marvell/mwifiex/main.c        |   8 +-
 drivers/net/wireless/ralink/rt2x00/rt2500usb.c     |  19 +--
 .../realtek/rtlwifi/btcoexist/halbtc8723b1ant.c    |  24 +--
 .../realtek/rtlwifi/btcoexist/halbtc8821a1ant.c    |  18 +-
 .../realtek/rtlwifi/btcoexist/halbtc8821a2ant.c    | 187 +++--------------=
----
 drivers/net/wireless/ti/wlcore/main.c              |  15 ++
 28 files changed, 213 insertions(+), 431 deletions(-)
