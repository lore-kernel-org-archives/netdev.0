From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Intel wireless microcode problem..
Date: Thu, 14 Aug 2014 09:05:55 -0600
Message-ID: <CA+55aFxdt-9e9X0EYCu2Ku8sSTspUGPk5qKa72XH63zrkdPthw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:39769 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755174AbaHNPF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2014 11:05:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, so it seems the current merge window introduces some horrid intel
microcode problem, because I don't seem to see this with 3.16. But
maybe that's just happenstance.

Any ideas? This fills up all the logs etc.

                      Linus

---

iwlwifi 0000:01:00.0: L1 Disabled; Enabling L0S
iwlwifi 0000:01:00.0: L1 Disabled; Enabling L0S
iwlwifi 0000:01:00.0: Microcode SW error detected.  Restarting 0x2000000.
iwlwifi 0000:01:00.0: CSR values:
iwlwifi 0000:01:00.0: (2nd byte of CSR_INT_COALESCING is CSR_INT_PERIODIC_REG)
iwlwifi 0000:01:00.0:        CSR_HW_IF_CONFIG_REG: 0X40489204
iwlwifi 0000:01:00.0:          CSR_INT_COALESCING: 0X80000040
iwlwifi 0000:01:00.0:                     CSR_INT: 0X00000000
iwlwifi 0000:01:00.0:                CSR_INT_MASK: 0X00000000
iwlwifi 0000:01:00.0:           CSR_FH_INT_STATUS: 0X00000000
iwlwifi 0000:01:00.0:                 CSR_GPIO_IN: 0X00000000
iwlwifi 0000:01:00.0:                   CSR_RESET: 0X00000000
iwlwifi 0000:01:00.0:                CSR_GP_CNTRL: 0X080403c5
iwlwifi 0000:01:00.0:                  CSR_HW_REV: 0X00000144
iwlwifi 0000:01:00.0:              CSR_EEPROM_REG: 0X00000000
iwlwifi 0000:01:00.0:               CSR_EEPROM_GP: 0X80000000
iwlwifi 0000:01:00.0:              CSR_OTP_GP_REG: 0X803a0000
iwlwifi 0000:01:00.0:                 CSR_GIO_REG: 0X00080044
iwlwifi 0000:01:00.0:            CSR_GP_UCODE_REG: 0X00000000
iwlwifi 0000:01:00.0:           CSR_GP_DRIVER_REG: 0X00000000
iwlwifi 0000:01:00.0:           CSR_UCODE_DRV_GP1: 0X00000000
iwlwifi 0000:01:00.0:           CSR_UCODE_DRV_GP2: 0X00000000
iwlwifi 0000:01:00.0:                 CSR_LED_REG: 0X00000060
iwlwifi 0000:01:00.0:        CSR_DRAM_INT_TBL_REG: 0X880d8e9d
iwlwifi 0000:01:00.0:        CSR_GIO_CHICKEN_BITS: 0X27800200
iwlwifi 0000:01:00.0:             CSR_ANA_PLL_CFG: 0Xd55555d5
iwlwifi 0000:01:00.0:      CSR_MONITOR_STATUS_REG: 0X3d0801bd
iwlwifi 0000:01:00.0:           CSR_HW_REV_WA_REG: 0X0001001a
iwlwifi 0000:01:00.0:        CSR_DBG_HPET_MEM_REG: 0Xffff0000
iwlwifi 0000:01:00.0: FH register values:
iwlwifi 0000:01:00.0:         FH_RSCSR_CHNL0_STTS_WPTR_REG: 0X0d42d300
iwlwifi 0000:01:00.0:        FH_RSCSR_CHNL0_RBDCB_BASE_REG: 0X00d42d20
iwlwifi 0000:01:00.0:                  FH_RSCSR_CHNL0_WPTR: 0X00000028
iwlwifi 0000:01:00.0:         FH_MEM_RCSR_CHNL0_CONFIG_REG: 0X80801114
iwlwifi 0000:01:00.0:          FH_MEM_RSSR_SHARED_CTRL_REG: 0X000000fc
iwlwifi 0000:01:00.0:            FH_MEM_RSSR_RX_STATUS_REG: 0X07030000
iwlwifi 0000:01:00.0:    FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
iwlwifi 0000:01:00.0:                FH_TSSR_TX_STATUS_REG: 0X07ff0001
iwlwifi 0000:01:00.0:                 FH_TSSR_TX_ERROR_REG: 0X00000000
iwlwifi 0000:01:00.0: Start IWL Error Log Dump:
iwlwifi 0000:01:00.0: Status: 0x00000000, count: 6
iwlwifi 0000:01:00.0: Loaded firmware version: 23.214.9.0
iwlwifi 0000:01:00.0: 0x0000277B | ADVANCED_SYSASSERT
iwlwifi 0000:01:00.0: 0x00A002A0 | uPc
iwlwifi 0000:01:00.0: 0x00000000 | branchlink1
iwlwifi 0000:01:00.0: 0x00000BA4 | branchlink2
iwlwifi 0000:01:00.0: 0x000166A4 | interruptlink1
iwlwifi 0000:01:00.0: 0x004C0648 | interruptlink2
iwlwifi 0000:01:00.0: 0x00000021 | data1
iwlwifi 0000:01:00.0: 0x00000016 | data2
iwlwifi 0000:01:00.0: 0xDEADBEEF | data3
iwlwifi 0000:01:00.0: 0x003CC2EC | beacon time
iwlwifi 0000:01:00.0: 0x00033D3D | tsf low
iwlwifi 0000:01:00.0: 0x00000000 | tsf hi
iwlwifi 0000:01:00.0: 0x00000000 | time gp1
iwlwifi 0000:01:00.0: 0x00033D3D | time gp2
iwlwifi 0000:01:00.0: 0x00000000 | time gp3
iwlwifi 0000:01:00.0: 0x000417D6 | uCode version
iwlwifi 0000:01:00.0: 0x00000144 | hw version
iwlwifi 0000:01:00.0: 0x40489204 | board version
iwlwifi 0000:01:00.0: 0x0000001C | hcmd
iwlwifi 0000:01:00.0: 0x00022000 | isr0
iwlwifi 0000:01:00.0: 0x01000000 | isr1
iwlwifi 0000:01:00.0: 0x00000002 | isr2
iwlwifi 0000:01:00.0: 0x004058C0 | isr3
iwlwifi 0000:01:00.0: 0x00000001 | isr4
iwlwifi 0000:01:00.0: 0x00000110 | isr_pref
iwlwifi 0000:01:00.0: 0x00000000 | wait_event
iwlwifi 0000:01:00.0: 0x00000850 | l2p_control
iwlwifi 0000:01:00.0: 0x00018000 | l2p_duration
iwlwifi 0000:01:00.0: 0x0000003F | l2p_mhvalid
iwlwifi 0000:01:00.0: 0x00000081 | l2p_addr_match
iwlwifi 0000:01:00.0: 0x00000005 | lmpm_pmg_sel
iwlwifi 0000:01:00.0: 0x18051651 | timestamp
iwlwifi 0000:01:00.0: 0x00002830 | flow_handler
ieee80211 phy0: Hardware restart was requested
iwlwifi 0000:01:00.0: L1 Disabled; Enabling L0S
iwlwifi 0000:01:00.0: L1 Disabled; Enabling L0S
iwlwifi 0000:01:00.0: Microcode SW error detected.  Restarting 0x2000000.
iwlwifi 0000:01:00.0: CSR values:
iwlwifi 0000:01:00.0: (2nd byte of CSR_INT_COALESCING is CSR_INT_PERIODIC_REG)
iwlwifi 0000:01:00.0:        CSR_HW_IF_CONFIG_REG: 0X40489204
iwlwifi 0000:01:00.0:          CSR_INT_COALESCING: 0X8000ff40
iwlwifi 0000:01:00.0:                     CSR_INT: 0X00000000
iwlwifi 0000:01:00.0:                CSR_INT_MASK: 0X00000000
iwlwifi 0000:01:00.0:           CSR_FH_INT_STATUS: 0X00000000
iwlwifi 0000:01:00.0:                 CSR_GPIO_IN: 0X00000000
iwlwifi 0000:01:00.0:                   CSR_RESET: 0X00000000
iwlwifi 0000:01:00.0:                CSR_GP_CNTRL: 0X080403cd
iwlwifi 0000:01:00.0:                  CSR_HW_REV: 0X00000144
iwlwifi 0000:01:00.0:              CSR_EEPROM_REG: 0X00000000
iwlwifi 0000:01:00.0:               CSR_EEPROM_GP: 0X80000000
iwlwifi 0000:01:00.0:              CSR_OTP_GP_REG: 0X803a0000
iwlwifi 0000:01:00.0:                 CSR_GIO_REG: 0X00080044
iwlwifi 0000:01:00.0:            CSR_GP_UCODE_REG: 0X00000000
iwlwifi 0000:01:00.0:           CSR_GP_DRIVER_REG: 0X00000000
iwlwifi 0000:01:00.0:           CSR_UCODE_DRV_GP1: 0X00000000
iwlwifi 0000:01:00.0:           CSR_UCODE_DRV_GP2: 0X00000000
iwlwifi 0000:01:00.0:                 CSR_LED_REG: 0X00000060
iwlwifi 0000:01:00.0:        CSR_DRAM_INT_TBL_REG: 0X880d8e9d
iwlwifi 0000:01:00.0:        CSR_GIO_CHICKEN_BITS: 0X27800200
iwlwifi 0000:01:00.0:             CSR_ANA_PLL_CFG: 0Xd55555d5
iwlwifi 0000:01:00.0:      CSR_MONITOR_STATUS_REG: 0X3d0801bd
iwlwifi 0000:01:00.0:           CSR_HW_REV_WA_REG: 0X0001001a
iwlwifi 0000:01:00.0:        CSR_DBG_HPET_MEM_REG: 0Xffff0000
iwlwifi 0000:01:00.0: FH register values:
iwlwifi 0000:01:00.0:         FH_RSCSR_CHNL0_STTS_WPTR_REG: 0X0d42d300
iwlwifi 0000:01:00.0:        FH_RSCSR_CHNL0_RBDCB_BASE_REG: 0X00d42d20
iwlwifi 0000:01:00.0:                  FH_RSCSR_CHNL0_WPTR: 0X00000018
iwlwifi 0000:01:00.0:         FH_MEM_RCSR_CHNL0_CONFIG_REG: 0X80801114
iwlwifi 0000:01:00.0:          FH_MEM_RSSR_SHARED_CTRL_REG: 0X000000fc
iwlwifi 0000:01:00.0:            FH_MEM_RSSR_RX_STATUS_REG: 0X07030000
iwlwifi 0000:01:00.0:    FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
iwlwifi 0000:01:00.0:                FH_TSSR_TX_STATUS_REG: 0X07ff0001
iwlwifi 0000:01:00.0:                 FH_TSSR_TX_ERROR_REG: 0X00000000
iwlwifi 0000:01:00.0: Start IWL Error Log Dump:
iwlwifi 0000:01:00.0: Status: 0x00000008, count: 6
iwlwifi 0000:01:00.0: Loaded firmware version: 23.214.9.0
iwlwifi 0000:01:00.0: 0x00003401 | ADVANCED_SYSASSERT
iwlwifi 0000:01:00.0: 0x000002F0 | uPc
iwlwifi 0000:01:00.0: 0x00000000 | branchlink1
iwlwifi 0000:01:00.0: 0x00000BA4 | branchlink2
iwlwifi 0000:01:00.0: 0x000166A4 | interruptlink1
iwlwifi 0000:01:00.0: 0x004C0648 | interruptlink2
iwlwifi 0000:01:00.0: 0x0000FF00 | data1
iwlwifi 0000:01:00.0: 0xFFFFFFFF | data2
iwlwifi 0000:01:00.0: 0xDEADBEEF | data3
iwlwifi 0000:01:00.0: 0x003FEE8D | beacon time
iwlwifi 0000:01:00.0: 0x00001172 | tsf low
iwlwifi 0000:01:00.0: 0x00000000 | tsf hi
iwlwifi 0000:01:00.0: 0x00000000 | time gp1
iwlwifi 0000:01:00.0: 0x00001173 | time gp2
iwlwifi 0000:01:00.0: 0x00000000 | time gp3
iwlwifi 0000:01:00.0: 0x000417D6 | uCode version
iwlwifi 0000:01:00.0: 0x00000144 | hw version
iwlwifi 0000:01:00.0: 0x40489204 | board version
iwlwifi 0000:01:00.0: 0x09190028 | hcmd
iwlwifi 0000:01:00.0: 0x00022080 | isr0
iwlwifi 0000:01:00.0: 0x00000000 | isr1
iwlwifi 0000:01:00.0: 0x00000002 | isr2
iwlwifi 0000:01:00.0: 0x004000C0 | isr3
iwlwifi 0000:01:00.0: 0x00000001 | isr4
iwlwifi 0000:01:00.0: 0x01000112 | isr_pref
iwlwifi 0000:01:00.0: 0x00000000 | wait_event
iwlwifi 0000:01:00.0: 0x00000850 | l2p_control
iwlwifi 0000:01:00.0: 0x00000000 | l2p_duration
iwlwifi 0000:01:00.0: 0x00000000 | l2p_mhvalid
iwlwifi 0000:01:00.0: 0x00000000 | l2p_addr_match
iwlwifi 0000:01:00.0: 0x00000007 | lmpm_pmg_sel
iwlwifi 0000:01:00.0: 0x18051651 | timestamp
iwlwifi 0000:01:00.0: 0x00001820 | flow_handler
iwlwifi 0000:01:00.0: Firmware error during reconfiguration - reprobe!
iwlwifi 0000:01:00.0: FW error in SYNC CMD MAC_CONTEXT_CMD



