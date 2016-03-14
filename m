From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2016-03-14
Date: Mon, 14 Mar 2016 10:31:48 +0200
Message-ID: <87y49llatn.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

I know I'm late now that merge window was opened yesterday but here's
one more set of patches I would like to get to 4.6 still. There isn't
anything controversial so I hope this should be still safe to pull. The
patches have been in linux-next since Friday and I haven't seen any
reports about issues. But if you think it's too late just let me know
and I'll resubmit these for 4.7.

The most notable part here of course is rtl8xxxu with over 100 patches.
As the driver is new and under heavy development I think they are ok to
take still. Otherwise there are mostly fixes with an exception of adding
a new debugfs file to wl18xx.

Please let me know if you have any problems.

Kalle

The following changes since commit 836856e3bd61d0644e5178a2c1b51d90459e2788:

  wireless: cw1200: use __maybe_unused to hide pm functions_ (2016-03-08 12:32:52 +0200)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2016-03-14

for you to fetch changes up to ccfe1e85322090649d2fae599e55300c1512bf15:

  rtl8xxxu: Temporarily disable 8192eu device init (2016-03-10 15:29:21 +0200)

----------------------------------------------------------------
wireless-drivers patches for 4.6

Major changes:

rtl8xxxu

* add 8723bu support

wl18xx

* add radar_debug_mode debugfs file for DFS testing

----------------------------------------------------------------
Amitkumar Karwar (1):
      mwifiex: Empty Tx queue during suspend

Ayala Beker (1):
      iwlwifi: mvm: update GSCAN capabilities

Chaya Rachel Ivgi (4):
      iwlwifi: mvm: fix unregistration of thermal in some error flows
      iwlwifi: mvm: add ctdp operations to debugfs
      iwlwifi: mvm: add support for async rx handler without hold the mutex
      iwlwifi: mvm: return the cooling state index instead of the budget

Dan Carpenter (1):
      libertas: fix an error code in probe

Eliad Peller (2):
      wlcore: don't WARN_ON in case of existing ROC
      wlcore/wl18xx: add radar_debug_mode handling

Emmanuel Grumbach (4):
      iwlwifi: mvm: avoid panics with thermal device usage
      iwlwifi: mvm: don't let NDPs mess the packet tracking
      iwlwifi: mvm: remove RRM advertisement
      iwlwifi: mvm: adapt the firmware assert log to new firmware

Gregory Greenman (1):
      iwlwifi: pcie: avoid restocks inside rx loop if not emergency

Hui Wang (1):
      brcmfmac: Remove waitqueue_active check

Jakub Sitnicki (5):
      rtl8xxxu: Don't check for illegal offset when reading from efuse
      rtl8xxxu: Skip disabled efuse words early
      rtl8xxxu: rtl8723au: Introduce a pointer to efuse
      rtl8xxxu: rtl8192cu: Introduce a pointer to efuse
      rtl8xxxu: rtl8192eu: Map out EFUSE TX power area

