From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2015-08-26
Date: Wed, 26 Aug 2015 18:13:02 +0300
Message-ID: <87lhcyytfk.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:59589 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756101AbbHZPNL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 11:13:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's one more smaller pull request I would like to still get to 4.3.
Nothing really special expect the new firmware API 17 support for
iwlwifi and qca6164 support for ath10k which would be good to have in
4.3.

Please let me know if you have any problems.

Kalle

The following changes since commit 4a89ba04ecc6377696e4e26c1abc1cb5764d=
ecb9:

  3c59x: Add BQL support for 3c59x ethernet driver. (2015-08-24 12:20:5=
8 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2015-08-26

for you to fetch changes up to 0ba3ac03c1f38be17102d1c76c42a7c66a3e9ff2=
:

  Merge ath-next from ath.git (2015-08-26 12:40:23 +0300)

----------------------------------------------------------------

Major changes:

iwlwifi:

* new Tx power firmware API
* bump max firmware API to 17
* fix bug in debug prints
* static checker fix
* fix unused defines
* fix command list on newest firmware

brcmfmac:

* support NVRAM loading for bcm47xx platform
* new debugfs entry for msgbuf protocol layer used with PCIe devices

ath10k:

* add spectral scan support for qca99x0
* add qca6164 support

----------------------------------------------------------------
Adrien Schildknecht (1):
      rtlwifi: rtl8192cu: Add new device ID

Arend van Spriel (3):
      brcmfmac: correct interface combination info
      brcmfmac: make use of cfg80211_check_combinations()
      brcmfmac: bump highest event number for 4339 firmware

Ayala Beker (1):
      iwlwifi: mvm: split debug message to avoid exceeding 110 characte=
rs

Christian Engelmayer (1):
      rsi: Fix possible leak when loading firmware

Dan Carpenter (1):
      iwlwifi: mvm: catch underflow error earlier

Emmanuel Grumbach (1):
      iwlwifi: mvm: bump firmware API to 17

=46ranky Lin (2):
      brcmfmac: add debugfs entry for msgbuf statistics
      brcmfmac: block the correct flowring when backup queue overflow

Hante Meuleman (1):
      brcmfmac: Add support for host platform NVRAM loading.

Johannes Berg (2):
      iwlwifi: correctly size command string arrays
      iwlwifi: mvm: support new TX power command

Kalle Valo (2):
      Merge tag 'iwlwifi-next-for-kalle-2015-08-23' of https://git.kern=
el.org/.../iwlwifi/iwlwifi-next
      Merge ath-next from ath.git

Michal Kazior (6):
      ath10k: wake up offchannel queue properly
      ath10k: wake up queue upon vif creation
      ath10k: split ap/ibss wep key install process
      ath10k: add missing mutex unlock on failpath
      ath10k: fix dma_mapping_error() handling
      ath10k: add qca6164 support

Nicholas Mc Guire (1):
      wil6210: match wait_for_completion_timeout return type

Oleksij Rempel (1):
      ath9k_htc: do ani shortcalibratio if we got -ETIMEDOUT

Rafa=C5=82 Mi=C5=82ecki (1):
      brcmfmac: check all combinations when setting wiphy's addresses

Raja Mani (6):
      ath10k: refactor phyerr event handlers
      ath10k: handle 10.4 firmware phyerr event
      ath10k: ensure pktlog disable cmd reaches fw before pdev suspend
      ath10k: free collected fw stats memory if .pull_fw_stats fails
      ath10k: add spectral scan support for 10.4 fw
      ath10k: fix compilation warnings in wmi phyerr pull function

Sara Sharon (1):
      iwlwifi: mvm: update wakeup reason enum

Vasanthakumar Thiagarajan (3):
      ath10k: fix invalid survey reporting for QCA99X0
      ath10k: add cycle/rx_clear counters frequency to hw_params
      ath10k: fill in wmi 10.4 command handlers for addba/delba debug c=
ommands

Wu Fengguang (1):
      rtlwifi: rtl8192ee: fix semicolon.cocci warnings

 drivers/net/wireless/ath/ath10k/core.c             |   18 +-
 drivers/net/wireless/ath/ath10k/core.h             |    3 +
 drivers/net/wireless/ath/ath10k/debug.c            |    3 +-
 drivers/net/wireless/ath/ath10k/htc.c              |    4 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |    8 +-
 drivers/net/wireless/ath/ath10k/hw.c               |    4 +-
 drivers/net/wireless/ath/ath10k/hw.h               |    3 +-
 drivers/net/wireless/ath/ath10k/mac.c              |   54 +++--
 drivers/net/wireless/ath/ath10k/pci.c              |   21 +-
 drivers/net/wireless/ath/ath10k/spectral.c         |   18 +-
 drivers/net/wireless/ath/ath10k/spectral.h         |    4 +-
 drivers/net/wireless/ath/ath10k/wmi-ops.h          |   22 ++-
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |   17 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |  198 ++++++++++++=
+++----
 drivers/net/wireless/ath/ath10k/wmi.h              |   64 ++++--
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |   13 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |    2 +-
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c |  206 ++++++++++++=
++++----
 drivers/net/wireless/brcm80211/brcmfmac/firmware.c |   39 ++--
 drivers/net/wireless/brcm80211/brcmfmac/flowring.c |   10 +-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.h     |   10 +-
 drivers/net/wireless/brcm80211/brcmfmac/msgbuf.c   |   56 ++++++
 drivers/net/wireless/iwlwifi/dvm/agn.h             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/rx.c              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |    2 +-
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |    3 +
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |    5 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h       |    7 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |   29 ++-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   15 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |    2 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |   20 +-
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c        |    8 +-
 drivers/net/wireless/rsi/rsi_91x_usb_ops.c         |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    1 +
 drivers/net/wireless/rtlwifi/rtl8192ee/phy.c       |    6 +-
 37 files changed, 693 insertions(+), 196 deletions(-)

--=20
Kalle Valo