CPU: 0 PID: 748 Comm: kworker/0:4 Not tainted 3.16.0-10959-gf0094b28f303 #1
Hardware name: Sony Corporation SVP11213CXB/VAIO, BIOS R0270V7 05/17/2013
Workqueue: events ieee80211_restart_work [mac80211]
 ffff8800d42e7c10 ffffffff815b1809 ffff8800d9ef8000 ffffffffc0665430
 0000000000000286 0000000000000000 ffff8800d3d5d070 ffffffff81099e50
 ffff8800d42e7bb8 ffff8800d42e7bb8 ffff8800d42e7c10 ffff8800d42e7c60
Call Trace:
 [<ffffffff815b1809>] ? dump_stack+0x41/0x51
 [<ffffffffc0665430>] ? iwl_trans_pcie_send_hcmd+0x590/0x5a0 [iwlwifi]
 [<ffffffff81099e50>] ? prepare_to_wait_event+0xf0/0xf0
 [<ffffffffc078c818>] ? iwl_mvm_send_cmd+0x38/0xb0 [iwlmvm]
 [<ffffffffc078c8cc>] ? iwl_mvm_send_cmd_pdu+0x3c/0x50 [iwlmvm]
 [<ffffffffc078affe>] ? iwl_mvm_mac_ctxt_send_cmd+0x1e/0x50 [iwlmvm]
 [<ffffffffc078b895>] ? iwl_mvm_mac_ctxt_cmd_sta+0xd5/0x170 [iwlmvm]
 [<ffffffffc06646e0>] ? iwl_trans_pcie_txq_enable+0x260/0x400 [iwlwifi]
 [<ffffffffc078c314>] ? iwl_mvm_mac_ctxt_add+0x24/0xb0 [iwlmvm]
 [<ffffffffc0788005>] ? iwl_mvm_mac_add_interface+0xe5/0x290 [iwlmvm]
 [<ffffffffc0741a7b>] ? ieee80211_reconfig+0x4ab/0xd10 [mac80211]
 [<ffffffffc071a1e8>] ? ieee80211_restart_work+0x38/0x70 [mac80211]
 [<ffffffff81079cb0>] ? process_one_work+0x160/0x370
 [<ffffffff8107a274>] ? worker_thread+0x114/0x470
 [<ffffffff8107a160>] ? rescuer_thread+0x2a0/0x2a0
 [<ffffffff8107e728>] ? kthread+0xb8/0xd0
 [<ffffffff8107e670>] ? kthread_create_on_node+0x170/0x170
 [<ffffffff815b81ec>] ? ret_from_fork+0x7c/0xb0
 [<ffffffff8107e670>] ? kthread_create_on_node+0x170/0x170
