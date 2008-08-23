From: "Tomas Winkler" <tomasw@gmail.com>
Subject: Re: pull request: wireless-next-2.6 2008-08-22
Date: Sat, 23 Aug 2008 04:21:23 +0300
Message-ID: <1ba2fa240808221821l3fcc4091l57caba03f86526ea@mail.gmail.com>
References: <20080822234632.GA12922@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:58902 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbYHWBVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 21:21:25 -0400
Received: by fg-out-1718.google.com with SMTP id 19so394218fgg.17
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2008 18:21:23 -0700 (PDT)
In-Reply-To: <20080822234632.GA12922@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 23, 2008 at 2:46 AM, John W. Linville
<linville@tuxdriver.com> wrote:
> Dave,
>
> Here is my current stack of updates for 2.6.28 -- included is an
> orinoco update to support WPA on certain firmware, the new libertas_tf
> driver, a number of cleanups, and a variety of other driver updates.
> Still more to come, but I think it is better to get these out rather
> than wait for the rest...
>
> Please let me know of there are problems!
>

Missing this one
iwlwifi: allow consecutive scans in unassociated state
http://marc.info/?l=linux-wireless&m=121919791411147&w=2
Thanks
Tomas

> Thanks,
>
> John
>
> ---
>
> Individual patches are available here:
>
>        http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6/
>
> ---
>
> The following changes since commit 2540e0511ea17e25831be543cdf9381e6209950d:
>  Jarek Poplawski (1):
>        pkt_sched: Fix qdisc_watchdog() vs. dev_deactivate() race
>
> are available in the git repository at:
>
>  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-2.6.git master
>
> Andrey Yurovsky (1):
>      ath5k: add Mesh Point support
>
> Brian Cavagnolo (2):
>      libertas: support boot commands to write persistent firmware and bootloader
>      libertas: add sysfs hooks to update boot2 and persistent firmware
>
> Bruno Randolf (5):
>      ath5k: rates cleanup
>      mac80211: add rx status flag for short preamble
>      mac80211: radiotap: assume modulation from rates
>      iwlwifi: use generic mac80211 radiotap headers
>      ath5k: set short preamble flag for rx
>
> Christian Lamparter (1):
>      p54: rename prism54xyz -> p54xyz
>
> Daniel Wagner (1):
>      rt2x00mac: In error case stop netdev queue, free skb and return NETDEV_TX_OK
>
> David Kilroy (19):
>      orinoco: Add ESSID specific scanning for Agere fw
>      orinoco: Update scan translation
>      orinoco: Specify all three parameters to every Hermes command.
>      orinoco: Move EXPORT_SYMBOL declarations next to exported function
>      orinoco: Add function to execute Hermes initialisation commands synchronously
>      orinoco: Move firmware download functionality into new module
>      orinoco: Make firmware download logic more generic
>      orinoco: Extend hermes_dld routines for Agere firmware
>      orinoco: Invoke firmware download in main driver
>      orinoco: Fix transmit for Agere/Lucent with fw 9.x
>      orinoco: address checkpatch typedef warning
>      orinoco: Use extended Agere scans available on 9.x series firmwares
>      orinoco: Don't use boolean parameter to record encoding type
>      orinoco: Split wevent work thread from wevent sending
>      orinoco: Use a macro to define wireless handlers
>      orinoco: Add WE-18 ioctls for WPA
>      orinoco: Send association events to userspace
>      orinoco: Process bulk of receive interrupt in a tasklet
>      orinoco: Add MIC on TX and check on RX
>
> Esti Kummer (1):
>      iwlwifi: add level for debugging host command
>
> Harvey Harrison (13):
>      b43legacy: use le16 frame control directly, avoid byteswapping
>      iwlwifi: use le16 frame control directly, use QOS symbolic constant mask
>      ath5k: explicitly check skb->len
>      mac80211: explicitly check skb->len
>      mac80211: wme.h remove unused QOS_CONTROL_LEN
>      mac80211: wep.c replace magic numbers in IV/ICV removal
>      mac80211: rx.c/tx.c remove more users of tx/rx_data->fc
>      mac80211: remove ieee80211_get_hdrlen
>      mac80211: remove IEEE80211_FC helper
>      mac80211: use ieee80211 frame control directly
>      mac80211: remove rx/tx_data->fc member
>      mac80211: remove WLAN_FC_DATA_PRESENT
>      wireless: replace __FUNCTION__ with __func__
>
> Henrique de Moraes Holschuh (4):
>      rfkill: detect bogus double-registering (v2)
>      rfkill: add default global states (v2)
>      rfkill: add __must_check annotations
>      rfkill: introduce RFKILL_STATE_MAX
>
> Herton Ronaldo Krzesinski (1):
>      rtl818x: merge tx/rx descriptor flags
>
> Ivo van Doorn (7):
>      rt2x00: Implement HW encryption
>      rt2x00: Implement HW encryption (rt61pci)
>      rt2x00: Implement HW encryption (rt73usb)
>      rt2x00: Gather channel information in structure
>      rt2x00: Release rt2x00 2.2.0
>      rt2x00: Move lna_gain calculation to config() callback
>      rt2x00: Add module parameter to disable HW crypto
>
> Jasper Bryant-Greene (2):
>      move ETH_P_PAE from ieee80211_i.h to if_ether.h
>      replace net_device arguments with ieee80211_{local,sub_if_data} as appropriate
>
> Jiri Slaby (1):
>      Ath5k: unify resets
>
> Julia Lawall (1):
>      net/ieee80211: adjust error handling
>
> Luis Carlos Cobo (6):
>      mac80211: allow no mac address until firmware load
>      libertas_tf: header file
>      libertas_tf: main.c, data paths and mac80211 handlers
>      libertas_tf: command helper functions for libertas_tf
>      libertas_tf: usb specific functions
>      libertas_tf: config and makefile
>
> Robert P. J. Day (1):
>      WIRELESS: Make wireless one-click selectable.
>
> Ron Rindjunsky (2):
>      mac80211: change number of pre-assoc scans
>      mac80211: add direct probe before association
>
> Tomas Winkler (4):
>      mac80211: add ieee80211_queue_stopped)
>      iwlwifi: kill struct iwl4965_lq_mngr
>      mac80211: filter probes in ieee80211_rx_mgmt_probe_resp
>      mac80211: cleanup mlme state namespace
>
> roel kluin (1):
>      iwl-4965: test below 0 on unsigned num_tbs
>
>  drivers/net/wireless/Kconfig                   |   17 +-
>  drivers/net/wireless/Makefile                  |    4 +-
>  drivers/net/wireless/airo.c                    |   16 +-
>  drivers/net/wireless/airport.c                 |    3 +-
>  drivers/net/wireless/ath5k/ath5k.h             |  162 +--
>  drivers/net/wireless/ath5k/base.c              |  383 ++---
>  drivers/net/wireless/ath5k/base.h              |    8 +-
>  drivers/net/wireless/ath5k/hw.c                |   77 +-
>  drivers/net/wireless/b43legacy/xmit.c          |    4 +-
>  drivers/net/wireless/hermes.c                  |  124 +-
>  drivers/net/wireless/hermes.h                  |   45 +
>  drivers/net/wireless/hermes_dld.c              |  730 +++++++++
>  drivers/net/wireless/hermes_dld.h              |   48 +
>  drivers/net/wireless/hermes_rid.h              |   17 +
>  drivers/net/wireless/ipw2100.c                 |    2 +-
>  drivers/net/wireless/ipw2200.h                 |    4 +-
>  drivers/net/wireless/iwlwifi/iwl-3945-debug.h  |    4 +-
>  drivers/net/wireless/iwlwifi/iwl-3945.c        |  104 +--
>  drivers/net/wireless/iwlwifi/iwl-3945.h        |    1 -
>  drivers/net/wireless/iwlwifi/iwl-agn.c         |    2 -
>  drivers/net/wireless/iwlwifi/iwl-core.c        |    1 -
>  drivers/net/wireless/iwlwifi/iwl-debug.h       |   12 +-
>  drivers/net/wireless/iwlwifi/iwl-dev.h         |   16 -
>  drivers/net/wireless/iwlwifi/iwl-hcmd.c        |   14 +-
>  drivers/net/wireless/iwlwifi/iwl-rx.c          |  125 +--
>  drivers/net/wireless/iwlwifi/iwl-tx.c          |   32 +-
>  drivers/net/wireless/iwlwifi/iwl3945-base.c    |    8 +-
>  drivers/net/wireless/libertas/cmd.c            |   21 +-
>  drivers/net/wireless/libertas/defs.h           |    6 +-
>  drivers/net/wireless/libertas/if_cs.c          |    2 +-
>  drivers/net/wireless/libertas/if_usb.c         |  177 ++-
>  drivers/net/wireless/libertas/if_usb.h         |    5 +
>  drivers/net/wireless/libertas_tf/Makefile      |    6 +
>  drivers/net/wireless/libertas_tf/cmd.c         |  669 ++++++++
>  drivers/net/wireless/libertas_tf/if_usb.c      |  766 ++++++++++
>  drivers/net/wireless/libertas_tf/if_usb.h      |   98 ++
>  drivers/net/wireless/libertas_tf/libertas_tf.h |  514 +++++++
>  drivers/net/wireless/libertas_tf/main.c        |  666 ++++++++
>  drivers/net/wireless/orinoco.c                 | 1949 +++++++++++++++++++++---
>  drivers/net/wireless/orinoco.h                 |   61 +-
>  drivers/net/wireless/orinoco_cs.c              |    3 +-
>  drivers/net/wireless/orinoco_nortel.c          |    3 +-
>  drivers/net/wireless/orinoco_pci.c             |    3 +-
>  drivers/net/wireless/orinoco_plx.c             |    3 +-
>  drivers/net/wireless/orinoco_tmd.c             |    3 +-
>  drivers/net/wireless/p54/p54.h                 |    6 +-
>  drivers/net/wireless/p54/p54common.h           |    6 +-
>  drivers/net/wireless/p54/p54pci.c              |   34 +-
>  drivers/net/wireless/p54/p54pci.h              |   10 +-
>  drivers/net/wireless/p54/p54usb.c              |   32 +-
>  drivers/net/wireless/p54/p54usb.h              |    6 +-
>  drivers/net/wireless/prism54/isl_ioctl.c       |    8 +-
>  drivers/net/wireless/rt2x00/Kconfig            |    6 +
>  drivers/net/wireless/rt2x00/Makefile           |    1 +
>  drivers/net/wireless/rt2x00/rt2400pci.c        |   40 +-
>  drivers/net/wireless/rt2x00/rt2400pci.h        |   22 +-
>  drivers/net/wireless/rt2x00/rt2500pci.c        |   39 +-
>  drivers/net/wireless/rt2x00/rt2500pci.h        |   17 +-
>  drivers/net/wireless/rt2x00/rt2500usb.c        |   39 +-
>  drivers/net/wireless/rt2x00/rt2500usb.h        |   17 +-
>  drivers/net/wireless/rt2x00/rt2x00.h           |   73 +-
>  drivers/net/wireless/rt2x00/rt2x00config.c     |    4 +
>  drivers/net/wireless/rt2x00/rt2x00crypto.c     |  215 +++
>  drivers/net/wireless/rt2x00/rt2x00debug.c      |   97 ++
>  drivers/net/wireless/rt2x00/rt2x00dev.c        |   48 +-
>  drivers/net/wireless/rt2x00/rt2x00lib.h        |   47 +
>  drivers/net/wireless/rt2x00/rt2x00mac.c        |  153 ++-
>  drivers/net/wireless/rt2x00/rt2x00queue.c      |   81 +-
>  drivers/net/wireless/rt2x00/rt2x00queue.h      |   73 +-
>  drivers/net/wireless/rt2x00/rt2x00reg.h        |   19 +-
>  drivers/net/wireless/rt2x00/rt61pci.c          |  354 ++++-
>  drivers/net/wireless/rt2x00/rt61pci.h          |   38 +-
>  drivers/net/wireless/rt2x00/rt73usb.c          |  363 ++++-
>  drivers/net/wireless/rt2x00/rt73usb.h          |   38 +-
>  drivers/net/wireless/rtl8180.h                 |   31 -
>  drivers/net/wireless/rtl8180_dev.c             |   34 +-
>  drivers/net/wireless/rtl8187.h                 |    6 -
>  drivers/net/wireless/rtl8187_dev.c             |   10 +-
>  drivers/net/wireless/rtl818x.h                 |   35 +
>  drivers/net/wireless/spectrum_cs.c             |  426 +-----
>  drivers/net/wireless/wl3501_cs.c               |    8 +-
>  include/linux/if_ether.h                       |    1 +
>  include/linux/rfkill.h                         |    7 +-
>  include/net/mac80211.h                         |   22 +-
>  net/Kconfig                                    |    8 +-
>  net/ieee80211/ieee80211_module.c               |    8 +-
>  net/mac80211/cfg.c                             |   21 +-
>  net/mac80211/debugfs_sta.c                     |    2 +-
>  net/mac80211/event.c                           |    5 +-
>  net/mac80211/ieee80211_i.h                     |  103 +-
>  net/mac80211/iface.c                           |    8 +-
>  net/mac80211/main.c                            |   81 +-
>  net/mac80211/mesh.c                            |   29 +-
>  net/mac80211/mesh.h                            |   61 +-
>  net/mac80211/mesh_hwmp.c                       |  120 +-
>  net/mac80211/mesh_pathtbl.c                    |   76 +-
>  net/mac80211/mesh_plink.c                      |   56 +-
>  net/mac80211/mlme.c                            |  850 ++++++-----
>  net/mac80211/rx.c                              |  140 +-
>  net/mac80211/tx.c                              |   46 +-
>  net/mac80211/util.c                            |   46 +-
>  net/mac80211/wep.c                             |   14 +-
>  net/mac80211/wext.c                            |   53 +-
>  net/mac80211/wme.h                             |    2 -
>  net/mac80211/wpa.c                             |    2 +-
>  net/rfkill/rfkill-input.h                      |    1 +
>  net/rfkill/rfkill.c                            |  170 ++-
>  107 files changed, 8652 insertions(+), 2634 deletions(-)
>  create mode 100644 drivers/net/wireless/hermes_dld.c
>  create mode 100644 drivers/net/wireless/hermes_dld.h
>  create mode 100644 drivers/net/wireless/libertas_tf/Makefile
>  create mode 100644 drivers/net/wireless/libertas_tf/cmd.c
>  create mode 100644 drivers/net/wireless/libertas_tf/if_usb.c
>  create mode 100644 drivers/net/wireless/libertas_tf/if_usb.h
>  create mode 100644 drivers/net/wireless/libertas_tf/libertas_tf.h
>  create mode 100644 drivers/net/wireless/libertas_tf/main.c
>  create mode 100644 drivers/net/wireless/rt2x00/rt2x00crypto.c
>
> Omnibus patch available here:
>
>        http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2.6-2008-08-22.patch.bz2
>
> --
> John W. Linville
> linville@tuxdriver.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
