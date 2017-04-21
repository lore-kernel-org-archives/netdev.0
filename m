From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2017-04-21
Date: Fri, 21 Apr 2017 12:08:10 +0300
Message-ID: <87h91i3z7p.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:39774 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1037123AbdDUJIR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 05:08:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's most likely the last pull request to net-next for 4.12, unless
Linus delayes the start of merge window. More info in the signed tag
below and please let me know if there are any problems.

Kalle

The following changes since commit d92be7a41ef15463eb816a4a2d42bf094b56dfce:

  net: make struct net_device::min_header_len 8-bit (2017-04-12 13:59:21 -0=
400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next=
.git tags/wireless-drivers-next-for-davem-2017-04-21

for you to fetch changes up to a0597834dc0e1af68f48f92b31617b360a14dfc8:

  rt2800: fix mt7620 E2 channel registers (2017-04-20 14:00:54 +0300)

----------------------------------------------------------------
wireless-drivers-next patches for 4.12

Quite a lot of patches for rtlwifi and iwlwifi this time, but changes
also for other active wireless drivers.

Major changes:

ath9k

* add support for Dell Wireless 1601 PCI device

* add debugfs file to manually override noise floor

ath10k

* bump up FW API to 6 for a new QCA6174 firmware branch

wil6210

* support 8 kB RX buffers

iwlwifi

* work to support A000 devices continues

* add support for FW API 30

* add Geographical and Dynamic Specific Absorption Rate (SAR) support

* support a few new PCI device IDs

rtlwifi

* work on adding Bluetooth coexistance support, not finished yet

----------------------------------------------------------------
Arend Van Spriel (7):
      brcmfmac: rename brcmf_fws_{de,}init to brcmf_fws{at,de}tach
      brcmfmac: ignore interfaces when fwsignal is disabled
      brcmfmac: remove reference to fwsignal data from struct brcmf_pub
      brcmfmac: add length checks in scheduled scan result handler
      brcmfmac: remove bogus check in scheduled scan result handler
      brcmfmac: only add channels and ssids once in scan request
      brcmfmac: only build fwsignal module for CONFIG_BRCMFMAC_PROTO_BCDC

Brian Norris (6):
      mwifiex: MAC randomization should not be persistent
      mwifiex: pcie: fix cmd_buf use-after-free in remove/reset
      mwifiex: reset timeout flag when resetting device
      mwifiex: pcie: clear outstanding work when resetting
      mwifiex: don't leak 'chan_stats' on reset
      MAINTAINERS: update Amitkumar's email address

Damien Th=C3=A9bault (1):
      ath9k: Add Dell Wireless 1601 with wowlan capability

Dan Carpenter (1):
      ath9k: off by one in ath9k_hw_nvram_read_array()

Daniel Golle (3):
      rt2x00: reverse external PA capability flag logic
      rt2800: fix LNA gain assignment for MT7620
      rt2800: do VCO calibration after programming ALC

David Spinadel (1):
      iwlwifi: mvm: change TX_CMD_SEC_KEY_FROM_TABLE value

Dedy Lansky (3):
      wil6210: align to latest auto generated wmi.h
      wil6210: fix memory access violation in wil_memcpy_from/toio_32
      wil6210: fix array out of bounds access in pmc

Emmanuel Grumbach (5):
      iwlwifi: mvm: add DQA_ENABLE_CMD to the command list
      iwlwifi: pcie: print less data upon firmware crash
      iwlwifi: mvm: tell the firmware about the U-APSD parameters
      iwlwifi: mvm: provide the actual number of frames for the SP len
      iwlwifi: split the handler and the wake parts of the notification inf=
ra

Ganapathi Bhat (1):
      mwifiex: Fix invalid port issue

Golan Ben-Ami (1):
      iwlwifi: mvm: support MFUART dump in case of MFUART assert

Goodstein, Mordechay (1):
      iwlwifi: mvm: move new API code to the end

Haim Dreyfuss (2):
      iwlwifi: mvm: refactor SAR init to prepare for dynamic SAR
      iwlwifi: mvm: add GEO_TX_POWER_LIMIT cmd for geographic tx power table

Hamad Kadmany (3):
      wil6210: fix sequence for scan-abort during reset
      wil6210: fix protection against connections during reset
      wil6210: fix check for sparrow D0 FW file

Heiner Kallweit (1):
      brcmfmac: properly align buffers on certain platforms with 64 bit DMA

Joe Perches (1):
      ath6kl: add __printf verification to ath6kl_dbg

Johan Hovold (1):
      ath9k_htc: fix NULL-deref at probe

Johannes Berg (5):
      iwlwifi: mvm: fix RX SKB header size and align it properly
      iwlwifi: use upper_32_bits/lower_32_bits where appropriate
      iwlwifi: pcie: use iwl_get_dma_hi_addr()
      iwlwifi: pcie: fix mutex leak in gen2 start
      iwlwifi: pcie: free context info in case of failures

Kalle Valo (3):
      Merge tag 'iwlwifi-next-for-kalle-2017-04-13' of git://git.kernel.org=
/.../iwlwifi/iwlwifi-next
      Merge tag 'iwlwifi-next-for-kalle-2017-04-19-2' of git://git.kernel.o=
rg/.../iwlwifi/iwlwifi-next
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Lazar Alexei (1):
      wil6210: restore power save state after internal FW reset

Liad Kaufman (3):
      iwlwifi: add support for 9000 HW B-step NICs
      iwlwifi: mvm: remove unneeded reg write in iwl_mvm_up()
      iwlwifi: a000: fix memory offsets and lengths

Lior David (1):
      wil6210: support 8KB RX buffers

Luca Coelho (9):
      iwlwifi: be more verbose about needed firmware
      iwlwifi: remove support for deprecated RF
      iwlwifi: mvm: bump max API to 30
      iwlwifi: remove unnecessary dev_cmd_headroom parameter
      iwlwifi: mvm: spin off SAR profile selection function
      iwlwifi: mvm: add support for EWRD (Dynamic SAR) ACPI table
      iwlwifi: mvm: remove unnecessary debugging from UMAC scan
      iwlwifi: mvm: remove unnecessary label in iwl_mvm_handle_rx_statistic=
s()
      iwlwifi: pcie: remove RSA race workaround

Maharaja Kennadyrajan (1):
      ath10k: fix the Transmit Power Control stats display format

Marcin Rokicki (3):
      ath10k: fix block comments style
      ath10k: use octal permission representation
      ath10k: clean header files from bad block comments

Matthias Kaehlcke (1):
      ath9k: Add cast to u8 to FREQ2FBIN macro

Maya Erez (3):
      wil6210: protect against sporadic interrupt during suspend flow
      wil6210: remove HALP voting in debugfs ioblob
      wil6210: prevent access to 11AD device if resume fails

Mohammed Shafi Shajakhan (7):
      ath10k: fix NAPI enable/disable symmetry for AHB interface
      ath10k: cancel coverage class work during stop and restart
      ath10k: enable a HTC debug message during insufficient tx credits
      ath10k: remove obselete Copy Engine comments
      ath10k: fix compile time sanity check for CE4 buffer size
      ath10k: fix spectral scan for QCA99X0 family of chipsets
      ath: Fix updating radar flags for coutry code India

Ryan Hsu (1):
      ath10k: bump up FW API to 6

Sara Sharon (48):
      iwlwifi: mvm: support new binding API
      iwlwifi: mvm: adjust new API of compressed BA
      iwlwifi: mvm: cleanup pending frames in DQA mode
      iwlwifi: mvm: add multicast station
      iwlwifi: mvm: support new ADD_MODIFY_STA_KEY command
      iwlwifi: mvm: optimize reorder timeout frame releasing
      iwlwifi: mvm: don't assume static queue numbers
      Revert "iwlwifi: introduce trans API to get byte count table"
      iwlwifi: pcie: remove the active field in struct iwl_txq
      iwlwifi: pcie: use WFPM_GP for debugging D3 flows
      iwlwifi: pcie: introduce split point to a000 devices
      iwlwifi: pcie: add context information support
      iwlwifi: mvm: remove call for paging in new init flow
      iwlwifi: mvm: separate queue mapping from queue enablement
      iwlwifi: mvm: read new secure boot registers
      iwlwifi: mvm: add queues after adding station
      iwlwifi: cleanup unused function
      iwlwifi: mvm: prepare for station count change
      iwlwifi: mvm: use same scan API for all a000 devices
      iwlwifi: mvm: disable multi-queue for a000 devices
      iwlwifi: mvm: support new TX API
      iwlwifi: pcie: introduce a000 TX queues management
      iwlwifi: mvm: support a000 SCD queue configuration
      iwlwifi: mvm: support moving to mgmt tid
      iwlwifi: pcie: copy TX functions to new transport
      iwlwifi: pcie: cleanup old transport code from gen2
      iwlwifi: pcie: support new TX command
      iwlwifi: pcie: rewrite TFD creation
      iwlwifi: pcie: support host commands in new transport
      iwlwifi: pcie: support new write pointer width
      iwlwifi: pcie: remove block and freeze operations from new transport
      iwlwifi: pcie: prepare for dynamic queue allocation
      iwlwifi: pcie: introduce new stop_device
      iwlwifi: pcie: alloc queues dynamically
      iwlwifi: pcie: get rid of txq id assignment
      iwlwifi: mvm: support new TX response for TVQM
      iwlwifi: move to TVQM mode
      iwlwifi: mvm: do not turn on RX_FLAG_AMSDU_MORE
      iwlwifi: mvm: work around HW issue with AMSDU de-aggregation
      iwlwifi: mvm: ignore BAID for SN smaller than SSN
      iwlwifi: mvm: support change to a000 smem API
      iwlwifi: support a000 CDB product
      iwlwifi: mvm: support init extended command
      iwlwifi: mvm: disable RX queue notification for a000 devices
      iwlwifi: mvm: dump frames early on invalid rate
      iwlwifi: mvm: flip address 4 of AMSDU frames
      iwlwifi: mvm: support changing band for phy context
      iwlwifi: mvm: allow block ack response without data

Simon Wunderlich (1):
      ath9k: add noise floor override option

Tomislav Po=C5=BEega (2):
      rt2800: fix mt7620 vco calibration registers
      rt2800: fix mt7620 E2 channel registers

Tzipi Peres (1):
      iwlwifi: add four new 8265 and 8275 series PCI IDs

Venkateswara Rao Naralasetty (1):
      ath10k: fix station nss computation

Xinming Hu (4):
      mwifiex: remove unnecessary wakeup interrupt number sanity check
      mwifiex: fall back mwifiex_dbg to pr_info when adapter->dev not set
      mwifiex: pcie: correct scratch register name
      mwifiex: pcie: extract wifi part from combo firmware during function =
level reset

Yan-Hsuan Chuang (71):
      rtlwifi: btcoex: 23b 2ant: check PS state before setting tdma duration
      rtlwifi: btcoex: 23b 2ant: rename tdma_adj_type to ps_tdma_du_adj_type
      rtlwifi: btcoex: 23b 2ant: detect ap num and set GNT_BT properly
      rtlwifi: btcoex: 23b 2ant: more cases for adjusting tdma duration
      rtlwifi: btcoex: 23b 2ant: fix PTA unstable problem when hw init
      rtlwifi: btcoex: 23b 2ant: add pnp notidy to avoid LPS/IPS mismatch
      rtlwifi: btcoex: 23b 2ant: check more cases when bt is queuing
      rtlwifi: btcoex: 23b 2ant: workaround for bt a2dp and hid
      rtlwifi: btcoex: 23b 2ant: tell fw if external or internal switch is =
used
      rtlwifi: btcoex: 23b 2ant: let bt transmit when hw initialisation done
      rtlwifi: btcoex: 23b 2ant: turn off ps and tdma mechanism when in con=
current mode
      rtlwifi: btcoex: 23b 2ant: turn off antenna when rssi is too high/low
      rtlwifi: btcoex: 23b 2ant: set coex table when wifi is linking
      rtlwifi: btcoex: 23b 2ant: set coex table when wifi is idle
      rtlwifi: btcoex: 23b 2ant: treat too many low prio packets as retry
      rtlwifi: btcoex: 23b 2ant: remove debugging code for 0x948
      rtlwifi: btcoex: 23b 2ant: need those information when scan
      rtlwifi: btcoex: 23b 2ant: wifi is not actually off in mp mode
      rtlwifi: btcoex: 23b 2ant: power on settings for coex
      rtlwifi: btcoex: 23b 2ant: before firmware ready settings
      rtlwifi: btcoex: 23b 2ant: fine tune for bt pan_edr_a2dp
      rtlwifi: btcoex: 23b 2ant: fine tune for bt hid_a2dp
      rtlwifi: btcoex: 23b 2ant: notify more bt information
      rtlwifi: btcoex: 23b 2ant: some hi-prio pkt will cause hid_exist
      rtlwifi: btcoex: 21a 1ant: fw settings for softap mode
      rtlwifi: btcoex: 21a 1ant: add function to check wifi status
      rtlwifi: btcoex: 21a 1ant: coex table setting for new fw
      rtlwifi: btcoex: 21a 1ant: mask profile bit for connect-ilde
      rtlwifi: btcoex: 21a 1ant: remove setting for 2 antennas
      rtlwifi: btcoex: 21a 1ant: set antenna control path for PTA
      rtlwifi: btcoex: 21a 1ant: add multi port action for miracast and P2P
      rtlwifi: btcoex: 21a 1ant: action when associating/authenticating
      rtlwifi: btcoex: 21a 1ant: If wifi only, do not initiate coex mechani=
sm
      rtlwifi: btcoex: 21a 1ant: move bt_disabled to global struct
      rtlwifi: btcoex: 21a 1ant: consider more cases when bt inquiry
      rtlwifi: btcoex: 21a 1ant: monitor bt profiling when scan
      rtlwifi: btcoex: 21a 1ant: do not switch antenna when wifi is under 5=
G channel
      rtlwifi: btcoex: 21a 1ant: avoid LPS/IPS mismatch for pnp notify
      rtlwifi: btcoex: 21a 2ant: limit rx aggregation size to avoid bt inte=
rrupt
      rtlwifi: btcoex: 21a 2ant: monitor if bt is slave or not
      rtlwifi: btcoex: 21a 2ant: monitor wifi counter to check network stat=
us
      rtlwifi: btcoex: 21a 2ant: update bt profiling information
      rtlwifi: btcoex: 21a 2ant: finer adjustment of bt power
      rtlwifi: btcoex: 21a 2ant: move from bt_stack_info to bt_link_info
      rtlwifi: btcoex: 21a 2ant: suffer less tx penalty from retry
      rtlwifi: btcoex: 21a 2ant: check power save state before pstdma
      rtlwifi: btcoex: 21a 2ant: do not check wifi bandwidth
      rtlwifi: btcoex: 21a 2ant: centralized control of coex table
      rtlwifi: btcoex: 21a 2ant: check if wifi status changed
      rtlwifi: btcoex: 21a 2ant: ignore wifi if it is at 5G band
      rtlwifi: btcoex: 21a 2ant: set coex table and tdma when bt inquiry
      rtlwifi: btcoex: 21a 2ant: let PTA circuit control the switch
      rtlwifi: btcoex: 21a 2ant: slot time fine tune
      rtlwifi: btcoex: 21a 2ant: tdma cases for low wifi/bt rssi
      rtlwifi: btcoex: 21a 2ant: action for wifi is idle/linking/common
      rtlwifi: btcoex: 21a 2ant: fix invalid argument passed
      rtlwifi: btcoex: 21a 2ant: refine tdma duration adjust function
      rtlwifi: btcoex: 21a 2ant: turn on sw dac swing and check if is sco_o=
nly
      rtlwifi: btcoex: 21a 2ant: add threshold to examine bt rssi
      rtlwifi: btcoex: 21a 2ant: force wifi to use RF path A
      rtlwifi: btcoex: 21a 2ant: more combinations of wifi/bt rssi state
      rtlwifi: btcoex: 21a 2ant: fix some coding style issues
      rtlwifi: btcoex: 21a 2ant: set tdma based on rssi state amd limit rx =
agg size
      rtlwifi: btcoex: 21a 2ant: add multiport action for p2p/miracast
      rtlwifi: btcoex: 21a 2ant: monitor extra wifi rssi to examine network=
 status
      rtlwifi: btcoex: 21a 2ant: notify fw the number of APs
      rtlwifi: btcoex: 21a 2ant: dec bt power according to bt rssi and set =
tdma
      rtlwifi: btcoex: 21a 2ant: macro for bt rssi threshold
      rtlwifi: btcoex: 21a 2ant: do not limit rx agg size
      rtlwifi: btcoex: 21a 2ant: just return when wifi is under ips
      rtlwifi: btcoex: 21a 2ant: wifi is linking action

 MAINTAINERS                                        |    2 +-
 drivers/net/wireless/ath/ath10k/ahb.c              |    2 +-
 drivers/net/wireless/ath/ath10k/bmi.h              |    3 +-
 drivers/net/wireless/ath/ath10k/ce.c               |    5 +-
 drivers/net/wireless/ath/ath10k/core.c             |   28 +-
 drivers/net/wireless/ath/ath10k/core.h             |    9 +-
 drivers/net/wireless/ath/ath10k/debug.c            |   93 +-
 drivers/net/wireless/ath/ath10k/debugfs_sta.c      |    9 +-
 drivers/net/wireless/ath/ath10k/hif.h              |    6 +-
 drivers/net/wireless/ath/ath10k/htc.c              |    6 +-
 drivers/net/wireless/ath/ath10k/htt.h              |   24 +-
 drivers/net/wireless/ath/ath10k/htt_rx.c           |    9 +-
 drivers/net/wireless/ath/ath10k/htt_tx.c           |    6 +-
 drivers/net/wireless/ath/ath10k/hw.h               |   11 +-
 drivers/net/wireless/ath/ath10k/mac.c              |   58 +-
 drivers/net/wireless/ath/ath10k/pci.c              |   13 +-
 drivers/net/wireless/ath/ath10k/rx_desc.h          |   13 +-
 drivers/net/wireless/ath/ath10k/spectral.c         |   32 +-
 drivers/net/wireless/ath/ath10k/targaddrs.h        |   19 +-
 drivers/net/wireless/ath/ath10k/thermal.c          |    5 +-
 drivers/net/wireless/ath/ath10k/txrx.c             |    3 +-
 drivers/net/wireless/ath/ath10k/wmi-ops.h          |    3 +-
 drivers/net/wireless/ath/ath10k/wmi.c              |   16 +-
 drivers/net/wireless/ath/ath10k/wmi.h              |   30 +-
 drivers/net/wireless/ath/ath6kl/debug.h            |    2 +
 drivers/net/wireless/ath/ath6kl/htc_pipe.c         |    2 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |    2 +-
 drivers/net/wireless/ath/ath9k/calib.c             |    5 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   62 +
 drivers/net/wireless/ath/ath9k/eeprom.c            |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom.h            |    2 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    3 +
 drivers/net/wireless/ath/ath9k/hw.h                |    1 +
 drivers/net/wireless/ath/ath9k/pci.c               |    5 +
 drivers/net/wireless/ath/regd.c                    |   19 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |   12 +-
 drivers/net/wireless/ath/wil6210/debugfs.c         |    5 +-
 drivers/net/wireless/ath/wil6210/fw_inc.c          |    4 +-
 drivers/net/wireless/ath/wil6210/main.c            |   65 +-
 drivers/net/wireless/ath/wil6210/pm.c              |   27 +-
 drivers/net/wireless/ath/wil6210/pmc.c             |    4 +-
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |   12 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |   24 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   13 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   14 +-
 drivers/net/wireless/ath/wil6210/wmi.h             |   73 +-
 .../wireless/broadcom/brcm80211/brcmfmac/Makefile  |    4 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcdc.c    |   35 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcdc.h    |    1 +
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |   39 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.h    |    2 -
 .../broadcom/brcm80211/brcmfmac/fwsignal.c         |   53 +-
 .../broadcom/brcm80211/brcmfmac/fwsignal.h         |    4 +-
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |    4 +
 drivers/net/wireless/intel/iwlwifi/Makefile        |    1 +
 drivers/net/wireless/intel/iwlwifi/iwl-7000.c      |    4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-8000.c      |    4 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |   48 +-
 drivers/net/wireless/intel/iwlwifi/iwl-a000.c      |   31 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |   25 +-
 .../net/wireless/intel/iwlwifi/iwl-context-info.h  |  203 ++
 drivers/net/wireless/intel/iwlwifi/iwl-csr.h       |    1 -
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |   34 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fh.h        |    6 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |    5 +
 drivers/net/wireless/intel/iwlwifi/iwl-io.c        |    4 +-
 .../net/wireless/intel/iwlwifi/iwl-notif-wait.c    |   10 +-
 .../net/wireless/intel/iwlwifi/iwl-notif-wait.h    |   25 +-
 drivers/net/wireless/intel/iwlwifi/iwl-prph.h      |    9 +-
 drivers/net/wireless/intel/iwlwifi/iwl-trans.c     |    7 +-
 drivers/net/wireless/intel/iwlwifi/iwl-trans.h     |  105 +-
 drivers/net/wireless/intel/iwlwifi/mvm/binding.c   |   17 +-
 drivers/net/wireless/intel/iwlwifi/mvm/coex.c      |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/d3.c        |   26 +-
 .../net/wireless/intel/iwlwifi/mvm/debugfs-vif.c   |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |    2 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-mac.h    |    4 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-power.h  |   43 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-scan.h   |   14 +-
 .../net/wireless/intel/iwlwifi/mvm/fw-api-sta.h    |   50 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-tx.h |   91 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h    |  107 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-dbg.c    |  287 ++-
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c        |  520 ++++-
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c  |    9 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   48 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |   83 +-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |   26 +-
 drivers/net/wireless/intel/iwlwifi/mvm/phy-ctxt.c  |   21 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rx.c        |  111 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |   87 +-
 drivers/net/wireless/intel/iwlwifi/mvm/scan.c      |   85 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sf.c        |    6 +-
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c       |  486 ++--
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h       |    3 +
 drivers/net/wireless/intel/iwlwifi/mvm/tdls.c      |   22 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tof.c       |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |  132 +-
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |  108 +-
 .../net/wireless/intel/iwlwifi/pcie/ctxt-info.c    |  277 +++
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |   24 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |   93 +-
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |   57 +-
 .../net/wireless/intel/iwlwifi/pcie/trans-gen2.c   |  374 ++++
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |  284 +--
 drivers/net/wireless/intel/iwlwifi/pcie/tx-gen2.c  | 1018 +++++++++
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c       |  237 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |    4 +-
 drivers/net/wireless/marvell/mwifiex/fw.h          |   18 +
 drivers/net/wireless/marvell/mwifiex/main.c        |   20 +-
 drivers/net/wireless/marvell/mwifiex/pcie.c        |  127 +-
 drivers/net/wireless/marvell/mwifiex/pcie.h        |   16 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c        |    4 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c     |   72 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00.h        |    4 +-
 .../realtek/rtlwifi/btcoexist/halbtc8723b2ant.c    | 1661 ++++++++++++--
 .../realtek/rtlwifi/btcoexist/halbtc8723b2ant.h    |   22 +-
 .../realtek/rtlwifi/btcoexist/halbtc8821a1ant.c    |  408 +++-
 .../realtek/rtlwifi/btcoexist/halbtc8821a1ant.h    |    2 +
 .../realtek/rtlwifi/btcoexist/halbtc8821a2ant.c    | 2357 +++++++++++++++-=
----
 .../realtek/rtlwifi/btcoexist/halbtc8821a2ant.h    |   29 +-
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.h       |   20 +
 123 files changed, 8770 insertions(+), 2181 deletions(-)
 create mode 100644 drivers/net/wireless/intel/iwlwifi/iwl-context-info.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/pcie/ctxt-info.c
 create mode 100644 drivers/net/wireless/intel/iwlwifi/pcie/trans-gen2.c
 create mode 100644 drivers/net/wireless/intel/iwlwifi/pcie/tx-gen2.c
