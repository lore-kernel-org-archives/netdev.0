From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-01-01
Date: Wed, 1 Jan 2014 16:04:40 -0500
Message-ID: <20140101210440.GD24093@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zYM0uCDKw75PZbzx"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37758 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754556AbaAAVPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 16:15:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--zYM0uCDKw75PZbzx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

These patches were tucked-in with me for my long winter's nap!
Please pull them for the 3.14 stream...

For the mac80211 bits, Johannes says:

"Here I just have a collection of fixes/improvements/cleanups, very
little really stands out apart from CSA fixes, vendor command support
and the RCU speedups."

For the iwlwifi bits, Emmanuel says:

"I have hear quite a few things. Alex continues his work on power
management. Arik is reworking the transport API by unifying redudant
APIs and making error handling more generic. Eyal keeps on digging in
the rate scaling code.
We also have two new features - Max is using the brand new generic
cipher infrastructure in mac80211, and Lilach implements the smart fifo
which allows to save power by making interrupt coalescing smarter."

Along with those, Arend and company bring a batch of brcmfmac.
Sujith and Felix bring the usual high level of ath9k activity as well.
Bing gives mwifiex some love as well, and a handful of other bits
get updates here and there.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 21eb218989523b7bee28900aaec9f9296b70fa27:

  net, sch: fix the typo in register_qdisc() (2013-12-31 16:44:10 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to ad86c55bac643a745f480d26689d153ec0f38b04:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2014-01-01 15:39:56 -0500)

----------------------------------------------------------------

Alexander Bondar (6):
      iwlwifi: mvm: Add uAPSD misbehaving AP notification handling
      iwlwifi: mvm: Change power management dependency on multi MAC
      iwlwifi: mvm: Disable power save for monitor interface
      iwlwifi: mvm: Enable power save on a single P2P client interface
      iwlwifi: mvm: add per-vif power debugfs hooks
      iwlwifi: mvm: Add and examine TLV flag for P2P client uAPSD support

Arend van Spriel (14):
      brcmfmac: add missing curly braces in brcmf_fws_txstatus_suppressed()
      brcmfmac: combine bcmsdh source files into one
      brcmfmac: remove unnecessary function prototypes
      brcmfmac: remove unused struct brcmf_sdio_dev::func_cis_ptr attribute
      brcmfmac: use sdio functions to enable/disable F2
      brcmfmac: remove brcmf_sdio_regrw_helper() from header file
      brcmfmac: remove regs parameter from sdio probe functions
      brcmfmac: get rid of some void pointer parameters
      brcmfmac: remove brcmf_sdio_wdtimer_enable() function
      brcmfmac: use consistent function names in bcmsdh.c
      brcmfmac: reduce function parameters in sdio send/receive calls
      brcmfmac: use consistent function names in dhd_sdio.c
      brcmfmac: remove brcmf_sdio_disconnect() function
      brcmfmac: clarify struct brcmf_sdio_dev::func[0] reference

Arik Nemtsov (6):
      iwlwifi: trans: divide stop_hw into stop_device/op_mode_leave
      iwlwifi: trans: use a unified transport status
      iwlwifi: trans: prevent tx and cmds during FW error
      iwlwifi: trans: prevent reprobe on repeated FW errors before restart
      iwlwifi: trans: clear FW_ERROR status in common code
      iwlwifi: trans: turn set_pmi into an optional callback

Barak Bercovitz (1):
      cfg80211: stop sched scan only when needed

Bing Zhao (4):
      mwifiex: send regulatory domain info to firmware only if alpha2 chang=
ed
      mwifiex: remove cfg_data construction
      mwifiex: download cal-data from device-tree to firmware
      mwifiex: download per country tx power table to firmware

Chun-Yeow Yeoh (1):
      nl80211: allow the use of DFS channel in mesh

David Spinadel (1):
      mac80211: reschedule sched scan after HW restart

Eliad Peller (7):
      mac80211: remove duplicate code
      mac80211: determine completed scan type by defined ops
      mac80211: start_next_roc only if scan was actually running
      cfg80211: don't "leak" uncompleted scans
      iwlwifi: mvm: add multicast filtering support
      iwlwifi: mvm: configure phy_ctxt with min_def
      iwlwifi: mvm: check iwl_nvm_init return value

Emmanuel Grumbach (4):
      iwlwifi: mvm: don't send SMPS action frame with single RX antenna
      iwlwifi: mvm: move iwl_mvm_set_tx_power to PHY area
      iwlwifi: remove pointer to transport from op_mode
      iwlwifi: mvm: fixup Makefile

