From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-next 2011-10-17
Date: Mon, 17 Oct 2011 16:23:33 -0400
Message-ID: <20111017202332.GE8948@tuxdriver.com>
References: <20111017191945.GD8948@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="C7zPtVaVf+AK4Oqc"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111017191945.GD8948-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I neglected to identify the HEAD and sign...

commit 41ebe9cde738a972d05c7282e09f5ed54cff0e8d

Thanks,

John

On Mon, Oct 17, 2011 at 03:19:46PM -0400, John W. Linville wrote:
> Dave,
>=20
> Here is one more (last?) wireless pull request intended for 3.2.
>=20
> The most notable bits of this request are the long awaited brcm80211
> drivers.  Along with those come the usual strong showings from the
> iwlwifi and ath9k teams and some mac80211 updates from Johannes
> and others.  There are also updates for mwifiex, rtlwifi, wl12xx,
> and b43, as well as a few other random bits.
>=20
> Please let me know if there are problems!
>=20
> Thanks,
>=20
> JOhn
>=20
> ---
>=20
> The following changes since commit fd38f734cb8200529e281338514945fcbff236=
4b:
>=20
>   igbvf: convert to ndo_fix_features (2011-10-16 13:18:47 -0700)
>=20
> are available in the git repository at:
>   git://git.infradead.org/users/linville/wireless-next.git for-davem
>=20
> Alwin Beukers (9):
>       brcm80211: cleanup function prototypes
>       brcm80211: removed unused functions
>       brcm80211: moved power conversion functions
>       brcm80211: moved function brcmu_chipname
>       brcm80211: moved function brcmu_parse_tlvs
>       brcm80211: moved function brcmu_chspec_malformed
>       brcm80211: moved function brcmu_mkiovar
>       brcm80211: moved function brcmu_format_flags
>       brcm80211: removed file wifi.c
>=20
> Amitkumar Karwar (3):
>       mwifiex: add support for Marvell pcie8766 chipset
>       mwifiex: use separate wait condition for each command node
>       mwifiex: fix make namespacecheck warnings
>=20
> Arend van Spriel (11):
>       net: wireless: add brcm80211 drivers
>       brcm80211: remove sparse warning in fullmac debug function
>       brcm80211: fix sparse endianess error in mac80211_if.c
>       brcm80211: add endian annotation to packet filter structures
>       brcm80211: rename variable in _brcmf_set_multicast_list()
>       brcm80211: fix annotations in TOE configuration functions
>       brcm80211: use endian annotations in scan related function
>       brcm80211: use endian annotation for pmk related structure
>       brcm80211: use endian annotations for assoc ie length request
>       brcm80211: use endian annotation for roaming related parameters
>       brcm80211: use endian annotation for scan time configuration
>=20
> Chaoming Li (4):
>       rtlwifi: Update to new Realtek version - Part I
>       rtlwifi: rtl8192ce: Add new chip revisions
>       rtlwifi: rtl8192se: Updates from latest Realtek driver version - Pa=
rt II
>       rtlwifi: rtl8192de: Updates from latest Reaktek driver - Part III
>=20
> Dan Carpenter (3):
>       ath5k: remove some unneeded error handling code
>       ath9k: remove some bogus error handling code
>       iwmc3200wifi: add a range check to iwm_cfg80211_get_key()
>=20
> Daniel Drake (1):
>       libertas: fix changing interface type when interface is down
>=20
> Don Fry (1):
>       iwlagn: eliminate bus pointer from iwl_priv structure
>=20
> Eliad Peller (2):
>       wl12xx: configure rate policy for p2p operations
>       wl12xx: disable AP-mode-specific quirks
>=20
> Emmanuel Grumbach (7):
>       iwlagn: kill hw_params.max_stations
>       iwlagn: fix a race in the unmapping of the TFDs
>       iwlagn: warn only once if AGG state is wrong
>       iwlagn: move iwl_beacon_time_mask_XXX near to usage
>       iwlagn: move iwl_enable_rfkill_int and kill iwl-helpers.h
>       iwlagn: remove uneeded include to iwl-dev.h
>       iwlagn: add missing include to iwl-agn-rs.h
>=20
> Felix Fietkau (11):
>       ath9k: indicate which queues are blocked when stopping tx fails
>       ath9k: keep track of what's triggering hardware resets
>       ath9k: improve PS filter clearing and retry counting for A-MPDU
>       ath9k: fix retry counting / BAR handling during queue flush
>       ath9k: disable unnecessary PHY error reporting
>       ath9k_hw: make ath9k_hw_set_interrupts use ah->imask by default
>       ath9k_hw: clean up tx power handling
>       ath: remove ath_regulatory::current_rd_ext
>       ath9k_hw: remove EEP_REG_1
>       ath9k_hw: fix a regression in key miss handling
>       ath9k: only send FCS-fail packets to mac80211 if requested
>=20
> Helmut Schaa (5):
>       mac80211: Update injection documentation
>       mac80211: Build TX radiotap header dynamically
>       mac80211: Populate radiotap header with MCS info for TX frames
>       nl80211: Add sta_flags to the station info
>       mac80211: Provide station flags to cfg80211
>=20
> Javier Cardona (1):
>       mac80211: Fix regression that allowed mpaths between non-peers.
>=20
> Johannes Berg (16):
>       mac80211: pass no-CCK flag through to HW scan
>       mac80211: fix offchannel TX cookie matching
>       mac80211: optimise monitor xmit
>       mac80211: remove tx_data ethertype
>       mac80211: move fragment flag to info flag as dont-fragment
>       mac80211: parse radiotap header earlier
>       mac80211: dont adjust truesize
>       mac80211: dont orphan TX skb
>       iwlagn: update beacon smarter
>       iwlagn: don't assign seqno to QoS Null frames
>       iwlagn: send simple LQ command for WoWLAN
>       iwlagn: stop interrupts when suspending
>       iwlagn: remove 5000 hw header
>       iwlagn: remove 6000 hw header
>       mac80211: reformat TX unauthorised check
>       mac80211: fix TID for null poll response
>=20
> John W. Linville (2):
>       Merge branch 'for-linville' of git://github.com/lucacoelho/wl12xx
>       Merge branch 'master' of git://git.infradead.org/users/linville/wir=
eless-next into for-davem
>=20
> Larry Finger (2):
>       rtlwifi: Change debug parameter to apply to individual drivers
>       rtlwifi: Change PCI drivers to use the new PM framework
>=20
> Luciano Coelho (1):
>       wl12xx: set max_sched_scan_ie_len correctly
>=20
> Rafa=C5=82 Mi=C5=82ecki (3):
>       b43: trivial: do not report any link quality instead of invalid one
>       Revert "b43: trivial: do not report any link quality instead of inv=
alid one"
>       b43: N-PHY: report signal to mac80211
>=20
> Rajkumar Manoharan (14):
>       ath9k_hw: Fix ASPM L1 issue for AR9480
>       ath9k_hw: Updated ar9003 initval table for AR9380
>       ath9k_hw: Update AR9003 initval to improve phase noise
>       ath9k_hw: Updated AR9003 tx gain table for 5GHz
>       ath9k_hw: Improve fast channel change for AR9003 chips
>       ath9k_hw: Add support to reuse TxIQ cal measurements
>       ath9k_hw: Add support to reuse Carrier leak calibration
>       ath9k_hw: Cleanup Tx calibrations for AR9003 chips
>       ath9k_hw: Support fast channel change on 5GHz for AR9003 chips
>       ath9k_hw: Update normal/min noise floor value for AR9480
>       ath9k_hw: Add radio retention support for AR9480
>       ath9k_hw: Do fast channel change based on reusable calibration resu=
lts
>       ath9k_hw: Rename AR9480 -> AR9462 initvals
>       ath9k: Rename AR9480 into AR9462
>=20
> Roland Vossen (3):
>       brcm80211: smac: removed redundant timer function parameters
>       brcm80211: smac: decreased timer callback irq level
>       brcm80211: fmac: fixed weird indentation
>=20
> Shahar Levi (1):
>       wl12xx: Add support for HW channel switch
>=20
> Stanislaw Gruszka (1):
>       iwlagn: fix priv->cfg->ht_params NULL pointer dereference
>=20
> Stephen Rothwell (2):
>       net: wireless: brcm80211: replace ndo_set_multicast_list  with ndo_=
set_rx_mode
>       net: wireless: brcm80210: include module.h
>=20
> Wey-Yi Guy (20):
>       iwlagn: separate init calib and rt calib
>       iwlagn: add cmd queue pointer info when timeout
>       iwlagn: add REPLY_ECHO host command
>       iwlagn: add WARN if tx cmd complete come back late
>       iwlagn: add "echo" test when command queue stuck
>       iwlagn: check rf kill in queue stuck
>       iwlagn: add "echo test" command to debugfs
>       iwlagn: remove un-necessary step
>       iwlagn: set rts retry limit
>       iwlagn: add "_d" sku to 6005 series of devices
>       iwlagn: Add "_d" sku to 105 series of devices
>       iwlagn: do nothing when disable agg in wrong state
>       iwlagn: use low retry limit for WoWLAN
>       iwlwifi: update comments on how to enable debug flag
>       iwlagn: more info on warning for shutdown agg queue
>       iwlagn: don't stop rts/cts until last aggregation queue close
>       iwlagn: add debug for mac80211 callback
>       iwlagn: rename all the mac80211 callback functions
>       iwlagn: merge station management functions
>       iwlagn: rename iwl-rx.c to iwl-agn-rx.c
>=20
> Yogesh Ashok Powar (1):
>       mwifiex: fix smatch errors
>=20
>  Documentation/networking/mac80211-injection.txt    |    4 +
>  drivers/net/wireless/Kconfig                       |    1 +
>  drivers/net/wireless/Makefile                      |    3 +
>  drivers/net/wireless/ath/ath.h                     |    2 -
>  drivers/net/wireless/ath/ath5k/base.c              |    6 -
>  drivers/net/wireless/ath/ath9k/Makefile            |    1 +
>  drivers/net/wireless/ath/ath9k/ani.c               |    5 -
>  drivers/net/wireless/ath/ath9k/ar5008_phy.c        |   11 +-
>  .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |  172 +-
>  drivers/net/wireless/ath/ath9k/ar9003_calib.c      |  250 +-
>  drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   59 +-
>  drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  186 +-
>  drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    4 +-
>  drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |   15 +-
>  drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   97 +-
>  drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   52 +-
>  drivers/net/wireless/ath/ath9k/ar9003_rtt.c        |  153 +
>  drivers/net/wireless/ath/ath9k/ar9003_rtt.h        |   28 +
>  ...ar9480_1p0_initvals.h =3D> ar9462_1p0_initvals.h} |   62 +-
>  ...ar9480_2p0_initvals.h =3D> ar9462_2p0_initvals.h} |   68 +-
>  drivers/net/wireless/ath/ath9k/ath9k.h             |    2 +-
>  drivers/net/wireless/ath/ath9k/beacon.c            |   10 +-
>  drivers/net/wireless/ath/ath9k/common.c            |    6 +-
>  drivers/net/wireless/ath/ath9k/debug.c             |   19 +-
>  drivers/net/wireless/ath/ath9k/debug.h             |   13 +
>  drivers/net/wireless/ath/ath9k/eeprom.h            |   10 +-
>  drivers/net/wireless/ath/ath9k/eeprom_4k.c         |   29 +-
>  drivers/net/wireless/ath/ath9k/eeprom_9287.c       |   35 +-
>  drivers/net/wireless/ath/ath9k/eeprom_def.c        |   45 +-
>  drivers/net/wireless/ath/ath9k/gpio.c              |    8 +-
>  drivers/net/wireless/ath/ath9k/hw-ops.h            |    7 +
>  drivers/net/wireless/ath/ath9k/hw.c                |  158 +-
>  drivers/net/wireless/ath/ath9k/hw.h                |   39 +-
>  drivers/net/wireless/ath/ath9k/init.c              |    2 -
>  drivers/net/wireless/ath/ath9k/mac.c               |   10 +-
>  drivers/net/wireless/ath/ath9k/mac.h               |    6 +-
>  drivers/net/wireless/ath/ath9k/main.c              |   25 +-
>  drivers/net/wireless/ath/ath9k/pci.c               |    2 +-
>  drivers/net/wireless/ath/ath9k/recv.c              |   35 +-
>  drivers/net/wireless/ath/ath9k/reg.h               |   29 +-
>  drivers/net/wireless/ath/ath9k/xmit.c              |   40 +-
>  drivers/net/wireless/ath/carl9170/main.c           |    1 -
>  drivers/net/wireless/b43/xmit.c                    |   18 +-
>  drivers/net/wireless/b43/xmit.h                    |   10 +-
>  drivers/net/wireless/brcm80211/Kconfig             |   35 +
>  drivers/net/wireless/brcm80211/Makefile            |   23 +
>  drivers/net/wireless/brcm80211/brcmfmac/Makefile   |   33 +
>  drivers/net/wireless/brcm80211/brcmfmac/bcmchip.h  |   32 +
>  drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |  371 +
>  .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |  626 +
>  drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |  776 +
>  drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   57 +
>  drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |  498 +
>  .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |  895 +
>  drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |   58 +
>  .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    | 1356 +
>  .../net/wireless/brcm80211/brcmfmac/dhd_proto.h    |   60 +
>  drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c | 4591 ++++
>  .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |  252 +
>  .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  | 3868 +++
>  .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |  375 +
>  drivers/net/wireless/brcm80211/brcmsmac/Makefile   |   51 +
>  drivers/net/wireless/brcm80211/brcmsmac/aiutils.c  | 2079 ++
>  drivers/net/wireless/brcm80211/brcmsmac/aiutils.h  |  378 +
>  drivers/net/wireless/brcm80211/brcmsmac/ampdu.c    | 1241 +
>  drivers/net/wireless/brcm80211/brcmsmac/ampdu.h    |   30 +
>  drivers/net/wireless/brcm80211/brcmsmac/antsel.c   |  307 +
>  drivers/net/wireless/brcm80211/brcmsmac/antsel.h   |   29 +
>  .../brcm80211/brcmsmac/brcms_trace_events.c        |   23 +
>  .../brcm80211/brcmsmac/brcms_trace_events.h        |   92 +
>  drivers/net/wireless/brcm80211/brcmsmac/channel.c  | 1591 ++
>  drivers/net/wireless/brcm80211/brcmsmac/channel.h  |   53 +
>  drivers/net/wireless/brcm80211/brcmsmac/d11.h      | 1898 ++
>  drivers/net/wireless/brcm80211/brcmsmac/dma.c      | 1425 +
>  drivers/net/wireless/brcm80211/brcmsmac/dma.h      |  120 +
>  .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  | 1696 ++
>  .../net/wireless/brcm80211/brcmsmac/mac80211_if.h  |  108 +
>  drivers/net/wireless/brcm80211/brcmsmac/main.c     | 8775 ++++++
>  drivers/net/wireless/brcm80211/brcmsmac/main.h     |  735 +
>  drivers/net/wireless/brcm80211/brcmsmac/nicpci.c   |  835 +
>  drivers/net/wireless/brcm80211/brcmsmac/nicpci.h   |   82 +
>  drivers/net/wireless/brcm80211/brcmsmac/otp.c      |  426 +
>  drivers/net/wireless/brcm80211/brcmsmac/otp.h      |   36 +
>  .../net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c  | 2988 ++
>  .../net/wireless/brcm80211/brcmsmac/phy/phy_hal.h  |  301 +
>  .../net/wireless/brcm80211/brcmsmac/phy/phy_int.h  | 1169 +
>  .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c  | 5154 ++++
>  .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.h  |  121 +
>  .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |28876 ++++++++++++++=
++++++
>  .../wireless/brcm80211/brcmsmac/phy/phy_qmath.c    |  308 +
>  .../wireless/brcm80211/brcmsmac/phy/phy_qmath.h    |   42 +
>  .../wireless/brcm80211/brcmsmac/phy/phy_radio.h    | 1533 ++
>  .../net/wireless/brcm80211/brcmsmac/phy/phyreg_n.h |  167 +
>  .../wireless/brcm80211/brcmsmac/phy/phytbl_lcn.c   | 3250 +++
>  .../wireless/brcm80211/brcmsmac/phy/phytbl_lcn.h   |   54 +
>  .../net/wireless/brcm80211/brcmsmac/phy/phytbl_n.c |10630 +++++++
>  .../net/wireless/brcm80211/brcmsmac/phy/phytbl_n.h |   50 +
>  drivers/net/wireless/brcm80211/brcmsmac/phy_shim.c |  225 +
>  drivers/net/wireless/brcm80211/brcmsmac/phy_shim.h |  182 +
>  drivers/net/wireless/brcm80211/brcmsmac/pmu.c      |  458 +
>  drivers/net/wireless/brcm80211/brcmsmac/pmu.h      |   38 +
>  drivers/net/wireless/brcm80211/brcmsmac/pub.h      |  634 +
>  drivers/net/wireless/brcm80211/brcmsmac/rate.c     |  514 +
>  drivers/net/wireless/brcm80211/brcmsmac/rate.h     |  250 +
>  drivers/net/wireless/brcm80211/brcmsmac/scb.h      |   82 +
>  drivers/net/wireless/brcm80211/brcmsmac/srom.c     | 1298 +
>  drivers/net/wireless/brcm80211/brcmsmac/srom.h     |   34 +
>  drivers/net/wireless/brcm80211/brcmsmac/stf.c      |  436 +
>  drivers/net/wireless/brcm80211/brcmsmac/stf.h      |   42 +
>  drivers/net/wireless/brcm80211/brcmsmac/types.h    |  352 +
>  .../net/wireless/brcm80211/brcmsmac/ucode_loader.c |  109 +
>  .../net/wireless/brcm80211/brcmsmac/ucode_loader.h |   58 +
>  drivers/net/wireless/brcm80211/brcmutil/Makefile   |   28 +
>  drivers/net/wireless/brcm80211/brcmutil/utils.c    |  386 +
>  .../net/wireless/brcm80211/include/brcm_hw_ids.h   |   59 +
>  .../net/wireless/brcm80211/include/brcmu_utils.h   |  195 +
>  .../net/wireless/brcm80211/include/brcmu_wifi.h    |  239 +
>  .../net/wireless/brcm80211/include/chipcommon.h    |  284 +
>  drivers/net/wireless/brcm80211/include/defs.h      |  104 +
>  drivers/net/wireless/brcm80211/include/soc.h       |   90 +
>  drivers/net/wireless/iwlwifi/Kconfig               |    4 +-
>  drivers/net/wireless/iwlwifi/Makefile              |    3 +-
>  drivers/net/wireless/iwlwifi/iwl-1000.c            |    3 -
>  drivers/net/wireless/iwlwifi/iwl-2000.c            |   10 +-
>  drivers/net/wireless/iwlwifi/iwl-5000-hw.h         |   88 -
>  drivers/net/wireless/iwlwifi/iwl-5000.c            |   22 +-
>  drivers/net/wireless/iwlwifi/iwl-6000-hw.h         |   81 -
>  drivers/net/wireless/iwlwifi/iwl-6000.c            |   12 +-
>  drivers/net/wireless/iwlwifi/iwl-agn-hw.h          |   15 +-
>  drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |    2 -
>  drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    4 +-
>  drivers/net/wireless/iwlwifi/iwl-agn-rs.h          |    4 +
>  .../wireless/iwlwifi/{iwl-rx.c =3D> iwl-agn-rx.c}    |  112 +-
>  drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |   10 +-
>  drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |  861 +-
>  drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   32 +-
>  drivers/net/wireless/iwlwifi/iwl-agn-ucode.c       |    1 -
>  drivers/net/wireless/iwlwifi/iwl-agn.c             |  126 +-
>  drivers/net/wireless/iwlwifi/iwl-agn.h             |  131 +-
>  drivers/net/wireless/iwlwifi/iwl-cfg.h             |    2 +
>  drivers/net/wireless/iwlwifi/iwl-commands.h        |   11 +
>  drivers/net/wireless/iwlwifi/iwl-core.c            |   83 +-
>  drivers/net/wireless/iwlwifi/iwl-core.h            |   20 +-
>  drivers/net/wireless/iwlwifi/iwl-debug.h           |    8 +-
>  drivers/net/wireless/iwlwifi/iwl-debugfs.c         |   22 +-
>  drivers/net/wireless/iwlwifi/iwl-dev.h             |    3 -
>  drivers/net/wireless/iwlwifi/iwl-helpers.h         |   72 -
>  drivers/net/wireless/iwlwifi/iwl-led.c             |    3 +-
>  drivers/net/wireless/iwlwifi/iwl-pci.c             |    2 +
>  drivers/net/wireless/iwlwifi/iwl-power.c           |    2 +-
>  drivers/net/wireless/iwlwifi/iwl-scan.c            |    4 +-
>  drivers/net/wireless/iwlwifi/iwl-shared.h          |    2 -
>  drivers/net/wireless/iwlwifi/iwl-sta.c             |  835 -
>  drivers/net/wireless/iwlwifi/iwl-sta.h             |  141 -
>  drivers/net/wireless/iwlwifi/iwl-sv-open.c         |    8 +-
>  drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c   |    1 -
>  drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |   23 +-
>  drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |   21 +-
>  drivers/net/wireless/iwmc3200wifi/cfg80211.c       |    6 +-
>  drivers/net/wireless/libertas/cfg.c                |   20 +-
>  drivers/net/wireless/libertas/decl.h               |    2 +
>  drivers/net/wireless/libertas/main.c               |   32 +
>  drivers/net/wireless/mwifiex/11n_aggr.c            |    3 +-
>  drivers/net/wireless/mwifiex/Kconfig               |   11 +
>  drivers/net/wireless/mwifiex/Makefile              |    3 +
>  drivers/net/wireless/mwifiex/cfp.c                 |   10 +-
>  drivers/net/wireless/mwifiex/cmdevt.c              |   34 +-
>  drivers/net/wireless/mwifiex/decl.h                |    1 -
>  drivers/net/wireless/mwifiex/fw.h                  |   36 +-
>  drivers/net/wireless/mwifiex/init.c                |   73 +-
>  drivers/net/wireless/mwifiex/main.c                |   10 +-
>  drivers/net/wireless/mwifiex/main.h                |   35 +-
>  drivers/net/wireless/mwifiex/pcie.c                | 1948 ++
>  drivers/net/wireless/mwifiex/pcie.h                |  148 +
>  drivers/net/wireless/mwifiex/scan.c                |   56 +-
>  drivers/net/wireless/mwifiex/sdio.c                |   19 +-
>  drivers/net/wireless/mwifiex/sdio.h                |   24 +-
>  drivers/net/wireless/mwifiex/sta_cmd.c             |   64 +
>  drivers/net/wireless/mwifiex/sta_cmdresp.c         |    2 +
>  drivers/net/wireless/mwifiex/sta_ioctl.c           |   12 +-
>  drivers/net/wireless/mwifiex/sta_tx.c              |    2 +-
>  drivers/net/wireless/mwifiex/txrx.c                |   45 +-
>  drivers/net/wireless/mwifiex/util.c                |    5 +-
>  drivers/net/wireless/mwifiex/util.h                |    9 +-
>  drivers/net/wireless/mwifiex/wmm.c                 |    4 +-
>  drivers/net/wireless/rtlwifi/base.c                |    6 +-
>  drivers/net/wireless/rtlwifi/debug.c               |    6 -
>  drivers/net/wireless/rtlwifi/pci.c                 |   19 +-
>  drivers/net/wireless/rtlwifi/pci.h                 |    4 +-
>  drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |   14 +
>  drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |   35 +-
>  drivers/net/wireless/rtlwifi/rtl8192cu/def.h       |    4 -
>  drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    7 +
>  drivers/net/wireless/rtlwifi/rtl8192de/def.h       |  135 +-
>  drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |   15 +-
>  drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |   21 +-
>  drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |   22 +-
>  drivers/net/wireless/rtlwifi/rtl8192se/reg.h       |    1 +
>  drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |   22 +-
>  drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |   55 +-
>  drivers/net/wireless/rtlwifi/wifi.h                |    5 +
>  drivers/net/wireless/wl12xx/acx.c                  |   16 +
>  drivers/net/wireless/wl12xx/acx.h                  |    1 +
>  drivers/net/wireless/wl12xx/boot.c                 |    6 +-
>  drivers/net/wireless/wl12xx/cmd.c                  |   63 +-
>  drivers/net/wireless/wl12xx/cmd.h                  |   20 +
>  drivers/net/wireless/wl12xx/conf.h                 |    6 +-
>  drivers/net/wireless/wl12xx/event.c                |   15 +
>  drivers/net/wireless/wl12xx/main.c                 |   48 +-
>  drivers/net/wireless/wl12xx/wl12xx.h               |    7 +-
>  drivers/staging/Kconfig                            |    2 +-
>  drivers/staging/Makefile                           |    4 +-
>  include/linux/nl80211.h                            |    2 +
>  include/net/cfg80211.h                             |    5 +-
>  include/net/mac80211.h                             |   10 +-
>  net/mac80211/cfg.c                                 |   22 +-
>  net/mac80211/ieee80211_i.h                         |   15 +-
>  net/mac80211/main.c                                |    6 +-
>  net/mac80211/mesh_hwmp.c                           |    9 +
>  net/mac80211/scan.c                                |    1 +
>  net/mac80211/sta_info.c                            |    6 +-
>  net/mac80211/status.c                              |  137 +-
>  net/mac80211/tx.c                                  |  360 +-
>  net/mac80211/work.c                                |    2 +-
>  net/mac80211/wpa.c                                 |    3 +-
>  net/wireless/nl80211.c                             |    4 +
>  226 files changed, 102247 insertions(+), 2686 deletions(-)
>  create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_rtt.c
>  create mode 100644 drivers/net/wireless/ath/ath9k/ar9003_rtt.h
>  rename drivers/net/wireless/ath/ath9k/{ar9480_1p0_initvals.h =3D> ar9462=
_1p0_initvals.h} (97%)
>  rename drivers/net/wireless/ath/ath9k/{ar9480_2p0_initvals.h =3D> ar9462=
_2p0_initvals.h} (97%)
>  create mode 100644 drivers/net/wireless/brcm80211/Kconfig
>  create mode 100644 drivers/net/wireless/brcm80211/Makefile
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/Makefile
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/bcmchip.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/dhd.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/dhd_proto.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/sdio_host.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/Makefile
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/aiutils.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/ampdu.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/antsel.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/antsel.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/brcms_trace_e=
vents.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/brcms_trace_e=
vents.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/channel.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/channel.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/d11.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/dma.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/dma.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/main.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/main.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/nicpci.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/nicpci.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/otp.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/otp.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_hal.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_int.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_lcn.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_n.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_qmath=
=2Ec
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_qmath=
=2Eh
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy/phy_radio=
=2Eh
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy/phyreg_n.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_lc=
n.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_lc=
n.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_n.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy/phytbl_n.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy_shim.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/phy_shim.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/pmu.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/pmu.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/pub.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/rate.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/rate.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/scb.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/srom.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/srom.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/stf.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/stf.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/types.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/ucode_loader.c
>  create mode 100644 drivers/net/wireless/brcm80211/brcmsmac/ucode_loader.h
>  create mode 100644 drivers/net/wireless/brcm80211/brcmutil/Makefile
>  create mode 100644 drivers/net/wireless/brcm80211/brcmutil/utils.c
>  create mode 100644 drivers/net/wireless/brcm80211/include/brcm_hw_ids.h
>  create mode 100644 drivers/net/wireless/brcm80211/include/brcmu_utils.h
>  create mode 100644 drivers/net/wireless/brcm80211/include/brcmu_wifi.h
>  create mode 100644 drivers/net/wireless/brcm80211/include/chipcommon.h
>  create mode 100644 drivers/net/wireless/brcm80211/include/defs.h
>  create mode 100644 drivers/net/wireless/brcm80211/include/soc.h
>  delete mode 100644 drivers/net/wireless/iwlwifi/iwl-5000-hw.h
>  delete mode 100644 drivers/net/wireless/iwlwifi/iwl-6000-hw.h
>  rename drivers/net/wireless/iwlwifi/{iwl-rx.c =3D> iwl-agn-rx.c} (91%)
>  delete mode 100644 drivers/net/wireless/iwlwifi/iwl-helpers.h
>  delete mode 100644 drivers/net/wireless/iwlwifi/iwl-sta.c
>  delete mode 100644 drivers/net/wireless/iwlwifi/iwl-sta.h
>  create mode 100644 drivers/net/wireless/mwifiex/pcie.c
>  create mode 100644 drivers/net/wireless/mwifiex/pcie.h
> --=20
> John W. Linville		Someday the world will need a hero, and you
> linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--C7zPtVaVf+AK4Oqc
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJOnI7EAAoJEJctW/TcYTgG2IYP/3Ugw82swKAFGxEP8ZaZ6K87
jGWukx03oMpzDGRyzQ7kjOQzdhcm2cROatDbG/KLE9odn13CxCKus1CnhtUf5/zV
CG27Q/lm/YI3atc/zqZy00/+nXxsNo42AvRdvoz9Uw7fpRWuA4k3CmX+sMknZtHO
f1dOEZcuiRhqRXoMzF0gC0OKwM+6DY0m+c5wN4cDLdu8BJB3Ij86oEgGPzl3BKCb
+n7GE/PnYlBRxVUUp1zN0hB3wdZo5OVUdNIA3VvMcaWaebiCBJI8VsJrLitIGuCC
dseE6IVOZq0ClRwIkEAb1Vy07iMeEZCrjveTdWU116i1QhKZZGCWqSt9qxeqH/FO
hcUa6uoEa50Dm/Rcu5MvaRo6/vOxarOvd7xfLkw/0eXk6nM3DotU0cIw4i3m/FIZ
rncQNdl21j7IQCViVH+C06PuczO/TGC+HU7ALyWhBfir29UrNwsj9k3/7QfGz+qb
Sy+s4DF3Ui/LhVk3QtZLs8YwILm3itw3sIyhE7HGqyPNZBLIksoScjexlYOiFdU0
5ZzDG9T/CxjSbrc7pY+gCNB/Pnt2v8RobfgBk5bksvytVybI2k+dX14kurTqFCkK
0DKxdPLNam+HX0lofhd4EkCd5+7VjGLi3K3ZQjrF9q1r1J3Os8pSvutsVB6/ufBB
FKLwftxENpElzIvOxOBI
=4ytE
-----END PGP SIGNATURE-----

--C7zPtVaVf+AK4Oqc--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