iwlwifi 0000:01:00.0: Failed to send MAC context (action:1): -5
------------[ cut here ]------------
WARNING: CPU: 0 PID: 748 at
drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c:1177
iwl_mvm_mac_ctxt_changed+0x65/0x80 [iwlmvm]()
Changing inactive MAC 5c:51:4f:1e:c3:c8/2
Modules linked in: rfcomm fuse ip6t_rpfilter ip6t_REJECT xt_conntrack
ebtable_nat ebtable_broute bridge stp llc mmc_block ebtable_filter
ebtables ip6table_nat bnep nf_conntrack_ipv6 nf_defrag_ipv6
nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw
ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle
iptable_security iptable_raw vfat fat pn544_mei mei_phy pn544 hci nfc
rtsx_pci_sdmmc mmc_core snd_hda_codec_hdmi snd_hda_codec_realtek
iTCO_wdt snd_hda_codec_generic arc4 iTCO_vendor_support snd_hda_intel
snd_hda_controller iwlmvm snd_hda_codec snd_hwdep mac80211
x86_pkg_temp_thermal coretemp snd_seq microcode uvcvideo btusb
videobuf2_vmalloc videobuf2_memops joydev snd_seq_device
videobuf2_core bluetooth serio_raw i2c_i801
 v4l2_common iwlwifi snd_pcm videodev hid_multitouch media cfg80211