Eyal Shapira (12):
      iwlwifi: publish STBC support in HT
      iwlwifi: set VHT beamformee STS cap correctly
      iwlwifi: publish Tx STBC support in VHT
      iwlwifi: mvm: rs: move rs_program_fix_rate to cleanup ifdefs
      iwlwifi: mvm: rs: refactor building the LQ command
      iwlwifi: mvm: rs: avoid recalc of supported legacy rate mask
      iwlwifi: mvm: rs: improve rates table algo
      iwlwifi: mvm: rs: remove unnecessary debug logs
      iwlwifi: mvm: rs: refactor rate scale action decision
      iwlwifi: mvm: rs: disable MCS9 Tx workaround
      iwlwifi: mvm: set highest rate in VHT MCS Set
      iwlwifi: mvm: rs: fix RTS protection being set indefinitely

Felix Fietkau (16):
      mac80211: let the driver reserve extra tailroom in beacons
      ath9k_common: get rid of an unnecessary variable
      ath9k: add support for reporting per-chain signal strength
      ath9k_hw: use a software timer for btcoex no_stomp_timer
      ath9k_hw: clean up generic timer code
      ath9k_hw: remove defunct ad-hoc mode ATIM window handling code
      ath9k_hw: remove ah->config.pcie_clock_req
      ath9k_hw: simplify spur channel handling
      ath9k_hw: remove additional_swba_backoff
      ath9k_hw: remove spur related unused defines
      ath9k_hw: clean up station beacon timer API
      ath9k: properly preserve TSF across reset
      ath9k: move ath9k_debug_sync_cause out of ath9k_hw
      ath9k: call ath9k_set_tsfadjust from ath9k_beacon_config
      ath9k: fix TSF offset precision issue
      ath9k: simplify/fix tx packet TID handling

Hante Meuleman (4):
      brcmfmac: Move common BCDC code in single function.
      brcmfmac: Fix hex dump for FWIL.
      brcmfmac: Add definition of new protocol layer msgbuf.
      brcmfmac: Combine protocol push hdr and bus txdata.

Ilan Peer (1):
      iwlwifi: mvm: Do not allow AP MAC context update if not active

Janusz Dziedzic (4):
      nl80211: don't clear bitrate_mask twice
      nl80211: allow setting bitrate mask back to default
      cfg80211: in bitrate_mask, rename mcs to ht_mcs
      nl80211: add VHT support for set_bitrate_mask

Johannes Berg (16):
      Revert "mac80211: add driver callback for per-interface multicast fil=
ter"
      mac80211: move align variable to remove __maybe_unused
      nl80211: vendor command support
      mac80211: neaten ieee80211_deliver_skb
      mac80211: warn if unhashing station fails
      Merge remote-tracking branch 'wireless-next/master' into mac80211-next
      mac80211: add pre-RCU-sync sta removal driver operation
      iwlwifi: mvm: use pre-RCU-sync sta removal operation
      mac80211: move 4-addr sta pointer clearing before synchronize_rcu()
      mac80211: don't delay station destruction
      mac80211: move synchronize_net() before sta key removal
      mac80211: optimise synchronize_net() for sta_info_flush
      mac80211: optimise mixed AP/VLAN station removal
      mac80211: free all AP/VLAN keys at once
      iwlwifi: mvm: clarify smps_requests documentation
      iwlwifi: mvm: rs: fix variable shadowing

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Levente Kurusa (1):
      bcma: add missing put_device call

Lilach Edelstein (1):
      iwlwifi: mvm: Add Smart FIFO support

Lorenzo Bianconi (1):
      ath9k: fix 5/10MHz channel width initialization on ar9003

Luciano Coelho (4):
      mac80211: lock sdata in ieee80211_csa_connection_drop_work()
      mac80211: make ieee80211_assign_beacon() static
      mac80211: refactor ieee80211_ibss_process_chanswitch()
      mac80211: align ieee80211_ibss_csa_beacon() with ieee80211_assign_bea=
con()

Luis R. Rodriguez (3):
      cfg80211: add reg_get_dfs_region()
      cfg80211: DFS check dfs_region before usage
      wireless: update MAINTAINERS

Marek Kwaczynski (1):
      nl80211/cfg80211: Set Operating Mode Notification

Max Stepanov (3):
      mac80211: check pairwise key_idx on get_key call
      mac80211: read station mgmt keys via get_key call
      iwlwifi: mvm: add a generic cipher scheme support

Michal Nazarewicz (1):
      net: wirelesse: wcn36xx: pull allocation outside of critical section

Oleksij Rempel (1):
      ath9k_htc: reconfigure led_gpios after resume

