From: Kalle Valo <kvalo@codeaurora.org>
Subject: wireless-drivers-next 2015-01-02
Date: Fri, 02 Jan 2015 15:59:44 +0200
Message-ID: <87zja1471r.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:33624 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbbABN7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 08:59:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's the first pull request for net-next. This time a slow start with
just few patches so it's easier to iron out any issues. I have a lot
more pending in patchwork and will send them later.

Please let me know if there are any issues.

Kalle

The following changes since commit b8fb4e0648a2ab3734140342002f68fb0c7d1602:

  net: Reset secmark when scrubbing packet (2014-12-24 00:21:43 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2015-01-02

for you to fetch changes up to 354f473ee2c5d01c1cf90f747f95218ee3e73e95:

  ath9k: fix typo (2014-12-24 19:14:44 +0200)

----------------------------------------------------------------
Changes:

* ath9k: enable Transmit Power Control (TPC) for ar9003 chips

* rtlwifi: cleanup and updates from the vendor driver

* rsi: fix memory leak related to firmware image

* ath: parameter fix for FCC DFS pattern

----------------------------------------------------------------
Alexey Khoroshilov (1):
      rsi: fix memory leak in rsi_load_ta_instructions()

Larry Finger (15):
      rtlwifi: rtl8821ae: Fix typos in power-sequence macro
      rtlwifi: rtl8192ce: Add code to set the keep-alive operation
      rtlwifi: rtl8192ce: Update setting of the media status
      rtlwifi: rtl8192ce: Update rate setting routines
      rtlwifi: rtl8192ce: Improve RF sleep routine
      rtlwifi: Remove extraneous argument for rate mapping
      rtlwifi: rtl8723be: Switch to use common rate-mapping routine
      rtlwifi: rtl8188ee: Switch to use common rate-mapping routine
      rtlwifi: rtl8723ae: Modify driver to use rate-mapping routine in core
      rtlwifi: rtl8192ee: Convert driver to use common rate-mapping code
      rtlwifi: Convert all drivers to use a common set of rate descriptors
      rtlwifi: rtl8821ae: Add VHT rate descriptors
      rtlwifi: rtl8192cu: Rework calls to rate-control routine
      rtlwifi: rtl8192de: Rework calls to rate-control routine
      rtlwifi: rtl8821ae: Switch to use common rate control routine

Lorenzo Bianconi (3):
      ath9k: enable TPC by default
      ath9k: add debugfs support for hw TPC
      ath9k: fix typo

Peter Oh (1):
      ath: fix incorrect PPB on FCC radar type 5

Rickard Strandqvist (3):
      rtlwifi: rtl8192de: fw.c: Remove unused function
      rtlwifi: rtl8192ee: trx.c: Remove unused function
      rtlwifi: rtl8723be: phy.c: Remove unused function

Troy Tan (1):
      rtlwifi: rtl8821ae: Simplify loading of WOWLAN firmware

 drivers/net/wireless/ath/ath9k/debug.c            |   71 +++++++
 drivers/net/wireless/ath/ath9k/hw.c               |    3 +
 drivers/net/wireless/ath/ath9k/xmit.c             |    2 +-
 drivers/net/wireless/ath/dfs_pattern_detector.c   |    2 +-
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c       |    4 +-
 drivers/net/wireless/rtlwifi/base.c               |  156 ++++++++++----
 drivers/net/wireless/rtlwifi/base.h               |    4 +-
 drivers/net/wireless/rtlwifi/core.c               |   24 ++-
 drivers/net/wireless/rtlwifi/core.h               |    1 +
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c      |  162 +-------------
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h |    1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c       |  165 +++++++--------
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c      |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c       |   30 +--
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c      |   13 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c      |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c       |   28 +--
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c      |   20 +-
 drivers/net/wireless/rtlwifi/rtl8192de/fw.c       |   17 --
 drivers/net/wireless/rtlwifi/rtl8192de/fw.h       |    1 -
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c       |   30 +--
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c      |   27 ++-
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.c      |  196 +----------------
 drivers/net/wireless/rtlwifi/rtl8192ee/trx.h      |    9 +-
 drivers/net/wireless/rtlwifi/rtl8192se/def.h      |    8 +-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c       |   30 +--
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c      |   23 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c      |  162 +-------------
 drivers/net/wireless/rtlwifi/rtl8723be/phy.c      |   25 ---
 drivers/net/wireless/rtlwifi/rtl8723be/phy.h      |    2 -
 drivers/net/wireless/rtlwifi/rtl8723be/trx.c      |  162 +-------------
 drivers/net/wireless/rtlwifi/rtl8821ae/def.h      |   54 -----
 drivers/net/wireless/rtlwifi/rtl8821ae/pwrseq.h   |    4 +-
 drivers/net/wireless/rtlwifi/rtl8821ae/sw.c       |   74 +++----
 drivers/net/wireless/rtlwifi/rtl8821ae/trx.c      |  232 +--------------------
 drivers/net/wireless/rtlwifi/wifi.h               |   96 +++++----
 36 files changed, 510 insertions(+), 1337 deletions(-)

-- 
Kalle Valo