rtsx_pci mei_me lpc_ich snd_timer mei mfd_core snd shpchp soundcore
sony_laptop rfkill dm_crypt i915 crct10dif_pclmul crc32_pclmul
crc32c_intel i2c_algo_bit drm_kms_helper drm ghash_clmulni_intel video
CPU: 0 PID: 748 Comm: kworker/0:4 Not tainted 3.16.0-10959-gf0094b28f303 #1
Hardware name: Sony Corporation SVP11213CXB/VAIO, BIOS R0270V7 05/17/2013
Workqueue: events ieee80211_restart_work [mac80211]
 0000000000000009 ffffffff815b1809 ffff8800d42e7d20 ffffffff8106619d
 ffff8800d3c35a68 ffff8800d42e7d70 00000000000674ff ffff8800d933b310
 ffff8800d933b318 ffffffff81066207 ffffffffc07b06dd ffffffff00000028
Call Trace:
 [<ffffffff815b1809>] ? dump_stack+0x41/0x51
 [<ffffffff8106619d>] ? warn_slowpath_common+0x6d/0x90
 [<ffffffff81066207>] ? warn_slowpath_fmt+0x47/0x50
 [<ffffffffc073f305>] ?
ieee80211_iterate_active_interfaces_atomic+0x5/0x10 [mac80211]
 [<ffffffffc0785bb0>] ? iwl_mvm_recalc_multicast+0x30/0x60 [iwlmvm]
 [<ffffffffc078c405>] ? iwl_mvm_mac_ctxt_changed+0x65/0x80 [iwlmvm]
 [<ffffffffc0787acc>] ? iwl_mvm_bss_info_changed+0x12c/0x580 [iwlmvm]
 [<ffffffffc0741e6f>] ? ieee80211_reconfig+0x89f/0xd10 [mac80211]
 [<ffffffffc071a1e8>] ? ieee80211_restart_work+0x38/0x70 [mac80211]
 [<ffffffff81079cb0>] ? process_one_work+0x160/0x370
 [<ffffffff8107a274>] ? worker_thread+0x114/0x470
 [<ffffffff8107a160>] ? rescuer_thread+0x2a0/0x2a0
 [<ffffffff8107e728>] ? kthread+0xb8/0xd0
 [<ffffffff8107e670>] ? kthread_create_on_node+0x170/0x170
 [<ffffffff815b81ec>] ? ret_from_fork+0x7c/0xb0
 [<ffffffff8107e670>] ? kthread_create_on_node+0x170/0x170
