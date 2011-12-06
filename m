From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2011-12-06
Date: Tue, 6 Dec 2011 11:02:34 -0500
Message-ID: <20111206160234.GB30288@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OXfL5xGRrasGEqWY"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50013 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255Ab1LFQPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 11:15:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit d39aeaf260e7d1ec6a677beed230a0406d0069a6

Dave,

This round of updates is intended for 3.3.  Highlights include ath5k
updates, ath9k updates, brcm80211 updates (particularly for brcmfmac),
some NFC logging cleanups, some mesh updates, and the "NoAck per tid"
work from Simon Wunderlich.  Also included is a pull of the wireless
tree to resolve a merge conflict.

Please let me know if there are problems!

John

---

The following changes since commit 40e4783ee62ac656a9a0fa3b512b6aee4f07d2d1:

  ipv4: arp: Cleanup in arp.c (2011-12-06 00:34:40 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

Alwin Beukers (2):
      brcm80211: smac: fix channel frequency
      brcm80211: smac: added support for mac80211 filter flags

Arend van Spriel (7):
      brcm80211: fmac: cleanup receive path using proper skb_queue functions
      brcm80211: smac: remove skb next pointer usage from the driver
      brcm80211: fmac: separate receiving skb chain from other receive path
      brcm80211: fmac: remove width parameter from brcmf_sdioh_request_buff=
er
      brcm80211: fmac: simplify the brcmf_sdioh_request_buffer() function
      brcm80211: fmac: remove alignment check from brcmf_sdioh_request_buff=
er()
      brcm80211: fmac: rename wait queue name to match using function

Arik Nemtsov (2):
      mac80211: dereference RCU protected probe_resp pointer correctly
      mac80211: don't indicate probe resp change in IBSS mode

Axel Lin (2):
      net: rfkill: convert net/rfkill/* to use module_platform_driver()
      NFC: pn533: Staticise pn533_data_exchange()

Ben Greear (1):
      mac80211: Make __check_htcap_disable static.

Chun-Yeow Yeoh (1):
      {nl,cfg,mac}80211: Allow Setting Multicast Rate in Mesh

Dan Carpenter (1):
      brcm80211: fmac: small memory leak on error

Eliad Peller (1):
      mac80211: call skb_put() before copying the data (trivial)

Emmanuel Grumbach (1):
      iwlwifi: help to debug AGG SM inconsistencies

Felix Fietkau (1):
      mac80211: do not pass AP VLAN vif pointers to drivers

Franky Lin (15):
      brcm80211: fmac: change firmware/nvram name to be more generic
      brcm80211: fmac: discard packet received when net device not register=
ed
      brcm80211: fmac: move module init/exit to sdio layer
      brcm80211: fmac: remove function brcmf_c_init
      brcm80211: fmac: remove unused parameter of brcmf_sdbrcm_probe
      brcm80211: fmac: rename structure brcmf_bus to brcmf_sdio
      brcm80211: fmac: introduce common bus interface struct brcmf_bus
      brcm80211: fmac: move busstate to struct brcmf_bus
      brcm80211: fmac: stop using brcmf_pub in brcmf_sdbrcm_bus_watchdog
      brcm80211: fmac: change function bus_rxctl parameter
      brcm80211: fmac: change function bus_txctl parameter
      brcm80211: fmac: change function bus_txdata parameter
      brcm80211: fmac: change function bus_init parameter
      brcm80211: fmac: remove function brcmf_bus_get_device
      brcm80211: fmac: change function bus_stop parameter

Helmut Schaa (1):
      rt2x00: Pass BlockAck and BlackAckReq frames to mac80211 in monitor m=
ode

Hsu, Kenny (1):
      iwlwifi: add tm commands for indirect register access

Joe Perches (4):
      nfc: Use standard logging styles
      nfc: Convert nfc_dbg to pr_debug
      nfc: Remove unused nfc_printk and nfc_<level> macros
      nfc: Remove function tracer like entry messages

Johannes Berg (7):
      mac80211: fix TX warning
      mac80211: remove tracing config symbol
      iwlagn: remove calibration knowledge
      iwlagn: dynamically allocate & reflect calibration data
      iwlagn: allow up to uCode API 6 for 6000 devices
      mac80211: revert on-channel work optimisations
      iwlagn: fix HW crypto for TX-only keys

John W. Linville (3):
      Revert "mac80211: clear sta.drv_priv on reconfiguration"
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Larry Finger (1):
      rtlwifi: Fix incorrect return of IRQ_HANDLED

Lars-Peter Clausen (1):
      wireless: Remove redundant spi driver bus initialization

Luis R. Rodriguez (7):
      cfg80211: fix race on init and driver registration
      cfg80211: amend regulatory NULL dereference fix
      cfg80211: clarify set tx power mBm documentation
      brcm80211: fix usage of set tx power
      brcm80211: avoid code duplication on set tx power
      mwifiex: fix usage of set tx power
      prism54: remove private driver ioctls

Mohammed Shafi Shajakhan (24):
      ath9k_hw: cosmetic change in calibration debug log
      mac80211: remove unused function declaration
      ath9k: Fix LED GPIO pin for AR9462
      ath9k: change the default antenna settings based on diversity
      ath9k_hw: add definitions to support MCI h/w code
      ath9k_hw: add GPIO output MUX related macros
      ath9k_hw: Add MCI h/w specific structure
      ath9k_hw: initialize MCI parameters
      ath9k_hw: Add MCI h/w code and state machine
      ath9k: Add MCI interrupt to interrupt mask
      ath9k_hw: take care of enabling MCI interrupts
      ath9k_hw: check for asynchronous MCI interrupt pending
      ath9k_hw: check for MCI interrupt in get_isr
      ath9k: add MCI specific definitions and structures
      ath9k: Add functions to allocate/free buffers for MCI
      ath9k_hw: MCI related changes in chip management
      ath9k_hw: MCI related changes in set_reset_reg
      ath9k_hw: Add support for MCI WLAN calibration
      ath9k_hw: Add MCI related changes in chip reset
      ath9k: MCI state machine based on MCI interrupt
      ath9k: fix a typo
      ath9k: minor cleanup
      ath9k_hw: Fix TX IQ calibration for AR9003
      ath9k_hw: add default chainmask for AR9462

Nick Kossifidis (12):
      ath5k: Switch from read-and-clear to write-to-clear method when handl=
ing PISR/SISR registers
      ath5k: Add TXNOFRM to INT_TX_ALL
      ath5k: Cleanups v1
      ath5k: Calibration re-work
      ath5k: Use usleep_range where possible
      ath5k: Cleanups v2 + add kerneldoc on all hw functions
      ath5k: We always do full calibration on AR5210
      ath5k: Add a module parameter to disable hw rf kill switch
      ath5k: MRR support and 2GHz radio override belong in ah_capabilities
      ath5k: ath5k_ani_period_restart only touches struct ath5k_ani_state
      ath5k: Renumber hw queue ids
      ath5k: Optimize ath5k_cw_validate

Nikolay Martynov (4):
      ath9k: improve ath_tx_aggr_stop to avoid TID stuck in cleanup state
      mac80211: timeout tx agg sessions in way similar to rx agg sessions
      mac80211: trivial: use WLAN_BACK_RECIPIENT instead of hardcoded 0
      mac80211: log reason and initiator when rx agg is stopped

Rajkumar Manoharan (1):
      ath9k_hw: Fix minimum CTL power for each runtime mode

Simon Wunderlich (5):
      mac80211: remove debugfs noack test
      wireless: Add NoAck per tid support
      mac80211: Add NoAck per tid support
      mac80211: fix duration calculation for QoS NOACK frames
      mac80211: fill rate filter for internal scan requests

Thomas Pedersen (6):
      mac80211: failed forwarded mesh frame addressing
      mac80211: fix switched HWMP frame addresses
      mac80211: fix forwarded mesh frame queue mapping
      {nl,cfg,mac}80211: implement dot11MeshHWMPperrMinInterval
      mac80211: don't initiate path discovery when forwarding frame with un=
known DA
      mac80211: clean up rx_h_mesh_fwding

Veli-Pekka Peltola (1):
      hostap_cs: add ID for Canon K30225

Wey-Yi Guy (4):
      iwlwifi: show command string for REPLY_D3_CONFIG
      iwlwifi: show the configuration option
      iwlwifi: do not re-configure HT40 after associated
      iwlwifi: change the default behavior of watchdog timer

 drivers/net/wireless/ath/ath5k/ahb.c               |    4 +-
 drivers/net/wireless/ath/ath5k/ani.c               |   91 +-
 drivers/net/wireless/ath/ath5k/ani.h               |   32 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |  569 ++++++---
 drivers/net/wireless/ath/ath5k/attach.c            |   16 +-
 drivers/net/wireless/ath/ath5k/base.c              |  287 +++--
 drivers/net/wireless/ath/ath5k/caps.c              |   27 +-
 drivers/net/wireless/ath/ath5k/desc.c              |  217 +++-
 drivers/net/wireless/ath/ath5k/desc.h              |  124 ++-
 drivers/net/wireless/ath/ath5k/dma.c               |  370 +++--
 drivers/net/wireless/ath/ath5k/gpio.c              |   81 +-
 drivers/net/wireless/ath/ath5k/initvals.c          |   75 +-
 drivers/net/wireless/ath/ath5k/pci.c               |    2 +-
 drivers/net/wireless/ath/ath5k/pcu.c               |  222 ++-
 drivers/net/wireless/ath/ath5k/phy.c               |  853 +++++++++---
 drivers/net/wireless/ath/ath5k/qcu.c               |  143 ++-
 drivers/net/wireless/ath/ath5k/reg.h               |   27 +-
 drivers/net/wireless/ath/ath5k/reset.c             |  230 +++-
 drivers/net/wireless/ath/ath5k/rfbuffer.h          |   59 +-
 drivers/net/wireless/ath/ath5k/rfgain.h            |   22 +-
 drivers/net/wireless/ath/ath9k/Makefile            |    3 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   45 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    3 +-
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   36 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        | 1464 ++++++++++++++++=
++++
 drivers/net/wireless/ath/ath9k/ar9003_mci.h        |  102 ++
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |    3 +
 drivers/net/wireless/ath/ath9k/ath9k.h             |    3 +-
 drivers/net/wireless/ath/ath9k/btcoex.c            |    2 +-
 drivers/net/wireless/ath/ath9k/btcoex.h            |   31 +
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |    6 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |    3 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |    6 +-
 drivers/net/wireless/ath/ath9k/hw.c                |  178 +++-
 drivers/net/wireless/ath/ath9k/hw.h                |  182 +++
 drivers/net/wireless/ath/ath9k/init.c              |   33 +
 drivers/net/wireless/ath/ath9k/mac.c               |   17 +-
 drivers/net/wireless/ath/ath9k/main.c              |    9 +-
 drivers/net/wireless/ath/ath9k/mci.c               |  419 ++++++
 drivers/net/wireless/ath/ath9k/mci.h               |   20 +
 drivers/net/wireless/ath/ath9k/recv.c              |   24 +-
 drivers/net/wireless/ath/ath9k/reg.h               |  306 ++++-
 drivers/net/wireless/ath/ath9k/xmit.c              |   13 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmchip.h  |   25 -
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |  148 ++-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |  211 ++--
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |   31 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   19 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |    6 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |   15 -
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |   85 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  320 ++---
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |   30 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |    9 +-
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |   62 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   38 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |   47 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.h     |    6 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c  |    2 +-
 drivers/net/wireless/hostap/hostap_cs.c            |    3 +
 drivers/net/wireless/iwlwifi/iwl-1000.c            |   10 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   14 -
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   17 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   22 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |   66 +-
 drivers/net/wireless/iwlwifi/iwl-agn-calib.h       |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |   36 +-
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |    5 -
 drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |   48 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   39 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |    2 +
 drivers/net/wireless/iwlwifi/iwl-core.c            |   22 +-
 drivers/net/wireless/iwlwifi/iwl-core.h            |    7 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   24 +-
 drivers/net/wireless/iwlwifi/iwl-shared.h          |    6 +-
 drivers/net/wireless/iwlwifi/iwl-sv-open.c         |   40 +-
 drivers/net/wireless/iwlwifi/iwl-testmode.h        |   20 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |   12 +-
 drivers/net/wireless/libertas/if_spi.c             |    1 -
 drivers/net/wireless/mwifiex/cfg80211.c            |    3 +-
 drivers/net/wireless/p54/p54spi.c                  |    1 -
 drivers/net/wireless/prism54/isl_ioctl.c           |  333 -----
 drivers/net/wireless/prism54/isl_ioctl.h           |    2 -
 drivers/net/wireless/prism54/islpci_dev.c          |    1 -
 drivers/net/wireless/rt2x00/rt2800lib.c            |    6 +-
 drivers/net/wireless/rtlwifi/pci.c                 |    7 +-
 drivers/net/wireless/wl1251/spi.c                  |    1 -
 drivers/net/wireless/wl12xx/spi.c                  |    1 -
 drivers/nfc/pn533.c                                |    2 +-
 include/linux/nl80211.h                            |   15 +
 include/net/cfg80211.h                             |   12 +-
 net/mac80211/Kconfig                               |   12 -
 net/mac80211/Makefile                              |    4 +-
 net/mac80211/agg-rx.c                              |   11 +-
 net/mac80211/agg-tx.c                              |   39 +-
 net/mac80211/cfg.c                                 |   22 +-
 net/mac80211/debugfs.c                             |   35 -
 net/mac80211/debugfs_netdev.c                      |    3 +
 net/mac80211/driver-ops.h                          |   14 +
 net/mac80211/driver-trace.h                        |   11 -
 net/mac80211/ht.c                                  |    6 +-
 net/mac80211/ieee80211_i.h                         |   10 +-
 net/mac80211/iface.c                               |   17 +-
 net/mac80211/main.c                                |   47 +-
 net/mac80211/mesh.c                                |    1 +
 net/mac80211/mesh.h                                |    2 +
 net/mac80211/mesh_hwmp.c                           |  146 ++-
 net/mac80211/mesh_pathtbl.c                        |   29 +-
 net/mac80211/offchannel.c                          |    9 +-
 net/mac80211/rx.c                                  |  105 +-
 net/mac80211/scan.c                                |    4 +-
 net/mac80211/sta_info.c                            |    4 -
 net/mac80211/sta_info.h                            |    3 +-
 net/mac80211/tx.c                                  |   44 +-
 net/mac80211/util.c                                |    8 +-
 net/mac80211/wme.c                                 |   32 +-
 net/mac80211/wme.h                                 |    3 +
 net/mac80211/work.c                                |   99 +--
 net/nfc/core.c                                     |   60 +-
 net/nfc/nci/core.c                                 |   84 +-
 net/nfc/nci/data.c                                 |   30 +-
 net/nfc/nci/ntf.c                                  |   83 +-
 net/nfc/nci/rsp.c                                  |   84 +-
 net/nfc/netlink.c                                  |   32 +-
 net/nfc/nfc.h                                      |    7 -
 net/nfc/rawsock.c                                  |   28 +-
 net/rfkill/rfkill-gpio.c                           |   13 +-
 net/rfkill/rfkill-regulator.c                      |   12 +-
 net/wireless/mesh.c                                |    2 +
 net/wireless/nl80211.c                             |   39 +
 net/wireless/reg.c                                 |   49 +-
 132 files changed, 6634 insertions(+), 2804 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_mci.c
 create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_mci.h
 delete mode 100644 drivers/net/wireless/brcm80211/brcmfmac/bcmchip.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--OXfL5xGRrasGEqWY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJO3jyZAAoJEJctW/TcYTgGHyYP/jG3Oc24J9lEM8c6Eesa2REm
kkJhl+Eq3nnuUInWeo+NPbDCE77EDbvqz3fuNESr9V7wPSPe89few2cCtbtHRoc3
lMC/KSpC2SOnAXsGzCUlgcgQNxLIydz0y3FZ6La9RU7jqBQM+CCCaHcon8D1zotS
eSFapA20QBuhRMw93hHN/KJydZsl+BAzQhlQN634Y9UX3pTDbPuV1aXks2J1p023
TPl0AMZy0p3R8WSq7uy2hva7f3dZxvdZvP2lTima1naMW9oMv1ot+INDQct4cF0j
8k9a5nZthtb5+LrMJDpdzg8fseqoe17p66uEXrC1QDjhyVnzjd08RlTlva2z5s7+
LUlhucxB0StV9VTY71jENdtw4bjthlIrrZBouWGuxJB1zWubo8V5v2XT1umuVPcn
OfKDST6WMP4RxQLBvD8ojWBsHQGhTtasnIA1AjH2bfdEkgmqh+ipEVkYVSLKhI00
yLF6hCIvVLkaaYk4nosH5DV1xQRRs2e5JcxlPu0MwTyaSMGIKm0pB2DCHU4gzcD/
gOIjfwDHC1nHL8crvGAnXj9MIE9Ei32sSKkzxgFFAtaW+tswg5IMWQq0qceMF5lc
FPMY+k63aDqLoEvipOHZwuwuLeTXCjJGXU6a/GYOIO2HXgo2j/QIuok7YH9NPNoY
tZSZogwWpaJtMuNko44F
=SlAK
-----END PGP SIGNATURE-----

--OXfL5xGRrasGEqWY--