Jes Sorensen (108):
      rtl8xxxu: Add initial code to parse rtl8192eu efuse
      rtl8xxxu: Identify chip vendors correctly
      rtl8xxxu: Use 1024 byte block loads for 8192eu firmware
      rtl8xxxu: Add rtl8192eu_nic.bin to the MODULE_FIRMWARE list
      rtl8xxxu: Implment rtl8192eu_power_on()
      rtl8xxxu: Add rtl8xxxu_auto_llt_table()
      rtl8xxxu: Init page boundaries before starting the firmware
      rtl8xxxu: Init the LLT after we start the firmware
      rtl8xxxu: Fix incorrect test for auto LLT failure
      rtl8xxxu: Kludge to drop incorrect USB OUT EP for 8192EU
      rtl8xxxu: Init REG_HIMR[01] for 8192eu parts
      rtl8xxxu: Initial rtl8723bu chip identification
      rtl8xxxu: Add rtl8723bu_parse_efuse() and 8723bu efuse definition
      rtl8xxxu: Use 1024 byte writes for writing 8723bu firmware
      rtl8xxxu: Only setup USB interrupts for parts which support it
      rtl8xxxu: Add rtl8723b_phy_1t_init_table
      rtl8xxxu: Add rtl8723bu_radioa_1t_init_table
      rtl8xxxu: Add rtl8723bu_phy_init_antenna_selection()
      rtl8xxxu: Add rtl8723b_mac_init_table
      rtl8xxxu: Add 8723by AGC table
      rtl8xxxu: Handle 32 bit mailbox extension regs found on 8723bu/8192eu/8812
      rtl8xxxu: Add some missing register definitions for 8723bu
      rtl8xxxu: Group USB fixups together for all chips
      rtl8xxxu: Add definitions for new generation h2c commands
      rtl8xxxu: rtl8192eu_parse_efuse(): Use a pointer to the struct rtl8192eu_efuse
      rtl8xxxu: rtl8723bu_parse_efuse(): Use a pointer to the struct rtl8723bu_efuse
      rtl8xxxu: rtl8xxxu_h2c_cmd(): Add size argument
      rtl8xxxu: Do BT_WLAN_CALIBRATION before doing IQK calibration
      rtl8xxxu: Do not overwrite rtl8xxxu_debug for untested chips
      rtl8xxxu: Use correct formatting type to print sizeof()
      rtl8xxxu: Make rtl8xxxu_add_path_on() use device specific init values
      rtl8xxxu: Add a couple of new register definitions
      rtl8xxxu: First stab at adding IQK calibration for 8723bu parts
      rtl8xxxu: Handle S0S1 register in lc_calibrate()
      rtl8xxxu: Do LC calibration before IQK calibration
      rtl8xxxu: Remove backing up certain registers, which was never used
      rtl8xxxu: Initial implementation of rtl8723bu_config_channel()
      rtl8xxxu: Initial rtl8723bu_init_bt() code
      rtl8xxxu: Remove unused variable
      rtl8xxxu: Improve 8723bu init code
      rtl8xxxu: Do not ignore wlan activity on 8723bu
      rtl8xxxu: Set the right type for ps tdma on 8723bu
      rtl8xxxu: Add rtl8723bu (nextgen) rx descriptor definition
      rtl8xxxu: Handle 8723bu style rx descriptors
      rtl8xxxu: Initial functionality to handle C2H events for 8723bu
      rtl8xxxu: Handle BT register writes and MP_OPER events
      rtl8xxxu: Issue BT_INFO command
      rtl8xxxu: Do not set REG_AFE_XTAL_CTRL on 8723bu
      rtl8xxxu: Implement 8723bu power on sequence
      rtl8xxxu: Setup LLT before downloading firmware
      rtl8xxxu: Additional fixes for 8723bu
      rtl8xxxu: Handle XTAL_K value in efuse specific location
      rtl8xxxu: Another 8723bu patch for rtl8xxxu_init_phy_bb()
      rtl8xxxu: Another 8723bu magic register set during init
      rtl8xxxu: Init H2C command register for 8723bu
      rtl8xxxu: 80M spur hack is for 8723au only
      rtl8xxxu: Do queue init in same order as 8723bu vendor driver
      rtl8xxxu: Do not set FPGA0_TX_INFO for 8723bu and use a larger PBP page size
      rtl8xxxu: Set RX boundary for 8723bu
      rtl8xxxu: Initialize burst parameters for 8723bu
      rtl8xxxu: Call device specific _config_channel()
      rtl8xxxu: 8723bu lock phy after RF init
      rtl8xxxu: Add REG_DWBCN1_CTRL_8723B define
      rtl8xxxu: Group chip quirks together
      rtl8xxxu: Setup RX aggregation
      rtl8xxxu: Add missing blank space in front of bracket
      rtl8xxxu: Implement init_statistics for 8723bu
      rtl8xxxu: RF_T_METER is different on the newer chips
      rtl8xxxu: Set WLAN_ACT_CONTROL per vendor driver setting
      rtl8xxxu: 8723bu: REG_BT_COEX_TABLE4 is only 8 bits
      rtl8xxxu: Use name for REG_RFE_BUFFER rather than hard coded value
      rtl8xxxu: Use REG_RFE_CTRL_ANTA_SRC rather than hard coded value
      rtl8xxxu: Setup coex table correctly (hopefully)
      rtl8xxxu: Do not use hard-wired RF enable settings for 8723bu
      rtl8xxxu: Correct struct rtl8723bu_efuse to list power bases correctly
      rtl8xxxu: Introduce set_tx_power() fileop and a new 8723b dummy derivative
      rtl8xxxu: Use size of source pointer when copying efuse data
      rtl8xxxu: Bump TX power arrays to handle larger channel groups
      rtl8xxxu: Parse efuse power indices for 8723bu
      rtl8xxxu: Set 8723bu TX power for CCK and OFDM rates
      rtl8xxxu: Set 8723bu MCS TX power
      rtl8xxxu: Set the correct thermal meter register for 8723bu
      rtl8xxxu: Add definition for 8723bu tx descriptor
      rtl8xxxu: Handle 40 byte TX descriptors for rtl8723bu
      rtl8xxxu: Do not unconditionally print debug info in rtl8723bu_handle_c2h()
      rtl8xxxu: Add additional tx descriptor bits for data word 0
      rtl8xxxu: Add more 40 byte TX desc bit definitions
      rtl8xxxu: Set the correct TX descriptor bits for agg and break on 8723b
      rtl8xxxu: Set sequence number correctly for 40 byte TX descriptors
      rtl8723au: Update TX descriptor words 4 and 5 definitions
      rtl8xxxu: TX RTS rate is word 4 for 8723a
      rtl8xxxu: Improve handling of txdesc32 vs txdesc40 handling
      rtl8xxxu: Do not parse RX descriptor info for C2H packets
      rtl8xxxu: Define 8723b H2C ramask command structure
      rtl8xxxu: Implement basic 8723b specific update_rate_mask() function
      rtl8xxxu: Report media status using the correct H2C command for 8723bu
      rtl8xxxu: Dump contents of unhandled C2H events
      rtl8xxxu: Process C2H RA_REPORT events for 8723bu
      rtl8xxxu: Pass RX rate to rx_parse_phystats and enable phystats for rtl8723bu
      rtl8xxxu: Remove unncessary semicolon
      rtl8xxxu: convert rtl8723bu_init_bt() into rtl8723b_enable_rf()
      rtl8xxxu: Use define for REG_PWR_DATA bits
      rtl8xxxu: Implement 8723bu specific disable_rf() function
      rtl8xxxu: Implement device specific power_off function
      rtl8xxxu: Flush FIFO before powering down devices
      rtl8xxxu: Print a warning if flushing the FIFO fails
      rtl8xxxu: Use correct 8051 reset function for 8723b parts
      rtl8xxxu: Temporarily disable 8192eu device init