---[ end trace 52195047d9637af6 ]---
iwlwifi 0000:01:00.0: failed to update MAC 5c:51:4f:1e:c3:c8
iwlwifi 0000:01:00.0: Failed to update the ctrl_kill_msk
iwlwifi 0000:01:00.0: Failed to send quota: -5
iwlwifi 0000:01:00.0: Failed to update quotas after restart (-5)
iwlwifi 0000:01:00.0: Failed to send flush command (-5)
------------[ cut here ]------------
WARNING: CPU: 0 PID: 748 at
drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c:1191
iwl_mvm_mac_ctxt_remove+0x120/0x140 [iwlmvm]()
Removing inactive MAC 5c:51:4f:1e:c3:c8/2
Modules linked in: rfcomm fuse ip6t_rpfilter ip6t_REJECT xt_conntrack
ebtable_nat ebtable_broute bridge stp llc mmc_block ebtable_filter
ebtables ip6table_nat bnep nf_conntrack_ipv6 nf_defrag_ipv6
nf_nat_ipv6 ip6table_mangle ip6table_security ip6table_raw
ip6table_filter ip6_tables iptable_nat nf_conntrack_ipv4
nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack iptable_mangle
iptable_security iptable_raw vfat fat pn544_mei mei_phy pn544 hci nfc
rtsx_pci_sdmmc mmc_core snd_hda_codec_hdmi snd_hda_codec_realtek
iTCO_wdt snd_hda_codec_generic arc4 iTCO_vendor_support snd_hda_intel
snd_hda_controller iwlmvm snd_hda_codec snd_hwdep mac80211
x86_pkg_temp_thermal coretemp snd_seq microcode uvcvideo btusb
videobuf2_vmalloc videobuf2_memops joydev snd_seq_device
videobuf2_core bluetooth serio_raw i2c_i801
 v4l2_common iwlwifi snd_pcm videodev hid_multitouch media cfg80211
