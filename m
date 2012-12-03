From: Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>
Subject: [GIT PULL] Remove __dev* markings from the networking drivers
Date: Mon, 3 Dec 2012 12:29:10 -0800
Message-ID: <20121203202910.GB29451@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bill Pemberton <wfp5p-4Ng6DfrEGID2fBVCVOL8/A@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi John,

Here's a pull request for all of Bill's __dev* removal patches for the
wireless networking drivers, based on net-next.  If you want this
rebased on a different tree, or sent as patches (it's only 18 of them),
please let me know.

thanks,

greg k-h

-------------

The following changes since commit 60e476d02129acb1f863a9b4932358678ee6a355:

  bna: remove useless calls to memset(). (2012-12-02 20:32:56 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/net-next.git tags/dev_removal_wireless

for you to fetch changes up to 40ccc6ab03053a2ad1f52c8b3f4d3ee828b7c013:

  rtlwifi: remove __dev* attributes (2012-12-03 11:47:38 -0800)

----------------------------------------------------------------
Wireless:  Remove __dev* markings from the wireless drivers

This is a series of patches that remove the dev* attributes for all
wireless drivers.

Use of __devinit, __devexit_p, __devinitdata, __devinitconst, and
__devexit are no longer needed since CONFIG_HOTPLUG is being removed as
an option.

Note, there are some devinit compiler section mismatch warnings due to
this series, but they are fixed up when merged with my driver-next
branch, which fixes the PCI device id warnings, and removes the modpost
detection, as it's no longer needed.

Signed-off-by: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>

----------------------------------------------------------------
Bill Pemberton (18):
      rfkill: remove __dev* attributes
      wireless: remove __dev* attributes
      ath5k: remove __dev* attributes
      atmel: remove __dev* attributes
      b43: remove __dev* attributes
      brcm80211: remove __dev* attributes
      ipw2x00: remove __dev* attributes
      iwlegacy: remove __dev* attributes
      iwlwifi: remove __dev* attributes
      libertas: remove __dev* attributes
      mwl8k: remove __dev* attributes
      orinoco: remove __dev* attributes
      p54: remove __dev* attributes
      rt2x00: remove __dev* attributes
      rtl8187: remove __dev* attributes
      rtl8187: remove __dev* attributes
      wlcore/wl18xx/wl12xx: remove __dev* attributes
      rtlwifi: remove __dev* attributes

 drivers/net/wireless/adm8211.c                        |  6 +++---
 drivers/net/wireless/airo.c                           |  6 +++---
 drivers/net/wireless/ath/ath5k/base.c                 |  4 ++--
 drivers/net/wireless/ath/ath5k/led.c                  |  2 +-
 drivers/net/wireless/ath/ath5k/pci.c                  |  6 +++---
 drivers/net/wireless/atmel_pci.c                      |  6 +++---
 drivers/net/wireless/b43/pcmcia.c                     |  6 +++---
 drivers/net/wireless/b43/sdio.c                       |  6 +++---
 drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c |  4 ++--
 drivers/net/wireless/ipw2x00/ipw2100.c                |  4 ++--
 drivers/net/wireless/ipw2x00/ipw2200.c                |  8 ++++----
 drivers/net/wireless/iwlegacy/3945-mac.c              |  4 ++--
 drivers/net/wireless/iwlegacy/4965-mac.c              |  4 ++--
 drivers/net/wireless/iwlwifi/pcie/drv.c               |  4 ++--
 drivers/net/wireless/libertas/if_spi.c                |  6 +++---
 drivers/net/wireless/mwl8k.c                          | 12 ++++++------
 drivers/net/wireless/orinoco/orinoco_nortel.c         |  4 ++--
 drivers/net/wireless/orinoco/orinoco_pci.c            |  4 ++--
 drivers/net/wireless/orinoco/orinoco_plx.c            |  4 ++--
 drivers/net/wireless/orinoco/orinoco_tmd.c            |  4 ++--
 drivers/net/wireless/p54/p54pci.c                     |  6 +++---
 drivers/net/wireless/p54/p54spi.c                     |  6 +++---
 drivers/net/wireless/p54/p54usb.c                     |  6 +++---
 drivers/net/wireless/rt2x00/rt2400pci.c               |  2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c               |  2 +-
 drivers/net/wireless/rt2x00/rt2800pci.c               |  4 ++--
 drivers/net/wireless/rt2x00/rt61pci.c                 |  2 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c            |  6 +++---
 drivers/net/wireless/rtl818x/rtl8187/dev.c            |  6 +++---
 drivers/net/wireless/rtlwifi/pci.c                    |  2 +-
 drivers/net/wireless/rtlwifi/pci.h                    |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c           |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c           |  2 +-
 drivers/net/wireless/rtlwifi/usb.c                    |  2 +-
 drivers/net/wireless/rtlwifi/usb.h                    |  2 +-
 drivers/net/wireless/ti/wl1251/sdio.c                 |  4 ++--
 drivers/net/wireless/ti/wl1251/spi.c                  |  6 +++---
 drivers/net/wireless/ti/wl12xx/main.c                 |  6 +++---
 drivers/net/wireless/ti/wl18xx/main.c                 |  6 +++---
 drivers/net/wireless/ti/wlcore/main.c                 |  4 ++--
 drivers/net/wireless/ti/wlcore/sdio.c                 |  8 ++++----
 drivers/net/wireless/ti/wlcore/spi.c                  |  6 +++---
 drivers/net/wireless/ti/wlcore/wlcore.h               |  4 ++--
 net/rfkill/rfkill-gpio.c                              |  2 +-
 net/rfkill/rfkill-regulator.c                         |  6 +++---
 45 files changed, 104 insertions(+), 104 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