Rashika Kheria (3):
      drivers: net: Mark functions as static in 3945-debug.c
      drivers: net: Mark functions as static in 4965-debug.c
      drivers: net: Mark functions as static in debug.c

Simon Wunderlich (1):
      mac80211: fix nested sdata lock for IBSS/CSA

Sujith Manoharan (9):
      ath9k: Cleanup spectral scan code
      ath9k: Cleanup ath9k.h
      ath9k: Remove unneeded ref. count initialization
      ath9k: Initialize "switchcomspdt" eeprom field explicitly
      ath9k: Update BaseExtension_1 eeprom structure
      ath9k: Fix regulatory compliance
      ath9k: Add a delay between RTC reset/clear for AR9003
      ath9k: Fix RTC reset delay
      ath9k: Use a subroutine for the AR9330 reset WAR

Thomas Pedersen (1):
      mac80211: update adjusting TBTT bit in beacon

 MAINTAINERS                                        |   4 +-
 drivers/bcma/main.c                                |   1 +
 drivers/net/wireless/ath/ath6kl/wmi.c              |   6 +-
 drivers/net/wireless/ath/ath9k/Makefile            |   4 +-
 drivers/net/wireless/ath/ath9k/antenna.c           |   8 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |   8 +-
 drivers/net/wireless/ath/ath9k/ar9002_mac.c        |   6 +-
 drivers/net/wireless/ath/ath9k/ar9002_phy.c        |   1 -
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |  52 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |  14 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |  18 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   4 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             | 367 +++-------
 drivers/net/wireless/ath/ath9k/beacon.c            | 137 ++--
 drivers/net/wireless/ath/ath9k/btcoex.c            |   6 -
 drivers/net/wireless/ath/ath9k/common.c            |   4 +-
 drivers/net/wireless/ath/ath9k/debug.c             | 352 ++--------
 drivers/net/wireless/ath/ath9k/debug.h             |   9 +-
 drivers/net/wireless/ath/ath9k/dfs.c               |   4 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |  26 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |  26 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |  26 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |  89 +--
 drivers/net/wireless/ath/ath9k/htc.h               |   5 +
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |  39 +-
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c      |  17 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   2 +
 drivers/net/wireless/ath/ath9k/hw-ops.h            |   5 +-
 drivers/net/wireless/ath/ath9k/hw.c                | 249 +++----
 drivers/net/wireless/ath/ath9k/hw.h                |  38 +-
 drivers/net/wireless/ath/ath9k/init.c              |   4 +-
 drivers/net/wireless/ath/ath9k/mac.c               |  27 +-
 drivers/net/wireless/ath/ath9k/mac.h               |   8 +-
 drivers/net/wireless/ath/ath9k/main.c              |  18 +-
 drivers/net/wireless/ath/ath9k/mci.c               |   2 +-
 drivers/net/wireless/ath/ath9k/recv.c              | 196 +-----
 drivers/net/wireless/ath/ath9k/spectral.c          | 543 +++++++++++++++
 drivers/net/wireless/ath/ath9k/spectral.h          | 212 ++++++
 drivers/net/wireless/ath/ath9k/xmit.c              |   9 +-
 drivers/net/wireless/ath/wcn36xx/smd.c             |  32 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |   1 -
 drivers/net/wireless/brcm80211/brcmfmac/bcdc.c     |  79 +--
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   | 628 ++++++++++++++---
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c | 552 ---------------
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   8 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c | 740 ++++++++++-------=
----
 drivers/net/wireless/brcm80211/brcmfmac/fwil.c     |  12 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c |  41 +-
 drivers/net/wireless/brcm80211/brcmfmac/proto.c    |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/proto.h    |  14 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    | 296 ++++-----
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.h    |   2 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |  82 +--
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |   1 +
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   6 -
 drivers/net/wireless/iwlwifi/dvm/main.c            |   4 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c            |   2 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |   2 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |  39 ++
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |   7 +
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |   1 +
 drivers/net/wireless/iwlwifi/iwl-fw.h              |  46 ++
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |  15 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |   4 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |  66 +-
 drivers/net/wireless/iwlwifi/mvm/Makefile          |   3 +-
 drivers/net/wireless/iwlwifi/mvm/binding.c         |  16 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     | 366 +++++++++-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |  16 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-sta.h      |  10 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h       |   1 +
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |  65 ++
 drivers/net/wireless/iwlwifi/mvm/fw.c              |  28 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        | 275 +++++---
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  45 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |  20 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           | 395 ++++++-----
 drivers/net/wireless/iwlwifi/mvm/rs.c              | 686 +++++++++--------=