rtsx_pci mei_me lpc_ich snd_timer mei mfd_core snd shpchp soundcore
sony_laptop rfkill dm_crypt i915 crct10dif_pclmul crc32_pclmul
crc32c_intel i2c_algo_bit drm_kms_helper drm ghash_clmulni_intel video
CPU: 0 PID: 748 Comm: kworker/0:4 Tainted: G        W
3.16.0-10959-gf0094b28f303 #1
Hardware name: Sony Corporation SVP11213CXB/VAIO, BIOS R0270V7 05/17/2013
Workqueue: events iwl_mvm_reprobe_wk [iwlmvm]
 0000000000000009 ffffffff815b1809 ffff8800d42e7ab0 ffffffff8106619d
 ffff8800d933b310 ffff8800d42e7b00 ffff8800d3c35a60 ffff8800d3c35a98
 ffff8800d3c354e8 ffffffff81066207 ffffffffc07b06fb 0000000000000028
Call Trace:
 [<ffffffff815b1809>] ? dump_stack+0x41/0x51
 [<ffffffff8106619d>] ? warn_slowpath_common+0x6d/0x90
 [<ffffffff81066207>] ? warn_slowpath_fmt+0x47/0x50
 [<ffffffff81099e80>] ? autoremove_wake_function+0x30/0x30
 [<ffffffff81196b85>] ? fsnotify_clear_marks_by_inode+0x25/0x110
 [<ffffffffc078c540>] ? iwl_mvm_mac_ctxt_remove+0x120/0x140 [iwlmvm]
 [<ffffffffc073f305>] ?
