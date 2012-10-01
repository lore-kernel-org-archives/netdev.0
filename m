From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-10-01
Date: Mon, 1 Oct 2012 15:24:49 -0400
Message-ID: <20121001192448.GA1944@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WIyZ46R2i8wDzkSu"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit e4d680c706284ca0413a84bd2a28fda76b360904

In my previous pull request, I mentioned that I had a few stragglers.
They are all driver updates: ti, brcmfmac, ath9k, one for bcma and
one for b43legacy.  I merged them late last week and was letting them
soak in linux-next.  I hope they can still make 3.7.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit a248afdc1b5916c2bfd007233112333d85aa28f6:

  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git=
/linville/wireless-next (2012-09-30 02:30:16 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to e4d680c706284ca0413a84bd2a28fda76b360904:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2012-10-01 07:39:36 -0400)

----------------------------------------------------------------

Arend van Spriel (6):
      brcmfmac: get rid of extern keyword in wl_cfg80211.h
      brcmfmac: use brcmf_cfg80211_priv to interface with wl_cfg80211 code
      brcmfmac: remove two obsolete structure definitions
      brcmfmac: rename structure brcmf_cfg80211_priv
      brcmfmac: remove brcmf_read_prof() function
      brcmfmac: remove brcmf_update_prof() function

Arik Nemtsov (9):
      wlcore: AP mode - send non-data packets with basic rates
      wlcore: allow only the lowest OFDM rate for p2p setup frames
      wlcore: make Tx flush timings more verbose
      wlcore: tx_flush - optimize flow and force Tx during the flush
      wlcore/wl18xx/wl12xx: allow up to 3 mac addresses
      wlcore: make debug prints work without dynamic debug
      wlcore: allow up to 3 running STA interfaces in combinations
      wlcore: spi: use private max-buf-size limit
      wl18xx: default to siso40 in 2.4ghz with a single antenna

Avinash Patil (1):
      mwifiex: enhance RX reordering to avoid packet drop during host sleep

Bala Shanmugam (1):
      ath9k: Enable MCI for AR9565

Dan Carpenter (1):
      brcmfmac: use kcalloc() to prevent integer overflow

Devendra Naga (1):
      wl18xx: use module_platform_driver

Eliad Peller (9):
      wlcore: consider single fw case
      wlcore: cancel recovery_work on stop() instead of remove_interface()
      wlcore: resume() only if sta is associated
      wlcore: always use wlvif->role_id for scans
      wlcore: lazy-enable device roles
      wlcore: invalidate keep-alive template on disconnection
      wlcore: use dynamic keep-alive template ids
      wlcore: decrease elp timeout
      wlcore: protect wlcore_op_set_key with mutex

Eyal Shapira (1):
      wlcore: configure wowlan regardless of wakeup conditions

Hante Meuleman (5):
      brcmfmac: use wait_event_timeout for fw control packets over usb.
      brcmfmac: use different fw api for encryption,auth. config
      brcmfmac: use define instead of hardcoded values.
      brcmfmac: notify common driver about usb tx completion.
      brcmfmac: add hostap supoort.

Ido Reis (2):
      wl18xx: update default phy configuration for pg2
      wl18xx: increase rx_ba_win_size to 32

Ido Yariv (6):
      wlcore: Prevent interaction with HW after recovery is queued
      wlcore: Don't recover during boot
      wlcore: Fix unbalanced interrupts enablement
      wlcore: Allow memory access when the FW crashes
      wlcore: Refactor probe
      wlcore: Load the NVS file asynchronously

Igal Chernobelsky (2):
      wl18xx/wl12xx: defines for Tx/Rx descriptors num
      wlcore/wl18xx/wl12xx: aggregation buffer size set

John W. Linville (2):
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12xx
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Kevin Gan (1):
      mwifiex: add inactivity deauth support for ap

Larry Finger (1):
      b43legacy: Fix crash on unload when firmware not available

Luciano Coelho (1):
      wl12xx: use module_platform_driver

Rafa=C5=82 Mi=C5=82ecki (1):
      bcma: change delays to follow timers-howto guide

Stone Piao (14):
      mwifiex: fix coding style issue
      mwifiex: implement cfg80211 mgmt_tx handler
      mwifiex: advertise mgmt_stype to cfg80211
      mwifiex: implement cfg80211 mgmt_frame_register handler
      mwifiex: report received management frames to cfg80211
      mwifiex: implement remain_on_channel and cancel_remain_on_channel
      mwifiex: process remain on channel expired event
      mwifiex: append each IE into a seperate IE buffer
      mwifiex: send firmware initialization commands synchronously
      mwifiex: add P2P interface
      mwifiex: add support for P2P client in interface type change
      mwifiex: add support for P2P GO in interface type change
      mwifiex: parse P2P IEs from beacon_data
      mwifiex: set txpd when send a mgmt frame for AP and GO mode

Sujith Manoharan (4):
      ath9k: Handle errors properly in MCI initialization
      ath9k: Add a debugfs file to adjust antenna diversity
      ath9k: Fix chainmask selection for AR9462
      ath9k: Fix BTCOEX weight initialization

Sven Eckelmann (1):
      ath9k_hw: Handle AR_INTR_SYNC_HOST1_(FATAL|PERR) on AR9003

Thomas Wagner (1):
      ath9k: Fix rx filtering issue for older chips

Tim Gardner (1):
      wlcore: Declare MODULE_FIRMWARE usage

Wei Yongjun (2):
      wl12xx: remove duplicated include from main.c
      mwifiex: convert to use le16_add_cpu()

