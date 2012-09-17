From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: (unknown)
Date: Mon, 17 Sep 2012 14:22:36 -0700 (PDT)
Message-ID: <5057949c.c10c320a.7d79.ffffffbe@mx.google.com>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:48910 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753179Ab2IQVWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 17:22:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

,
	netdev@vger.kernel.org,
	<chaoming_li@realsil.com.cn>
Subject: [PATCH 00/15] Add new driver RTL8723AE
Date: Mon, 17 Sep 2012 16:21:58 -0500
Message-Id: <1347483294-6943-1-git-send-email-Larry.Finger@lwfinger.net>
X-Mailer: git-send-email 1.7.10.4
X-Mailer: git-send-email 1.7.10.4

From: Larry Finger <Larry.Finger@lwfinger.net>

This set of patches add the new driver rtl8723ae to the rtlwifi family
of drivers. It handles the RTL8723AE, which is now being included in
some Toshiba laptops. This driver is derived from version 0007.0809.2012
of the vendor driver.

Depending on how long the review process takes, I am hoping to include
this driver in kernel 3.7.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Larry Finger (15):
  rtlwifi: rtl8723ae: Add new driver - Part 1
  rtlwifi: rtl8723ae: Add new driver - Part 2
  rtlwifi: rtl8723ae: Add new driver - Part 3
  rtlwifi: rtl8723ae: Add new driver - Part 4
  rtlwifi: rtl8723ae: Add new driver - Part 5
  rtlwifi: rtl8723ae: Add new driver - Part 6
  rtlwifi: rtl8723ae: Add new driver - Part 7
  rtlwifi: rtl8723ae: Add new driver - Part 8
  rtlwifi: rtl8723ae: Add new driver - Part 9
  rtlwifi: rtl8723ae: Add new driver - Part 10
  rtlwifi: rtl8723ae: Add new driver - Part 11
  rtlwifi: rtl8723ae: Add new driver - Part 12
  rtlwifi: rtl8723ae: Add new driver - Part 13
  rtlwifi: Modify files for addition of rtl8723ae
  rtlwifi: rtl8192ce: rtl8192cu: rtl8192se: rtl81723ae: Turn on
    building of the new driver

 drivers/net/wireless/rtlwifi/Kconfig               |   19 +-
 drivers/net/wireless/rtlwifi/Makefile              |    4 +-
 drivers/net/wireless/rtlwifi/debug.h               |    2 +
 drivers/net/wireless/rtlwifi/pci.h                 |    1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   83 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   10 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile    |   23 +
 drivers/net/wireless/rtlwifi/rtl8723ae/btc.h       |   41 +
 drivers/net/wireless/rtlwifi/rtl8723ae/def.h       |  291 +++
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        |  952 ++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h        |  174 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c        |  758 ++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h        |   99 +
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c    |  554 +++++
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.h    |  161 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c   | 1807 ++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h   |  161 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        | 2559 ++++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.h        |   70 +
 drivers/net/wireless/rtlwifi/rtl8723ae/led.c       |  158 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/led.h       |   40 +
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c       | 2160 +++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h       |  228 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c    |  113 +
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h    |  313 +++
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c |  145 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h |  101 +
 drivers/net/wireless/rtlwifi/rtl8723ae/reg.h       | 2129 ++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.c        |  518 ++++
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.h        |   45 +
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |  405 ++++
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.h        |   38 +
 drivers/net/wireless/rtlwifi/rtl8723ae/table.c     |  744 ++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/table.h     |   51 +
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |  830 +++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.h       |  725 ++++++
 drivers/net/wireless/rtlwifi/stats.c               |  274 +++
 drivers/net/wireless/rtlwifi/stats.h               |   47 +
 drivers/net/wireless/rtlwifi/wifi.h                |  112 +-
 40 files changed, 16919 insertions(+), 32 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/btc.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/trx.h
 create mode 100644 drivers/net/wireless/rtlwifi/stats.c
 create mode 100644 drivers/net/wireless/rtlwifi/stats.h

-- 
1.7.10.4