ieee80211_iterate_active_interfaces_atomic+0x5/0x10 [mac80211]
 [<ffffffffc079aae7>] ? iwl_mvm_power_update_mac+0x37/0x340 [iwlmvm]
 [<ffffffff8117cde6>] ? mnt_get_count+0x46/0x60
 [<ffffffff8117ce32>] ? mntput_no_expire+0x32/0x110
 [<ffffffffc0785ccc>] ? iwl_mvm_mac_remove_interface+0x8c/0x130 [iwlmvm]
 [<ffffffffc072b6db>] ? ieee80211_do_stop+0x4db/0x820 [mac80211]
 [<ffffffff814dfdc0>] ? dev_deactivate_many+0x200/0x250
 [<ffffffffc072ba31>] ? ieee80211_stop+0x11/0x20 [mac80211]
 [<ffffffff814bedf5>] ? __dev_close_many+0x85/0xd0
 [<ffffffff814beeb9>] ? dev_close_many+0x79/0x110
 [<ffffffff814c05f7>] ? rollback_registered_many+0x117/0x2c0
 [<ffffffff814c07f2>] ? unregister_netdevice_many+0x12/0xa0
 [<ffffffffc072d01b>] ? ieee80211_remove_interfaces+0x11b/0x1b0 [mac80211]
 [<ffffffffc071a882>] ? ieee80211_unregister_hw+0x52/0x110 [mac80211]
 [<ffffffffc078a425>] ? iwl_op_mode_mvm_stop+0x25/0x110 [iwlmvm]
 [<ffffffffc065c9d0>] ? _iwl_op_mode_stop.isra.13+0x20/0x40 [iwlwifi]
 [<ffffffffc065cc43>] ? iwl_drv_stop+0x23/0xa0 [iwlwifi]
 [<ffffffffc065ff54>] ? iwl_pci_remove+0x14/0x20 [iwlwifi]
 [<ffffffff812ca5ee>] ? pci_device_remove+0x2e/0xa0
 [<ffffffff8136dcc5>] ? __device_release_driver+0x75/0xf0
 [<ffffffff8136dd59>] ? device_release_driver+0x19/0x30
 [<ffffffff8136c917>] ? device_reprobe+0x27/0x50
 [<ffffffffc078a092>] ? iwl_mvm_reprobe_wk+0x12/0x40 [iwlmvm]
 [<ffffffff81079cb0>] ? process_one_work+0x160/0x370
 [<ffffffff8107a274>] ? worker_thread+0x114/0x470
 [<ffffffff8107a160>] ? rescuer_thread+0x2a0/0x2a0
 [<ffffffff8107e728>] ? kthread+0xb8/0xd0
 [<ffffffff8107e670>] ? kthread_create_on_node+0x170/0x170
 [<ffffffff815b81ec>] ? ret_from_fork+0x7c/0xb0
 [<ffffffff8107e670>] ? kthread_create_on_node+0x170/0x170