Yair Shapira (2):
      wl18xx: number_of_assembled_ant5 indicates if A band is enabled
      wlcore/wl18xx: add phy_fw_version_str to debugfs driver_state

 drivers/bcma/core.c                                |    2 +-
 drivers/bcma/driver_chipcommon_pmu.c               |    5 +-
 drivers/bcma/driver_pci.c                          |    6 +-
 drivers/bcma/driver_pci_host.c                     |    8 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   17 +
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |   21 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.h        |    8 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    2 +
 drivers/net/wireless/ath/ath9k/btcoex.c            |   65 +-
 drivers/net/wireless/ath/ath9k/btcoex.h            |    3 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   55 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |    7 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |    2 +-
 drivers/net/wireless/ath/ath9k/mci.c               |   11 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    4 +-
 drivers/net/wireless/ath/ath9k/wow.c               |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    4 +
 drivers/net/wireless/b43legacy/main.c              |    2 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |   33 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |   46 +
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |   48 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  | 2416 +++++++++++++---=
----
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |   81 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |   49 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.h       |    5 +
 drivers/net/wireless/mwifiex/cfg80211.c            |  386 +++-
 drivers/net/wireless/mwifiex/cmdevt.c              |    2 +
 drivers/net/wireless/mwifiex/decl.h                |    6 +-
 drivers/net/wireless/mwifiex/fw.h                  |   43 +
 drivers/net/wireless/mwifiex/ie.c                  |   86 +-
 drivers/net/wireless/mwifiex/init.c                |   14 +-
 drivers/net/wireless/mwifiex/ioctl.h               |    2 +
 drivers/net/wireless/mwifiex/main.c                |   41 +-
 drivers/net/wireless/mwifiex/main.h                |   36 +
 drivers/net/wireless/mwifiex/scan.c                |    5 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |   92 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   39 +
 drivers/net/wireless/mwifiex/sta_event.c           |   12 +
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   59 +
 drivers/net/wireless/mwifiex/sta_rx.c              |    6 +
 drivers/net/wireless/mwifiex/sta_tx.c              |   12 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |   22 +
 drivers/net/wireless/mwifiex/uap_txrx.c            |   15 +
 drivers/net/wireless/mwifiex/util.c                |   40 +
 drivers/net/wireless/mwifiex/wmm.c                 |    9 +-
 drivers/net/wireless/ti/wl12xx/main.c              |   79 +-
 drivers/net/wireless/ti/wl12xx/wl12xx.h            |    7 +
 drivers/net/wireless/ti/wl18xx/debugfs.c           |    2 +-
 drivers/net/wireless/ti/wl18xx/main.c              |  128 +-
 drivers/net/wireless/ti/wl18xx/wl18xx.h            |    7 +
 drivers/net/wireless/ti/wlcore/cmd.c               |   21 +-
 drivers/net/wireless/ti/wlcore/cmd.h               |    5 -
 drivers/net/wireless/ti/wlcore/conf.h              |    3 +-
 drivers/net/wireless/ti/wlcore/debug.h             |   16 +-
 drivers/net/wireless/ti/wlcore/debugfs.c           |   32 +-
 drivers/net/wireless/ti/wlcore/init.c              |   12 +-
 drivers/net/wireless/ti/wlcore/io.h                |    4 +-
 drivers/net/wireless/ti/wlcore/main.c              |  366 +--
 drivers/net/wireless/ti/wlcore/ps.c                |   10 +-
 drivers/net/wireless/ti/wlcore/rx.c                |    2 +-
 drivers/net/wireless/ti/wlcore/scan.c              |   20 +-
 drivers/net/wireless/ti/wlcore/spi.c               |   10 +-
 drivers/net/wireless/ti/wlcore/testmode.c          |    4 +-
 drivers/net/wireless/ti/wlcore/tx.c                |   51 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |   23 +-
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |   13 +-
 67 files changed, 3271 insertions(+), 1375 deletions(-)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--WIyZ46R2i8wDzkSu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQae4AAAoJEJctW/TcYTgGsRgP/j0FeChJV2GWj9cmNXrjBfYN
F5WN66B1hoWb794uRVM3lTwuBAUS3ii6TYzAFGT1SJi7IRu99ABGSZqeBXiG4Y0H
Y4UN15erJ8H1ib5QY3oKL+F1tuz5sBfqXWnzotUj+v9PJC/qMMeCOmQ5R+tvds+S
CRx9YUQqCdChGFpyIsFxIXhZ1y8nEWNzla9KpthIqlMNFiLk9z3JR7cyVY1ktoXo
T4hYuMrpAxeX8j/dFnbHyhSe+NZ0cz31/iJalHv0dyc3O9GJGw7TyeeWOX6Ukitc
65kTYFK54lJ3yvj7K9bKieKA9LxVWQxVJU5g21UXLZa9nIHcMcs6UCPxTRp7bQrE
8P+iGOzl/WVA4JBRMeUVFh4yfwkSRpP9PwutJxUV4ZPr8E1FW16GTDtNrKTQFnJi
aSSIYbIuhPzO5qRNt0MNJDkuEbvfQpQ4rQCG0oRsC4uqK4UaSASwPJtJYgBWu/U+
AhA14BfENe1n6CeXa9tldVKFW8D3rVuEtHMp2sFdA7eroiOceE+umOsWsrMKFvwP
a+YMfYG+3ovydZ3hUcT2/wRs79Y/X7TjIaqpTSdzz58syxhIKf+mulq8hot9XVqY
nhkx7bM5eN7v52S2M/Oti+WHePJBcAfqthZlzHBJW224oPrgURdlxSrdRBmQs0rH
Yi8h9tFSfOZYBWlEgDwm
=KxBk
-----END PGP SIGNATURE-----

--WIyZ46R2i8wDzkSu--