Johannes Berg (1):
      iwlwifi: mvm: don't try to offload AES-CMAC in AP/IBSS modes

Kalle Valo (1):
      Merge tag 'iwlwifi-next-for-kalle-2016-03-09_2' of https://git.kernel.org/.../iwlwifi/iwlwifi-next

Luca Coelho (1):
      iwlwifi: pcie: forbid RTPM on device removal

Matti Gottlieb (1):
      iwlwifi: mvm: ROC: cleanup time event info on FW failure

Sara Sharon (8):
      iwlwifi: pcie: refactor RXBs reclaiming code
      iwlwifi: pcie: set RB chunk size back to 64
      iwlwifi: refactor the code that reads the MAC address from the NVM
      iwlwifi: mvm: set the correct amsdu enum values
      iwlwifi: mvm: extend time event duration
      iwlwifi: mvm: turn off AMSDU bit in QoS control for de-aggregated AMSDUs
      iwlwifi: pcie: fine tune number of rxbs
      iwlwifi: add support for getting HW address from CSR

 .../wireless/broadcom/brcm80211/brcmfmac/pcie.c    |    6 +-
 drivers/net/wireless/intel/iwlwifi/dvm/main.c      |    8 +-
 drivers/net/wireless/intel/iwlwifi/iwl-9000.c      |    3 +-
 drivers/net/wireless/intel/iwlwifi/iwl-config.h    |    2 +
 drivers/net/wireless/intel/iwlwifi/iwl-csr.h       |   10 +
 .../wireless/intel/iwlwifi/iwl-devtrace-iwlwifi.h  |   27 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c       |   38 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fh.h        |    9 +-
 drivers/net/wireless/intel/iwlwifi/iwl-fw-file.h   |   11 +
 drivers/net/wireless/intel/iwlwifi/iwl-fw.h        |   13 +
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c |  146 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.h |    5 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c   |   42 +
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api-rx.h |    5 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c  |   14 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h       |    5 +-
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c       |   11 +-
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c       |  120 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rxmq.c      |   12 +
 .../net/wireless/intel/iwlwifi/mvm/time-event.c    |   15 +-
 .../net/wireless/intel/iwlwifi/mvm/time-event.h    |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c        |  177 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c        |   29 +-
 drivers/net/wireless/intel/iwlwifi/mvm/utils.c     |   28 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c      |   28 +
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h |    2 +-
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c       |  148 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c    |    6 -
 drivers/net/wireless/marvell/libertas/main.c       |    3 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   28 +-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.c   | 3524 +++++++++++++++++---
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu.h   |  691 +++-
 .../net/wireless/realtek/rtl8xxxu/rtl8xxxu_regs.h  |   97 +-
 drivers/net/wireless/ti/wl18xx/debugfs.c           |   66 +
 drivers/net/wireless/ti/wl18xx/event.c             |    3 +-
 drivers/net/wireless/ti/wlcore/init.c              |    5 +
 drivers/net/wireless/ti/wlcore/main.c              |    8 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |    1 +
 38 files changed, 4524 insertions(+), 824 deletions(-)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