---[ end trace 52195047d9637af7 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 748 at
drivers/net/wireless/iwlwifi/pcie/tx.c:1171
iwl_trans_pcie_txq_disable+0x10c/0x140 [iwlwifi]()
queue 0 not used
Modules linked in:
 rfcomm fuse ip6t_rpfilter ip6t_REJECT xt_conntrack ebtable_nat
ebtable_broute bridge stp llc mmc_block ebtable_filter ebtables
ip6table_nat bnep nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6
ip6table_mangle ip6table_security ip6table_raw ip6table_filter
ip6_tables iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4
nf_nat nf_conntrack iptable_mangle iptable_security iptable_raw vfat
fat pn544_mei mei_phy pn544 hci nfc rtsx_pci_sdmmc mmc_core
snd_hda_codec_hdmi snd_hda_codec_realtek iTCO_wdt
snd_hda_codec_generic arc4 iTCO_vendor_support snd_hda_intel
snd_hda_controller iwlmvm snd_hda_codec snd_hwdep mac80211
x86_pkg_temp_thermal coretemp snd_seq microcode uvcvideo btusb
videobuf2_vmalloc videobuf2_memops joydev snd_seq_device
videobuf2_core bluetooth serio_raw i2c_i801 v4l2_common
 iwlwifi snd_pcm videodev hid_multitouch media cfg80211 rtsx_pci
mei_me lpc_ich snd_timer mei mfd_core snd shpchp soundcore sony_laptop
rfkill dm_crypt i915 crct10dif_pclmul crc32_pclmul crc32c_intel
i2c_algo_bit drm_kms_helper drm ghash_clmulni_intel video
CPU: 0 PID: 748 Comm: kworker/0:4 Tainted: G        W
3.16.0-10959-gf0094b28f303 #1
Hardware name: Sony Corporation SVP11213CXB/VAIO, BIOS R0270V7 05/17/2013
Workqueue: events iwl_mvm_reprobe_wk [iwlmvm]
 0000000000000009 ffffffff815b1809 ffff8800d42e7b18 ffffffff8106619d
 ffff8800d9ef8000 ffff8800d42e7b68 0000000000000000 ffff8800d3c35a98
 000000000080a000 ffffffff81066207 ffffffffc066d53a ffff880000000020
Call Trace:
 [<ffffffff815b1809>] ? dump_stack+0x41/0x51
 [<ffffffff8106619d>] ? warn_slowpath_common+0x6d/0x90
 [<ffffffff81066207>] ? warn_slowpath_fmt+0x47/0x50
 [<ffffffffc073f305>] ?
ieee80211_iterate_active_interfaces_atomic+0x5/0x10 [mac80211]
 [<ffffffffc079aae7>] ? iwl_mvm_power_update_mac+0x37/0x340 [iwlmvm]
 [<ffffffff8117cde6>] ? mnt_get_count+0x46/0x60
 [<ffffffffc066498c>] ? iwl_trans_pcie_txq_disable+0x10c/0x140 [iwlwifi]
 [<ffffffffc078c22f>] ? iwl_mvm_mac_ctxt_release+0x2f/0x80 [iwlmvm]
 [<ffffffffc0785cd7>] ? iwl_mvm_mac_remove_interface+0x97/0x130 [iwlmvm]
 [<ffffffffc072b6db>] ? ieee80211_do_stop+0x4db/0x820 [mac80211]
 [<ffffffff814dfdc0>] ? dev_deactivate_many+0x200/0x250
 [<ffffffffc072ba31>] ? ieee80211_stop+0x11/0x20 [mac80211]
 [<ffffffff814bedf5>] ? __dev_close_many+0x85/0xd0
 [<ffffffff814beeb9>] ? dev_close_many+0x79/0x110
 [<ffffffff814c05f7>] ? rollback_registered_many+0x117/0x2c0
 [<ffffffff814c07f2>] ? unregister_netdevice_many+0x12/0xa0
 [<ffffffffc072d01b>] ? ieee80211_remove_interfaces+0x11b/0x1b0 [mac80211]
 [<ffffffffc071a882>] ? ieee80211_unregister_hw+0x52/0x110 [mac80211]
 [<ffffffffc078a425>] ? iwl_op_mode_mvm_stop+0x25/0x110 [iwlmvm]
 [<ffffffffc065c9d0>] ? _iwl_op_mode_stop.isra.13+0x20/0x40 [iwlwifi]
 [<ffffffffc065cc43>] ? iwl_drv_stop+0x23/0xa0 [iwlwifi]
 [<ffffffffc065ff54>] ? iwl_pci_remove+0x14/0x20 [iwlwifi]
 [<ffffffff812ca5ee>] ? pci_device_remove+0x2e/0xa0
 [<ffffffff8136dcc5>] ? __device_release_driver+0x75/0xf0
 [<ffffffff8136dd59>] ? device_release_driver+0x19/0x30
 [<ffffffff8136c917>] ? device_reprobe+0x27/0x50
 [<ffffffffc078a092>] ? iwl_mvm_reprobe_wk+0x12/0x40 [iwlmvm]
 [<ffffffff81079cb0>] ? process_one_work+0x160/0x370
 [<ffffffff8107a274>] ? worker_thread+0x114/0x470
 [<ffffffff8107a160>] ? rescuer_thread+0x2a0/0x2a0
 [<ffffffff8107e728>] ? kthread+0xb8/0xd0
 [<ffffffff8107e670>] ? kthread_create_on_node+0x170/0x170
 [<ffffffff815b81ec>] ? ret_from_fork+0x7c/0xb0
 [<ffffffff8107e670>] ? kthread_create_on_node+0x170/0x170
---[ end trace 52195047d9637af8 ]---
iwlwifi 0000:01:00.0: irq 45 for MSI/MSI-X
iwlwifi 0000:01:00.0: loaded firmware version 23.214.9.0 op_mode iwlmvm
iwlwifi 0000:01:00.0: Detected Intel(R) Dual Band Wireless N 7260, REV=0x144
iwlwifi 0000:01:00.0: L1 Disabled; Enabling L0S
iwlwifi 0000:01:00.0: L1 Disabled; Enabling L0S
ieee80211 phy1: Selected rate control algorithm 'iwl-mvm-rs'
iwlwifi 0000:01:00.0 wlp1s0: renamed from wlan0
systemd-udevd[2662]: renamed network interface wlan0 to wlp1s0
iwlwifi 0000:01:00.0: L1 Disabled; Enabling L0S
iwlwifi 0000:01:00.0: L1 Disabled; Enabling L0S
IPv6: ADDRCONF(NETDEV_UP): wlp1s0: link is not ready
iwlwifi 0000:01:00.0: RF_KILL bit toggled to disable radio.
