From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC/RFT 00/27] Updates for the rtlwifi family of drivers
Date: Mon, 25 Feb 2013 18:13:12 -0600
Message-ID: <1361837619-2985-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, jcheung@suse.com, machen@suse.com,
	mmarek@suse.cz
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:37451 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759130Ab3BZAOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 19:14:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches upgrades drivers rtlwifi, rtl8192c, rtl8192ce, rtl8192se,
and rtl8723ae to the state of the vendor driver issued on 2013.02.07. In
addition, a new driver for the RTL8188EE chip is added to the kernel.

Note: These patches do not upgrade rtl8192de. Those changes will be sent
later.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Larry Finger (27):
  rtlwifi: Modify the master header for for updates to vendor version
    2013.02.07
  rtlwifi: Modify files for 2013.02.07 vendor version - part 2
  rtlwifi: Modify files for 2013.02.07 vendor version - part 3
  rtlwifi: Modify files for 2013.02.07 vendor version - part 4
  rtlwifi: Modify files for 2013.02.07 vendor version - part 4
  rtlwifi: rtl8192se: Update driver to match vendor driver of 2013.02.07
  rtlwifi: rtl8723ae: Update to vendor driver of 2013.02.07
  rtlwifi: rtl8192c: rtl8192ce: Update to vendor driver of 2013.02.07
  rtlwifi: Rework rtl_lps_leave() and rtl_lps_enter() to use work queue
  rtlwifi: rtl8188ee: Add new driver - part 1
  rtlwifi: rtl8188ee: Add new driver files - part 2
  rtlwifi: rtl8188ee: Add new driver files - part 3
  rtlwifi: rtl8188ee: Add files for new driver - part 4
  rtlwifi: rtl8188ee: Add files for new driver - part 5
  rtlwifi: rtl8188ee: Add files for new driver - part 6
  rtlwifi: rtl8188ee: Add files for new driver - part 7
  rtlwifi: rtl8188ee: Add files for new driver - part 8
  rtlwifi: rtl8188ee: Add files for new driver - part 9
  rtlwifi: rtl8188ee: Add files for new driver - part 10
  rtlwifi: rtl8188ee: Add files for new driver - part 11
  rtlwifi: rtl8188ee: Add files for new driver - part 12
  rtlwifi: rtl8188ee: Add files for new driver - part 13
  rtlwifi: rtl8188ee: Add files for new driver - part 14
  rtlwifi: rtl8192c: rtl8192ce: rtl8192cu: rtl8192de: rtl8723ae: Add
    changes required by adding rtl81988ee
  rtlwifi: rtl8188ee: Enable recognition of RTL8188EE
  rtlwifi: rtl8188e: Remove some CamelCase variable names
  rtlwifi: rtl8188ee: Enable build of new driver

 drivers/net/wireless/rtlwifi/Kconfig               |   11 +
 drivers/net/wireless/rtlwifi/Makefile              |    1 +
 drivers/net/wireless/rtlwifi/base.c                |  377 ++-
 drivers/net/wireless/rtlwifi/base.h                |   14 +-
 drivers/net/wireless/rtlwifi/core.c                |  213 +-
 drivers/net/wireless/rtlwifi/debug.c               |    5 +-
 drivers/net/wireless/rtlwifi/debug.h               |   13 +-
 drivers/net/wireless/rtlwifi/efuse.c               |   53 +-
 drivers/net/wireless/rtlwifi/efuse.h               |    1 -
 drivers/net/wireless/rtlwifi/pci.c                 |  618 +++--
 drivers/net/wireless/rtlwifi/pci.h                 |    2 +
 drivers/net/wireless/rtlwifi/ps.c                  |  330 ++-
 drivers/net/wireless/rtlwifi/ps.h                  |    2 +
 drivers/net/wireless/rtlwifi/rc.c                  |    7 +
 drivers/net/wireless/rtlwifi/rtl8188ee/Makefile    |   16 +
 drivers/net/wireless/rtlwifi/rtl8188ee/def.h       |  324 +++
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c        | 1829 ++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.h        |  326 +++
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c        |  851 +++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.h        |  301 +++
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        | 2661 ++++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.h        |   68 +
 drivers/net/wireless/rtlwifi/rtl8188ee/led.c       |  158 ++
 drivers/net/wireless/rtlwifi/rtl8188ee/led.h       |   38 +
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c       | 2324 +++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.h       |  236 ++
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c    |  109 +
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h    |  327 +++
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c |  141 ++
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h |   70 +
 drivers/net/wireless/rtlwifi/rtl8188ee/reg.h       | 2258 +++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/rf.c        |  505 ++++
 drivers/net/wireless/rtlwifi/rtl8188ee/rf.h        |   46 +
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c        |  402 +++
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.h        |   36 +
 drivers/net/wireless/rtlwifi/rtl8188ee/table.c     |  642 +++++
 drivers/net/wireless/rtlwifi/rtl8188ee/table.h     |   47 +
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c       |  984 ++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.h       |  797 ++++++
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |  101 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |   99 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h  |    4 +
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |  118 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.h        |    4 +
 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h       |    1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |  324 +--
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   20 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |   24 +-
 drivers/net/wireless/rtlwifi/rtl8192de/reg.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192se/def.h       |    7 -
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |   49 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |  150 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.h        |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |   61 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.h       |    1 +
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |  296 +--
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        |   88 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h        |    6 +
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c        |   97 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h        |    7 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |   70 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/led.c       |   22 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |   10 +-
 drivers/net/wireless/rtlwifi/wifi.h                |  217 +-
 69 files changed, 17729 insertions(+), 1212 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/trx.h

-- 
1.8.1.4