--
 drivers/net/wireless/iwlwifi/mvm/rs.h              |   2 -
 drivers/net/wireless/iwlwifi/mvm/rx.c              |   6 +
 drivers/net/wireless/iwlwifi/mvm/sf.c              | 291 ++++++++
 drivers/net/wireless/iwlwifi/mvm/sta.c             |  32 +-
 drivers/net/wireless/iwlwifi/mvm/tt.c              |   2 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   3 +-
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   5 +
 drivers/net/wireless/iwlwifi/pcie/internal.h       |  33 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |  35 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  86 ++-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |  37 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  35 +-
 drivers/net/wireless/mwifiex/fw.h                  |   9 -
 drivers/net/wireless/mwifiex/main.h                |   4 +
 drivers/net/wireless/mwifiex/sta_cmd.c             |  77 ++-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |  15 +
 include/net/cfg80211.h                             | 123 +++-
 include/net/mac80211.h                             |  45 +-
 include/uapi/linux/nl80211.h                       |  65 +-
 net/mac80211/cfg.c                                 |  30 +-
 net/mac80211/driver-ops.h                          |  32 +-
 net/mac80211/ibss.c                                |  74 +--
 net/mac80211/ieee80211_i.h                         |  21 +-
 net/mac80211/iface.c                               |  49 +-
 net/mac80211/key.c                                 |  60 +-
 net/mac80211/key.h                                 |   3 +-
 net/mac80211/main.c                                |   8 +-
 net/mac80211/mesh.c                                |   5 +
 net/mac80211/mesh_sync.c                           |   9 +-
 net/mac80211/mlme.c                                |   2 +-
 net/mac80211/pm.c                                  |   3 +-
 net/mac80211/rx.c                                  |  33 +-
 net/mac80211/scan.c                                |  80 ++-
 net/mac80211/sta_info.c                            | 118 ++--
 net/mac80211/sta_info.h                            |  30 +-
 net/mac80211/trace.h                               |  58 +-
 net/mac80211/tx.c                                  |  12 +-
 net/mac80211/util.c                                |  34 +
 net/wireless/core.c                                |  25 +-
 net/wireless/core.h                                |   6 +-
 net/wireless/mesh.c                                |  13 +-
 net/wireless/nl80211.c                             | 380 ++++++++---
 net/wireless/reg.c                                 |  27 +
 net/wireless/reg.h                                 |   1 +
 net/wireless/scan.c                                |  16 +-
 123 files changed, 5206 insertions(+), 3982 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/spectral.c
 create mode 100644 drivers/net/wireless/ath/ath9k/spectral.h
 delete mode 100644 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
 create mode 100644 drivers/net/wireless/iwlwifi/mvm/sf.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--zYM0uCDKw75PZbzx
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJSxILoAAoJEJctW/TcYTgGXq8P/0t/K3aZ9ZAE0nHF8lZsdUP7
6+106fzq5x4thDB7tArA80VbC+VtIYioCQ/w3P+QsWOkutcV7SE4RlRPWOPd+oRR
ar+IIO9V4dOpOFXhZXk00unuMERr0loVVi7n2iSM7L0veE4r8P4+6wDGtMsORo0/
eEMAy53RhLiIqNyXBoNqICyBmAmzxezGCoJEUGFH0BoDGIGdqe6dCBZXuMZHAw7F
/BqTgdMUhcR/vDlWlowie1L6tRvm2Y00jPvuYgHC2NxT7MkK0W32aSI/xolPmEgX
snM4I1++I69UOhbmUptn57Mv+vZGQaFniy7GBCeIbybgAotc1HbRJgjlraL4j9Ej
THJFLCmpZcKA4JaB3rd0dhhRJPmfRxp3zKvSF8rYoEfKmK9KEwBmA1iju7bBKgxU
0lpFOmU9X8JWDuPji+WOOVPthnQtiRGTTVKi2ChO5sreQQSo9Om8hZMcKaDWgag9
xpoF61jcNZ827br/CY3NWnmt9qrBTEfFeFSd1bgDgmO5TLwgI9CtdnjL4BFWE8XD
HF1DQns3FBhNxvUTaVyxJ1UrDYB7z7CRpsgDuhSk/+/2neg/QYKhnVaw787LEDIb
ZVJv+Zaa3w5fa9k8PTWs9xboMlAV/K2m/REe0Muocrfs4Y3UXijoKrrOB/tCZetV
yQmPiDhQ6gi7TC+8+sAD
=ZUTo
-----END PGP SIGNATURE-----

--zYM0uCDKw75PZbzx--
