From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2016-05-02
Date: Mon, 02 May 2016 15:01:09 +0300
Message-ID: <87y47su0sa.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

another pull request for 4.7. Nothing really special, from the diffstat
stands out a new bindings document for Marvell but I can't think of
anything else special worth mentioning.

Please let me know if there are any problems.

Kalle


The following changes since commit f38ba953bee01887d520f7abba536721a1d1=
6477:

  gre: eliminate holes in ip_tunnel (2016-04-14 01:15:52 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-=
next.git tags/wireless-drivers-next-for-davem-2016-05-02

for you to fetch changes up to 9d3f65b0c2ddb926340af96eb89ad9be589865c0=
:

  mwifiex: increase dwell time for active scan (2016-04-27 16:52:56 +03=
00)

----------------------------------------------------------------
wireless-drivers patches for 4.7

Major changes:

brcmfmac

* add support for nl80211 BSS_SELECT feature

mwifiex

* add platform specific wakeup interrupt support

ath10k

* implement set_tsf() for 10.2.4 branch
* remove rare MSI range support
* remove deprecated firmware API 1 support

ath9k

* add module parameter to invert LED polarity

wcn36xx

* fixes to get the driver properly working on Dragonboard 410c

----------------------------------------------------------------
Amitkumar Karwar (7):
      mwifiex: missing break statement
      mwifiex: fix incorrect ht capability problem
      mwifiex: fix coding style
      mwifiex: report wowlan wakeup reasons correctly
      mwifiex: avoid querying wakeup reason when wowlan is disabled
      mwifiex: disable channel filtering feature in firmware
      mwifiex: increase dwell time for active scan

Andreas Fenkart (7):
      mwifiex: scan: simplify dereference of bss_desc fields
      mwifiex: scan: factor out has_ieee_hdr/has_vendor_hdr
      mwifiex: scan: simplify ternary operators using gnu extension
      mwifiex: scan: factor out dbg_security_flags
      mwifiex: scan: replace pointer arithmetic with array access
      mwifiex: factor out mwifiex_cancel_pending_scan_cmd
      mwifiex: make mwifiex_insert_cmd_to_free_q local static

Arend van Spriel (4):
      brcmfmac: cleanup ampdu-rx host reorder code
      brcmfmac: revise handling events in receive path
      brcmfmac: create common function for handling brcmf_proto_hdrpull=
()
      brcmfmac: add support for nl80211 BSS_SELECT feature

Arnd Bergmann (1):
      rtl8xxxu: hide unused tables

Ben Greear (1):
      ath10k: Document alloc_frag_desc_for_data_pkt config option.

Bjorn Andersson (3):
      wcn36xx: Delete BSS before idling link
      wcn36xx: Correct remove bss key response encoding
      wcn36xx: Fill in capability list

Chun-Yeow Yeoh (1):
      rt2800lib: enable MFP if hw crypt is disabled

Colin Ian King (2):
      rtl8xxxu: fix uninitialized return value in ret
      ath9k: remove duplicate assignment of variable ah

Dan Carpenter (4):
      ath10k: add some sanity checks to peer_map_event() functions
      mwifiex: missing error code on allocation failure
      mwifiex: fix loop timeout in mwifiex_prog_fw_w_helper()
      brcmfmac: testing the wrong variable in brcmf_rx_hdrpull()

David M=C3=BCller (1):
      rtlwifi: rtl8821ae: Make sure loop counter is signed on all archi=
tectures

=46ranky Lin (1):
      brcmfmac: screening firmware event packet

Hante Meuleman (4):
      brcmfmac: clear eventmask array before using it
      brcmfmac: fix clearing wowl wake indicators
      brcmfmac: insert default boardrev in nvram data if missing
      brcmfmac: fix p2p scan abort null pointer exception

Jes Sorensen (75):
      rtl8xxxu: Add MAC init table for 8192eu
      rtl8xxxu: Do not mess with AFE_XTAL_CTRL on 8192eu
      rtl8xxxu: Set TX page boundaries for 8192eu
      rtl8xxxu: Add radio init tables for 8192eu
      rtl8xxxu: Add 8192eu AGC tables
      rtl8xxxu: Add 8192eu PHY init table
      rtl8xxxu: Pick PHY init table based on chip version first
      rtl8xxxu: Correctly parse 8192eu efuse
      rtl8xxxu: Handle BB init for 8192eu
      rtl8xxxu: Provide special handling when writing RF regs on 8192eu
      rtl8xxxu: Handle XTAL value setting on 8192eu
      rtl8xxxu: Set correct interrupt masking registers on 8192eu
      rtl8xxxu: Set REG_USB_HRPWM for 8192eu
      rtl8xxxu: Fix LDPC RX hang issue on 8192eu
      rtl8xxxu: Implement 8192eu device specific quirks
      rtl8xxxu: Use proper register name for REG_PAD_CTRL1
      rtl8xxxu: Implement IQK calibration for 8192eu
      rtl8xxxu: Adjust AFE crystal value on 8192eu
      rtl8xxxu: Reorder parts of init code to match the 8192eu vendor c=
ode flow
      rtl8xxxu: Reorg more code to match the flow of the 8192eu vendor =
driver
      rtl8xxxu: Implement generic init_queue_reserved_page() function
      rtl8xxxu: Reorder chip quirks to follow flow of 8192eu driver
      rtl8xxxu: Do not set REG_PBP on 8192eu
      rtl8xxxu: Do not init FPGA0_TX_INFO on 8192eu
      rtl8xxxu: Do not try to set REG_LEDCFG2 on 8192eu
      rtl8xxxu: Implment rtl8192e_set_tx_power()
      rtl8xxxu: Use has_s0s1 for REG_S0S1 issues only
      rtl8xxxu: byteswap the entire RX descriptor for 24 byte RX descri=
ptors
      rtl8xxxu: Name RX descriptor types rxdesc16/rxdesc24
      rtl8xxxu: Remove misleading warning from rtl8192eu_phy_iqcalibrat=
e()
      rtl8xxxu: Remove unused 8723bu path B IQ calibration code
      rtl8xxxu: Correctly mask what was read from REG_CCK0_AFE_SETTING
      rtl8xxxu: Use descriptive bits for setting RX paths for 1T2R part=
s
      rtl8xxxu: Split rtl8xxxu_init_phy_bb() into device specific funct=
ions
      rtl8xxxu: Load AGC table before patching for 1T2R parts
      rtl8xxxu: Move loading of AGC table to device specific function
      rtl8xxxu: REG_LDOA15_CTRL is only used on gen1 parts
      rtl8xxxu: Store device specific TRXFF boundary in the fileops
      rtl8xxxu: Do not backup RF_MODE_AG when it's never being used
      rtl8xxxu: Make PBP tuning a fileops parameter
      rtl8xxxu: Split USB quirks into gen1 and gen2 quirks
      rtl8xxxu: Remove unneeded 8192eu hack
      rtl8xxxu: 8192eu Fix bug in LDPC RX hang fix
      Re-enable 8192eu support
      rtl8xxxu: Mark 0x050d:0x1004 as tested
      rtl8xxxu: Move PHY RF init into device specific functions
      rtl8xxxu: For devices with external PA (8188RU), limit CCK TX pow=
er
      rtl8xxxu: Apply 8188RU workaround for UMC B cut parts correctly
      rtl8xxxu: Use rtl_chip =3D=3D RTL8188R to identify high PA parts
      rtl8xxxu: Match 8723bu power down sequence to vendor driver
      rtl8xxxu: Unregister from mac80211 before shutting down the devic=
e
      rtl8xxxu: Update copyright statement to include 2016
      rtl8xxxu: Set register 0xfe10 on rtl8192cu based parts
      rtl8xxxu: Add TX power base values for gen1 parts
      rtl8xxxu: Fix 8188RU support
      rtl8xxxu: Fix OOPS if user tries to add device via /sys
      rtl8xxxu: Implement rtl8192e_enable_rf()
      rtl8xxxu: Pause TX before calling disable_rf()
      rtl8xxxu: MAINTAINERS: Update to point to the active devel branch
      rtl8xxxu: Rename rtl8723bu_update_rate_mask() to rtl8xxxu_gen2_up=
date_rate_mask()
      rtl8xxxu: Rename rtl8723bu_report_connect() to rtl8xxxu_gen2_repo=
rt_connect()
      rtl8xxxu: Rename rtl8723au_report_connect() to rtl8xxxu_gen1_repo=
rt_connect()
      rtl8xxxu: Rename rtl8723bu_config_channel() to rtl8xxxu_gen2_conf=
ig_channel()
      rtl8xxxu: Rename rtl8723b_disable_rf() to rtl8xxxu_gen2_disable_r=
f()
      rtl8xxxu: Rename rtl8723a_disable_rf() to rtl8xxxu_gen1_disable_r=
f()
      rtl8xxxu: Rename rtl8723au_config_channel() to rtl8xxxu_gen1_conf=
ig_channel()
      rtl8xxxu: Rename rtl8723au_update_rate_mask() to rtl8xxxu_update_=
rate_mask()
      rtl8xxxu: Rename rtl8723au_phy_iq_calibrate() to rtl8xxxu_gen1_ph=
y_iq_calibrate()
      rtl8xxxu: Rename rtl8723au_init_phy_bb() to rtl8xxxu_gen1_init_ph=
y_bb()
      rtl8xxxu: Rename rtl8723a_set_tx_power() to rtl8xxxu_gen1_set_tx_=
power()
      rtl8xxxu: Rename rtl8723a_enable_rf() to rtl8xxxu_gen1_enable_rf(=
)
      rtl8xxxu: Rename rtl8723a_mac_init_table to rtl8xxxu_gen1_mac_ini=
t_table
      rtl8xxxu: Rename rtl8723b_channel_to_group()
      rtl8xxxu: Rename rtl8723bu_simularity_compare()
      rtl8xxxu: Rename rtl8723au_iqk_phy_iq_bb_reg

Jia-Ju Bai (1):
      rtl818x_pci: Fix a memory leak in rtl8180_init_rx_ring

Kalle Valo (14):
      ath10k: fix checkpatch warnings related to spaces
      ath10k: prefer kernel type 'u64' over 'u_int64_t'
      ath10k: prefer ether_addr_equal() or ether_addr_equal_unaligned()=
 over memcmp()
      ath10k: prefer ether_addr_copy() over memcpy()
      ath10k: fix parenthesis alignment
      ath10k: remove deprecated firmware API 1 support
      ath10k: refactor firmware images to struct ath10k_fw_components
      ath10k: move fw_version inside struct ath10k_fw_file
      ath10k: move fw_features to struct ath10k_fw_file
      ath10k: move wmi_op_version to struct ath10k_fw_file
      ath10k: move htt_op_version to struct ath10k_fw_file
      ath10k: switch testmode to use ath10k_core_fetch_firmware_api_n()
      ath10k: remove enum ath10k_swap_code_seg_bin_type
      Merge ath-next from ath.git

Luca Coelho (1):
      iwlwifi: fix fw version reading for DVM devices

Markus Elfring (1):
      ath9k_htc: Replace a variable initialisation by an assignment in =
ath9k_htc_set_channel()

Marty Faltesek (3):
      mwifiex: bridged packets cause wmm_tx_pending counter to go negat=
ive
      mwifiex: fw download does not release sdio bus during failure
      mwifiex: transmit packet stats incorrect.

Mohammed Shafi Shajakhan (1):
      ath10k: fix return value for btcoex and peer stats debugfs

Per Forlin (1):
      brcmf: Fix null pointer exception in bcdc_hdrpull

Peter Oh (3):
      ath10k: add a support of set_tsf on vdev interface
      ath10k: update 10.4 WMI vdev parameters
      ath10k: enable set_tsf vdev command to WMI 10.4

Pontus Fuchs (15):
      wcn36xx: Clean up wcn36xx_smd_send_beacon
      wcn36xx: Pad TIM PVM if needed
      wcn36xx: Add helper macros to cast vif to private vif and vice ve=
rsa
      wcn36xx: Use consistent name for private vif
      wcn36xx: Use define for invalid index and fix typo
      wcn36xx: Add helper macros to cast sta to priv
      wcn36xx: Fetch private sta data from sta entry instead of from vi=
f
      wcn36xx: Remove sta pointer in private vif struct
      wcn36xx: Parse trigger_ba response properly
      wcn36xx: Copy all members in config_sta v1 conversion
      wcn36xx: Use allocated self sta index instead of hard coded
      wcn36xx: Clear encrypt_type when deleting bss key
      wcn36xx: Track association state
      wcn36xx: Implement multicast filtering
      wcn36xx: Use correct command struct for EXIT_BMPS_REQ

Raja Mani (1):
      ath10k: add dynamic tx mode switch config support for qca4019

Rajkumar Manoharan (2):
      ath10k: remove MSI range support
      ath10k: fix rx_channel during hw reconfigure

Shengzhen Li (2):
      mwifiex: add pcie usb/uart firmware download support
      mwifiex: add default setting for pcie firmware download

Tina Ruchandani (1):
      prism54: isl_38xx: Replace 'struct timeval'

Vishal Thanki (1):
      mwifiex: fix the incorrect WARN_ON during suspend

Vittorio Gambaletta (VittGam) (2):
      ath9k: Add a module parameter to invert LED polarity.
      ath9k: Fix LED polarity for some Mini PCI AR9220 MB92 cards.

Xinming Hu (4):
      mwifiex: do not wait on semaphore during card removal
      dt: bindings: add MARVELL's sd8xxx wireless device
      mwifiex: add platform specific wakeup interrupt support
      mwifiex: stop background scan when net device closed

Zefir Kurtisi (1):
      ath9k: interpret requested txpower in EIRP domain

 .../bindings/net/wireless/marvell-sd8xxx.txt       |   63 +
 MAINTAINERS                                        |    2 +-
 drivers/net/wireless/ath/ath10k/ce.c               |    6 +-
 drivers/net/wireless/ath/ath10k/ce.h               |    2 +-
 drivers/net/wireless/ath/ath10k/core.c             |  324 +--
 drivers/net/wireless/ath/ath10k/core.h             |   71 +-
 drivers/net/wireless/ath/ath10k/debug.c            |   44 +-
 drivers/net/wireless/ath/ath10k/debug.h            |    2 +-
 drivers/net/wireless/ath/ath10k/htc.h              |    4 +-
 drivers/net/wireless/ath/ath10k/htt.c              |    4 +-
 drivers/net/wireless/ath/ath10k/htt.h              |    5 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |    2 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |    9 +-
 drivers/net/wireless/ath/ath10k/hw.h               |   12 -
 drivers/net/wireless/ath/ath10k/mac.c              |   88 +-
 drivers/net/wireless/ath/ath10k/mac.h              |    1 +
 drivers/net/wireless/ath/ath10k/pci.c              |  165 +-
 drivers/net/wireless/ath/ath10k/pci.h              |   17 +-
 drivers/net/wireless/ath/ath10k/swap.c             |   44 +-
 drivers/net/wireless/ath/ath10k/swap.h             |    9 +-
 drivers/net/wireless/ath/ath10k/targaddrs.h        |    2 +-
 drivers/net/wireless/ath/ath10k/testmode.c         |  197 +-
 drivers/net/wireless/ath/ath10k/thermal.h          |    2 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |   18 +-
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |    1 +
 drivers/net/wireless/ath/ath10k/wmi-tlv.h          |    4 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |   24 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |   48 +-
 drivers/net/wireless/ath/ath10k/wow.c              |    7 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    7 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   10 +-
 drivers/net/wireless/ath/ath9k/init.c              |    9 +-
 drivers/net/wireless/ath/ath9k/pci.c               |   10 +
 drivers/net/wireless/ath/wcn36xx/debug.c           |   12 +-
 drivers/net/wireless/ath/wcn36xx/hal.h             |   55 +-
 drivers/net/wireless/ath/wcn36xx/main.c            |  133 +-
 drivers/net/wireless/ath/wcn36xx/pmc.c             |    4 +-
 drivers/net/wireless/ath/wcn36xx/smd.c             |  224 +-
 drivers/net/wireless/ath/wcn36xx/smd.h             |   12 +-
 drivers/net/wireless/ath/wcn36xx/txrx.c            |    8 +-
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h         |   20 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcdc.c    |   10 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/bus.h |    4 +-
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |   67 +-
 .../wireless/broadcom/brcm80211/brcmfmac/common.c  |   38 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |  247 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.h    |    5 +-
 .../broadcom/brcm80211/brcmfmac/firmware.c         |   30 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fweh.c    |    1 +
 .../wireless/broadcom/brcm80211/brcmfmac/fwil.h    |    1 +
 .../broadcom/brcm80211/brcmfmac/fwsignal.c         |  209 ++
 .../broadcom/brcm80211/brcmfmac/fwsignal.h         |    1 +
 .../wireless/broadcom/brcm80211/brcmfmac/msgbuf.c  |   46 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |    2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/proto.h   |   16 +
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |   32 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/usb.c |    2 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |    5 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |    2 +
 drivers/net/wireless/intersil/prism54/isl_38xx.c   |   35 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   13 +-
 drivers/net/wireless/marvell/mwifiex/cmdevt.c      |  127 +-
 drivers/net/wireless/marvell/mwifiex/main.c        |   16 +-
 drivers/net/wireless/marvell/mwifiex/main.h        |   18 +-
 drivers/net/wireless/marvell/mwifiex/pcie.c        |   21 +-
 drivers/net/wireless/marvell/mwifiex/pcie.h        |    9 +-
 drivers/net/wireless/marvell/mwifiex/scan.c        |  194 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c        |   80 +-
 drivers/net/wireless/marvell/mwifiex/sdio.h        |    7 +
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     |   14 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |   13 +-
 drivers/net/wireless/marvell/mwifiex/sta_ioctl.c   |   44 +-
 drivers/net/wireless/marvell/mwifiex/txrx.c        |   13 +-
 drivers/net/wireless/marvell/mwifiex/uap_txrx.c    |    4 +
 drivers/net/wireless/marvell/mwifiex/usb.c         |   11 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c     |    4 +
 drivers/net/wireless/realtek/rtl818x/rtl8180/dev.c |    4 +
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c   | 2614 ++++++++++++=
+++-----
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h   |   90 +-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_regs.h  |   15 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/phy.c   |    2 +-
 81 files changed, 3825 insertions(+), 1922 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/wireless/marv=
ell-sd8xxx.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
