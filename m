From: Shan Wei <shanwei-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2011-02-22
Date: Fri, 04 Mar 2011 12:35:58 +0800
Message-ID: <4D706C2E.40307@cn.fujitsu.com>
References: <20110222215229.GJ12153@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070607070904080106030202"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110222215229.GJ12153-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--------------070607070904080106030202
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8

John W. Linville wrote, at 02/23/2011 05:52 AM:
> Please let me know if there are problems!

Fail to compile with attached config under net-next tree.
 
======Error Begin================================================================
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_sw_chnl':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:803: multiple definition of `rtl92c_phy_sw_chnl'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:803: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_fill_h2c_cmd':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192ce/fw.c:504: multiple definition of `rtl92c_fill_h2c_cmd'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/fw.c:504: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_rf6052_set_ofdm_txpower':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c:393: multiple definition of `rtl92c_phy_rf6052_set_ofdm_txpower'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c:415: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_sw_chnl_callback':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:775: multiple definition of `rtl92c_phy_sw_chnl_callback'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:775: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_query_bb_reg':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:69: multiple definition of `rtl92c_phy_query_bb_reg'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:69: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_set_io':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:1981: multiple definition of `rtl92c_phy_set_io'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:1981: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_get_hw_reg_originalvalue':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:415: multiple definition of `rtl92c_phy_get_hw_reg_originalvalue'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:415: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92ce_phy_set_rf_on':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:2010: multiple definition of `rtl92ce_phy_set_rf_on'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:2010: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl8192_phy_check_is_legal_rfpath':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:961: multiple definition of `rtl8192_phy_check_is_legal_rfpath'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:961: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_dm_init_edca_turbo':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/dm_common.c:552: multiple definition of `dm_digtable'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../wifi.h:1793: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_set_bw_mode_callback':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c:356: multiple definition of `rtl92c_phy_set_bw_mode_callback'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c:371: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_query_rf_reg':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c:44: multiple definition of `rtl92c_phy_query_rf_reg'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c:44: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_scan_operation_backup':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:725: multiple definition of `rtl92c_phy_scan_operation_backup'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:725: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_rf_config':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:224: multiple definition of `rtl92c_phy_rf_config'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:224: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_rf6052_set_cck_txpower':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c:66: multiple definition of `rtl92c_phy_rf6052_set_cck_txpower'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c:66: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_dm_dynamic_txpower':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/dm.c:41: multiple definition of `rtl92c_dm_dynamic_txpower'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/dm.c:41: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_bb_config':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c:121: multiple definition of `rtl92c_phy_bb_config'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c:138: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_set_io_cmd':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:1943: multiple definition of `rtl92c_phy_set_io_cmd'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:1943: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_config_rf_with_headerfile':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c:268: multiple definition of `rtl92c_phy_config_rf_with_headerfile'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c:281: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_mac_config':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c:108: multiple definition of `rtl92c_phy_mac_config'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c:126: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_download_fw':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192ce/fw.c:224: multiple definition of `rtl92c_download_fw'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/fw.c:224: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_set_fw_joinbss_report_cmd':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192ce/fw.c:763: multiple definition of `rtl92c_set_fw_joinbss_report_cmd'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/fw.c:763: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_dm_write_dig':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/dm_common.c:502: multiple definition of `rtl92c_dm_write_dig'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/dm_common.c:502: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_set_fw_pwrmode_cmd':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192ce/fw.c:542: multiple definition of `rtl92c_set_fw_pwrmode_cmd'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/fw.c:542: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_dm_rf_saving':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/dm_common.c:1245: multiple definition of `rtl92c_dm_rf_saving'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/dm_common.c:1245: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_firmware_selfreset':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192ce/fw.c:522: multiple definition of `rtl92c_firmware_selfreset'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/fw.c:522: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_rf6052_set_bandwidth':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c:40: multiple definition of `rtl92c_phy_rf6052_set_bandwidth'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c:40: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_set_bb_reg':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:90: multiple definition of `rtl92c_phy_set_bb_reg'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:90: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_rf6052_config':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/rf.c:410: multiple definition of `rtl92c_phy_rf6052_config'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/rf.c:434: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_set_rf_power_state':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c:603: multiple definition of `rtl92c_phy_set_rf_power_state'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c:622: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_dm_init':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/dm_common.c:1352: multiple definition of `rtl92c_dm_init'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/dm_common.c:1352: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_iq_calibrate':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:1783: multiple definition of `rtl92c_phy_iq_calibrate'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:1783: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_dm_init_edca_turbo':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/dm_common.c:551: multiple definition of `rtl92c_dm_init_edca_turbo'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/dm_common.c:551: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_set_beacon_hw_reg':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:667: multiple definition of `rtl92c_phy_set_beacon_hw_reg'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:667: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_lc_calibrate':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:1906: multiple definition of `rtl92c_phy_lc_calibrate'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:1906: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_set_bw_mode':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:755: multiple definition of `rtl92c_phy_set_bw_mode'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:755: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_update_txpower_dbm':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:633: multiple definition of `rtl92c_phy_update_txpower_dbm'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:633: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_dm_init_rate_adaptive_mask':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/dm_common.c:1108: multiple definition of `rtl92c_dm_init_rate_adaptive_mask'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/dm_common.c:1108: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_dm_watchdog':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/dm_common.c:1365: multiple definition of `rtl92c_dm_watchdog'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/dm_common.c:1365: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_dm_check_txpower_tracking':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/dm_common.c:1103: multiple definition of `rtl92c_dm_check_txpower_tracking'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/dm_common.c:1103: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_set_fw_rsvdpagepkt':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192ce/fw.c:679: multiple definition of `rtl92c_set_fw_rsvdpagepkt'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/fw.c:679: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_get_txpower_level':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:552: multiple definition of `rtl92c_phy_get_txpower_level'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:552: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_set_txpower_level':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:617: multiple definition of `rtl92c_phy_set_txpower_level'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:617: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_config_bb_external_pa':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:269: multiple definition of `rtl92c_phy_config_bb_external_pa'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:269: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_ap_calibrate':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:1919: multiple definition of `rtl92c_phy_ap_calibrate'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:1919: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_set_rfpath_switch':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/../rtl8192c/phy_common.c:1933: multiple definition of `rtl92c_phy_set_rfpath_switch'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/../rtl8192c/phy_common.c:1933: first defined here
drivers/net/wireless/rtlwifi/rtl8192cu/built-in.o: In function `rtl92c_phy_set_rf_reg':
/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192cu/phy.c:71: multiple definition of `rtl92c_phy_set_rf_reg'
drivers/net/wireless/rtlwifi/rtl8192ce/built-in.o:/data2/net-next-2.6/drivers/net/wireless/rtlwifi/rtl8192ce/phy.c:80: first defined here
  CC      drivers/net/tlan.o
make[4]: *** [drivers/net/wireless/rtlwifi/built-in.o] Error 1
make[3]: *** [drivers/net/wireless/rtlwifi] Error 2
make[2]: *** [drivers/net/wireless] Error 2
make[2]: *** Waiting for unfinished jobs....
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2
 

--------------070607070904080106030202
Content-Type: text/plain;
 name="config"
Content-Disposition: attachment;
 filename="config"
Content-Transfer-Encoding: quoted-printable

#=0A# Automatically generated make config: don't edit=0A# Linux/x86=5F64 2.=
6.38-rc5 Kernel Configuration=0A# Fri Mar  4 21:31:47 2011=0A#=0ACONFIG=5F6=
4BIT=3Dy=0A# CONFIG=5FX86=5F32 is not set=0ACONFIG=5FX86=5F64=3Dy=0ACONFIG=
=5FX86=3Dy=0ACONFIG=5FINSTRUCTION=5FDECODER=3Dy=0ACONFIG=5FOUTPUT=5FFORMAT=
=3D"elf64-x86-64"=0ACONFIG=5FARCH=5FDEFCONFIG=3D"arch/x86/configs/x86=5F64=
=5Fdefconfig"=0ACONFIG=5FGENERIC=5FCMOS=5FUPDATE=3Dy=0ACONFIG=5FCLOCKSOURCE=
=5FWATCHDOG=3Dy=0ACONFIG=5FGENERIC=5FCLOCKEVENTS=3Dy=0ACONFIG=5FGENERIC=5FC=
LOCKEVENTS=5FBROADCAST=3Dy=0ACONFIG=5FLOCKDEP=5FSUPPORT=3Dy=0ACONFIG=5FSTAC=
KTRACE=5FSUPPORT=3Dy=0ACONFIG=5FHAVE=5FLATENCYTOP=5FSUPPORT=3Dy=0ACONFIG=5F=
MMU=3Dy=0ACONFIG=5FZONE=5FDMA=3Dy=0ACONFIG=5FNEED=5FDMA=5FMAP=5FSTATE=3Dy=
=0ACONFIG=5FNEED=5FSG=5FDMA=5FLENGTH=3Dy=0ACONFIG=5FGENERIC=5FISA=5FDMA=3Dy=
=0ACONFIG=5FGENERIC=5FIOMAP=3Dy=0ACONFIG=5FGENERIC=5FBUG=3Dy=0ACONFIG=5FGEN=
ERIC=5FBUG=5FRELATIVE=5FPOINTERS=3Dy=0ACONFIG=5FGENERIC=5FHWEIGHT=3Dy=0ACON=
FIG=5FGENERIC=5FGPIO=3Dy=0ACONFIG=5FARCH=5FMAY=5FHAVE=5FPC=5FFDC=3Dy=0A# CO=
NFIG=5FRWSEM=5FGENERIC=5FSPINLOCK is not set=0ACONFIG=5FRWSEM=5FXCHGADD=5FA=
LGORITHM=3Dy=0ACONFIG=5FARCH=5FHAS=5FCPU=5FIDLE=5FWAIT=3Dy=0ACONFIG=5FGENER=
IC=5FCALIBRATE=5FDELAY=3Dy=0ACONFIG=5FGENERIC=5FTIME=5FVSYSCALL=3Dy=0ACONFI=
G=5FARCH=5FHAS=5FCPU=5FRELAX=3Dy=0ACONFIG=5FARCH=5FHAS=5FDEFAULT=5FIDLE=3Dy=
=0ACONFIG=5FARCH=5FHAS=5FCACHE=5FLINE=5FSIZE=3Dy=0ACONFIG=5FHAVE=5FSETUP=5F=
PER=5FCPU=5FAREA=3Dy=0ACONFIG=5FNEED=5FPER=5FCPU=5FEMBED=5FFIRST=5FCHUNK=3D=
y=0ACONFIG=5FNEED=5FPER=5FCPU=5FPAGE=5FFIRST=5FCHUNK=3Dy=0ACONFIG=5FHAVE=5F=
CPUMASK=5FOF=5FCPU=5FMAP=3Dy=0ACONFIG=5FARCH=5FHIBERNATION=5FPOSSIBLE=3Dy=
=0ACONFIG=5FARCH=5FSUSPEND=5FPOSSIBLE=3Dy=0ACONFIG=5FZONE=5FDMA32=3Dy=0ACON=
FIG=5FARCH=5FPOPULATES=5FNODE=5FMAP=3Dy=0ACONFIG=5FAUDIT=5FARCH=3Dy=0ACONFI=
G=5FARCH=5FSUPPORTS=5FOPTIMIZED=5FINLINING=3Dy=0ACONFIG=5FARCH=5FSUPPORTS=
=5FDEBUG=5FPAGEALLOC=3Dy=0ACONFIG=5FHAVE=5FINTEL=5FTXT=3Dy=0ACONFIG=5FX86=
=5F64=5FSMP=3Dy=0ACONFIG=5FX86=5FHT=3Dy=0ACONFIG=5FX86=5FTRAMPOLINE=3Dy=0AC=
ONFIG=5FARCH=5FHWEIGHT=5FCFLAGS=3D"-fcall-saved-rdi -fcall-saved-rsi -fcall=
-saved-rdx -fcall-saved-rcx -fcall-saved-r8 -fcall-saved-r9 -fcall-saved-r1=
0 -fcall-saved-r11"=0A# CONFIG=5FKTIME=5FSCALAR is not set=0ACONFIG=5FARCH=
=5FCPU=5FPROBE=5FRELEASE=3Dy=0ACONFIG=5FDEFCONFIG=5FLIST=3D"/lib/modules/$U=
NAME=5FRELEASE/.config"=0ACONFIG=5FCONSTRUCTORS=3Dy=0ACONFIG=5FHAVE=5FIRQ=
=5FWORK=3Dy=0ACONFIG=5FIRQ=5FWORK=3Dy=0A=0A#=0A# General setup=0A#=0ACONFIG=
=5FEXPERIMENTAL=3Dy=0ACONFIG=5FLOCK=5FKERNEL=3Dy=0ACONFIG=5FINIT=5FENV=5FAR=
G=5FLIMIT=3D32=0ACONFIG=5FCROSS=5FCOMPILE=3D""=0ACONFIG=5FLOCALVERSION=3D""=
=0ACONFIG=5FLOCALVERSION=5FAUTO=3Dy=0ACONFIG=5FHAVE=5FKERNEL=5FGZIP=3Dy=0AC=
ONFIG=5FHAVE=5FKERNEL=5FBZIP2=3Dy=0ACONFIG=5FHAVE=5FKERNEL=5FLZMA=3Dy=0ACON=
FIG=5FHAVE=5FKERNEL=5FXZ=3Dy=0ACONFIG=5FHAVE=5FKERNEL=5FLZO=3Dy=0ACONFIG=5F=
KERNEL=5FGZIP=3Dy=0A# CONFIG=5FKERNEL=5FBZIP2 is not set=0A# CONFIG=5FKERNE=
L=5FLZMA is not set=0A# CONFIG=5FKERNEL=5FXZ is not set=0A# CONFIG=5FKERNEL=
=5FLZO is not set=0ACONFIG=5FSWAP=3Dy=0ACONFIG=5FSYSVIPC=3Dy=0ACONFIG=5FSYS=
VIPC=5FSYSCTL=3Dy=0ACONFIG=5FPOSIX=5FMQUEUE=3Dy=0ACONFIG=5FPOSIX=5FMQUEUE=
=5FSYSCTL=3Dy=0ACONFIG=5FBSD=5FPROCESS=5FACCT=3Dy=0ACONFIG=5FBSD=5FPROCESS=
=5FACCT=5FV3=3Dy=0ACONFIG=5FTASKSTATS=3Dy=0ACONFIG=5FTASK=5FDELAY=5FACCT=3D=
y=0ACONFIG=5FTASK=5FXACCT=3Dy=0ACONFIG=5FTASK=5FIO=5FACCOUNTING=3Dy=0ACONFI=
G=5FAUDIT=3Dy=0ACONFIG=5FAUDITSYSCALL=3Dy=0ACONFIG=5FAUDIT=5FWATCH=3Dy=0ACO=
NFIG=5FAUDIT=5FTREE=3Dy=0ACONFIG=5FHAVE=5FGENERIC=5FHARDIRQS=3Dy=0A=0A#=0A#=
 IRQ subsystem=0A#=0ACONFIG=5FGENERIC=5FHARDIRQS=3Dy=0A# CONFIG=5FGENERIC=
=5FHARDIRQS=5FNO=5FDEPRECATED is not set=0ACONFIG=5FHAVE=5FSPARSE=5FIRQ=3Dy=
=0ACONFIG=5FGENERIC=5FIRQ=5FPROBE=3Dy=0ACONFIG=5FGENERIC=5FPENDING=5FIRQ=3D=
y=0A# CONFIG=5FAUTO=5FIRQ=5FAFFINITY is not set=0A# CONFIG=5FIRQ=5FPER=5FCP=
U is not set=0A# CONFIG=5FHARDIRQS=5FSW=5FRESEND is not set=0ACONFIG=5FSPAR=
SE=5FIRQ=3Dy=0A=0A#=0A# RCU Subsystem=0A#=0ACONFIG=5FTREE=5FRCU=3Dy=0A# CON=
FIG=5FPREEMPT=5FRCU is not set=0ACONFIG=5FRCU=5FTRACE=3Dy=0ACONFIG=5FRCU=5F=
FANOUT=3D64=0ACONFIG=5FRCU=5FFANOUT=5FEXACT=3Dy=0ACONFIG=5FRCU=5FFAST=5FNO=
=5FHZ=3Dy=0ACONFIG=5FTREE=5FRCU=5FTRACE=3Dy=0ACONFIG=5FIKCONFIG=3Dy=0ACONFI=
G=5FIKCONFIG=5FPROC=3Dy=0ACONFIG=5FLOG=5FBUF=5FSHIFT=3D17=0ACONFIG=5FHAVE=
=5FUNSTABLE=5FSCHED=5FCLOCK=3Dy=0ACONFIG=5FCGROUPS=3Dy=0ACONFIG=5FCGROUP=5F=
DEBUG=3Dy=0ACONFIG=5FCGROUP=5FNS=3Dy=0ACONFIG=5FCGROUP=5FFREEZER=3Dy=0ACONF=
IG=5FCGROUP=5FDEVICE=3Dy=0ACONFIG=5FCPUSETS=3Dy=0ACONFIG=5FPROC=5FPID=5FCPU=
SET=3Dy=0ACONFIG=5FCGROUP=5FCPUACCT=3Dy=0ACONFIG=5FRESOURCE=5FCOUNTERS=3Dy=
=0ACONFIG=5FCGROUP=5FMEM=5FRES=5FCTLR=3Dy=0ACONFIG=5FCGROUP=5FMEM=5FRES=5FC=
TLR=5FSWAP=3Dy=0ACONFIG=5FCGROUP=5FMEM=5FRES=5FCTLR=5FSWAP=5FENABLED=3Dy=0A=
CONFIG=5FCGROUP=5FSCHED=3Dy=0ACONFIG=5FFAIR=5FGROUP=5FSCHED=3Dy=0ACONFIG=5F=
RT=5FGROUP=5FSCHED=3Dy=0ACONFIG=5FBLK=5FCGROUP=3Dy=0ACONFIG=5FDEBUG=5FBLK=
=5FCGROUP=3Dy=0ACONFIG=5FNAMESPACES=3Dy=0ACONFIG=5FUTS=5FNS=3Dy=0ACONFIG=5F=
IPC=5FNS=3Dy=0ACONFIG=5FUSER=5FNS=3Dy=0ACONFIG=5FPID=5FNS=3Dy=0ACONFIG=5FNE=
T=5FNS=3Dy=0ACONFIG=5FSCHED=5FAUTOGROUP=3Dy=0ACONFIG=5FMM=5FOWNER=3Dy=0ACON=
FIG=5FSYSFS=5FDEPRECATED=3Dy=0ACONFIG=5FSYSFS=5FDEPRECATED=5FV2=3Dy=0ACONFI=
G=5FRELAY=3Dy=0ACONFIG=5FBLK=5FDEV=5FINITRD=3Dy=0ACONFIG=5FINITRAMFS=5FSOUR=
CE=3D""=0ACONFIG=5FRD=5FGZIP=3Dy=0ACONFIG=5FRD=5FBZIP2=3Dy=0ACONFIG=5FRD=5F=
LZMA=3Dy=0ACONFIG=5FRD=5FXZ=3Dy=0ACONFIG=5FRD=5FLZO=3Dy=0ACONFIG=5FCC=5FOPT=
IMIZE=5FFOR=5FSIZE=3Dy=0ACONFIG=5FSYSCTL=3Dy=0ACONFIG=5FANON=5FINODES=3Dy=
=0ACONFIG=5FEXPERT=3Dy=0ACONFIG=5FEMBEDDED=3Dy=0ACONFIG=5FUID16=3Dy=0ACONFI=
G=5FSYSCTL=5FSYSCALL=3Dy=0ACONFIG=5FKALLSYMS=3Dy=0ACONFIG=5FKALLSYMS=5FALL=
=3Dy=0ACONFIG=5FKALLSYMS=5FEXTRA=5FPASS=3Dy=0ACONFIG=5FHOTPLUG=3Dy=0ACONFIG=
=5FPRINTK=3Dy=0ACONFIG=5FBUG=3Dy=0ACONFIG=5FELF=5FCORE=3Dy=0ACONFIG=5FPCSPK=
R=5FPLATFORM=3Dy=0ACONFIG=5FBASE=5FFULL=3Dy=0ACONFIG=5FFUTEX=3Dy=0ACONFIG=
=5FEPOLL=3Dy=0ACONFIG=5FSIGNALFD=3Dy=0ACONFIG=5FTIMERFD=3Dy=0ACONFIG=5FEVEN=
TFD=3Dy=0ACONFIG=5FSHMEM=3Dy=0ACONFIG=5FAIO=3Dy=0ACONFIG=5FHAVE=5FPERF=5FEV=
ENTS=3Dy=0ACONFIG=5FPERF=5FUSE=5FVMALLOC=3Dy=0A=0A#=0A# Kernel Performance =
Events And Counters=0A#=0ACONFIG=5FPERF=5FEVENTS=3Dy=0ACONFIG=5FPERF=5FCOUN=
TERS=3Dy=0ACONFIG=5FDEBUG=5FPERF=5FUSE=5FVMALLOC=3Dy=0ACONFIG=5FVM=5FEVENT=
=5FCOUNTERS=3Dy=0ACONFIG=5FPCI=5FQUIRKS=3Dy=0ACONFIG=5FSLUB=5FDEBUG=3Dy=0AC=
ONFIG=5FCOMPAT=5FBRK=3Dy=0A# CONFIG=5FSLAB is not set=0ACONFIG=5FSLUB=3Dy=
=0A# CONFIG=5FSLOB is not set=0ACONFIG=5FPROFILING=3Dy=0ACONFIG=5FTRACEPOIN=
TS=3Dy=0ACONFIG=5FOPROFILE=3Dy=0ACONFIG=5FOPROFILE=5FEVENT=5FMULTIPLEX=3Dy=
=0ACONFIG=5FHAVE=5FOPROFILE=3Dy=0ACONFIG=5FKPROBES=3Dy=0ACONFIG=5FJUMP=5FLA=
BEL=3Dy=0ACONFIG=5FOPTPROBES=3Dy=0ACONFIG=5FHAVE=5FEFFICIENT=5FUNALIGNED=5F=
ACCESS=3Dy=0ACONFIG=5FKRETPROBES=3Dy=0ACONFIG=5FUSER=5FRETURN=5FNOTIFIER=3D=
y=0ACONFIG=5FHAVE=5FIOREMAP=5FPROT=3Dy=0ACONFIG=5FHAVE=5FKPROBES=3Dy=0ACONF=
IG=5FHAVE=5FKRETPROBES=3Dy=0ACONFIG=5FHAVE=5FOPTPROBES=3Dy=0ACONFIG=5FHAVE=
=5FARCH=5FTRACEHOOK=3Dy=0ACONFIG=5FHAVE=5FDMA=5FATTRS=3Dy=0ACONFIG=5FUSE=5F=
GENERIC=5FSMP=5FHELPERS=3Dy=0ACONFIG=5FHAVE=5FREGS=5FAND=5FSTACK=5FACCESS=
=5FAPI=3Dy=0ACONFIG=5FHAVE=5FDMA=5FAPI=5FDEBUG=3Dy=0ACONFIG=5FHAVE=5FHW=5FB=
REAKPOINT=3Dy=0ACONFIG=5FHAVE=5FMIXED=5FBREAKPOINTS=5FREGS=3Dy=0ACONFIG=5FH=
AVE=5FUSER=5FRETURN=5FNOTIFIER=3Dy=0ACONFIG=5FHAVE=5FPERF=5FEVENTS=5FNMI=3D=
y=0ACONFIG=5FHAVE=5FARCH=5FJUMP=5FLABEL=3Dy=0A=0A#=0A# GCOV-based kernel pr=
ofiling=0A#=0ACONFIG=5FGCOV=5FKERNEL=3Dy=0ACONFIG=5FGCOV=5FPROFILE=5FALL=3D=
y=0A# CONFIG=5FHAVE=5FGENERIC=5FDMA=5FCOHERENT is not set=0ACONFIG=5FSLABIN=
FO=3Dy=0ACONFIG=5FRT=5FMUTEXES=3Dy=0ACONFIG=5FBASE=5FSMALL=3D0=0ACONFIG=5FM=
ODULES=3Dy=0ACONFIG=5FMODULE=5FFORCE=5FLOAD=3Dy=0ACONFIG=5FMODULE=5FUNLOAD=
=3Dy=0ACONFIG=5FMODULE=5FFORCE=5FUNLOAD=3Dy=0ACONFIG=5FMODVERSIONS=3Dy=0ACO=
NFIG=5FMODULE=5FSRCVERSION=5FALL=3Dy=0ACONFIG=5FSTOP=5FMACHINE=3Dy=0ACONFIG=
=5FBLOCK=3Dy=0ACONFIG=5FBLK=5FDEV=5FBSG=3Dy=0ACONFIG=5FBLK=5FDEV=5FINTEGRIT=
Y=3Dy=0ACONFIG=5FBLK=5FDEV=5FTHROTTLING=3Dy=0ACONFIG=5FBLOCK=5FCOMPAT=3Dy=
=0A=0A#=0A# IO Schedulers=0A#=0ACONFIG=5FIOSCHED=5FNOOP=3Dy=0ACONFIG=5FIOSC=
HED=5FDEADLINE=3Dy=0ACONFIG=5FIOSCHED=5FCFQ=3Dy=0ACONFIG=5FCFQ=5FGROUP=5FIO=
SCHED=3Dy=0A# CONFIG=5FDEFAULT=5FDEADLINE is not set=0ACONFIG=5FDEFAULT=5FC=
FQ=3Dy=0A# CONFIG=5FDEFAULT=5FNOOP is not set=0ACONFIG=5FDEFAULT=5FIOSCHED=
=3D"cfq"=0ACONFIG=5FPREEMPT=5FNOTIFIERS=3Dy=0ACONFIG=5FPADATA=3Dy=0A# CONFI=
G=5FINLINE=5FSPIN=5FTRYLOCK is not set=0A# CONFIG=5FINLINE=5FSPIN=5FTRYLOCK=
=5FBH is not set=0A# CONFIG=5FINLINE=5FSPIN=5FLOCK is not set=0A# CONFIG=5F=
INLINE=5FSPIN=5FLOCK=5FBH is not set=0A# CONFIG=5FINLINE=5FSPIN=5FLOCK=5FIR=
Q is not set=0A# CONFIG=5FINLINE=5FSPIN=5FLOCK=5FIRQSAVE is not set=0A# CON=
FIG=5FINLINE=5FSPIN=5FUNLOCK is not set=0A# CONFIG=5FINLINE=5FSPIN=5FUNLOCK=
=5FBH is not set=0A# CONFIG=5FINLINE=5FSPIN=5FUNLOCK=5FIRQ is not set=0A# C=
ONFIG=5FINLINE=5FSPIN=5FUNLOCK=5FIRQRESTORE is not set=0A# CONFIG=5FINLINE=
=5FREAD=5FTRYLOCK is not set=0A# CONFIG=5FINLINE=5FREAD=5FLOCK is not set=
=0A# CONFIG=5FINLINE=5FREAD=5FLOCK=5FBH is not set=0A# CONFIG=5FINLINE=5FRE=
AD=5FLOCK=5FIRQ is not set=0A# CONFIG=5FINLINE=5FREAD=5FLOCK=5FIRQSAVE is n=
ot set=0A# CONFIG=5FINLINE=5FREAD=5FUNLOCK is not set=0A# CONFIG=5FINLINE=
=5FREAD=5FUNLOCK=5FBH is not set=0A# CONFIG=5FINLINE=5FREAD=5FUNLOCK=5FIRQ =
is not set=0A# CONFIG=5FINLINE=5FREAD=5FUNLOCK=5FIRQRESTORE is not set=0A# =
CONFIG=5FINLINE=5FWRITE=5FTRYLOCK is not set=0A# CONFIG=5FINLINE=5FWRITE=5F=
LOCK is not set=0A# CONFIG=5FINLINE=5FWRITE=5FLOCK=5FBH is not set=0A# CONF=
IG=5FINLINE=5FWRITE=5FLOCK=5FIRQ is not set=0A# CONFIG=5FINLINE=5FWRITE=5FL=
OCK=5FIRQSAVE is not set=0A# CONFIG=5FINLINE=5FWRITE=5FUNLOCK is not set=0A=
# CONFIG=5FINLINE=5FWRITE=5FUNLOCK=5FBH is not set=0A# CONFIG=5FINLINE=5FWR=
ITE=5FUNLOCK=5FIRQ is not set=0A# CONFIG=5FINLINE=5FWRITE=5FUNLOCK=5FIRQRES=
TORE is not set=0A# CONFIG=5FMUTEX=5FSPIN=5FON=5FOWNER is not set=0ACONFIG=
=5FFREEZER=3Dy=0A=0A#=0A# Processor type and features=0A#=0ACONFIG=5FTICK=
=5FONESHOT=3Dy=0ACONFIG=5FNO=5FHZ=3Dy=0ACONFIG=5FHIGH=5FRES=5FTIMERS=3Dy=0A=
CONFIG=5FGENERIC=5FCLOCKEVENTS=5FBUILD=3Dy=0ACONFIG=5FSMP=3Dy=0ACONFIG=5FX8=
6=5FX2APIC=3Dy=0ACONFIG=5FX86=5FMPPARSE=3Dy=0ACONFIG=5FX86=5FEXTENDED=5FPLA=
TFORM=3Dy=0ACONFIG=5FX86=5FVSMP=3Dy=0ACONFIG=5FX86=5FUV=3Dy=0ACONFIG=5FX86=
=5FSUPPORTS=5FMEMORY=5FFAILURE=3Dy=0ACONFIG=5FSCHED=5FOMIT=5FFRAME=5FPOINTE=
R=3Dy=0ACONFIG=5FPARAVIRT=5FGUEST=3Dy=0ACONFIG=5FXEN=3Dy=0ACONFIG=5FXEN=5FD=
OM0=3Dy=0ACONFIG=5FXEN=5FPRIVILEGED=5FGUEST=3Dy=0ACONFIG=5FXEN=5FPVHVM=3Dy=
=0ACONFIG=5FXEN=5FMAX=5FDOMAIN=5FMEMORY=3D128=0ACONFIG=5FXEN=5FSAVE=5FRESTO=
RE=3Dy=0ACONFIG=5FXEN=5FDEBUG=5FFS=3Dy=0ACONFIG=5FKVM=5FCLOCK=3Dy=0ACONFIG=
=5FKVM=5FGUEST=3Dy=0ACONFIG=5FPARAVIRT=3Dy=0ACONFIG=5FPARAVIRT=5FSPINLOCKS=
=3Dy=0ACONFIG=5FPARAVIRT=5FCLOCK=3Dy=0ACONFIG=5FPARAVIRT=5FDEBUG=3Dy=0ACONF=
IG=5FNO=5FBOOTMEM=3Dy=0ACONFIG=5FMEMTEST=3Dy=0A# CONFIG=5FMK8 is not set=0A=
# CONFIG=5FMPSC is not set=0A# CONFIG=5FMCORE2 is not set=0A# CONFIG=5FMATO=
M is not set=0ACONFIG=5FGENERIC=5FCPU=3Dy=0ACONFIG=5FX86=5FCPU=3Dy=0ACONFIG=
=5FX86=5FINTERNODE=5FCACHE=5FSHIFT=3D12=0ACONFIG=5FX86=5FCMPXCHG=3Dy=0ACONF=
IG=5FCMPXCHG=5FLOCAL=3Dy=0ACONFIG=5FX86=5FL1=5FCACHE=5FSHIFT=3D6=0ACONFIG=
=5FX86=5FXADD=3Dy=0ACONFIG=5FX86=5FWP=5FWORKS=5FOK=3Dy=0ACONFIG=5FX86=5FTSC=
=3Dy=0ACONFIG=5FX86=5FCMPXCHG64=3Dy=0ACONFIG=5FX86=5FCMOV=3Dy=0ACONFIG=5FX8=
6=5FMINIMUM=5FCPU=5FFAMILY=3D64=0ACONFIG=5FX86=5FDEBUGCTLMSR=3Dy=0ACONFIG=
=5FPROCESSOR=5FSELECT=3Dy=0ACONFIG=5FCPU=5FSUP=5FINTEL=3Dy=0ACONFIG=5FCPU=
=5FSUP=5FAMD=3Dy=0ACONFIG=5FCPU=5FSUP=5FCENTAUR=3Dy=0ACONFIG=5FHPET=5FTIMER=
=3Dy=0ACONFIG=5FHPET=5FEMULATE=5FRTC=3Dy=0ACONFIG=5FDMI=3Dy=0ACONFIG=5FGART=
=5FIOMMU=3Dy=0ACONFIG=5FCALGARY=5FIOMMU=3Dy=0ACONFIG=5FCALGARY=5FIOMMU=5FEN=
ABLED=5FBY=5FDEFAULT=3Dy=0ACONFIG=5FAMD=5FIOMMU=3Dy=0ACONFIG=5FAMD=5FIOMMU=
=5FSTATS=3Dy=0ACONFIG=5FSWIOTLB=3Dy=0ACONFIG=5FIOMMU=5FHELPER=3Dy=0ACONFIG=
=5FIOMMU=5FAPI=3Dy=0ACONFIG=5FMAXSMP=3Dy=0ACONFIG=5FNR=5FCPUS=3D4096=0ACONF=
IG=5FSCHED=5FSMT=3Dy=0ACONFIG=5FSCHED=5FMC=3Dy=0ACONFIG=5FIRQ=5FTIME=5FACCO=
UNTING=3Dy=0ACONFIG=5FPREEMPT=5FNONE=3Dy=0A# CONFIG=5FPREEMPT=5FVOLUNTARY i=
s not set=0A# CONFIG=5FPREEMPT is not set=0ACONFIG=5FX86=5FLOCAL=5FAPIC=3Dy=
=0ACONFIG=5FX86=5FIO=5FAPIC=3Dy=0ACONFIG=5FX86=5FREROUTE=5FFOR=5FBROKEN=5FB=
OOT=5FIRQS=3Dy=0ACONFIG=5FX86=5FMCE=3Dy=0ACONFIG=5FX86=5FMCE=5FINTEL=3Dy=0A=
CONFIG=5FX86=5FMCE=5FAMD=3Dy=0ACONFIG=5FX86=5FMCE=5FTHRESHOLD=3Dy=0ACONFIG=
=5FX86=5FMCE=5FINJECT=3Dy=0ACONFIG=5FX86=5FTHERMAL=5FVECTOR=3Dy=0ACONFIG=5F=
I8K=3Dy=0ACONFIG=5FMICROCODE=3Dy=0ACONFIG=5FMICROCODE=5FINTEL=3Dy=0ACONFIG=
=5FMICROCODE=5FAMD=3Dy=0ACONFIG=5FMICROCODE=5FOLD=5FINTERFACE=3Dy=0ACONFIG=
=5FX86=5FMSR=3Dy=0ACONFIG=5FX86=5FCPUID=3Dy=0ACONFIG=5FARCH=5FPHYS=5FADDR=
=5FT=5F64BIT=3Dy=0ACONFIG=5FARCH=5FDMA=5FADDR=5FT=5F64BIT=3Dy=0ACONFIG=5FDI=
RECT=5FGBPAGES=3Dy=0ACONFIG=5FNUMA=3Dy=0ACONFIG=5FAMD=5FNUMA=3Dy=0ACONFIG=
=5FX86=5F64=5FACPI=5FNUMA=3Dy=0ACONFIG=5FNODES=5FSPAN=5FOTHER=5FNODES=3Dy=
=0ACONFIG=5FNUMA=5FEMU=3Dy=0ACONFIG=5FNODES=5FSHIFT=3D10=0ACONFIG=5FARCH=5F=
PROC=5FKCORE=5FTEXT=3Dy=0ACONFIG=5FARCH=5FSPARSEMEM=5FDEFAULT=3Dy=0ACONFIG=
=5FARCH=5FSPARSEMEM=5FENABLE=3Dy=0ACONFIG=5FARCH=5FSELECT=5FMEMORY=5FMODEL=
=3Dy=0ACONFIG=5FARCH=5FMEMORY=5FPROBE=3Dy=0ACONFIG=5FILLEGAL=5FPOINTER=5FVA=
LUE=3D0xdead000000000000=0ACONFIG=5FSELECT=5FMEMORY=5FMODEL=3Dy=0ACONFIG=5F=
SPARSEMEM=5FMANUAL=3Dy=0ACONFIG=5FSPARSEMEM=3Dy=0ACONFIG=5FNEED=5FMULTIPLE=
=5FNODES=3Dy=0ACONFIG=5FHAVE=5FMEMORY=5FPRESENT=3Dy=0ACONFIG=5FSPARSEMEM=5F=
EXTREME=3Dy=0ACONFIG=5FSPARSEMEM=5FVMEMMAP=5FENABLE=3Dy=0ACONFIG=5FSPARSEME=
M=5FALLOC=5FMEM=5FMAP=5FTOGETHER=3Dy=0ACONFIG=5FSPARSEMEM=5FVMEMMAP=3Dy=0AC=
ONFIG=5FHAVE=5FMEMBLOCK=3Dy=0ACONFIG=5FMEMORY=5FHOTPLUG=3Dy=0ACONFIG=5FMEMO=
RY=5FHOTPLUG=5FSPARSE=3Dy=0ACONFIG=5FMEMORY=5FHOTREMOVE=3Dy=0ACONFIG=5FPAGE=
FLAGS=5FEXTENDED=3Dy=0ACONFIG=5FSPLIT=5FPTLOCK=5FCPUS=3D999999=0ACONFIG=5FC=
OMPACTION=3Dy=0ACONFIG=5FMIGRATION=3Dy=0ACONFIG=5FPHYS=5FADDR=5FT=5F64BIT=
=3Dy=0ACONFIG=5FZONE=5FDMA=5FFLAG=3D1=0ACONFIG=5FBOUNCE=3Dy=0ACONFIG=5FVIRT=
=5FTO=5FBUS=3Dy=0ACONFIG=5FMMU=5FNOTIFIER=3Dy=0ACONFIG=5FKSM=3Dy=0ACONFIG=
=5FDEFAULT=5FMMAP=5FMIN=5FADDR=3D4096=0ACONFIG=5FARCH=5FSUPPORTS=5FMEMORY=
=5FFAILURE=3Dy=0ACONFIG=5FMEMORY=5FFAILURE=3Dy=0ACONFIG=5FHWPOISON=5FINJECT=
=3Dy=0ACONFIG=5FTRANSPARENT=5FHUGEPAGE=3Dy=0ACONFIG=5FTRANSPARENT=5FHUGEPAG=
E=5FALWAYS=3Dy=0A# CONFIG=5FTRANSPARENT=5FHUGEPAGE=5FMADVISE is not set=0AC=
ONFIG=5FX86=5FCHECK=5FBIOS=5FCORRUPTION=3Dy=0ACONFIG=5FX86=5FBOOTPARAM=5FME=
MORY=5FCORRUPTION=5FCHECK=3Dy=0ACONFIG=5FX86=5FRESERVE=5FLOW=3D64=0ACONFIG=
=5FMTRR=3Dy=0ACONFIG=5FMTRR=5FSANITIZER=3Dy=0ACONFIG=5FMTRR=5FSANITIZER=5FE=
NABLE=5FDEFAULT=3D0=0ACONFIG=5FMTRR=5FSANITIZER=5FSPARE=5FREG=5FNR=5FDEFAUL=
T=3D1=0ACONFIG=5FX86=5FPAT=3Dy=0ACONFIG=5FARCH=5FUSES=5FPG=5FUNCACHED=3Dy=
=0ACONFIG=5FEFI=3Dy=0ACONFIG=5FSECCOMP=3Dy=0ACONFIG=5FCC=5FSTACKPROTECTOR=
=3Dy=0A# CONFIG=5FHZ=5F100 is not set=0ACONFIG=5FHZ=5F250=3Dy=0A# CONFIG=5F=
HZ=5F300 is not set=0A# CONFIG=5FHZ=5F1000 is not set=0ACONFIG=5FHZ=3D250=
=0ACONFIG=5FSCHED=5FHRTICK=3Dy=0ACONFIG=5FKEXEC=3Dy=0ACONFIG=5FCRASH=5FDUMP=
=3Dy=0ACONFIG=5FKEXEC=5FJUMP=3Dy=0ACONFIG=5FPHYSICAL=5FSTART=3D0x1000000=0A=
CONFIG=5FRELOCATABLE=3Dy=0ACONFIG=5FPHYSICAL=5FALIGN=3D0x1000000=0ACONFIG=
=5FHOTPLUG=5FCPU=3Dy=0ACONFIG=5FCOMPAT=5FVDSO=3Dy=0ACONFIG=5FCMDLINE=5FBOOL=
=3Dy=0ACONFIG=5FCMDLINE=3D""=0ACONFIG=5FCMDLINE=5FOVERRIDE=3Dy=0ACONFIG=5FA=
RCH=5FENABLE=5FMEMORY=5FHOTPLUG=3Dy=0ACONFIG=5FARCH=5FENABLE=5FMEMORY=5FHOT=
REMOVE=3Dy=0ACONFIG=5FHAVE=5FARCH=5FEARLY=5FPFN=5FTO=5FNID=3Dy=0ACONFIG=5FU=
SE=5FPERCPU=5FNUMA=5FNODE=5FID=3Dy=0A=0A#=0A# Power management and ACPI opt=
ions=0A#=0ACONFIG=5FARCH=5FHIBERNATION=5FHEADER=3Dy=0ACONFIG=5FPM=3Dy=0ACON=
FIG=5FPM=5FDEBUG=3Dy=0ACONFIG=5FPM=5FADVANCED=5FDEBUG=3Dy=0ACONFIG=5FPM=5FV=
ERBOSE=3Dy=0ACONFIG=5FCAN=5FPM=5FTRACE=3Dy=0ACONFIG=5FPM=5FTRACE=3Dy=0ACONF=
IG=5FPM=5FTRACE=5FRTC=3Dy=0ACONFIG=5FPM=5FSLEEP=5FSMP=3Dy=0ACONFIG=5FPM=5FS=
LEEP=3Dy=0A# CONFIG=5FPM=5FSLEEP=5FADVANCED=5FDEBUG is not set=0ACONFIG=5FS=
USPEND=3Dy=0ACONFIG=5FPM=5FTEST=5FSUSPEND=3Dy=0ACONFIG=5FSUSPEND=5FFREEZER=
=3Dy=0ACONFIG=5FHIBERNATION=3Dy=0ACONFIG=5FPM=5FSTD=5FPARTITION=3D""=0ACONF=
IG=5FPM=5FRUNTIME=3Dy=0ACONFIG=5FPM=5FOPS=3Dy=0ACONFIG=5FACPI=3Dy=0ACONFIG=
=5FACPI=5FSLEEP=3Dy=0ACONFIG=5FACPI=5FPROCFS=3Dy=0ACONFIG=5FACPI=5FPROCFS=
=5FPOWER=3Dy=0ACONFIG=5FACPI=5FPOWER=5FMETER=3Dy=0ACONFIG=5FACPI=5FEC=5FDEB=
UGFS=3Dy=0ACONFIG=5FACPI=5FPROC=5FEVENT=3Dy=0ACONFIG=5FACPI=5FAC=3Dy=0ACONF=
IG=5FACPI=5FBATTERY=3Dy=0ACONFIG=5FACPI=5FBUTTON=3Dy=0ACONFIG=5FACPI=5FVIDE=
O=3Dy=0ACONFIG=5FACPI=5FFAN=3Dy=0ACONFIG=5FACPI=5FDOCK=3Dy=0ACONFIG=5FACPI=
=5FPROCESSOR=3Dy=0ACONFIG=5FACPI=5FIPMI=3Dy=0ACONFIG=5FACPI=5FHOTPLUG=5FCPU=
=3Dy=0ACONFIG=5FACPI=5FPROCESSOR=5FAGGREGATOR=3Dy=0ACONFIG=5FACPI=5FTHERMAL=
=3Dy=0ACONFIG=5FACPI=5FNUMA=3Dy=0A# CONFIG=5FACPI=5FCUSTOM=5FDSDT is not se=
t=0ACONFIG=5FACPI=5FBLACKLIST=5FYEAR=3D0=0ACONFIG=5FACPI=5FDEBUG=3Dy=0ACONF=
IG=5FACPI=5FDEBUG=5FFUNC=5FTRACE=3Dy=0ACONFIG=5FACPI=5FPCI=5FSLOT=3Dy=0ACON=
FIG=5FX86=5FPM=5FTIMER=3Dy=0ACONFIG=5FACPI=5FCONTAINER=3Dy=0ACONFIG=5FACPI=
=5FHOTPLUG=5FMEMORY=3Dy=0ACONFIG=5FACPI=5FSBS=3Dy=0ACONFIG=5FACPI=5FHED=3Dy=
=0ACONFIG=5FACPI=5FAPEI=3Dy=0ACONFIG=5FACPI=5FAPEI=5FGHES=3Dy=0ACONFIG=5FAC=
PI=5FAPEI=5FEINJ=3Dy=0ACONFIG=5FACPI=5FAPEI=5FERST=5FDEBUG=3Dy=0ACONFIG=5FS=
FI=3Dy=0A=0A#=0A# CPU Frequency scaling=0A#=0ACONFIG=5FCPU=5FFREQ=3Dy=0ACON=
FIG=5FCPU=5FFREQ=5FTABLE=3Dy=0ACONFIG=5FCPU=5FFREQ=5FDEBUG=3Dy=0ACONFIG=5FC=
PU=5FFREQ=5FSTAT=3Dy=0ACONFIG=5FCPU=5FFREQ=5FSTAT=5FDETAILS=3Dy=0ACONFIG=5F=
CPU=5FFREQ=5FDEFAULT=5FGOV=5FPERFORMANCE=3Dy=0A# CONFIG=5FCPU=5FFREQ=5FDEFA=
ULT=5FGOV=5FPOWERSAVE is not set=0A# CONFIG=5FCPU=5FFREQ=5FDEFAULT=5FGOV=5F=
USERSPACE is not set=0A# CONFIG=5FCPU=5FFREQ=5FDEFAULT=5FGOV=5FONDEMAND is =
not set=0A# CONFIG=5FCPU=5FFREQ=5FDEFAULT=5FGOV=5FCONSERVATIVE is not set=
=0ACONFIG=5FCPU=5FFREQ=5FGOV=5FPERFORMANCE=3Dy=0ACONFIG=5FCPU=5FFREQ=5FGOV=
=5FPOWERSAVE=3Dy=0ACONFIG=5FCPU=5FFREQ=5FGOV=5FUSERSPACE=3Dy=0ACONFIG=5FCPU=
=5FFREQ=5FGOV=5FONDEMAND=3Dy=0ACONFIG=5FCPU=5FFREQ=5FGOV=5FCONSERVATIVE=3Dy=
=0A=0A#=0A# CPUFreq processor drivers=0A#=0ACONFIG=5FX86=5FPCC=5FCPUFREQ=3D=
y=0ACONFIG=5FX86=5FACPI=5FCPUFREQ=3Dy=0ACONFIG=5FX86=5FPOWERNOW=5FK8=3Dy=0A=
CONFIG=5FX86=5FSPEEDSTEP=5FCENTRINO=3Dy=0ACONFIG=5FX86=5FP4=5FCLOCKMOD=3Dy=
=0A=0A#=0A# shared options=0A#=0ACONFIG=5FX86=5FSPEEDSTEP=5FLIB=3Dy=0ACONFI=
G=5FCPU=5FIDLE=3Dy=0ACONFIG=5FCPU=5FIDLE=5FGOV=5FLADDER=3Dy=0ACONFIG=5FCPU=
=5FIDLE=5FGOV=5FMENU=3Dy=0ACONFIG=5FINTEL=5FIDLE=3Dy=0A=0A#=0A# Memory powe=
r savings=0A#=0ACONFIG=5FI7300=5FIDLE=5FIOAT=5FCHANNEL=3Dy=0ACONFIG=5FI7300=
=5FIDLE=3Dy=0A=0A#=0A# Bus options (PCI etc.)=0A#=0ACONFIG=5FPCI=3Dy=0ACONF=
IG=5FPCI=5FDIRECT=3Dy=0ACONFIG=5FPCI=5FMMCONFIG=3Dy=0ACONFIG=5FPCI=5FXEN=3D=
y=0ACONFIG=5FPCI=5FDOMAINS=3Dy=0ACONFIG=5FPCI=5FCNB20LE=5FQUIRK=3Dy=0ACONFI=
G=5FDMAR=3Dy=0ACONFIG=5FDMAR=5FDEFAULT=5FON=3Dy=0ACONFIG=5FDMAR=5FFLOPPY=5F=
WA=3Dy=0ACONFIG=5FINTR=5FREMAP=3Dy=0ACONFIG=5FPCIEPORTBUS=3Dy=0ACONFIG=5FHO=
TPLUG=5FPCI=5FPCIE=3Dy=0ACONFIG=5FPCIEAER=3Dy=0ACONFIG=5FPCIE=5FECRC=3Dy=0A=
CONFIG=5FPCIEAER=5FINJECT=3Dy=0ACONFIG=5FPCIEASPM=3Dy=0ACONFIG=5FPCIEASPM=
=5FDEBUG=3Dy=0ACONFIG=5FPCIE=5FPME=3Dy=0ACONFIG=5FARCH=5FSUPPORTS=5FMSI=3Dy=
=0ACONFIG=5FPCI=5FMSI=3Dy=0ACONFIG=5FPCI=5FDEBUG=3Dy=0ACONFIG=5FPCI=5FSTUB=
=3Dy=0ACONFIG=5FXEN=5FPCIDEV=5FFRONTEND=3Dy=0ACONFIG=5FXEN=5FPCIDEV=5FFE=5F=
DEBUG=3Dy=0ACONFIG=5FHT=5FIRQ=3Dy=0ACONFIG=5FPCI=5FIOV=3Dy=0ACONFIG=5FPCI=
=5FIOAPIC=3Dy=0ACONFIG=5FISA=5FDMA=5FAPI=3Dy=0ACONFIG=5FAMD=5FNB=3Dy=0ACONF=
IG=5FPCCARD=3Dy=0ACONFIG=5FPCMCIA=3Dy=0ACONFIG=5FPCMCIA=5FLOAD=5FCIS=3Dy=0A=
CONFIG=5FCARDBUS=3Dy=0A=0A#=0A# PC-card bridges=0A#=0ACONFIG=5FYENTA=3Dy=0A=
CONFIG=5FYENTA=5FO2=3Dy=0ACONFIG=5FYENTA=5FRICOH=3Dy=0ACONFIG=5FYENTA=5FTI=
=3Dy=0ACONFIG=5FYENTA=5FENE=5FTUNE=3Dy=0ACONFIG=5FYENTA=5FTOSHIBA=3Dy=0ACON=
FIG=5FPD6729=3Dy=0ACONFIG=5FI82092=3Dy=0ACONFIG=5FPCCARD=5FNONSTATIC=3Dy=0A=
CONFIG=5FHOTPLUG=5FPCI=3Dy=0ACONFIG=5FHOTPLUG=5FPCI=5FFAKE=3Dy=0ACONFIG=5FH=
OTPLUG=5FPCI=5FACPI=3Dy=0ACONFIG=5FHOTPLUG=5FPCI=5FACPI=5FIBM=3Dy=0ACONFIG=
=5FHOTPLUG=5FPCI=5FCPCI=3Dy=0ACONFIG=5FHOTPLUG=5FPCI=5FCPCI=5FZT5550=3Dy=0A=
CONFIG=5FHOTPLUG=5FPCI=5FCPCI=5FGENERIC=3Dy=0ACONFIG=5FHOTPLUG=5FPCI=5FSHPC=
=3Dy=0A=0A#=0A# Executable file formats / Emulations=0A#=0ACONFIG=5FBINFMT=
=5FELF=3Dy=0ACONFIG=5FCOMPAT=5FBINFMT=5FELF=3Dy=0ACONFIG=5FCORE=5FDUMP=5FDE=
FAULT=5FELF=5FHEADERS=3Dy=0A# CONFIG=5FHAVE=5FAOUT is not set=0ACONFIG=5FBI=
NFMT=5FMISC=3Dy=0ACONFIG=5FIA32=5FEMULATION=3Dy=0ACONFIG=5FIA32=5FAOUT=3Dy=
=0ACONFIG=5FCOMPAT=3Dy=0ACONFIG=5FCOMPAT=5FFOR=5FU64=5FALIGNMENT=3Dy=0ACONF=
IG=5FSYSVIPC=5FCOMPAT=3Dy=0ACONFIG=5FHAVE=5FTEXT=5FPOKE=5FSMP=3Dy=0ACONFIG=
=5FNET=3Dy=0ACONFIG=5FCOMPAT=5FNETLINK=5FMESSAGES=3Dy=0A=0A#=0A# Networking=
 options=0A#=0ACONFIG=5FPACKET=3Dy=0ACONFIG=5FUNIX=3Dy=0ACONFIG=5FXFRM=3Dy=
=0ACONFIG=5FXFRM=5FUSER=3Dy=0ACONFIG=5FXFRM=5FSUB=5FPOLICY=3Dy=0ACONFIG=5FX=
FRM=5FMIGRATE=3Dy=0ACONFIG=5FXFRM=5FSTATISTICS=3Dy=0ACONFIG=5FXFRM=5FIPCOMP=
=3Dy=0ACONFIG=5FNET=5FKEY=3Dy=0ACONFIG=5FNET=5FKEY=5FMIGRATE=3Dy=0ACONFIG=
=5FINET=3Dy=0ACONFIG=5FIP=5FMULTICAST=3Dy=0ACONFIG=5FIP=5FADVANCED=5FROUTER=
=3Dy=0ACONFIG=5FIP=5FFIB=5FTRIE=5FSTATS=3Dy=0ACONFIG=5FIP=5FMULTIPLE=5FTABL=
ES=3Dy=0ACONFIG=5FIP=5FROUTE=5FMULTIPATH=3Dy=0ACONFIG=5FIP=5FROUTE=5FVERBOS=
E=3Dy=0ACONFIG=5FIP=5FROUTE=5FCLASSID=3Dy=0ACONFIG=5FIP=5FPNP=3Dy=0ACONFIG=
=5FIP=5FPNP=5FDHCP=3Dy=0ACONFIG=5FIP=5FPNP=5FBOOTP=3Dy=0ACONFIG=5FIP=5FPNP=
=5FRARP=3Dy=0ACONFIG=5FNET=5FIPIP=3Dy=0ACONFIG=5FNET=5FIPGRE=5FDEMUX=3Dy=0A=
CONFIG=5FNET=5FIPGRE=3Dy=0ACONFIG=5FNET=5FIPGRE=5FBROADCAST=3Dy=0ACONFIG=5F=
IP=5FMROUTE=3Dy=0ACONFIG=5FIP=5FMROUTE=5FMULTIPLE=5FTABLES=3Dy=0ACONFIG=5FI=
P=5FPIMSM=5FV1=3Dy=0ACONFIG=5FIP=5FPIMSM=5FV2=3Dy=0ACONFIG=5FARPD=3Dy=0ACON=
FIG=5FSYN=5FCOOKIES=3Dy=0ACONFIG=5FINET=5FAH=3Dy=0ACONFIG=5FINET=5FESP=3Dy=
=0ACONFIG=5FINET=5FIPCOMP=3Dy=0ACONFIG=5FINET=5FXFRM=5FTUNNEL=3Dy=0ACONFIG=
=5FINET=5FTUNNEL=3Dy=0ACONFIG=5FINET=5FXFRM=5FMODE=5FTRANSPORT=3Dy=0ACONFIG=
=5FINET=5FXFRM=5FMODE=5FTUNNEL=3Dy=0ACONFIG=5FINET=5FXFRM=5FMODE=5FBEET=3Dy=
=0ACONFIG=5FINET=5FLRO=3Dy=0ACONFIG=5FINET=5FDIAG=3Dy=0ACONFIG=5FINET=5FTCP=
=5FDIAG=3Dy=0ACONFIG=5FTCP=5FCONG=5FADVANCED=3Dy=0ACONFIG=5FTCP=5FCONG=5FBI=
C=3Dy=0ACONFIG=5FTCP=5FCONG=5FCUBIC=3Dy=0ACONFIG=5FTCP=5FCONG=5FWESTWOOD=3D=
y=0ACONFIG=5FTCP=5FCONG=5FHTCP=3Dy=0ACONFIG=5FTCP=5FCONG=5FHSTCP=3Dy=0ACONF=
IG=5FTCP=5FCONG=5FHYBLA=3Dy=0ACONFIG=5FTCP=5FCONG=5FVEGAS=3Dy=0ACONFIG=5FTC=
P=5FCONG=5FSCALABLE=3Dy=0ACONFIG=5FTCP=5FCONG=5FLP=3Dy=0ACONFIG=5FTCP=5FCON=
G=5FVENO=3Dy=0ACONFIG=5FTCP=5FCONG=5FYEAH=3Dy=0ACONFIG=5FTCP=5FCONG=5FILLIN=
OIS=3Dy=0A# CONFIG=5FDEFAULT=5FBIC is not set=0ACONFIG=5FDEFAULT=5FCUBIC=3D=
y=0A# CONFIG=5FDEFAULT=5FHTCP is not set=0A# CONFIG=5FDEFAULT=5FHYBLA is no=
t set=0A# CONFIG=5FDEFAULT=5FVEGAS is not set=0A# CONFIG=5FDEFAULT=5FVENO i=
s not set=0A# CONFIG=5FDEFAULT=5FWESTWOOD is not set=0A# CONFIG=5FDEFAULT=
=5FRENO is not set=0ACONFIG=5FDEFAULT=5FTCP=5FCONG=3D"cubic"=0ACONFIG=5FTCP=
=5FMD5SIG=3Dy=0ACONFIG=5FIPV6=3Dy=0ACONFIG=5FIPV6=5FPRIVACY=3Dy=0ACONFIG=5F=
IPV6=5FROUTER=5FPREF=3Dy=0ACONFIG=5FIPV6=5FROUTE=5FINFO=3Dy=0ACONFIG=5FIPV6=
=5FOPTIMISTIC=5FDAD=3Dy=0ACONFIG=5FINET6=5FAH=3Dy=0ACONFIG=5FINET6=5FESP=3D=
y=0ACONFIG=5FINET6=5FIPCOMP=3Dy=0ACONFIG=5FIPV6=5FMIP6=3Dy=0ACONFIG=5FINET6=
=5FXFRM=5FTUNNEL=3Dy=0ACONFIG=5FINET6=5FTUNNEL=3Dy=0ACONFIG=5FINET6=5FXFRM=
=5FMODE=5FTRANSPORT=3Dy=0ACONFIG=5FINET6=5FXFRM=5FMODE=5FTUNNEL=3Dy=0ACONFI=
G=5FINET6=5FXFRM=5FMODE=5FBEET=3Dy=0ACONFIG=5FINET6=5FXFRM=5FMODE=5FROUTEOP=
TIMIZATION=3Dy=0ACONFIG=5FIPV6=5FSIT=3Dy=0ACONFIG=5FIPV6=5FSIT=5F6RD=3Dy=0A=
CONFIG=5FIPV6=5FNDISC=5FNODETYPE=3Dy=0ACONFIG=5FIPV6=5FTUNNEL=3Dy=0ACONFIG=
=5FIPV6=5FMULTIPLE=5FTABLES=3Dy=0ACONFIG=5FIPV6=5FSUBTREES=3Dy=0ACONFIG=5FI=
PV6=5FMROUTE=3Dy=0ACONFIG=5FIPV6=5FMROUTE=5FMULTIPLE=5FTABLES=3Dy=0ACONFIG=
=5FIPV6=5FPIMSM=5FV2=3Dy=0ACONFIG=5FNETLABEL=3Dy=0ACONFIG=5FNETWORK=5FSECMA=
RK=3Dy=0ACONFIG=5FNETWORK=5FPHY=5FTIMESTAMPING=3Dy=0ACONFIG=5FNETFILTER=3Dy=
=0ACONFIG=5FNETFILTER=5FDEBUG=3Dy=0ACONFIG=5FNETFILTER=5FADVANCED=3Dy=0ACON=
FIG=5FBRIDGE=5FNETFILTER=3Dy=0A=0A#=0A# Core Netfilter Configuration=0A#=0A=
CONFIG=5FNETFILTER=5FNETLINK=3Dy=0ACONFIG=5FNETFILTER=5FNETLINK=5FQUEUE=3Dy=
=0ACONFIG=5FNETFILTER=5FNETLINK=5FLOG=3Dy=0ACONFIG=5FNF=5FCONNTRACK=3Dy=0AC=
ONFIG=5FNF=5FCONNTRACK=5FMARK=3Dy=0ACONFIG=5FNF=5FCONNTRACK=5FSECMARK=3Dy=
=0ACONFIG=5FNF=5FCONNTRACK=5FZONES=3Dy=0ACONFIG=5FNF=5FCONNTRACK=5FEVENTS=
=3Dy=0ACONFIG=5FNF=5FCONNTRACK=5FTIMESTAMP=3Dy=0ACONFIG=5FNF=5FCT=5FPROTO=
=5FDCCP=3Dy=0ACONFIG=5FNF=5FCT=5FPROTO=5FGRE=3Dy=0ACONFIG=5FNF=5FCT=5FPROTO=
=5FSCTP=3Dy=0ACONFIG=5FNF=5FCT=5FPROTO=5FUDPLITE=3Dy=0ACONFIG=5FNF=5FCONNTR=
ACK=5FAMANDA=3Dy=0ACONFIG=5FNF=5FCONNTRACK=5FFTP=3Dy=0ACONFIG=5FNF=5FCONNTR=
ACK=5FH323=3Dy=0ACONFIG=5FNF=5FCONNTRACK=5FIRC=3Dy=0ACONFIG=5FNF=5FCONNTRAC=
K=5FBROADCAST=3Dy=0ACONFIG=5FNF=5FCONNTRACK=5FNETBIOS=5FNS=3Dy=0ACONFIG=5FN=
F=5FCONNTRACK=5FSNMP=3Dy=0ACONFIG=5FNF=5FCONNTRACK=5FPPTP=3Dy=0ACONFIG=5FNF=
=5FCONNTRACK=5FSANE=3Dy=0ACONFIG=5FNF=5FCONNTRACK=5FSIP=3Dy=0ACONFIG=5FNF=
=5FCONNTRACK=5FTFTP=3Dy=0ACONFIG=5FNF=5FCT=5FNETLINK=3Dy=0ACONFIG=5FNETFILT=
ER=5FTPROXY=3Dy=0ACONFIG=5FNETFILTER=5FXTABLES=3Dy=0A=0A#=0A# Xtables combi=
ned modules=0A#=0ACONFIG=5FNETFILTER=5FXT=5FMARK=3Dy=0ACONFIG=5FNETFILTER=
=5FXT=5FCONNMARK=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FSET=3Dy=0A=0A#=0A# Xtables=
 targets=0A#=0ACONFIG=5FNETFILTER=5FXT=5FTARGET=5FAUDIT=3Dy=0ACONFIG=5FNETF=
ILTER=5FXT=5FTARGET=5FCHECKSUM=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FTARGET=5FCLA=
SSIFY=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FTARGET=5FCONNMARK=3Dy=0ACONFIG=5FNETF=
ILTER=5FXT=5FTARGET=5FCONNSECMARK=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FTARGET=5F=
CT=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FTARGET=5FDSCP=3Dy=0ACONFIG=5FNETFILTER=
=5FXT=5FTARGET=5FHL=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FTARGET=5FIDLETIMER=3Dy=
=0ACONFIG=5FNETFILTER=5FXT=5FTARGET=5FLED=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FT=
ARGET=5FMARK=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FTARGET=5FNFLOG=3Dy=0ACONFIG=5F=
NETFILTER=5FXT=5FTARGET=5FNFQUEUE=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FTARGET=5F=
NOTRACK=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FTARGET=5FRATEEST=3Dy=0ACONFIG=5FNET=
FILTER=5FXT=5FTARGET=5FTEE=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FTARGET=5FTPROXY=
=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FTARGET=5FTRACE=3Dy=0ACONFIG=5FNETFILTER=5F=
XT=5FTARGET=5FSECMARK=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FTARGET=5FTCPMSS=3Dy=
=0ACONFIG=5FNETFILTER=5FXT=5FTARGET=5FTCPOPTSTRIP=3Dy=0A=0A#=0A# Xtables ma=
tches=0A#=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FCLUSTER=3Dy=0ACONFIG=5FNETFIL=
TER=5FXT=5FMATCH=5FCOMMENT=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FCONNBYTE=
S=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FCONNLIMIT=3Dy=0ACONFIG=5FNETFILTE=
R=5FXT=5FMATCH=5FCONNMARK=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FCONNTRACK=
=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FCPU=3Dy=0ACONFIG=5FNETFILTER=5FXT=
=5FMATCH=5FDCCP=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FDEVGROUP=3Dy=0ACONF=
IG=5FNETFILTER=5FXT=5FMATCH=5FDSCP=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5F=
ESP=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FHASHLIMIT=3Dy=0ACONFIG=5FNETFIL=
TER=5FXT=5FMATCH=5FHELPER=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FHL=3Dy=0A=
CONFIG=5FNETFILTER=5FXT=5FMATCH=5FIPRANGE=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FM=
ATCH=5FIPVS=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FLENGTH=3Dy=0ACONFIG=5FN=
ETFILTER=5FXT=5FMATCH=5FLIMIT=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FMAC=
=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FMARK=3Dy=0ACONFIG=5FNETFILTER=5FXT=
=5FMATCH=5FMULTIPORT=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FOSF=3Dy=0ACONF=
IG=5FNETFILTER=5FXT=5FMATCH=5FOWNER=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=
=5FPOLICY=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FPHYSDEV=3Dy=0ACONFIG=5FNE=
TFILTER=5FXT=5FMATCH=5FPKTTYPE=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FQUOT=
A=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FRATEEST=3Dy=0ACONFIG=5FNETFILTER=
=5FXT=5FMATCH=5FREALM=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FRECENT=3Dy=0A=
CONFIG=5FNETFILTER=5FXT=5FMATCH=5FSCTP=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATC=
H=5FSOCKET=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FSTATE=3Dy=0ACONFIG=5FNET=
FILTER=5FXT=5FMATCH=5FSTATISTIC=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FSTR=
ING=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FTCPMSS=3Dy=0ACONFIG=5FNETFILTER=
=5FXT=5FMATCH=5FTIME=3Dy=0ACONFIG=5FNETFILTER=5FXT=5FMATCH=5FU32=3Dy=0ACONF=
IG=5FIP=5FSET=3Dy=0ACONFIG=5FIP=5FSET=5FMAX=3D256=0ACONFIG=5FIP=5FSET=5FBIT=
MAP=5FIP=3Dy=0ACONFIG=5FIP=5FSET=5FBITMAP=5FIPMAC=3Dy=0ACONFIG=5FIP=5FSET=
=5FBITMAP=5FPORT=3Dy=0ACONFIG=5FIP=5FSET=5FHASH=5FIP=3Dy=0ACONFIG=5FIP=5FSE=
T=5FHASH=5FIPPORT=3Dy=0ACONFIG=5FIP=5FSET=5FHASH=5FIPPORTIP=3Dy=0ACONFIG=5F=
IP=5FSET=5FHASH=5FIPPORTNET=3Dy=0ACONFIG=5FIP=5FSET=5FHASH=5FNET=3Dy=0ACONF=
IG=5FIP=5FSET=5FHASH=5FNETPORT=3Dy=0ACONFIG=5FIP=5FSET=5FLIST=5FSET=3Dy=0AC=
ONFIG=5FIP=5FVS=3Dy=0ACONFIG=5FIP=5FVS=5FIPV6=3Dy=0ACONFIG=5FIP=5FVS=5FDEBU=
G=3Dy=0ACONFIG=5FIP=5FVS=5FTAB=5FBITS=3D12=0A=0A#=0A# IPVS transport protoc=
ol load balancing support=0A#=0ACONFIG=5FIP=5FVS=5FPROTO=5FTCP=3Dy=0ACONFIG=
=5FIP=5FVS=5FPROTO=5FUDP=3Dy=0ACONFIG=5FIP=5FVS=5FPROTO=5FAH=5FESP=3Dy=0ACO=
NFIG=5FIP=5FVS=5FPROTO=5FESP=3Dy=0ACONFIG=5FIP=5FVS=5FPROTO=5FAH=3Dy=0ACONF=
IG=5FIP=5FVS=5FPROTO=5FSCTP=3Dy=0A=0A#=0A# IPVS scheduler=0A#=0ACONFIG=5FIP=
=5FVS=5FRR=3Dy=0ACONFIG=5FIP=5FVS=5FWRR=3Dy=0ACONFIG=5FIP=5FVS=5FLC=3Dy=0AC=
ONFIG=5FIP=5FVS=5FWLC=3Dy=0ACONFIG=5FIP=5FVS=5FLBLC=3Dy=0ACONFIG=5FIP=5FVS=
=5FLBLCR=3Dy=0ACONFIG=5FIP=5FVS=5FDH=3Dy=0ACONFIG=5FIP=5FVS=5FSH=3Dy=0ACONF=
IG=5FIP=5FVS=5FSED=3Dy=0ACONFIG=5FIP=5FVS=5FNQ=3Dy=0A=0A#=0A# IPVS applicat=
ion helper=0A#=0ACONFIG=5FIP=5FVS=5FFTP=3Dy=0ACONFIG=5FIP=5FVS=5FNFCT=3Dy=
=0ACONFIG=5FIP=5FVS=5FPE=5FSIP=3Dy=0A=0A#=0A# IP: Netfilter Configuration=
=0A#=0ACONFIG=5FNF=5FDEFRAG=5FIPV4=3Dy=0ACONFIG=5FNF=5FCONNTRACK=5FIPV4=3Dy=
=0ACONFIG=5FNF=5FCONNTRACK=5FPROC=5FCOMPAT=3Dy=0ACONFIG=5FIP=5FNF=5FQUEUE=
=3Dy=0ACONFIG=5FIP=5FNF=5FIPTABLES=3Dy=0ACONFIG=5FIP=5FNF=5FMATCH=5FADDRTYP=
E=3Dy=0ACONFIG=5FIP=5FNF=5FMATCH=5FAH=3Dy=0ACONFIG=5FIP=5FNF=5FMATCH=5FECN=
=3Dy=0ACONFIG=5FIP=5FNF=5FMATCH=5FTTL=3Dy=0ACONFIG=5FIP=5FNF=5FFILTER=3Dy=
=0ACONFIG=5FIP=5FNF=5FTARGET=5FREJECT=3Dy=0ACONFIG=5FIP=5FNF=5FTARGET=5FLOG=
=3Dy=0ACONFIG=5FIP=5FNF=5FTARGET=5FULOG=3Dy=0ACONFIG=5FNF=5FNAT=3Dy=0ACONFI=
G=5FNF=5FNAT=5FNEEDED=3Dy=0ACONFIG=5FIP=5FNF=5FTARGET=5FMASQUERADE=3Dy=0ACO=
NFIG=5FIP=5FNF=5FTARGET=5FNETMAP=3Dy=0ACONFIG=5FIP=5FNF=5FTARGET=5FREDIRECT=
=3Dy=0ACONFIG=5FNF=5FNAT=5FSNMP=5FBASIC=3Dy=0ACONFIG=5FNF=5FNAT=5FPROTO=5FD=
CCP=3Dy=0ACONFIG=5FNF=5FNAT=5FPROTO=5FGRE=3Dy=0ACONFIG=5FNF=5FNAT=5FPROTO=
=5FUDPLITE=3Dy=0ACONFIG=5FNF=5FNAT=5FPROTO=5FSCTP=3Dy=0ACONFIG=5FNF=5FNAT=
=5FFTP=3Dy=0ACONFIG=5FNF=5FNAT=5FIRC=3Dy=0ACONFIG=5FNF=5FNAT=5FTFTP=3Dy=0AC=
ONFIG=5FNF=5FNAT=5FAMANDA=3Dy=0ACONFIG=5FNF=5FNAT=5FPPTP=3Dy=0ACONFIG=5FNF=
=5FNAT=5FH323=3Dy=0ACONFIG=5FNF=5FNAT=5FSIP=3Dy=0ACONFIG=5FIP=5FNF=5FMANGLE=
=3Dy=0ACONFIG=5FIP=5FNF=5FTARGET=5FCLUSTERIP=3Dy=0ACONFIG=5FIP=5FNF=5FTARGE=
T=5FECN=3Dy=0ACONFIG=5FIP=5FNF=5FTARGET=5FTTL=3Dy=0ACONFIG=5FIP=5FNF=5FRAW=
=3Dy=0ACONFIG=5FIP=5FNF=5FSECURITY=3Dy=0ACONFIG=5FIP=5FNF=5FARPTABLES=3Dy=
=0ACONFIG=5FIP=5FNF=5FARPFILTER=3Dy=0ACONFIG=5FIP=5FNF=5FARP=5FMANGLE=3Dy=
=0A=0A#=0A# IPv6: Netfilter Configuration=0A#=0ACONFIG=5FNF=5FDEFRAG=5FIPV6=
=3Dy=0ACONFIG=5FNF=5FCONNTRACK=5FIPV6=3Dy=0ACONFIG=5FIP6=5FNF=5FQUEUE=3Dy=
=0ACONFIG=5FIP6=5FNF=5FIPTABLES=3Dy=0ACONFIG=5FIP6=5FNF=5FMATCH=5FAH=3Dy=0A=
CONFIG=5FIP6=5FNF=5FMATCH=5FEUI64=3Dy=0ACONFIG=5FIP6=5FNF=5FMATCH=5FFRAG=3D=
y=0ACONFIG=5FIP6=5FNF=5FMATCH=5FOPTS=3Dy=0ACONFIG=5FIP6=5FNF=5FMATCH=5FHL=
=3Dy=0ACONFIG=5FIP6=5FNF=5FMATCH=5FIPV6HEADER=3Dy=0ACONFIG=5FIP6=5FNF=5FMAT=
CH=5FMH=3Dy=0ACONFIG=5FIP6=5FNF=5FMATCH=5FRT=3Dy=0ACONFIG=5FIP6=5FNF=5FTARG=
ET=5FHL=3Dy=0ACONFIG=5FIP6=5FNF=5FTARGET=5FLOG=3Dy=0ACONFIG=5FIP6=5FNF=5FFI=
LTER=3Dy=0ACONFIG=5FIP6=5FNF=5FTARGET=5FREJECT=3Dy=0ACONFIG=5FIP6=5FNF=5FMA=
NGLE=3Dy=0ACONFIG=5FIP6=5FNF=5FRAW=3Dy=0ACONFIG=5FIP6=5FNF=5FSECURITY=3Dy=
=0A=0A#=0A# DECnet: Netfilter Configuration=0A#=0ACONFIG=5FDECNET=5FNF=5FGR=
ABULATOR=3Dy=0ACONFIG=5FBRIDGE=5FNF=5FEBTABLES=3Dy=0ACONFIG=5FBRIDGE=5FEBT=
=5FBROUTE=3Dy=0ACONFIG=5FBRIDGE=5FEBT=5FT=5FFILTER=3Dy=0ACONFIG=5FBRIDGE=5F=
EBT=5FT=5FNAT=3Dy=0ACONFIG=5FBRIDGE=5FEBT=5F802=5F3=3Dy=0ACONFIG=5FBRIDGE=
=5FEBT=5FAMONG=3Dy=0ACONFIG=5FBRIDGE=5FEBT=5FARP=3Dy=0ACONFIG=5FBRIDGE=5FEB=
T=5FIP=3Dy=0ACONFIG=5FBRIDGE=5FEBT=5FIP6=3Dy=0ACONFIG=5FBRIDGE=5FEBT=5FLIMI=
T=3Dy=0ACONFIG=5FBRIDGE=5FEBT=5FMARK=3Dy=0ACONFIG=5FBRIDGE=5FEBT=5FPKTTYPE=
=3Dy=0ACONFIG=5FBRIDGE=5FEBT=5FSTP=3Dy=0ACONFIG=5FBRIDGE=5FEBT=5FVLAN=3Dy=
=0ACONFIG=5FBRIDGE=5FEBT=5FARPREPLY=3Dy=0ACONFIG=5FBRIDGE=5FEBT=5FDNAT=3Dy=
=0ACONFIG=5FBRIDGE=5FEBT=5FMARK=5FT=3Dy=0ACONFIG=5FBRIDGE=5FEBT=5FREDIRECT=
=3Dy=0ACONFIG=5FBRIDGE=5FEBT=5FSNAT=3Dy=0ACONFIG=5FBRIDGE=5FEBT=5FLOG=3Dy=
=0ACONFIG=5FBRIDGE=5FEBT=5FULOG=3Dy=0ACONFIG=5FBRIDGE=5FEBT=5FNFLOG=3Dy=0AC=
ONFIG=5FIP=5FDCCP=3Dy=0ACONFIG=5FINET=5FDCCP=5FDIAG=3Dy=0A=0A#=0A# DCCP CCI=
Ds Configuration (EXPERIMENTAL)=0A#=0ACONFIG=5FIP=5FDCCP=5FCCID2=5FDEBUG=3D=
y=0ACONFIG=5FIP=5FDCCP=5FCCID3=3Dy=0ACONFIG=5FIP=5FDCCP=5FCCID3=5FDEBUG=3Dy=
=0ACONFIG=5FIP=5FDCCP=5FTFRC=5FLIB=3Dy=0ACONFIG=5FIP=5FDCCP=5FTFRC=5FDEBUG=
=3Dy=0A=0A#=0A# DCCP Kernel Hacking=0A#=0ACONFIG=5FIP=5FDCCP=5FDEBUG=3Dy=0A=
CONFIG=5FNET=5FDCCPPROBE=3Dy=0ACONFIG=5FIP=5FSCTP=3Dy=0ACONFIG=5FNET=5FSCTP=
PROBE=3Dy=0ACONFIG=5FSCTP=5FDBG=5FMSG=3Dy=0ACONFIG=5FSCTP=5FDBG=5FOBJCNT=3D=
y=0A# CONFIG=5FSCTP=5FHMAC=5FNONE is not set=0A# CONFIG=5FSCTP=5FHMAC=5FSHA=
1 is not set=0ACONFIG=5FSCTP=5FHMAC=5FMD5=3Dy=0ACONFIG=5FRDS=3Dy=0ACONFIG=
=5FRDS=5FRDMA=3Dy=0ACONFIG=5FRDS=5FTCP=3Dy=0ACONFIG=5FRDS=5FDEBUG=3Dy=0ACON=
FIG=5FTIPC=3Dy=0ACONFIG=5FTIPC=5FADVANCED=3Dy=0ACONFIG=5FTIPC=5FNODES=3D255=
=0ACONFIG=5FTIPC=5FPORTS=3D8191=0ACONFIG=5FTIPC=5FLOG=3D0=0ACONFIG=5FTIPC=
=5FDEBUG=3Dy=0ACONFIG=5FATM=3Dy=0ACONFIG=5FATM=5FCLIP=3Dy=0ACONFIG=5FATM=5F=
CLIP=5FNO=5FICMP=3Dy=0ACONFIG=5FATM=5FLANE=3Dy=0ACONFIG=5FATM=5FMPOA=3Dy=0A=
CONFIG=5FATM=5FBR2684=3Dy=0ACONFIG=5FATM=5FBR2684=5FIPFILTER=3Dy=0ACONFIG=
=5FL2TP=3Dy=0ACONFIG=5FL2TP=5FDEBUGFS=3Dy=0ACONFIG=5FL2TP=5FV3=3Dy=0ACONFIG=
=5FL2TP=5FIP=3Dy=0ACONFIG=5FL2TP=5FETH=3Dy=0ACONFIG=5FSTP=3Dy=0ACONFIG=5FGA=
RP=3Dy=0ACONFIG=5FBRIDGE=3Dy=0ACONFIG=5FBRIDGE=5FIGMP=5FSNOOPING=3Dy=0ACONF=
IG=5FNET=5FDSA=3Dy=0ACONFIG=5FNET=5FDSA=5FTAG=5FDSA=3Dy=0ACONFIG=5FNET=5FDS=
A=5FTAG=5FEDSA=3Dy=0ACONFIG=5FNET=5FDSA=5FTAG=5FTRAILER=3Dy=0ACONFIG=5FNET=
=5FDSA=5FMV88E6XXX=3Dy=0ACONFIG=5FNET=5FDSA=5FMV88E6060=3Dy=0ACONFIG=5FNET=
=5FDSA=5FMV88E6XXX=5FNEED=5FPPU=3Dy=0ACONFIG=5FNET=5FDSA=5FMV88E6131=3Dy=0A=
CONFIG=5FNET=5FDSA=5FMV88E6123=5F61=5F65=3Dy=0ACONFIG=5FVLAN=5F8021Q=3Dy=0A=
CONFIG=5FVLAN=5F8021Q=5FGVRP=3Dy=0ACONFIG=5FDECNET=3Dy=0ACONFIG=5FDECNET=5F=
ROUTER=3Dy=0ACONFIG=5FLLC=3Dy=0ACONFIG=5FLLC2=3Dy=0ACONFIG=5FIPX=3Dy=0ACONF=
IG=5FIPX=5FINTERN=3Dy=0ACONFIG=5FATALK=3Dy=0ACONFIG=5FDEV=5FAPPLETALK=3Dy=
=0ACONFIG=5FIPDDP=3Dy=0ACONFIG=5FIPDDP=5FENCAP=3Dy=0ACONFIG=5FIPDDP=5FDECAP=
=3Dy=0ACONFIG=5FX25=3Dy=0ACONFIG=5FLAPB=3Dy=0ACONFIG=5FECONET=3Dy=0ACONFIG=
=5FECONET=5FAUNUDP=3Dy=0ACONFIG=5FECONET=5FNATIVE=3Dy=0ACONFIG=5FWAN=5FROUT=
ER=3Dy=0ACONFIG=5FPHONET=3Dy=0ACONFIG=5FPHONET=5FPIPECTRLR=3Dy=0ACONFIG=5FI=
EEE802154=3Dy=0ACONFIG=5FNET=5FSCHED=3Dy=0A=0A#=0A# Queueing/Scheduling=0A#=
=0ACONFIG=5FNET=5FSCH=5FCBQ=3Dy=0ACONFIG=5FNET=5FSCH=5FHTB=3Dy=0ACONFIG=5FN=
ET=5FSCH=5FHFSC=3Dy=0ACONFIG=5FNET=5FSCH=5FATM=3Dy=0ACONFIG=5FNET=5FSCH=5FP=
RIO=3Dy=0ACONFIG=5FNET=5FSCH=5FMULTIQ=3Dy=0ACONFIG=5FNET=5FSCH=5FRED=3Dy=0A=
CONFIG=5FNET=5FSCH=5FSFB=3Dy=0ACONFIG=5FNET=5FSCH=5FSFQ=3Dy=0ACONFIG=5FNET=
=5FSCH=5FTEQL=3Dy=0ACONFIG=5FNET=5FSCH=5FTBF=3Dy=0ACONFIG=5FNET=5FSCH=5FGRE=
D=3Dy=0ACONFIG=5FNET=5FSCH=5FDSMARK=3Dy=0ACONFIG=5FNET=5FSCH=5FNETEM=3Dy=0A=
CONFIG=5FNET=5FSCH=5FDRR=3Dy=0ACONFIG=5FNET=5FSCH=5FMQPRIO=3Dy=0ACONFIG=5FN=
ET=5FSCH=5FCHOKE=3Dy=0ACONFIG=5FNET=5FSCH=5FINGRESS=3Dy=0A=0A#=0A# Classifi=
cation=0A#=0ACONFIG=5FNET=5FCLS=3Dy=0ACONFIG=5FNET=5FCLS=5FBASIC=3Dy=0ACONF=
IG=5FNET=5FCLS=5FTCINDEX=3Dy=0ACONFIG=5FNET=5FCLS=5FROUTE4=3Dy=0ACONFIG=5FN=
ET=5FCLS=5FFW=3Dy=0ACONFIG=5FNET=5FCLS=5FU32=3Dy=0ACONFIG=5FCLS=5FU32=5FPER=
F=3Dy=0ACONFIG=5FCLS=5FU32=5FMARK=3Dy=0ACONFIG=5FNET=5FCLS=5FRSVP=3Dy=0ACON=
FIG=5FNET=5FCLS=5FRSVP6=3Dy=0ACONFIG=5FNET=5FCLS=5FFLOW=3Dy=0ACONFIG=5FNET=
=5FCLS=5FCGROUP=3Dy=0ACONFIG=5FNET=5FEMATCH=3Dy=0ACONFIG=5FNET=5FEMATCH=5FS=
TACK=3D32=0ACONFIG=5FNET=5FEMATCH=5FCMP=3Dy=0ACONFIG=5FNET=5FEMATCH=5FNBYTE=
=3Dy=0ACONFIG=5FNET=5FEMATCH=5FU32=3Dy=0ACONFIG=5FNET=5FEMATCH=5FMETA=3Dy=
=0ACONFIG=5FNET=5FEMATCH=5FTEXT=3Dy=0ACONFIG=5FNET=5FCLS=5FACT=3Dy=0ACONFIG=
=5FNET=5FACT=5FPOLICE=3Dy=0ACONFIG=5FNET=5FACT=5FGACT=3Dy=0ACONFIG=5FGACT=
=5FPROB=3Dy=0ACONFIG=5FNET=5FACT=5FMIRRED=3Dy=0ACONFIG=5FNET=5FACT=5FIPT=3D=
y=0ACONFIG=5FNET=5FACT=5FNAT=3Dy=0ACONFIG=5FNET=5FACT=5FPEDIT=3Dy=0ACONFIG=
=5FNET=5FACT=5FSIMP=3Dy=0ACONFIG=5FNET=5FACT=5FSKBEDIT=3Dy=0ACONFIG=5FNET=
=5FACT=5FCSUM=3Dy=0ACONFIG=5FNET=5FCLS=5FIND=3Dy=0ACONFIG=5FNET=5FSCH=5FFIF=
O=3Dy=0ACONFIG=5FDCB=3Dy=0ACONFIG=5FDNS=5FRESOLVER=3Dy=0ACONFIG=5FBATMAN=5F=
ADV=3Dy=0ACONFIG=5FBATMAN=5FADV=5FDEBUG=3Dy=0ACONFIG=5FRPS=3Dy=0ACONFIG=5FR=
FS=5FACCEL=3Dy=0ACONFIG=5FXPS=3Dy=0A=0A#=0A# Network testing=0A#=0ACONFIG=
=5FNET=5FPKTGEN=3Dy=0ACONFIG=5FNET=5FTCPPROBE=3Dy=0ACONFIG=5FNET=5FDROP=5FM=
ONITOR=3Dy=0ACONFIG=5FHAMRADIO=3Dy=0A=0A#=0A# Packet Radio protocols=0A#=0A=
CONFIG=5FAX25=3Dy=0ACONFIG=5FAX25=5FDAMA=5FSLAVE=3Dy=0ACONFIG=5FNETROM=3Dy=
=0ACONFIG=5FROSE=3Dy=0A=0A#=0A# AX.25 network device drivers=0A#=0ACONFIG=
=5FMKISS=3Dy=0ACONFIG=5F6PACK=3Dy=0ACONFIG=5FBPQETHER=3Dy=0ACONFIG=5FBAYCOM=
=5FSER=5FFDX=3Dy=0ACONFIG=5FBAYCOM=5FSER=5FHDX=3Dy=0ACONFIG=5FBAYCOM=5FPAR=
=3Dy=0ACONFIG=5FYAM=3Dy=0ACONFIG=5FCAN=3Dy=0ACONFIG=5FCAN=5FRAW=3Dy=0ACONFI=
G=5FCAN=5FBCM=3Dy=0A=0A#=0A# CAN Device Drivers=0A#=0ACONFIG=5FCAN=5FVCAN=
=3Dy=0ACONFIG=5FCAN=5FSLCAN=3Dy=0ACONFIG=5FCAN=5FDEV=3Dy=0ACONFIG=5FCAN=5FC=
ALC=5FBITTIMING=3Dy=0ACONFIG=5FCAN=5FMCP251X=3Dy=0ACONFIG=5FCAN=5FJANZ=5FIC=
AN3=3Dy=0ACONFIG=5FPCH=5FCAN=3Dy=0ACONFIG=5FCAN=5FSJA1000=3Dy=0ACONFIG=5FCA=
N=5FSJA1000=5FPLATFORM=3Dy=0ACONFIG=5FCAN=5FEMS=5FPCI=3Dy=0ACONFIG=5FCAN=5F=
KVASER=5FPCI=3Dy=0ACONFIG=5FCAN=5FPLX=5FPCI=3Dy=0ACONFIG=5FCAN=5FC=5FCAN=3D=
y=0ACONFIG=5FCAN=5FC=5FCAN=5FPLATFORM=3Dy=0A=0A#=0A# CAN USB interfaces=0A#=
=0ACONFIG=5FCAN=5FEMS=5FUSB=3Dy=0ACONFIG=5FCAN=5FESD=5FUSB2=3Dy=0ACONFIG=5F=
CAN=5FSOFTING=3Dy=0ACONFIG=5FCAN=5FSOFTING=5FCS=3Dy=0ACONFIG=5FCAN=5FDEBUG=
=5FDEVICES=3Dy=0ACONFIG=5FIRDA=3Dy=0A=0A#=0A# IrDA protocols=0A#=0ACONFIG=
=5FIRLAN=3Dy=0ACONFIG=5FIRNET=3Dy=0ACONFIG=5FIRCOMM=3Dy=0ACONFIG=5FIRDA=5FU=
LTRA=3Dy=0A=0A#=0A# IrDA options=0A#=0ACONFIG=5FIRDA=5FCACHE=5FLAST=5FLSAP=
=3Dy=0ACONFIG=5FIRDA=5FFAST=5FRR=3Dy=0ACONFIG=5FIRDA=5FDEBUG=3Dy=0A=0A#=0A#=
 Infrared-port device drivers=0A#=0A=0A#=0A# SIR device drivers=0A#=0ACONFI=
G=5FIRTTY=5FSIR=3Dy=0A=0A#=0A# Dongle support=0A#=0ACONFIG=5FDONGLE=3Dy=0AC=
ONFIG=5FESI=5FDONGLE=3Dy=0ACONFIG=5FACTISYS=5FDONGLE=3Dy=0ACONFIG=5FTEKRAM=
=5FDONGLE=3Dy=0ACONFIG=5FTOIM3232=5FDONGLE=3Dy=0ACONFIG=5FLITELINK=5FDONGLE=
=3Dy=0ACONFIG=5FMA600=5FDONGLE=3Dy=0ACONFIG=5FGIRBIL=5FDONGLE=3Dy=0ACONFIG=
=5FMCP2120=5FDONGLE=3Dy=0ACONFIG=5FOLD=5FBELKIN=5FDONGLE=3Dy=0ACONFIG=5FACT=
200L=5FDONGLE=3Dy=0ACONFIG=5FKINGSUN=5FDONGLE=3Dy=0ACONFIG=5FKSDAZZLE=5FDON=
GLE=3Dy=0ACONFIG=5FKS959=5FDONGLE=3Dy=0A=0A#=0A# FIR device drivers=0A#=0AC=
ONFIG=5FUSB=5FIRDA=3Dy=0ACONFIG=5FSIGMATEL=5FFIR=3Dy=0ACONFIG=5FNSC=5FFIR=
=3Dy=0ACONFIG=5FWINBOND=5FFIR=3Dy=0ACONFIG=5FSMC=5FIRCC=5FFIR=3Dy=0ACONFIG=
=5FALI=5FFIR=3Dy=0ACONFIG=5FVLSI=5FFIR=3Dy=0ACONFIG=5FVIA=5FFIR=3Dy=0ACONFI=
G=5FMCS=5FFIR=3Dy=0ACONFIG=5FBT=3Dy=0ACONFIG=5FBT=5FL2CAP=3Dy=0ACONFIG=5FBT=
=5FSCO=3Dy=0ACONFIG=5FBT=5FRFCOMM=3Dy=0ACONFIG=5FBT=5FRFCOMM=5FTTY=3Dy=0ACO=
NFIG=5FBT=5FBNEP=3Dy=0ACONFIG=5FBT=5FBNEP=5FMC=5FFILTER=3Dy=0ACONFIG=5FBT=
=5FBNEP=5FPROTO=5FFILTER=3Dy=0ACONFIG=5FBT=5FCMTP=3Dy=0ACONFIG=5FBT=5FHIDP=
=3Dy=0A=0A#=0A# Bluetooth device drivers=0A#=0ACONFIG=5FBT=5FHCIBTUSB=3Dy=
=0ACONFIG=5FBT=5FHCIBTSDIO=3Dy=0ACONFIG=5FBT=5FHCIUART=3Dy=0ACONFIG=5FBT=5F=
HCIUART=5FH4=3Dy=0ACONFIG=5FBT=5FHCIUART=5FBCSP=3Dy=0ACONFIG=5FBT=5FHCIUART=
=5FATH3K=3Dy=0ACONFIG=5FBT=5FHCIUART=5FLL=3Dy=0ACONFIG=5FBT=5FHCIBCM203X=3D=
y=0ACONFIG=5FBT=5FHCIBPA10X=3Dy=0ACONFIG=5FBT=5FHCIBFUSB=3Dy=0ACONFIG=5FBT=
=5FHCIDTL1=3Dy=0ACONFIG=5FBT=5FHCIBT3C=3Dy=0ACONFIG=5FBT=5FHCIBLUECARD=3Dy=
=0ACONFIG=5FBT=5FHCIBTUART=3Dy=0ACONFIG=5FBT=5FHCIVHCI=3Dy=0ACONFIG=5FBT=5F=
MRVL=3Dy=0ACONFIG=5FBT=5FMRVL=5FSDIO=3Dy=0ACONFIG=5FBT=5FATH3K=3Dy=0ACONFIG=
=5FAF=5FRXRPC=3Dy=0ACONFIG=5FAF=5FRXRPC=5FDEBUG=3Dy=0ACONFIG=5FRXKAD=3Dy=0A=
CONFIG=5FFIB=5FRULES=3Dy=0ACONFIG=5FWIRELESS=3Dy=0ACONFIG=5FWIRELESS=5FEXT=
=3Dy=0ACONFIG=5FWEXT=5FCORE=3Dy=0ACONFIG=5FWEXT=5FPROC=3Dy=0ACONFIG=5FWEXT=
=5FSPY=3Dy=0ACONFIG=5FWEXT=5FPRIV=3Dy=0ACONFIG=5FCFG80211=3Dy=0ACONFIG=5FNL=
80211=5FTESTMODE=3Dy=0ACONFIG=5FCFG80211=5FDEVELOPER=5FWARNINGS=3Dy=0ACONFI=
G=5FCFG80211=5FREG=5FDEBUG=3Dy=0ACONFIG=5FCFG80211=5FDEFAULT=5FPS=3Dy=0ACON=
FIG=5FCFG80211=5FDEBUGFS=3Dy=0ACONFIG=5FCFG80211=5FINTERNAL=5FREGDB=3Dy=0AC=
ONFIG=5FCFG80211=5FWEXT=3Dy=0ACONFIG=5FWIRELESS=5FEXT=5FSYSFS=3Dy=0ACONFIG=
=5FLIB80211=3Dy=0ACONFIG=5FLIB80211=5FCRYPT=5FWEP=3Dy=0ACONFIG=5FLIB80211=
=5FCRYPT=5FCCMP=3Dy=0ACONFIG=5FLIB80211=5FCRYPT=5FTKIP=3Dy=0ACONFIG=5FLIB80=
211=5FDEBUG=3Dy=0ACONFIG=5FMAC80211=3Dy=0ACONFIG=5FMAC80211=5FHAS=5FRC=3Dy=
=0ACONFIG=5FMAC80211=5FRC=5FPID=3Dy=0ACONFIG=5FMAC80211=5FRC=5FMINSTREL=3Dy=
=0ACONFIG=5FMAC80211=5FRC=5FMINSTREL=5FHT=3Dy=0A# CONFIG=5FMAC80211=5FRC=5F=
DEFAULT=5FPID is not set=0ACONFIG=5FMAC80211=5FRC=5FDEFAULT=5FMINSTREL=3Dy=
=0ACONFIG=5FMAC80211=5FRC=5FDEFAULT=3D"minstrel=5Fht"=0ACONFIG=5FMAC80211=
=5FMESH=3Dy=0ACONFIG=5FMAC80211=5FLEDS=3Dy=0ACONFIG=5FMAC80211=5FDEBUGFS=3D=
y=0ACONFIG=5FMAC80211=5FDEBUG=5FMENU=3Dy=0ACONFIG=5FMAC80211=5FNOINLINE=3Dy=
=0ACONFIG=5FMAC80211=5FVERBOSE=5FDEBUG=3Dy=0ACONFIG=5FMAC80211=5FHT=5FDEBUG=
=3Dy=0ACONFIG=5FMAC80211=5FTKIP=5FDEBUG=3Dy=0ACONFIG=5FMAC80211=5FIBSS=5FDE=
BUG=3Dy=0ACONFIG=5FMAC80211=5FVERBOSE=5FPS=5FDEBUG=3Dy=0ACONFIG=5FMAC80211=
=5FVERBOSE=5FMPL=5FDEBUG=3Dy=0ACONFIG=5FMAC80211=5FVERBOSE=5FMHWMP=5FDEBUG=
=3Dy=0ACONFIG=5FMAC80211=5FDEBUG=5FCOUNTERS=3Dy=0ACONFIG=5FMAC80211=5FDRIVE=
R=5FAPI=5FTRACER=3Dy=0ACONFIG=5FWIMAX=3Dy=0ACONFIG=5FWIMAX=5FDEBUG=5FLEVEL=
=3D8=0ACONFIG=5FRFKILL=3Dy=0ACONFIG=5FRFKILL=5FLEDS=3Dy=0ACONFIG=5FRFKILL=
=5FINPUT=3Dy=0ACONFIG=5FNET=5F9P=3Dy=0ACONFIG=5FNET=5F9P=5FVIRTIO=3Dy=0ACON=
FIG=5FNET=5F9P=5FRDMA=3Dy=0ACONFIG=5FNET=5F9P=5FDEBUG=3Dy=0ACONFIG=5FCAIF=
=3Dy=0ACONFIG=5FCAIF=5FDEBUG=3Dy=0ACONFIG=5FCAIF=5FNETDEV=3Dy=0ACONFIG=5FCE=
PH=5FLIB=3Dy=0ACONFIG=5FCEPH=5FLIB=5FPRETTYDEBUG=3Dy=0A=0A#=0A# Device Driv=
ers=0A#=0A=0A#=0A# Generic Driver Options=0A#=0ACONFIG=5FUEVENT=5FHELPER=5F=
PATH=3D""=0ACONFIG=5FDEVTMPFS=3Dy=0ACONFIG=5FDEVTMPFS=5FMOUNT=3Dy=0ACONFIG=
=5FSTANDALONE=3Dy=0ACONFIG=5FPREVENT=5FFIRMWARE=5FBUILD=3Dy=0ACONFIG=5FFW=
=5FLOADER=3Dy=0ACONFIG=5FFIRMWARE=5FIN=5FKERNEL=3Dy=0ACONFIG=5FEXTRA=5FFIRM=
WARE=3D""=0ACONFIG=5FDEBUG=5FDRIVER=3Dy=0ACONFIG=5FDEBUG=5FDEVRES=3Dy=0ACON=
FIG=5FSYS=5FHYPERVISOR=3Dy=0ACONFIG=5FCONNECTOR=3Dy=0ACONFIG=5FPROC=5FEVENT=
S=3Dy=0ACONFIG=5FMTD=3Dy=0ACONFIG=5FMTD=5FDEBUG=3Dy=0ACONFIG=5FMTD=5FDEBUG=
=5FVERBOSE=3D0=0ACONFIG=5FMTD=5FTESTS=3Dm=0ACONFIG=5FMTD=5FCONCAT=3Dy=0ACON=
FIG=5FMTD=5FPARTITIONS=3Dy=0ACONFIG=5FMTD=5FREDBOOT=5FPARTS=3Dy=0ACONFIG=5F=
MTD=5FREDBOOT=5FDIRECTORY=5FBLOCK=3D-1=0ACONFIG=5FMTD=5FREDBOOT=5FPARTS=5FU=
NALLOCATED=3Dy=0ACONFIG=5FMTD=5FREDBOOT=5FPARTS=5FREADONLY=3Dy=0ACONFIG=5FM=
TD=5FCMDLINE=5FPARTS=3Dy=0ACONFIG=5FMTD=5FAR7=5FPARTS=3Dy=0A=0A#=0A# User M=
odules And Translation Layers=0A#=0ACONFIG=5FMTD=5FCHAR=3Dy=0ACONFIG=5FHAVE=
=5FMTD=5FOTP=3Dy=0ACONFIG=5FMTD=5FBLKDEVS=3Dy=0ACONFIG=5FMTD=5FBLOCK=3Dy=0A=
CONFIG=5FFTL=3Dy=0ACONFIG=5FNFTL=3Dy=0ACONFIG=5FNFTL=5FRW=3Dy=0ACONFIG=5FIN=
FTL=3Dy=0ACONFIG=5FRFD=5FFTL=3Dy=0ACONFIG=5FSSFDC=3Dy=0ACONFIG=5FSM=5FFTL=
=3Dy=0ACONFIG=5FMTD=5FOOPS=3Dy=0A=0A#=0A# RAM/ROM/Flash chip drivers=0A#=0A=
CONFIG=5FMTD=5FCFI=3Dy=0ACONFIG=5FMTD=5FJEDECPROBE=3Dy=0ACONFIG=5FMTD=5FGEN=
=5FPROBE=3Dy=0ACONFIG=5FMTD=5FCFI=5FADV=5FOPTIONS=3Dy=0ACONFIG=5FMTD=5FCFI=
=5FNOSWAP=3Dy=0A# CONFIG=5FMTD=5FCFI=5FBE=5FBYTE=5FSWAP is not set=0A# CONF=
IG=5FMTD=5FCFI=5FLE=5FBYTE=5FSWAP is not set=0ACONFIG=5FMTD=5FCFI=5FGEOMETR=
Y=3Dy=0ACONFIG=5FMTD=5FMAP=5FBANK=5FWIDTH=5F1=3Dy=0ACONFIG=5FMTD=5FMAP=5FBA=
NK=5FWIDTH=5F2=3Dy=0ACONFIG=5FMTD=5FMAP=5FBANK=5FWIDTH=5F4=3Dy=0ACONFIG=5FM=
TD=5FMAP=5FBANK=5FWIDTH=5F8=3Dy=0ACONFIG=5FMTD=5FMAP=5FBANK=5FWIDTH=5F16=3D=
y=0ACONFIG=5FMTD=5FMAP=5FBANK=5FWIDTH=5F32=3Dy=0ACONFIG=5FMTD=5FCFI=5FI1=3D=
y=0ACONFIG=5FMTD=5FCFI=5FI2=3Dy=0ACONFIG=5FMTD=5FCFI=5FI4=3Dy=0ACONFIG=5FMT=
D=5FCFI=5FI8=3Dy=0ACONFIG=5FMTD=5FOTP=3Dy=0ACONFIG=5FMTD=5FCFI=5FINTELEXT=
=3Dy=0ACONFIG=5FMTD=5FCFI=5FAMDSTD=3Dy=0ACONFIG=5FMTD=5FCFI=5FSTAA=3Dy=0ACO=
NFIG=5FMTD=5FCFI=5FUTIL=3Dy=0ACONFIG=5FMTD=5FRAM=3Dy=0ACONFIG=5FMTD=5FROM=
=3Dy=0ACONFIG=5FMTD=5FABSENT=3Dy=0A=0A#=0A# Mapping drivers for chip access=
=0A#=0ACONFIG=5FMTD=5FCOMPLEX=5FMAPPINGS=3Dy=0ACONFIG=5FMTD=5FPHYSMAP=3Dy=
=0ACONFIG=5FMTD=5FPHYSMAP=5FCOMPAT=3Dy=0ACONFIG=5FMTD=5FPHYSMAP=5FSTART=3D0=
x8000000=0ACONFIG=5FMTD=5FPHYSMAP=5FLEN=3D0=0ACONFIG=5FMTD=5FPHYSMAP=5FBANK=
WIDTH=3D2=0ACONFIG=5FMTD=5FSC520CDP=3Dy=0ACONFIG=5FMTD=5FNETSC520=3Dy=0ACON=
FIG=5FMTD=5FTS5500=3Dy=0ACONFIG=5FMTD=5FSBC=5FGXX=3Dy=0ACONFIG=5FMTD=5FAMD7=
6XROM=3Dy=0ACONFIG=5FMTD=5FICHXROM=3Dy=0ACONFIG=5FMTD=5FESB2ROM=3Dy=0ACONFI=
G=5FMTD=5FCK804XROM=3Dy=0ACONFIG=5FMTD=5FSCB2=5FFLASH=3Dy=0ACONFIG=5FMTD=5F=
NETtel=3Dy=0ACONFIG=5FMTD=5FL440GX=3Dy=0ACONFIG=5FMTD=5FPCI=3Dy=0ACONFIG=5F=
MTD=5FPCMCIA=3Dy=0ACONFIG=5FMTD=5FPCMCIA=5FANONYMOUS=3Dy=0ACONFIG=5FMTD=5FG=
PIO=5FADDR=3Dy=0ACONFIG=5FMTD=5FINTEL=5FVR=5FNOR=3Dy=0ACONFIG=5FMTD=5FPLATR=
AM=3Dy=0A=0A#=0A# Self-contained MTD device drivers=0A#=0ACONFIG=5FMTD=5FPM=
C551=3Dy=0ACONFIG=5FMTD=5FPMC551=5FBUGFIX=3Dy=0ACONFIG=5FMTD=5FPMC551=5FDEB=
UG=3Dy=0ACONFIG=5FMTD=5FDATAFLASH=3Dy=0ACONFIG=5FMTD=5FDATAFLASH=5FWRITE=5F=
VERIFY=3Dy=0ACONFIG=5FMTD=5FDATAFLASH=5FOTP=3Dy=0ACONFIG=5FMTD=5FM25P80=3Dy=
=0ACONFIG=5FM25PXX=5FUSE=5FFAST=5FREAD=3Dy=0ACONFIG=5FMTD=5FSST25L=3Dy=0ACO=
NFIG=5FMTD=5FSLRAM=3Dy=0ACONFIG=5FMTD=5FPHRAM=3Dy=0ACONFIG=5FMTD=5FMTDRAM=
=3Dy=0ACONFIG=5FMTDRAM=5FTOTAL=5FSIZE=3D4096=0ACONFIG=5FMTDRAM=5FERASE=5FSI=
ZE=3D128=0ACONFIG=5FMTDRAM=5FABS=5FPOS=3D0=0ACONFIG=5FMTD=5FBLOCK2MTD=3Dy=
=0A=0A#=0A# Disk-On-Chip Device Drivers=0A#=0ACONFIG=5FMTD=5FDOC2000=3Dy=0A=
CONFIG=5FMTD=5FDOC2001=3Dy=0ACONFIG=5FMTD=5FDOC2001PLUS=3Dy=0ACONFIG=5FMTD=
=5FDOCPROBE=3Dy=0ACONFIG=5FMTD=5FDOCECC=3Dy=0ACONFIG=5FMTD=5FDOCPROBE=5FADV=
ANCED=3Dy=0ACONFIG=5FMTD=5FDOCPROBE=5FADDRESS=3D0x0000=0ACONFIG=5FMTD=5FDOC=
PROBE=5FHIGH=3Dy=0ACONFIG=5FMTD=5FDOCPROBE=5F55AA=3Dy=0ACONFIG=5FMTD=5FNAND=
=5FECC=3Dy=0ACONFIG=5FMTD=5FNAND=5FECC=5FSMC=3Dy=0ACONFIG=5FMTD=5FNAND=3Dy=
=0ACONFIG=5FMTD=5FNAND=5FVERIFY=5FWRITE=3Dy=0ACONFIG=5FMTD=5FSM=5FCOMMON=3D=
y=0ACONFIG=5FMTD=5FNAND=5FMUSEUM=5FIDS=3Dy=0ACONFIG=5FMTD=5FNAND=5FDENALI=
=3Dy=0ACONFIG=5FMTD=5FNAND=5FDENALI=5FSCRATCH=5FREG=5FADDR=3D0xFF108018=0AC=
ONFIG=5FMTD=5FNAND=5FIDS=3Dy=0ACONFIG=5FMTD=5FNAND=5FRICOH=3Dy=0ACONFIG=5FM=
TD=5FNAND=5FDISKONCHIP=3Dy=0ACONFIG=5FMTD=5FNAND=5FDISKONCHIP=5FPROBE=5FADV=
ANCED=3Dy=0ACONFIG=5FMTD=5FNAND=5FDISKONCHIP=5FPROBE=5FADDRESS=3D0=0ACONFIG=
=5FMTD=5FNAND=5FDISKONCHIP=5FPROBE=5FHIGH=3Dy=0ACONFIG=5FMTD=5FNAND=5FDISKO=
NCHIP=5FBBTWRITE=3Dy=0ACONFIG=5FMTD=5FNAND=5FCAFE=3Dy=0ACONFIG=5FMTD=5FNAND=
=5FNANDSIM=3Dy=0ACONFIG=5FMTD=5FNAND=5FPLATFORM=3Dy=0ACONFIG=5FMTD=5FALAUDA=
=3Dy=0ACONFIG=5FMTD=5FONENAND=3Dy=0ACONFIG=5FMTD=5FONENAND=5FVERIFY=5FWRITE=
=3Dy=0ACONFIG=5FMTD=5FONENAND=5FGENERIC=3Dy=0ACONFIG=5FMTD=5FONENAND=5FOTP=
=3Dy=0ACONFIG=5FMTD=5FONENAND=5F2X=5FPROGRAM=3Dy=0ACONFIG=5FMTD=5FONENAND=
=5FSIM=3Dy=0A=0A#=0A# LPDDR flash memory drivers=0A#=0ACONFIG=5FMTD=5FLPDDR=
=3Dy=0ACONFIG=5FMTD=5FQINFO=5FPROBE=3Dy=0ACONFIG=5FMTD=5FUBI=3Dy=0ACONFIG=
=5FMTD=5FUBI=5FWL=5FTHRESHOLD=3D4096=0ACONFIG=5FMTD=5FUBI=5FBEB=5FRESERVE=
=3D1=0ACONFIG=5FMTD=5FUBI=5FGLUEBI=3Dy=0A=0A#=0A# UBI debugging options=0A#=
=0ACONFIG=5FMTD=5FUBI=5FDEBUG=3Dy=0ACONFIG=5FMTD=5FUBI=5FDEBUG=5FMSG=3Dy=0A=
CONFIG=5FMTD=5FUBI=5FDEBUG=5FPARANOID=3Dy=0ACONFIG=5FMTD=5FUBI=5FDEBUG=5FDI=
SABLE=5FBGT=3Dy=0ACONFIG=5FMTD=5FUBI=5FDEBUG=5FEMULATE=5FBITFLIPS=3Dy=0ACON=
FIG=5FMTD=5FUBI=5FDEBUG=5FEMULATE=5FWRITE=5FFAILURES=3Dy=0ACONFIG=5FMTD=5FU=
BI=5FDEBUG=5FEMULATE=5FERASE=5FFAILURES=3Dy=0A=0A#=0A# Additional UBI debug=
ging messages=0A#=0ACONFIG=5FMTD=5FUBI=5FDEBUG=5FMSG=5FBLD=3Dy=0ACONFIG=5FM=
TD=5FUBI=5FDEBUG=5FMSG=5FEBA=3Dy=0ACONFIG=5FMTD=5FUBI=5FDEBUG=5FMSG=5FWL=3D=
y=0ACONFIG=5FMTD=5FUBI=5FDEBUG=5FMSG=5FIO=3Dy=0ACONFIG=5FPARPORT=3Dy=0ACONF=
IG=5FPARPORT=5FPC=3Dy=0ACONFIG=5FPARPORT=5FSERIAL=3Dy=0ACONFIG=5FPARPORT=5F=
PC=5FFIFO=3Dy=0ACONFIG=5FPARPORT=5FPC=5FSUPERIO=3Dy=0ACONFIG=5FPARPORT=5FPC=
=5FPCMCIA=3Dy=0A# CONFIG=5FPARPORT=5FGSC is not set=0ACONFIG=5FPARPORT=5FAX=
88796=3Dy=0ACONFIG=5FPARPORT=5F1284=3Dy=0ACONFIG=5FPARPORT=5FNOT=5FPC=3Dy=
=0ACONFIG=5FPNP=3Dy=0ACONFIG=5FPNP=5FDEBUG=5FMESSAGES=3Dy=0A=0A#=0A# Protoc=
ols=0A#=0ACONFIG=5FPNPACPI=3Dy=0ACONFIG=5FBLK=5FDEV=3Dy=0ACONFIG=5FBLK=5FDE=
V=5FFD=3Dy=0ACONFIG=5FPARIDE=3Dy=0A=0A#=0A# Parallel IDE high-level drivers=
=0A#=0ACONFIG=5FPARIDE=5FPD=3Dy=0ACONFIG=5FPARIDE=5FPCD=3Dy=0ACONFIG=5FPARI=
DE=5FPF=3Dy=0ACONFIG=5FPARIDE=5FPT=3Dy=0ACONFIG=5FPARIDE=5FPG=3Dy=0A=0A#=0A=
# Parallel IDE protocol modules=0A#=0ACONFIG=5FPARIDE=5FATEN=3Dy=0ACONFIG=
=5FPARIDE=5FBPCK=3Dy=0ACONFIG=5FPARIDE=5FCOMM=3Dy=0ACONFIG=5FPARIDE=5FDSTR=
=3Dy=0ACONFIG=5FPARIDE=5FFIT2=3Dy=0ACONFIG=5FPARIDE=5FFIT3=3Dy=0ACONFIG=5FP=
ARIDE=5FEPAT=3Dy=0ACONFIG=5FPARIDE=5FEPATC8=3Dy=0ACONFIG=5FPARIDE=5FEPIA=3D=
y=0ACONFIG=5FPARIDE=5FFRIQ=3Dy=0ACONFIG=5FPARIDE=5FFRPW=3Dy=0ACONFIG=5FPARI=
DE=5FKBIC=3Dy=0ACONFIG=5FPARIDE=5FKTTI=3Dy=0ACONFIG=5FPARIDE=5FON20=3Dy=0AC=
ONFIG=5FPARIDE=5FON26=3Dy=0ACONFIG=5FBLK=5FCPQ=5FDA=3Dy=0ACONFIG=5FBLK=5FCP=
Q=5FCISS=5FDA=3Dy=0ACONFIG=5FCISS=5FSCSI=5FTAPE=3Dy=0ACONFIG=5FBLK=5FDEV=5F=
DAC960=3Dy=0ACONFIG=5FBLK=5FDEV=5FUMEM=3Dy=0A# CONFIG=5FBLK=5FDEV=5FCOW=5FC=
OMMON is not set=0ACONFIG=5FBLK=5FDEV=5FLOOP=3Dy=0ACONFIG=5FBLK=5FDEV=5FCRY=
PTOLOOP=3Dy=0ACONFIG=5FBLK=5FDEV=5FDRBD=3Dy=0ACONFIG=5FDRBD=5FFAULT=5FINJEC=
TION=3Dy=0ACONFIG=5FBLK=5FDEV=5FNBD=3Dy=0ACONFIG=5FBLK=5FDEV=5FOSD=3Dy=0ACO=
NFIG=5FBLK=5FDEV=5FSX8=3Dy=0ACONFIG=5FBLK=5FDEV=5FUB=3Dy=0ACONFIG=5FBLK=5FD=
EV=5FRAM=3Dy=0ACONFIG=5FBLK=5FDEV=5FRAM=5FCOUNT=3D16=0ACONFIG=5FBLK=5FDEV=
=5FRAM=5FSIZE=3D4096=0ACONFIG=5FBLK=5FDEV=5FXIP=3Dy=0ACONFIG=5FCDROM=5FPKTC=
DVD=3Dy=0ACONFIG=5FCDROM=5FPKTCDVD=5FBUFFERS=3D8=0ACONFIG=5FCDROM=5FPKTCDVD=
=5FWCACHE=3Dy=0ACONFIG=5FATA=5FOVER=5FETH=3Dy=0ACONFIG=5FXEN=5FBLKDEV=5FFRO=
NTEND=3Dy=0ACONFIG=5FVIRTIO=5FBLK=3Dy=0ACONFIG=5FBLK=5FDEV=5FHD=3Dy=0ACONFI=
G=5FBLK=5FDEV=5FRBD=3Dy=0ACONFIG=5FMISC=5FDEVICES=3Dy=0ACONFIG=5FAD525X=5FD=
POT=3Dy=0ACONFIG=5FAD525X=5FDPOT=5FI2C=3Dy=0ACONFIG=5FAD525X=5FDPOT=5FSPI=
=3Dy=0ACONFIG=5FIBM=5FASM=3Dy=0ACONFIG=5FPHANTOM=3Dy=0ACONFIG=5FSGI=5FIOC4=
=3Dy=0ACONFIG=5FTIFM=5FCORE=3Dy=0ACONFIG=5FTIFM=5F7XX1=3Dy=0ACONFIG=5FICS93=
2S401=3Dy=0ACONFIG=5FENCLOSURE=5FSERVICES=3Dy=0ACONFIG=5FSGI=5FXP=3Dy=0ACON=
FIG=5FCS5535=5FMFGPT=3Dy=0ACONFIG=5FCS5535=5FMFGPT=5FDEFAULT=5FIRQ=3D7=0ACO=
NFIG=5FCS5535=5FCLOCK=5FEVENT=5FSRC=3Dy=0ACONFIG=5FHP=5FILO=3Dy=0ACONFIG=5F=
SGI=5FGRU=3Dy=0ACONFIG=5FSGI=5FGRU=5FDEBUG=3Dy=0ACONFIG=5FAPDS9802ALS=3Dy=
=0ACONFIG=5FISL29003=3Dy=0ACONFIG=5FISL29020=3Dy=0ACONFIG=5FSENSORS=5FTSL25=
50=3Dy=0ACONFIG=5FSENSORS=5FBH1780=3Dy=0ACONFIG=5FSENSORS=5FBH1770=3Dy=0ACO=
NFIG=5FSENSORS=5FAPDS990X=3Dy=0ACONFIG=5FHMC6352=3Dy=0ACONFIG=5FDS1682=3Dy=
=0ACONFIG=5FTI=5FDAC7512=3Dy=0ACONFIG=5FVMWARE=5FBALLOON=3Dy=0ACONFIG=5FBMP=
085=3Dy=0ACONFIG=5FPCH=5FPHUB=3Dy=0ACONFIG=5FC2PORT=3Dy=0ACONFIG=5FC2PORT=
=5FDURAMAR=5F2150=3Dy=0A=0A#=0A# EEPROM support=0A#=0ACONFIG=5FEEPROM=5FAT2=
4=3Dy=0ACONFIG=5FEEPROM=5FAT25=3Dy=0ACONFIG=5FEEPROM=5FLEGACY=3Dy=0ACONFIG=
=5FEEPROM=5FMAX6875=3Dy=0ACONFIG=5FEEPROM=5F93CX6=3Dy=0ACONFIG=5FCB710=5FCO=
RE=3Dy=0ACONFIG=5FCB710=5FDEBUG=3Dy=0ACONFIG=5FCB710=5FDEBUG=5FASSUMPTIONS=
=3Dy=0ACONFIG=5FIWMC3200TOP=3Dy=0ACONFIG=5FIWMC3200TOP=5FDEBUG=3Dy=0ACONFIG=
=5FIWMC3200TOP=5FDEBUGFS=3Dy=0A=0A#=0A# Texas Instruments shared transport =
line discipline=0A#=0ACONFIG=5FTI=5FST=3Dy=0ACONFIG=5FHAVE=5FIDE=3Dy=0ACONF=
IG=5FIDE=3Dy=0A=0A#=0A# Please see Documentation/ide/ide.txt for help/info =
on IDE drives=0A#=0ACONFIG=5FIDE=5FXFER=5FMODE=3Dy=0ACONFIG=5FIDE=5FTIMINGS=
=3Dy=0ACONFIG=5FIDE=5FATAPI=3Dy=0ACONFIG=5FBLK=5FDEV=5FIDE=5FSATA=3Dy=0ACON=
FIG=5FIDE=5FGD=3Dy=0ACONFIG=5FIDE=5FGD=5FATA=3Dy=0ACONFIG=5FIDE=5FGD=5FATAP=
I=3Dy=0ACONFIG=5FBLK=5FDEV=5FIDECS=3Dy=0ACONFIG=5FBLK=5FDEV=5FDELKIN=3Dy=0A=
CONFIG=5FBLK=5FDEV=5FIDECD=3Dy=0ACONFIG=5FBLK=5FDEV=5FIDECD=5FVERBOSE=5FERR=
ORS=3Dy=0ACONFIG=5FBLK=5FDEV=5FIDETAPE=3Dy=0ACONFIG=5FBLK=5FDEV=5FIDEACPI=
=3Dy=0ACONFIG=5FIDE=5FTASK=5FIOCTL=3Dy=0ACONFIG=5FIDE=5FPROC=5FFS=3Dy=0A=0A=
#=0A# IDE chipset support/bugfixes=0A#=0ACONFIG=5FIDE=5FGENERIC=3Dy=0ACONFI=
G=5FBLK=5FDEV=5FPLATFORM=3Dy=0ACONFIG=5FBLK=5FDEV=5FCMD640=3Dy=0ACONFIG=5FB=
LK=5FDEV=5FCMD640=5FENHANCED=3Dy=0ACONFIG=5FBLK=5FDEV=5FIDEPNP=3Dy=0ACONFIG=
=5FBLK=5FDEV=5FIDEDMA=5FSFF=3Dy=0A=0A#=0A# PCI IDE chipsets support=0A#=0AC=
ONFIG=5FBLK=5FDEV=5FIDEPCI=3Dy=0ACONFIG=5FIDEPCI=5FPCIBUS=5FORDER=3Dy=0ACON=
FIG=5FBLK=5FDEV=5FOFFBOARD=3Dy=0ACONFIG=5FBLK=5FDEV=5FGENERIC=3Dy=0ACONFIG=
=5FBLK=5FDEV=5FOPTI621=3Dy=0ACONFIG=5FBLK=5FDEV=5FRZ1000=3Dy=0ACONFIG=5FBLK=
=5FDEV=5FIDEDMA=5FPCI=3Dy=0ACONFIG=5FBLK=5FDEV=5FAEC62XX=3Dy=0ACONFIG=5FBLK=
=5FDEV=5FALI15X3=3Dy=0ACONFIG=5FBLK=5FDEV=5FAMD74XX=3Dy=0ACONFIG=5FBLK=5FDE=
V=5FATIIXP=3Dy=0ACONFIG=5FBLK=5FDEV=5FCMD64X=3Dy=0ACONFIG=5FBLK=5FDEV=5FTRI=
FLEX=3Dy=0ACONFIG=5FBLK=5FDEV=5FCS5520=3Dy=0ACONFIG=5FBLK=5FDEV=5FCS5530=3D=
y=0ACONFIG=5FBLK=5FDEV=5FHPT366=3Dy=0ACONFIG=5FBLK=5FDEV=5FJMICRON=3Dy=0ACO=
NFIG=5FBLK=5FDEV=5FSC1200=3Dy=0ACONFIG=5FBLK=5FDEV=5FPIIX=3Dy=0ACONFIG=5FBL=
K=5FDEV=5FIT8172=3Dy=0ACONFIG=5FBLK=5FDEV=5FIT8213=3Dy=0ACONFIG=5FBLK=5FDEV=
=5FIT821X=3Dy=0ACONFIG=5FBLK=5FDEV=5FNS87415=3Dy=0ACONFIG=5FBLK=5FDEV=5FPDC=
202XX=5FOLD=3Dy=0ACONFIG=5FBLK=5FDEV=5FPDC202XX=5FNEW=3Dy=0ACONFIG=5FBLK=5F=
DEV=5FSVWKS=3Dy=0ACONFIG=5FBLK=5FDEV=5FSIIMAGE=3Dy=0ACONFIG=5FBLK=5FDEV=5FS=
IS5513=3Dy=0ACONFIG=5FBLK=5FDEV=5FSLC90E66=3Dy=0ACONFIG=5FBLK=5FDEV=5FTRM29=
0=3Dy=0ACONFIG=5FBLK=5FDEV=5FVIA82CXXX=3Dy=0ACONFIG=5FBLK=5FDEV=5FTC86C001=
=3Dy=0ACONFIG=5FBLK=5FDEV=5FIDEDMA=3Dy=0A=0A#=0A# SCSI device support=0A#=
=0ACONFIG=5FSCSI=5FMOD=3Dy=0ACONFIG=5FRAID=5FATTRS=3Dy=0ACONFIG=5FSCSI=3Dy=
=0ACONFIG=5FSCSI=5FDMA=3Dy=0ACONFIG=5FSCSI=5FTGT=3Dy=0ACONFIG=5FSCSI=5FNETL=
INK=3Dy=0ACONFIG=5FSCSI=5FPROC=5FFS=3Dy=0A=0A#=0A# SCSI support type (disk,=
 tape, CD-ROM)=0A#=0ACONFIG=5FBLK=5FDEV=5FSD=3Dy=0ACONFIG=5FCHR=5FDEV=5FST=
=3Dy=0ACONFIG=5FCHR=5FDEV=5FOSST=3Dy=0ACONFIG=5FBLK=5FDEV=5FSR=3Dy=0ACONFIG=
=5FBLK=5FDEV=5FSR=5FVENDOR=3Dy=0ACONFIG=5FCHR=5FDEV=5FSG=3Dy=0ACONFIG=5FCHR=
=5FDEV=5FSCH=3Dy=0ACONFIG=5FSCSI=5FENCLOSURE=3Dy=0ACONFIG=5FSCSI=5FMULTI=5F=
LUN=3Dy=0ACONFIG=5FSCSI=5FCONSTANTS=3Dy=0ACONFIG=5FSCSI=5FLOGGING=3Dy=0ACON=
FIG=5FSCSI=5FSCAN=5FASYNC=3Dy=0ACONFIG=5FSCSI=5FWAIT=5FSCAN=3Dm=0A=0A#=0A# =
SCSI Transports=0A#=0ACONFIG=5FSCSI=5FSPI=5FATTRS=3Dy=0ACONFIG=5FSCSI=5FFC=
=5FATTRS=3Dy=0ACONFIG=5FSCSI=5FFC=5FTGT=5FATTRS=3Dy=0ACONFIG=5FSCSI=5FISCSI=
=5FATTRS=3Dy=0ACONFIG=5FSCSI=5FSAS=5FATTRS=3Dy=0ACONFIG=5FSCSI=5FSAS=5FLIBS=
AS=3Dy=0ACONFIG=5FSCSI=5FSAS=5FATA=3Dy=0ACONFIG=5FSCSI=5FSAS=5FHOST=5FSMP=
=3Dy=0ACONFIG=5FSCSI=5FSAS=5FLIBSAS=5FDEBUG=3Dy=0ACONFIG=5FSCSI=5FSRP=5FATT=
RS=3Dy=0ACONFIG=5FSCSI=5FSRP=5FTGT=5FATTRS=3Dy=0ACONFIG=5FSCSI=5FLOWLEVEL=
=3Dy=0ACONFIG=5FISCSI=5FTCP=3Dy=0ACONFIG=5FISCSI=5FBOOT=5FSYSFS=3Dy=0ACONFI=
G=5FSCSI=5FCXGB3=5FISCSI=3Dy=0ACONFIG=5FSCSI=5FCXGB4=5FISCSI=3Dy=0ACONFIG=
=5FSCSI=5FBNX2=5FISCSI=3Dy=0ACONFIG=5FBE2ISCSI=3Dy=0ACONFIG=5FBLK=5FDEV=5F3=
W=5FXXXX=5FRAID=3Dy=0ACONFIG=5FSCSI=5FHPSA=3Dy=0ACONFIG=5FSCSI=5F3W=5F9XXX=
=3Dy=0ACONFIG=5FSCSI=5F3W=5FSAS=3Dy=0ACONFIG=5FSCSI=5FACARD=3Dy=0ACONFIG=5F=
SCSI=5FAACRAID=3Dy=0ACONFIG=5FSCSI=5FAIC7XXX=3Dy=0ACONFIG=5FAIC7XXX=5FCMDS=
=5FPER=5FDEVICE=3D32=0ACONFIG=5FAIC7XXX=5FRESET=5FDELAY=5FMS=3D5000=0ACONFI=
G=5FAIC7XXX=5FDEBUG=5FENABLE=3Dy=0ACONFIG=5FAIC7XXX=5FDEBUG=5FMASK=3D0=0ACO=
NFIG=5FAIC7XXX=5FREG=5FPRETTY=5FPRINT=3Dy=0ACONFIG=5FSCSI=5FAIC7XXX=5FOLD=
=3Dy=0ACONFIG=5FSCSI=5FAIC79XX=3Dy=0ACONFIG=5FAIC79XX=5FCMDS=5FPER=5FDEVICE=
=3D32=0ACONFIG=5FAIC79XX=5FRESET=5FDELAY=5FMS=3D5000=0ACONFIG=5FAIC79XX=5FD=
EBUG=5FENABLE=3Dy=0ACONFIG=5FAIC79XX=5FDEBUG=5FMASK=3D0=0ACONFIG=5FAIC79XX=
=5FREG=5FPRETTY=5FPRINT=3Dy=0ACONFIG=5FSCSI=5FAIC94XX=3Dy=0ACONFIG=5FAIC94X=
X=5FDEBUG=3Dy=0ACONFIG=5FSCSI=5FMVSAS=3Dy=0ACONFIG=5FSCSI=5FMVSAS=5FDEBUG=
=3Dy=0ACONFIG=5FSCSI=5FDPT=5FI2O=3Dy=0ACONFIG=5FSCSI=5FADVANSYS=3Dy=0ACONFI=
G=5FSCSI=5FARCMSR=3Dy=0ACONFIG=5FSCSI=5FARCMSR=5FAER=3Dy=0ACONFIG=5FMEGARAI=
D=5FNEWGEN=3Dy=0ACONFIG=5FMEGARAID=5FMM=3Dy=0ACONFIG=5FMEGARAID=5FMAILBOX=
=3Dy=0ACONFIG=5FMEGARAID=5FLEGACY=3Dy=0ACONFIG=5FMEGARAID=5FSAS=3Dy=0ACONFI=
G=5FSCSI=5FMPT2SAS=3Dy=0ACONFIG=5FSCSI=5FMPT2SAS=5FMAX=5FSGE=3D128=0ACONFIG=
=5FSCSI=5FMPT2SAS=5FLOGGING=3Dy=0ACONFIG=5FSCSI=5FHPTIOP=3Dy=0ACONFIG=5FSCS=
I=5FBUSLOGIC=3Dy=0ACONFIG=5FVMWARE=5FPVSCSI=3Dy=0ACONFIG=5FLIBFC=3Dy=0ACONF=
IG=5FLIBFCOE=3Dy=0ACONFIG=5FFCOE=3Dy=0ACONFIG=5FFCOE=5FFNIC=3Dy=0ACONFIG=5F=
SCSI=5FDMX3191D=3Dy=0ACONFIG=5FSCSI=5FEATA=3Dy=0ACONFIG=5FSCSI=5FEATA=5FTAG=
GED=5FQUEUE=3Dy=0ACONFIG=5FSCSI=5FEATA=5FLINKED=5FCOMMANDS=3Dy=0ACONFIG=5FS=
CSI=5FEATA=5FMAX=5FTAGS=3D16=0ACONFIG=5FSCSI=5FFUTURE=5FDOMAIN=3Dy=0ACONFIG=
=5FSCSI=5FGDTH=3Dy=0ACONFIG=5FSCSI=5FIPS=3Dy=0ACONFIG=5FSCSI=5FINITIO=3Dy=
=0ACONFIG=5FSCSI=5FINIA100=3Dy=0ACONFIG=5FSCSI=5FPPA=3Dy=0ACONFIG=5FSCSI=5F=
IMM=3Dy=0ACONFIG=5FSCSI=5FIZIP=5FEPP16=3Dy=0ACONFIG=5FSCSI=5FIZIP=5FSLOW=5F=
CTR=3Dy=0ACONFIG=5FSCSI=5FSTEX=3Dy=0ACONFIG=5FSCSI=5FSYM53C8XX=5F2=3Dy=0ACO=
NFIG=5FSCSI=5FSYM53C8XX=5FDMA=5FADDRESSING=5FMODE=3D1=0ACONFIG=5FSCSI=5FSYM=
53C8XX=5FDEFAULT=5FTAGS=3D16=0ACONFIG=5FSCSI=5FSYM53C8XX=5FMAX=5FTAGS=3D64=
=0ACONFIG=5FSCSI=5FSYM53C8XX=5FMMIO=3Dy=0ACONFIG=5FSCSI=5FIPR=3Dy=0ACONFIG=
=5FSCSI=5FIPR=5FTRACE=3Dy=0ACONFIG=5FSCSI=5FIPR=5FDUMP=3Dy=0ACONFIG=5FSCSI=
=5FQLOGIC=5F1280=3Dy=0ACONFIG=5FSCSI=5FQLA=5FFC=3Dy=0ACONFIG=5FSCSI=5FQLA=
=5FISCSI=3Dy=0ACONFIG=5FSCSI=5FLPFC=3Dy=0ACONFIG=5FSCSI=5FLPFC=5FDEBUG=5FFS=
=3Dy=0ACONFIG=5FSCSI=5FDC395x=3Dy=0ACONFIG=5FSCSI=5FDC390T=3Dy=0ACONFIG=5FS=
CSI=5FDEBUG=3Dy=0ACONFIG=5FSCSI=5FPMCRAID=3Dy=0ACONFIG=5FSCSI=5FPM8001=3Dy=
=0ACONFIG=5FSCSI=5FSRP=3Dy=0ACONFIG=5FSCSI=5FBFA=5FFC=3Dy=0ACONFIG=5FSCSI=
=5FLOWLEVEL=5FPCMCIA=3Dy=0ACONFIG=5FPCMCIA=5FAHA152X=3Dm=0ACONFIG=5FPCMCIA=
=5FFDOMAIN=3Dm=0ACONFIG=5FPCMCIA=5FQLOGIC=3Dm=0ACONFIG=5FPCMCIA=5FSYM53C500=
=3Dm=0ACONFIG=5FSCSI=5FDH=3Dy=0ACONFIG=5FSCSI=5FDH=5FRDAC=3Dy=0ACONFIG=5FSC=
SI=5FDH=5FHP=5FSW=3Dy=0ACONFIG=5FSCSI=5FDH=5FEMC=3Dy=0ACONFIG=5FSCSI=5FDH=
=5FALUA=3Dy=0ACONFIG=5FSCSI=5FOSD=5FINITIATOR=3Dy=0ACONFIG=5FSCSI=5FOSD=5FU=
LD=3Dy=0ACONFIG=5FSCSI=5FOSD=5FDPRINT=5FSENSE=3D1=0ACONFIG=5FSCSI=5FOSD=5FD=
EBUG=3Dy=0ACONFIG=5FATA=3Dy=0A# CONFIG=5FATA=5FNONSTANDARD is not set=0ACON=
FIG=5FATA=5FVERBOSE=5FERROR=3Dy=0ACONFIG=5FATA=5FACPI=3Dy=0ACONFIG=5FSATA=
=5FPMP=3Dy=0A=0A#=0A# Controllers with non-SFF native interface=0A#=0ACONFI=
G=5FSATA=5FAHCI=3Dy=0ACONFIG=5FSATA=5FAHCI=5FPLATFORM=3Dy=0ACONFIG=5FSATA=
=5FINIC162X=3Dy=0ACONFIG=5FSATA=5FACARD=5FAHCI=3Dy=0ACONFIG=5FSATA=5FSIL24=
=3Dy=0ACONFIG=5FATA=5FSFF=3Dy=0A=0A#=0A# SFF controllers with custom DMA in=
terface=0A#=0ACONFIG=5FPDC=5FADMA=3Dy=0ACONFIG=5FSATA=5FQSTOR=3Dy=0ACONFIG=
=5FSATA=5FSX4=3Dy=0ACONFIG=5FATA=5FBMDMA=3Dy=0A=0A#=0A# SATA SFF controller=
s with BMDMA=0A#=0ACONFIG=5FATA=5FPIIX=3Dy=0ACONFIG=5FSATA=5FMV=3Dy=0ACONFI=
G=5FSATA=5FNV=3Dy=0ACONFIG=5FSATA=5FPROMISE=3Dy=0ACONFIG=5FSATA=5FSIL=3Dy=
=0ACONFIG=5FSATA=5FSIS=3Dy=0ACONFIG=5FSATA=5FSVW=3Dy=0ACONFIG=5FSATA=5FULI=
=3Dy=0ACONFIG=5FSATA=5FVIA=3Dy=0ACONFIG=5FSATA=5FVITESSE=3Dy=0A=0A#=0A# PAT=
A SFF controllers with BMDMA=0A#=0ACONFIG=5FPATA=5FALI=3Dy=0ACONFIG=5FPATA=
=5FAMD=3Dy=0ACONFIG=5FPATA=5FARTOP=3Dy=0ACONFIG=5FPATA=5FATIIXP=3Dy=0ACONFI=
G=5FPATA=5FATP867X=3Dy=0ACONFIG=5FPATA=5FCMD64X=3Dy=0ACONFIG=5FPATA=5FCS552=
0=3Dy=0ACONFIG=5FPATA=5FCS5530=3Dy=0ACONFIG=5FPATA=5FCS5536=3Dy=0ACONFIG=5F=
PATA=5FCYPRESS=3Dy=0ACONFIG=5FPATA=5FEFAR=3Dy=0ACONFIG=5FPATA=5FHPT366=3Dy=
=0ACONFIG=5FPATA=5FHPT37X=3Dy=0ACONFIG=5FPATA=5FHPT3X2N=3Dy=0ACONFIG=5FPATA=
=5FHPT3X3=3Dy=0ACONFIG=5FPATA=5FHPT3X3=5FDMA=3Dy=0ACONFIG=5FPATA=5FIT8213=
=3Dy=0ACONFIG=5FPATA=5FIT821X=3Dy=0ACONFIG=5FPATA=5FJMICRON=3Dy=0ACONFIG=5F=
PATA=5FMARVELL=3Dy=0ACONFIG=5FPATA=5FNETCELL=3Dy=0ACONFIG=5FPATA=5FNINJA32=
=3Dy=0ACONFIG=5FPATA=5FNS87415=3Dy=0ACONFIG=5FPATA=5FOLDPIIX=3Dy=0ACONFIG=
=5FPATA=5FOPTIDMA=3Dy=0ACONFIG=5FPATA=5FPDC2027X=3Dy=0ACONFIG=5FPATA=5FPDC=
=5FOLD=3Dy=0ACONFIG=5FPATA=5FRADISYS=3Dy=0ACONFIG=5FPATA=5FRDC=3Dy=0ACONFIG=
=5FPATA=5FSC1200=3Dy=0ACONFIG=5FPATA=5FSCH=3Dy=0ACONFIG=5FPATA=5FSERVERWORK=
S=3Dy=0ACONFIG=5FPATA=5FSIL680=3Dy=0ACONFIG=5FPATA=5FSIS=3Dy=0ACONFIG=5FPAT=
A=5FTOSHIBA=3Dy=0ACONFIG=5FPATA=5FTRIFLEX=3Dy=0ACONFIG=5FPATA=5FVIA=3Dy=0AC=
ONFIG=5FPATA=5FWINBOND=3Dy=0A=0A#=0A# PIO-only SFF controllers=0A#=0ACONFIG=
=5FPATA=5FCMD640=5FPCI=3Dy=0ACONFIG=5FPATA=5FMPIIX=3Dy=0ACONFIG=5FPATA=5FNS=
87410=3Dy=0ACONFIG=5FPATA=5FOPTI=3Dy=0ACONFIG=5FPATA=5FPCMCIA=3Dy=0ACONFIG=
=5FPATA=5FPLATFORM=3Dy=0ACONFIG=5FPATA=5FRZ1000=3Dy=0A=0A#=0A# Generic fall=
back / legacy drivers=0A#=0ACONFIG=5FPATA=5FACPI=3Dy=0ACONFIG=5FATA=5FGENER=
IC=3Dy=0ACONFIG=5FPATA=5FLEGACY=3Dy=0ACONFIG=5FMD=3Dy=0ACONFIG=5FBLK=5FDEV=
=5FMD=3Dy=0ACONFIG=5FMD=5FAUTODETECT=3Dy=0ACONFIG=5FMD=5FLINEAR=3Dy=0ACONFI=
G=5FMD=5FRAID0=3Dy=0ACONFIG=5FMD=5FRAID1=3Dy=0ACONFIG=5FMD=5FRAID10=3Dy=0AC=
ONFIG=5FMD=5FRAID456=3Dy=0ACONFIG=5FMULTICORE=5FRAID456=3Dy=0ACONFIG=5FMD=
=5FMULTIPATH=3Dy=0ACONFIG=5FMD=5FFAULTY=3Dy=0ACONFIG=5FBLK=5FDEV=5FDM=3Dy=
=0ACONFIG=5FDM=5FDEBUG=3Dy=0ACONFIG=5FDM=5FCRYPT=3Dy=0ACONFIG=5FDM=5FSNAPSH=
OT=3Dy=0ACONFIG=5FDM=5FMIRROR=3Dy=0ACONFIG=5FDM=5FRAID=3Dy=0ACONFIG=5FDM=5F=
LOG=5FUSERSPACE=3Dy=0ACONFIG=5FDM=5FZERO=3Dy=0ACONFIG=5FDM=5FMULTIPATH=3Dy=
=0ACONFIG=5FDM=5FMULTIPATH=5FQL=3Dy=0ACONFIG=5FDM=5FMULTIPATH=5FST=3Dy=0ACO=
NFIG=5FDM=5FDELAY=3Dy=0ACONFIG=5FDM=5FUEVENT=3Dy=0ACONFIG=5FTARGET=5FCORE=
=3Dy=0ACONFIG=5FTCM=5FIBLOCK=3Dy=0ACONFIG=5FTCM=5FFILEIO=3Dy=0ACONFIG=5FTCM=
=5FPSCSI=3Dy=0ACONFIG=5FFUSION=3Dy=0ACONFIG=5FFUSION=5FSPI=3Dy=0ACONFIG=5FF=
USION=5FFC=3Dy=0ACONFIG=5FFUSION=5FSAS=3Dy=0ACONFIG=5FFUSION=5FMAX=5FSGE=3D=
128=0ACONFIG=5FFUSION=5FCTL=3Dy=0ACONFIG=5FFUSION=5FLAN=3Dy=0ACONFIG=5FFUSI=
ON=5FLOGGING=3Dy=0A=0A#=0A# IEEE 1394 (FireWire) support=0A#=0ACONFIG=5FFIR=
EWIRE=3Dy=0ACONFIG=5FFIREWIRE=5FOHCI=3Dy=0ACONFIG=5FFIREWIRE=5FOHCI=5FDEBUG=
=3Dy=0ACONFIG=5FFIREWIRE=5FSBP2=3Dy=0ACONFIG=5FFIREWIRE=5FNET=3Dy=0ACONFIG=
=5FFIREWIRE=5FNOSY=3Dy=0ACONFIG=5FI2O=3Dy=0ACONFIG=5FI2O=5FLCT=5FNOTIFY=5FO=
N=5FCHANGES=3Dy=0ACONFIG=5FI2O=5FEXT=5FADAPTEC=3Dy=0ACONFIG=5FI2O=5FEXT=5FA=
DAPTEC=5FDMA64=3Dy=0ACONFIG=5FI2O=5FCONFIG=3Dy=0ACONFIG=5FI2O=5FCONFIG=5FOL=
D=5FIOCTL=3Dy=0ACONFIG=5FI2O=5FBUS=3Dy=0ACONFIG=5FI2O=5FBLOCK=3Dy=0ACONFIG=
=5FI2O=5FSCSI=3Dy=0ACONFIG=5FI2O=5FPROC=3Dy=0ACONFIG=5FMACINTOSH=5FDRIVERS=
=3Dy=0ACONFIG=5FMAC=5FEMUMOUSEBTN=3Dy=0ACONFIG=5FNETDEVICES=3Dy=0ACONFIG=5F=
IFB=3Dy=0ACONFIG=5FDUMMY=3Dy=0ACONFIG=5FBONDING=3Dy=0ACONFIG=5FMACVLAN=3Dy=
=0ACONFIG=5FMACVTAP=3Dy=0ACONFIG=5FEQUALIZER=3Dy=0ACONFIG=5FTUN=3Dy=0ACONFI=
G=5FVETH=3Dy=0ACONFIG=5FNET=5FSB1000=3Dy=0ACONFIG=5FARCNET=3Dy=0ACONFIG=5FA=
RCNET=5F1201=3Dy=0ACONFIG=5FARCNET=5F1051=3Dy=0ACONFIG=5FARCNET=5FRAW=3Dy=
=0ACONFIG=5FARCNET=5FCAP=3Dy=0ACONFIG=5FARCNET=5FCOM90xx=3Dy=0ACONFIG=5FARC=
NET=5FCOM90xxIO=3Dy=0ACONFIG=5FARCNET=5FRIM=5FI=3Dy=0ACONFIG=5FARCNET=5FCOM=
20020=3Dy=0ACONFIG=5FARCNET=5FCOM20020=5FPCI=3Dy=0ACONFIG=5FMII=3Dy=0ACONFI=
G=5FPHYLIB=3Dy=0A=0A#=0A# MII PHY device drivers=0A#=0ACONFIG=5FMARVELL=5FP=
HY=3Dy=0ACONFIG=5FDAVICOM=5FPHY=3Dy=0ACONFIG=5FQSEMI=5FPHY=3Dy=0ACONFIG=5FL=
XT=5FPHY=3Dy=0ACONFIG=5FCICADA=5FPHY=3Dy=0ACONFIG=5FVITESSE=5FPHY=3Dy=0ACON=
FIG=5FSMSC=5FPHY=3Dy=0ACONFIG=5FBROADCOM=5FPHY=3Dy=0ACONFIG=5FBCM63XX=5FPHY=
=3Dy=0ACONFIG=5FICPLUS=5FPHY=3Dy=0ACONFIG=5FREALTEK=5FPHY=3Dy=0ACONFIG=5FNA=
TIONAL=5FPHY=3Dy=0ACONFIG=5FSTE10XP=3Dy=0ACONFIG=5FLSI=5FET1011C=5FPHY=3Dy=
=0ACONFIG=5FMICREL=5FPHY=3Dy=0ACONFIG=5FFIXED=5FPHY=3Dy=0ACONFIG=5FMDIO=5FB=
ITBANG=3Dy=0ACONFIG=5FMDIO=5FGPIO=3Dy=0ACONFIG=5FNET=5FETHERNET=3Dy=0ACONFI=
G=5FHAPPYMEAL=3Dy=0ACONFIG=5FSUNGEM=3Dy=0ACONFIG=5FCASSINI=3Dy=0ACONFIG=5FN=
ET=5FVENDOR=5F3COM=3Dy=0ACONFIG=5FVORTEX=3Dy=0ACONFIG=5FTYPHOON=3Dy=0ACONFI=
G=5FENC28J60=3Dy=0ACONFIG=5FENC28J60=5FWRITEVERIFY=3Dy=0ACONFIG=5FETHOC=3Dy=
=0ACONFIG=5FDNET=3Dy=0ACONFIG=5FNET=5FTULIP=3Dy=0ACONFIG=5FDE2104X=3Dy=0ACO=
NFIG=5FDE2104X=5FDSL=3D0=0ACONFIG=5FTULIP=3Dy=0ACONFIG=5FTULIP=5FMWI=3Dy=0A=
CONFIG=5FTULIP=5FMMIO=3Dy=0ACONFIG=5FTULIP=5FNAPI=3Dy=0ACONFIG=5FTULIP=5FNA=
PI=5FHW=5FMITIGATION=3Dy=0ACONFIG=5FDE4X5=3Dy=0ACONFIG=5FWINBOND=5F840=3Dy=
=0ACONFIG=5FDM9102=3Dy=0ACONFIG=5FULI526X=3Dy=0ACONFIG=5FPCMCIA=5FXIRCOM=3D=
y=0ACONFIG=5FHP100=3Dy=0A# CONFIG=5FIBM=5FNEW=5FEMAC=5FZMII is not set=0A# =
CONFIG=5FIBM=5FNEW=5FEMAC=5FRGMII is not set=0A# CONFIG=5FIBM=5FNEW=5FEMAC=
=5FTAH is not set=0A# CONFIG=5FIBM=5FNEW=5FEMAC=5FEMAC4 is not set=0A# CONF=
IG=5FIBM=5FNEW=5FEMAC=5FNO=5FFLOW=5FCTRL is not set=0A# CONFIG=5FIBM=5FNEW=
=5FEMAC=5FMAL=5FCLR=5FICINTSTAT is not set=0A# CONFIG=5FIBM=5FNEW=5FEMAC=5F=
MAL=5FCOMMON=5FERR is not set=0ACONFIG=5FNET=5FPCI=3Dy=0ACONFIG=5FPCNET32=
=3Dy=0ACONFIG=5FAMD8111=5FETH=3Dy=0ACONFIG=5FADAPTEC=5FSTARFIRE=3Dy=0ACONFI=
G=5FKSZ884X=5FPCI=3Dy=0ACONFIG=5FB44=3Dy=0ACONFIG=5FB44=5FPCI=5FAUTOSELECT=
=3Dy=0ACONFIG=5FB44=5FPCICORE=5FAUTOSELECT=3Dy=0ACONFIG=5FB44=5FPCI=3Dy=0AC=
ONFIG=5FFORCEDETH=3Dy=0ACONFIG=5FE100=3Dy=0ACONFIG=5FFEALNX=3Dy=0ACONFIG=5F=
NATSEMI=3Dy=0ACONFIG=5FNE2K=5FPCI=3Dy=0ACONFIG=5F8139CP=3Dy=0ACONFIG=5F8139=
TOO=3Dy=0ACONFIG=5F8139TOO=5FPIO=3Dy=0ACONFIG=5F8139TOO=5FTUNE=5FTWISTER=3D=
y=0ACONFIG=5F8139TOO=5F8129=3Dy=0ACONFIG=5F8139=5FOLD=5FRX=5FRESET=3Dy=0ACO=
NFIG=5FR6040=3Dy=0ACONFIG=5FSIS900=3Dy=0ACONFIG=5FEPIC100=3Dy=0ACONFIG=5FSM=
SC9420=3Dy=0ACONFIG=5FSUNDANCE=3Dy=0ACONFIG=5FSUNDANCE=5FMMIO=3Dy=0ACONFIG=
=5FTLAN=3Dy=0ACONFIG=5FKS8842=3Dy=0ACONFIG=5FKS8851=3Dy=0ACONFIG=5FKS8851=
=5FMLL=3Dy=0ACONFIG=5FVIA=5FRHINE=3Dy=0ACONFIG=5FVIA=5FRHINE=5FMMIO=3Dy=0AC=
ONFIG=5FSC92031=3Dy=0ACONFIG=5FNET=5FPOCKET=3Dy=0ACONFIG=5FATP=3Dy=0ACONFIG=
=5FDE600=3Dy=0ACONFIG=5FDE620=3Dy=0ACONFIG=5FATL2=3Dy=0ACONFIG=5FNETDEV=5F1=
000=3Dy=0ACONFIG=5FACENIC=3Dy=0ACONFIG=5FACENIC=5FOMIT=5FTIGON=5FI=3Dy=0ACO=
NFIG=5FDL2K=3Dy=0ACONFIG=5FE1000=3Dy=0ACONFIG=5FE1000E=3Dy=0ACONFIG=5FIP100=
0=3Dy=0ACONFIG=5FIGB=3Dy=0ACONFIG=5FIGB=5FDCA=3Dy=0ACONFIG=5FIGBVF=3Dy=0ACO=
NFIG=5FNS83820=3Dy=0ACONFIG=5FHAMACHI=3Dy=0ACONFIG=5FYELLOWFIN=3Dy=0ACONFIG=
=5FR8169=3Dy=0ACONFIG=5FR8169=5FVLAN=3Dy=0ACONFIG=5FSIS190=3Dy=0ACONFIG=5FS=
KGE=3Dy=0ACONFIG=5FSKGE=5FDEBUG=3Dy=0ACONFIG=5FSKY2=3Dy=0ACONFIG=5FSKY2=5FD=
EBUG=3Dy=0ACONFIG=5FVIA=5FVELOCITY=3Dy=0ACONFIG=5FTIGON3=3Dy=0ACONFIG=5FBNX=
2=3Dy=0ACONFIG=5FCNIC=3Dy=0ACONFIG=5FQLA3XXX=3Dy=0ACONFIG=5FATL1=3Dy=0ACONF=
IG=5FATL1E=3Dy=0ACONFIG=5FATL1C=3Dy=0ACONFIG=5FJME=3Dy=0ACONFIG=5FSTMMAC=5F=
ETH=3Dy=0ACONFIG=5FSTMMAC=5FDA=3Dy=0ACONFIG=5FSTMMAC=5FDUAL=5FMAC=3Dy=0ACON=
FIG=5FPCH=5FGBE=3Dy=0ACONFIG=5FNETDEV=5F10000=3Dy=0ACONFIG=5FMDIO=3Dy=0ACON=
FIG=5FCHELSIO=5FT1=3Dy=0ACONFIG=5FCHELSIO=5FT1=5F1G=3Dy=0ACONFIG=5FCHELSIO=
=5FT3=3Dy=0ACONFIG=5FCHELSIO=5FT4=3Dy=0ACONFIG=5FCHELSIO=5FT4VF=3Dy=0ACONFI=
G=5FENIC=3Dy=0ACONFIG=5FIXGBE=3Dy=0ACONFIG=5FIXGBE=5FDCA=3Dy=0ACONFIG=5FIXG=
BE=5FDCB=3Dy=0ACONFIG=5FIXGBEVF=3Dy=0ACONFIG=5FIXGB=3Dy=0ACONFIG=5FS2IO=3Dy=
=0ACONFIG=5FVXGE=3Dy=0ACONFIG=5FVXGE=5FDEBUG=5FTRACE=5FALL=3Dy=0ACONFIG=5FM=
YRI10GE=3Dy=0ACONFIG=5FMYRI10GE=5FDCA=3Dy=0ACONFIG=5FNETXEN=5FNIC=3Dy=0ACON=
FIG=5FNIU=3Dy=0ACONFIG=5FMLX4=5FEN=3Dy=0ACONFIG=5FMLX4=5FCORE=3Dy=0ACONFIG=
=5FMLX4=5FDEBUG=3Dy=0ACONFIG=5FTEHUTI=3Dy=0ACONFIG=5FBNX2X=3Dy=0ACONFIG=5FQ=
LCNIC=3Dy=0ACONFIG=5FQLGE=3Dy=0ACONFIG=5FBNA=3Dy=0ACONFIG=5FSFC=3Dy=0ACONFI=
G=5FSFC=5FMTD=3Dy=0ACONFIG=5FBE2NET=3Dy=0ACONFIG=5FTR=3Dy=0ACONFIG=5FIBMOL=
=3Dy=0ACONFIG=5F3C359=3Dy=0ACONFIG=5FTMS380TR=3Dy=0ACONFIG=5FTMSPCI=3Dy=0AC=
ONFIG=5FABYSS=3Dy=0ACONFIG=5FWLAN=3Dy=0ACONFIG=5FPCMCIA=5FRAYCS=3Dy=0ACONFI=
G=5FLIBERTAS=5FTHINFIRM=3Dy=0ACONFIG=5FLIBERTAS=5FTHINFIRM=5FDEBUG=3Dy=0ACO=
NFIG=5FLIBERTAS=5FTHINFIRM=5FUSB=3Dy=0ACONFIG=5FAIRO=3Dy=0ACONFIG=5FATMEL=
=3Dy=0ACONFIG=5FPCI=5FATMEL=3Dy=0ACONFIG=5FPCMCIA=5FATMEL=3Dy=0ACONFIG=5FAT=
76C50X=5FUSB=3Dy=0ACONFIG=5FAIRO=5FCS=3Dy=0ACONFIG=5FPCMCIA=5FWL3501=3Dy=0A=
CONFIG=5FPRISM54=3Dy=0ACONFIG=5FUSB=5FZD1201=3Dy=0ACONFIG=5FUSB=5FNET=5FRND=
IS=5FWLAN=3Dy=0ACONFIG=5FRTL8180=3Dy=0ACONFIG=5FRTL8187=3Dy=0ACONFIG=5FRTL8=
187=5FLEDS=3Dy=0ACONFIG=5FADM8211=3Dy=0ACONFIG=5FMAC80211=5FHWSIM=3Dy=0ACON=
FIG=5FMWL8K=3Dy=0ACONFIG=5FATH=5FCOMMON=3Dy=0ACONFIG=5FATH=5FDEBUG=3Dy=0ACO=
NFIG=5FATH5K=3Dy=0ACONFIG=5FATH5K=5FDEBUG=3Dy=0ACONFIG=5FATH5K=5FTRACER=3Dy=
=0ACONFIG=5FATH5K=5FPCI=3Dy=0ACONFIG=5FATH9K=5FHW=3Dy=0ACONFIG=5FATH9K=5FCO=
MMON=3Dy=0ACONFIG=5FATH9K=3Dy=0ACONFIG=5FATH9K=5FDEBUGFS=3Dy=0ACONFIG=5FATH=
9K=5FRATE=5FCONTROL=3Dy=0ACONFIG=5FATH9K=5FHTC=3Dy=0ACONFIG=5FATH9K=5FHTC=
=5FDEBUGFS=3Dy=0ACONFIG=5FAR9170=5FUSB=3Dy=0ACONFIG=5FAR9170=5FLEDS=3Dy=0AC=
ONFIG=5FCARL9170=3Dy=0ACONFIG=5FCARL9170=5FLEDS=3Dy=0ACONFIG=5FCARL9170=5FD=
EBUGFS=3Dy=0ACONFIG=5FCARL9170=5FWPC=3Dy=0ACONFIG=5FB43=3Dy=0ACONFIG=5FB43=
=5FPCI=5FAUTOSELECT=3Dy=0ACONFIG=5FB43=5FPCICORE=5FAUTOSELECT=3Dy=0ACONFIG=
=5FB43=5FPCMCIA=3Dy=0ACONFIG=5FB43=5FSDIO=3Dy=0ACONFIG=5FB43=5FPIO=3Dy=0ACO=
NFIG=5FB43=5FPHY=5FN=3Dy=0ACONFIG=5FB43=5FPHY=5FLP=3Dy=0ACONFIG=5FB43=5FLED=
S=3Dy=0ACONFIG=5FB43=5FHWRNG=3Dy=0ACONFIG=5FB43=5FDEBUG=3Dy=0ACONFIG=5FB43=
=5FFORCE=5FPIO=3Dy=0ACONFIG=5FB43LEGACY=3Dy=0ACONFIG=5FB43LEGACY=5FPCI=5FAU=
TOSELECT=3Dy=0ACONFIG=5FB43LEGACY=5FPCICORE=5FAUTOSELECT=3Dy=0ACONFIG=5FB43=
LEGACY=5FLEDS=3Dy=0ACONFIG=5FB43LEGACY=5FHWRNG=3Dy=0ACONFIG=5FB43LEGACY=5FD=
EBUG=3Dy=0ACONFIG=5FB43LEGACY=5FDMA=3Dy=0ACONFIG=5FB43LEGACY=5FPIO=3Dy=0ACO=
NFIG=5FB43LEGACY=5FDMA=5FAND=5FPIO=5FMODE=3Dy=0A# CONFIG=5FB43LEGACY=5FDMA=
=5FMODE is not set=0A# CONFIG=5FB43LEGACY=5FPIO=5FMODE is not set=0ACONFIG=
=5FHOSTAP=3Dy=0ACONFIG=5FHOSTAP=5FFIRMWARE=3Dy=0ACONFIG=5FHOSTAP=5FFIRMWARE=
=5FNVRAM=3Dy=0ACONFIG=5FHOSTAP=5FPLX=3Dy=0ACONFIG=5FHOSTAP=5FPCI=3Dy=0ACONF=
IG=5FHOSTAP=5FCS=3Dy=0ACONFIG=5FIPW2100=3Dy=0ACONFIG=5FIPW2100=5FMONITOR=3D=
y=0ACONFIG=5FIPW2100=5FDEBUG=3Dy=0ACONFIG=5FIPW2200=3Dy=0ACONFIG=5FIPW2200=
=5FMONITOR=3Dy=0ACONFIG=5FIPW2200=5FRADIOTAP=3Dy=0ACONFIG=5FIPW2200=5FPROMI=
SCUOUS=3Dy=0ACONFIG=5FIPW2200=5FQOS=3Dy=0ACONFIG=5FIPW2200=5FDEBUG=3Dy=0ACO=
NFIG=5FLIBIPW=3Dy=0ACONFIG=5FLIBIPW=5FDEBUG=3Dy=0ACONFIG=5FIWLWIFI=3Dy=0A=
=0A#=0A# Debugging Options=0A#=0ACONFIG=5FIWLWIFI=5FDEBUG=3Dy=0ACONFIG=5FIW=
LWIFI=5FDEBUGFS=3Dy=0ACONFIG=5FIWLWIFI=5FDEBUG=5FEXPERIMENTAL=5FUCODE=3Dy=
=0ACONFIG=5FIWLWIFI=5FDEVICE=5FTRACING=3Dy=0ACONFIG=5FIWLAGN=3Dy=0ACONFIG=
=5FIWL4965=3Dy=0ACONFIG=5FIWL5000=3Dy=0ACONFIG=5FIWL=5FP2P=3Dy=0ACONFIG=5FI=
WL3945=3Dy=0ACONFIG=5FIWM=3Dy=0ACONFIG=5FIWM=5FDEBUG=3Dy=0ACONFIG=5FIWM=5FT=
RACING=3Dy=0ACONFIG=5FLIBERTAS=3Dy=0ACONFIG=5FLIBERTAS=5FUSB=3Dy=0ACONFIG=
=5FLIBERTAS=5FCS=3Dy=0ACONFIG=5FLIBERTAS=5FSDIO=3Dy=0ACONFIG=5FLIBERTAS=5FS=
PI=3Dy=0ACONFIG=5FLIBERTAS=5FDEBUG=3Dy=0ACONFIG=5FLIBERTAS=5FMESH=3Dy=0ACON=
FIG=5FHERMES=3Dy=0ACONFIG=5FHERMES=5FPRISM=3Dy=0ACONFIG=5FHERMES=5FCACHE=5F=
FW=5FON=5FINIT=3Dy=0ACONFIG=5FPLX=5FHERMES=3Dy=0ACONFIG=5FTMD=5FHERMES=3Dy=
=0ACONFIG=5FNORTEL=5FHERMES=3Dy=0ACONFIG=5FPCI=5FHERMES=3Dy=0ACONFIG=5FPCMC=
IA=5FHERMES=3Dy=0ACONFIG=5FPCMCIA=5FSPECTRUM=3Dy=0ACONFIG=5FORINOCO=5FUSB=
=3Dy=0ACONFIG=5FP54=5FCOMMON=3Dy=0ACONFIG=5FP54=5FUSB=3Dy=0ACONFIG=5FP54=5F=
PCI=3Dy=0ACONFIG=5FP54=5FSPI=3Dy=0ACONFIG=5FP54=5FSPI=5FDEFAULT=5FEEPROM=3D=
y=0ACONFIG=5FP54=5FLEDS=3Dy=0ACONFIG=5FRT2X00=3Dy=0ACONFIG=5FRT2400PCI=3Dy=
=0ACONFIG=5FRT2500PCI=3Dy=0ACONFIG=5FRT61PCI=3Dy=0ACONFIG=5FRT2800PCI=3Dy=
=0ACONFIG=5FRT2800PCI=5FRT33XX=3Dy=0ACONFIG=5FRT2800PCI=5FRT35XX=3Dy=0ACONF=
IG=5FRT2800PCI=5FRT53XX=3Dy=0ACONFIG=5FRT2500USB=3Dy=0ACONFIG=5FRT73USB=3Dy=
=0ACONFIG=5FRT2800USB=3Dy=0ACONFIG=5FRT2800USB=5FRT33XX=3Dy=0ACONFIG=5FRT28=
00USB=5FRT35XX=3Dy=0ACONFIG=5FRT2800USB=5FUNKNOWN=3Dy=0ACONFIG=5FRT2800=5FL=
IB=3Dy=0ACONFIG=5FRT2X00=5FLIB=5FPCI=3Dy=0ACONFIG=5FRT2X00=5FLIB=5FUSB=3Dy=
=0ACONFIG=5FRT2X00=5FLIB=3Dy=0ACONFIG=5FRT2X00=5FLIB=5FHT=3Dy=0ACONFIG=5FRT=
2X00=5FLIB=5FFIRMWARE=3Dy=0ACONFIG=5FRT2X00=5FLIB=5FCRYPTO=3Dy=0ACONFIG=5FR=
T2X00=5FLIB=5FLEDS=3Dy=0ACONFIG=5FRT2X00=5FLIB=5FDEBUGFS=3Dy=0ACONFIG=5FRT2=
X00=5FDEBUG=3Dy=0ACONFIG=5FRTL8192CE=3Dy=0ACONFIG=5FRTL8192CU=3Dy=0ACONFIG=
=5FRTLWIFI=3Dy=0ACONFIG=5FWL1251=3Dy=0ACONFIG=5FWL1251=5FSPI=3Dy=0ACONFIG=
=5FWL1251=5FSDIO=3Dy=0ACONFIG=5FWL12XX=5FMENU=3Dy=0ACONFIG=5FWL12XX=3Dy=0AC=
ONFIG=5FWL12XX=5FHT=3Dy=0ACONFIG=5FWL12XX=5FSPI=3Dy=0ACONFIG=5FWL12XX=5FSDI=
O=3Dy=0ACONFIG=5FWL12XX=5FSDIO=5FTEST=3Dy=0ACONFIG=5FWL12XX=5FPLATFORM=5FDA=
TA=3Dy=0ACONFIG=5FZD1211RW=3Dy=0ACONFIG=5FZD1211RW=5FDEBUG=3Dy=0A=0A#=0A# W=
iMAX Wireless Broadband devices=0A#=0ACONFIG=5FWIMAX=5FI2400M=3Dy=0ACONFIG=
=5FWIMAX=5FI2400M=5FUSB=3Dy=0ACONFIG=5FWIMAX=5FI2400M=5FSDIO=3Dy=0ACONFIG=
=5FWIMAX=5FIWMC3200=5FSDIO=3Dy=0ACONFIG=5FWIMAX=5FI2400M=5FDEBUG=5FLEVEL=3D=
8=0A=0A#=0A# USB Network Adapters=0A#=0ACONFIG=5FUSB=5FCATC=3Dy=0ACONFIG=5F=
USB=5FKAWETH=3Dy=0ACONFIG=5FUSB=5FPEGASUS=3Dy=0ACONFIG=5FUSB=5FRTL8150=3Dy=
=0ACONFIG=5FUSB=5FUSBNET=3Dy=0ACONFIG=5FUSB=5FNET=5FAX8817X=3Dy=0ACONFIG=5F=
USB=5FNET=5FCDCETHER=3Dy=0ACONFIG=5FUSB=5FNET=5FCDC=5FEEM=3Dy=0ACONFIG=5FUS=
B=5FNET=5FCDC=5FNCM=3Dy=0ACONFIG=5FUSB=5FNET=5FDM9601=3Dy=0ACONFIG=5FUSB=5F=
NET=5FSMSC75XX=3Dy=0ACONFIG=5FUSB=5FNET=5FSMSC95XX=3Dy=0ACONFIG=5FUSB=5FNET=
=5FGL620A=3Dy=0ACONFIG=5FUSB=5FNET=5FNET1080=3Dy=0ACONFIG=5FUSB=5FNET=5FPLU=
SB=3Dy=0ACONFIG=5FUSB=5FNET=5FMCS7830=3Dy=0ACONFIG=5FUSB=5FNET=5FRNDIS=5FHO=
ST=3Dy=0ACONFIG=5FUSB=5FNET=5FCDC=5FSUBSET=3Dy=0ACONFIG=5FUSB=5FALI=5FM5632=
=3Dy=0ACONFIG=5FUSB=5FAN2720=3Dy=0ACONFIG=5FUSB=5FBELKIN=3Dy=0ACONFIG=5FUSB=
=5FARMLINUX=3Dy=0ACONFIG=5FUSB=5FEPSON2888=3Dy=0ACONFIG=5FUSB=5FKC2190=3Dy=
=0ACONFIG=5FUSB=5FNET=5FZAURUS=3Dy=0ACONFIG=5FUSB=5FNET=5FCX82310=5FETH=3Dy=
=0ACONFIG=5FUSB=5FHSO=3Dy=0ACONFIG=5FUSB=5FNET=5FINT51X1=3Dy=0ACONFIG=5FUSB=
=5FCDC=5FPHONET=3Dy=0ACONFIG=5FUSB=5FIPHETH=3Dy=0ACONFIG=5FUSB=5FSIERRA=5FN=
ET=3Dy=0ACONFIG=5FNET=5FPCMCIA=3Dy=0ACONFIG=5FPCMCIA=5F3C589=3Dy=0ACONFIG=
=5FPCMCIA=5F3C574=3Dy=0ACONFIG=5FPCMCIA=5FFMVJ18X=3Dy=0ACONFIG=5FPCMCIA=5FP=
CNET=3Dy=0ACONFIG=5FPCMCIA=5FNMCLAN=3Dy=0ACONFIG=5FPCMCIA=5FSMC91C92=3Dy=0A=
CONFIG=5FPCMCIA=5FXIRC2PS=3Dy=0ACONFIG=5FPCMCIA=5FAXNET=3Dy=0ACONFIG=5FARCN=
ET=5FCOM20020=5FCS=3Dy=0ACONFIG=5FPCMCIA=5FIBMTR=3Dy=0ACONFIG=5FWAN=3Dy=0AC=
ONFIG=5FLANMEDIA=3Dy=0ACONFIG=5FHDLC=3Dy=0ACONFIG=5FHDLC=5FRAW=3Dy=0ACONFIG=
=5FHDLC=5FRAW=5FETH=3Dy=0ACONFIG=5FHDLC=5FCISCO=3Dy=0ACONFIG=5FHDLC=5FFR=3D=
y=0ACONFIG=5FHDLC=5FPPP=3Dy=0ACONFIG=5FHDLC=5FX25=3Dy=0ACONFIG=5FPCI200SYN=
=3Dy=0ACONFIG=5FWANXL=3Dy=0ACONFIG=5FPC300TOO=3Dy=0ACONFIG=5FFARSYNC=3Dy=0A=
CONFIG=5FDSCC4=3Dm=0ACONFIG=5FDSCC4=5FPCISYNC=3Dy=0ACONFIG=5FDSCC4=5FPCI=5F=
RST=3Dy=0ACONFIG=5FDLCI=3Dy=0ACONFIG=5FDLCI=5FMAX=3D8=0ACONFIG=5FWAN=5FROUT=
ER=5FDRIVERS=3Dy=0ACONFIG=5FCYCLADES=5FSYNC=3Dy=0ACONFIG=5FCYCLOMX=5FX25=3D=
y=0ACONFIG=5FLAPBETHER=3Dy=0ACONFIG=5FX25=5FASY=3Dy=0ACONFIG=5FSBNI=3Dy=0AC=
ONFIG=5FSBNI=5FMULTILINE=3Dy=0ACONFIG=5FATM=5FDRIVERS=3Dy=0ACONFIG=5FATM=5F=
DUMMY=3Dy=0ACONFIG=5FATM=5FTCP=3Dy=0ACONFIG=5FATM=5FLANAI=3Dy=0ACONFIG=5FAT=
M=5FENI=3Dy=0ACONFIG=5FATM=5FENI=5FDEBUG=3Dy=0ACONFIG=5FATM=5FENI=5FTUNE=5F=
BURST=3Dy=0ACONFIG=5FATM=5FENI=5FBURST=5FTX=5F16W=3Dy=0ACONFIG=5FATM=5FENI=
=5FBURST=5FTX=5F8W=3Dy=0ACONFIG=5FATM=5FENI=5FBURST=5FTX=5F4W=3Dy=0ACONFIG=
=5FATM=5FENI=5FBURST=5FTX=5F2W=3Dy=0ACONFIG=5FATM=5FENI=5FBURST=5FRX=5F16W=
=3Dy=0ACONFIG=5FATM=5FENI=5FBURST=5FRX=5F8W=3Dy=0ACONFIG=5FATM=5FENI=5FBURS=
T=5FRX=5F4W=3Dy=0ACONFIG=5FATM=5FENI=5FBURST=5FRX=5F2W=3Dy=0ACONFIG=5FATM=
=5FFIRESTREAM=3Dy=0ACONFIG=5FATM=5FZATM=3Dy=0ACONFIG=5FATM=5FZATM=5FDEBUG=
=3Dy=0ACONFIG=5FATM=5FNICSTAR=3Dy=0ACONFIG=5FATM=5FNICSTAR=5FUSE=5FSUNI=3Dy=
=0ACONFIG=5FATM=5FNICSTAR=5FUSE=5FIDT77105=3Dy=0ACONFIG=5FATM=5FIDT77252=3D=
y=0ACONFIG=5FATM=5FIDT77252=5FDEBUG=3Dy=0ACONFIG=5FATM=5FIDT77252=5FRCV=5FA=
LL=3Dy=0ACONFIG=5FATM=5FIDT77252=5FUSE=5FSUNI=3Dy=0ACONFIG=5FATM=5FAMBASSAD=
OR=3Dy=0ACONFIG=5FATM=5FAMBASSADOR=5FDEBUG=3Dy=0ACONFIG=5FATM=5FHORIZON=3Dy=
=0ACONFIG=5FATM=5FHORIZON=5FDEBUG=3Dy=0ACONFIG=5FATM=5FIA=3Dy=0ACONFIG=5FAT=
M=5FIA=5FDEBUG=3Dy=0ACONFIG=5FATM=5FFORE200E=3Dy=0ACONFIG=5FATM=5FFORE200E=
=5FUSE=5FTASKLET=3Dy=0ACONFIG=5FATM=5FFORE200E=5FTX=5FRETRY=3D16=0ACONFIG=
=5FATM=5FFORE200E=5FDEBUG=3D0=0ACONFIG=5FATM=5FHE=3Dy=0ACONFIG=5FATM=5FHE=
=5FUSE=5FSUNI=3Dy=0ACONFIG=5FATM=5FSOLOS=3Dy=0ACONFIG=5FIEEE802154=5FDRIVER=
S=3Dy=0ACONFIG=5FIEEE802154=5FFAKEHARD=3Dy=0A=0A#=0A# CAIF transport driver=
s=0A#=0ACONFIG=5FCAIF=5FTTY=3Dy=0ACONFIG=5FCAIF=5FSPI=5FSLAVE=3Dy=0ACONFIG=
=5FCAIF=5FSPI=5FSYNC=3Dy=0ACONFIG=5FXEN=5FNETDEV=5FFRONTEND=3Dy=0ACONFIG=5F=
FDDI=3Dy=0ACONFIG=5FDEFXX=3Dy=0ACONFIG=5FDEFXX=5FMMIO=3Dy=0ACONFIG=5FSKFP=
=3Dy=0ACONFIG=5FHIPPI=3Dy=0ACONFIG=5FROADRUNNER=3Dy=0ACONFIG=5FROADRUNNER=
=5FLARGE=5FRINGS=3Dy=0ACONFIG=5FPLIP=3Dy=0ACONFIG=5FPPP=3Dy=0ACONFIG=5FPPP=
=5FMULTILINK=3Dy=0ACONFIG=5FPPP=5FFILTER=3Dy=0ACONFIG=5FPPP=5FASYNC=3Dy=0AC=
ONFIG=5FPPP=5FSYNC=5FTTY=3Dy=0ACONFIG=5FPPP=5FDEFLATE=3Dy=0ACONFIG=5FPPP=5F=
BSDCOMP=3Dy=0ACONFIG=5FPPP=5FMPPE=3Dy=0ACONFIG=5FPPPOE=3Dy=0ACONFIG=5FPPTP=
=3Dy=0ACONFIG=5FPPPOATM=3Dy=0ACONFIG=5FPPPOL2TP=3Dy=0ACONFIG=5FSLIP=3Dy=0AC=
ONFIG=5FSLIP=5FCOMPRESSED=3Dy=0ACONFIG=5FSLHC=3Dy=0ACONFIG=5FSLIP=5FSMART=
=3Dy=0ACONFIG=5FSLIP=5FMODE=5FSLIP6=3Dy=0ACONFIG=5FNET=5FFC=3Dy=0ACONFIG=5F=
NETCONSOLE=3Dy=0ACONFIG=5FNETCONSOLE=5FDYNAMIC=3Dy=0ACONFIG=5FNETPOLL=3Dy=
=0ACONFIG=5FNETPOLL=5FTRAP=3Dy=0ACONFIG=5FNET=5FPOLL=5FCONTROLLER=3Dy=0ACON=
FIG=5FVIRTIO=5FNET=3Dy=0ACONFIG=5FVMXNET3=3Dy=0ACONFIG=5FISDN=3Dy=0ACONFIG=
=5FISDN=5FI4L=3Dy=0ACONFIG=5FISDN=5FPPP=3Dy=0ACONFIG=5FISDN=5FPPP=5FVJ=3Dy=
=0ACONFIG=5FISDN=5FMPP=3Dy=0ACONFIG=5FIPPP=5FFILTER=3Dy=0ACONFIG=5FISDN=5FP=
PP=5FBSDCOMP=3Dy=0ACONFIG=5FISDN=5FAUDIO=3Dy=0ACONFIG=5FISDN=5FTTY=5FFAX=3D=
y=0ACONFIG=5FISDN=5FX25=3Dy=0A=0A#=0A# ISDN feature submodules=0A#=0ACONFIG=
=5FISDN=5FDIVERSION=3Dy=0A=0A#=0A# ISDN4Linux hardware drivers=0A#=0A=0A#=
=0A# Passive cards=0A#=0ACONFIG=5FISDN=5FDRV=5FHISAX=3Dy=0A=0A#=0A# D-chann=
el protocol features=0A#=0ACONFIG=5FHISAX=5FEURO=3Dy=0ACONFIG=5FDE=5FAOC=3D=
y=0ACONFIG=5FHISAX=5FNO=5FSENDCOMPLETE=3Dy=0ACONFIG=5FHISAX=5FNO=5FLLC=3Dy=
=0ACONFIG=5FHISAX=5FNO=5FKEYPAD=3Dy=0ACONFIG=5FHISAX=5F1TR6=3Dy=0ACONFIG=5F=
HISAX=5FNI1=3Dy=0ACONFIG=5FHISAX=5FMAX=5FCARDS=3D8=0A=0A#=0A# HiSax support=
ed cards=0A#=0ACONFIG=5FHISAX=5F16=5F3=3Dy=0ACONFIG=5FHISAX=5FTELESPCI=3Dy=
=0ACONFIG=5FHISAX=5FS0BOX=3Dy=0ACONFIG=5FHISAX=5FFRITZPCI=3Dy=0ACONFIG=5FHI=
SAX=5FAVM=5FA1=5FPCMCIA=3Dy=0ACONFIG=5FHISAX=5FELSA=3Dy=0ACONFIG=5FHISAX=5F=
DIEHLDIVA=3Dy=0ACONFIG=5FHISAX=5FSEDLBAUER=3Dy=0ACONFIG=5FHISAX=5FNETJET=3D=
y=0ACONFIG=5FHISAX=5FNETJET=5FU=3Dy=0ACONFIG=5FHISAX=5FNICCY=3Dy=0ACONFIG=
=5FHISAX=5FBKM=5FA4T=3Dy=0ACONFIG=5FHISAX=5FSCT=5FQUADRO=3Dy=0ACONFIG=5FHIS=
AX=5FGAZEL=3Dy=0ACONFIG=5FHISAX=5FHFC=5FPCI=3Dy=0ACONFIG=5FHISAX=5FW6692=3D=
y=0ACONFIG=5FHISAX=5FHFC=5FSX=3Dy=0ACONFIG=5FHISAX=5FENTERNOW=5FPCI=3Dy=0AC=
ONFIG=5FHISAX=5FDEBUG=3Dy=0A=0A#=0A# HiSax PCMCIA card service modules=0A#=
=0ACONFIG=5FHISAX=5FSEDLBAUER=5FCS=3Dy=0ACONFIG=5FHISAX=5FELSA=5FCS=3Dy=0AC=
ONFIG=5FHISAX=5FAVM=5FA1=5FCS=3Dy=0ACONFIG=5FHISAX=5FTELES=5FCS=3Dy=0A=0A#=
=0A# HiSax sub driver modules=0A#=0ACONFIG=5FHISAX=5FST5481=3Dy=0ACONFIG=5F=
HISAX=5FHFCUSB=3Dy=0ACONFIG=5FHISAX=5FHFC4S8S=3Dy=0ACONFIG=5FHISAX=5FFRITZ=
=5FPCIPNP=3Dy=0A=0A#=0A# Active cards=0A#=0ACONFIG=5FISDN=5FCAPI=3Dy=0ACONF=
IG=5FISDN=5FDRV=5FAVMB1=5FVERBOSE=5FREASON=3Dy=0ACONFIG=5FCAPI=5FTRACE=3Dy=
=0ACONFIG=5FISDN=5FCAPI=5FMIDDLEWARE=3Dy=0ACONFIG=5FISDN=5FCAPI=5FCAPI20=3D=
y=0ACONFIG=5FISDN=5FCAPI=5FCAPIFS=5FBOOL=3Dy=0ACONFIG=5FISDN=5FCAPI=5FCAPIF=
S=3Dy=0ACONFIG=5FISDN=5FCAPI=5FCAPIDRV=3Dy=0A=0A#=0A# CAPI hardware drivers=
=0A#=0ACONFIG=5FCAPI=5FAVM=3Dy=0ACONFIG=5FISDN=5FDRV=5FAVMB1=5FB1PCI=3Dy=0A=
CONFIG=5FISDN=5FDRV=5FAVMB1=5FB1PCIV4=3Dy=0ACONFIG=5FISDN=5FDRV=5FAVMB1=5FB=
1PCMCIA=3Dy=0ACONFIG=5FISDN=5FDRV=5FAVMB1=5FAVM=5FCS=3Dy=0ACONFIG=5FISDN=5F=
DRV=5FAVMB1=5FT1PCI=3Dy=0ACONFIG=5FISDN=5FDRV=5FAVMB1=5FC4=3Dy=0ACONFIG=5FC=
API=5FEICON=3Dy=0ACONFIG=5FISDN=5FDIVAS=3Dy=0ACONFIG=5FISDN=5FDIVAS=5FBRIPC=
I=3Dy=0ACONFIG=5FISDN=5FDIVAS=5FPRIPCI=3Dy=0ACONFIG=5FISDN=5FDIVAS=5FDIVACA=
PI=3Dy=0ACONFIG=5FISDN=5FDIVAS=5FUSERIDI=3Dy=0ACONFIG=5FISDN=5FDIVAS=5FMAIN=
T=3Dm=0ACONFIG=5FISDN=5FDRV=5FGIGASET=3Dy=0ACONFIG=5FGIGASET=5FCAPI=3Dy=0A#=
 CONFIG=5FGIGASET=5FI4L is not set=0A# CONFIG=5FGIGASET=5FDUMMYLL is not se=
t=0ACONFIG=5FGIGASET=5FBASE=3Dy=0ACONFIG=5FGIGASET=5FM105=3Dy=0ACONFIG=5FGI=
GASET=5FM101=3Dy=0ACONFIG=5FGIGASET=5FDEBUG=3Dy=0ACONFIG=5FHYSDN=3Dm=0ACONF=
IG=5FHYSDN=5FCAPI=3Dy=0ACONFIG=5FMISDN=3Dy=0ACONFIG=5FMISDN=5FDSP=3Dy=0ACON=
FIG=5FMISDN=5FL1OIP=3Dy=0A=0A#=0A# mISDN hardware drivers=0A#=0ACONFIG=5FMI=
SDN=5FHFCPCI=3Dy=0ACONFIG=5FMISDN=5FHFCMULTI=3Dy=0ACONFIG=5FMISDN=5FHFCUSB=
=3Dy=0ACONFIG=5FMISDN=5FAVMFRITZ=3Dy=0ACONFIG=5FMISDN=5FSPEEDFAX=3Dy=0ACONF=
IG=5FMISDN=5FINFINEON=3Dy=0ACONFIG=5FMISDN=5FW6692=3Dy=0ACONFIG=5FMISDN=5FN=
ETJET=3Dy=0ACONFIG=5FMISDN=5FIPAC=3Dy=0ACONFIG=5FMISDN=5FISAR=3Dy=0ACONFIG=
=5FISDN=5FHDLC=3Dy=0ACONFIG=5FPHONE=3Dy=0ACONFIG=5FPHONE=5FIXJ=3Dy=0ACONFIG=
=5FPHONE=5FIXJ=5FPCMCIA=3Dy=0A=0A#=0A# Input device support=0A#=0ACONFIG=5F=
INPUT=3Dy=0ACONFIG=5FINPUT=5FFF=5FMEMLESS=3Dy=0ACONFIG=5FINPUT=5FPOLLDEV=3D=
y=0ACONFIG=5FINPUT=5FSPARSEKMAP=3Dy=0A=0A#=0A# Userland interfaces=0A#=0ACO=
NFIG=5FINPUT=5FMOUSEDEV=3Dy=0ACONFIG=5FINPUT=5FMOUSEDEV=5FPSAUX=3Dy=0ACONFI=
G=5FINPUT=5FMOUSEDEV=5FSCREEN=5FX=3D1024=0ACONFIG=5FINPUT=5FMOUSEDEV=5FSCRE=
EN=5FY=3D768=0ACONFIG=5FINPUT=5FJOYDEV=3Dy=0ACONFIG=5FINPUT=5FEVDEV=3Dy=0AC=
ONFIG=5FINPUT=5FEVBUG=3Dy=0ACONFIG=5FXEN=5FKBDDEV=5FFRONTEND=3Dy=0A=0A#=0A#=
 Input Device Drivers=0A#=0ACONFIG=5FINPUT=5FKEYBOARD=3Dy=0ACONFIG=5FKEYBOA=
RD=5FADP5520=3Dy=0ACONFIG=5FKEYBOARD=5FADP5588=3Dy=0ACONFIG=5FKEYBOARD=5FAT=
KBD=3Dy=0ACONFIG=5FKEYBOARD=5FQT2160=3Dy=0ACONFIG=5FKEYBOARD=5FLKKBD=3Dy=0A=
CONFIG=5FKEYBOARD=5FGPIO=3Dy=0ACONFIG=5FKEYBOARD=5FGPIO=5FPOLLED=3Dy=0ACONF=
IG=5FKEYBOARD=5FTCA6416=3Dy=0ACONFIG=5FKEYBOARD=5FMATRIX=3Dy=0ACONFIG=5FKEY=
BOARD=5FLM8323=3Dy=0ACONFIG=5FKEYBOARD=5FMAX7359=3Dy=0ACONFIG=5FKEYBOARD=5F=
MCS=3Dy=0ACONFIG=5FKEYBOARD=5FNEWTON=3Dy=0ACONFIG=5FKEYBOARD=5FOPENCORES=3D=
y=0ACONFIG=5FKEYBOARD=5FSTOWAWAY=3Dy=0ACONFIG=5FKEYBOARD=5FSUNKBD=3Dy=0ACON=
FIG=5FKEYBOARD=5FSTMPE=3Dy=0ACONFIG=5FKEYBOARD=5FTC3589X=3Dy=0ACONFIG=5FKEY=
BOARD=5FTWL4030=3Dy=0ACONFIG=5FKEYBOARD=5FXTKBD=3Dy=0ACONFIG=5FINPUT=5FMOUS=
E=3Dy=0ACONFIG=5FMOUSE=5FPS2=3Dy=0ACONFIG=5FMOUSE=5FPS2=5FALPS=3Dy=0ACONFIG=
=5FMOUSE=5FPS2=5FLOGIPS2PP=3Dy=0ACONFIG=5FMOUSE=5FPS2=5FSYNAPTICS=3Dy=0ACON=
FIG=5FMOUSE=5FPS2=5FLIFEBOOK=3Dy=0ACONFIG=5FMOUSE=5FPS2=5FTRACKPOINT=3Dy=0A=
CONFIG=5FMOUSE=5FPS2=5FELANTECH=3Dy=0ACONFIG=5FMOUSE=5FPS2=5FSENTELIC=3Dy=
=0ACONFIG=5FMOUSE=5FPS2=5FTOUCHKIT=3Dy=0ACONFIG=5FMOUSE=5FSERIAL=3Dy=0ACONF=
IG=5FMOUSE=5FAPPLETOUCH=3Dy=0ACONFIG=5FMOUSE=5FBCM5974=3Dy=0ACONFIG=5FMOUSE=
=5FVSXXXAA=3Dy=0ACONFIG=5FMOUSE=5FGPIO=3Dy=0ACONFIG=5FMOUSE=5FSYNAPTICS=5FI=
2C=3Dy=0ACONFIG=5FINPUT=5FJOYSTICK=3Dy=0ACONFIG=5FJOYSTICK=5FANALOG=3Dy=0AC=
ONFIG=5FJOYSTICK=5FA3D=3Dy=0ACONFIG=5FJOYSTICK=5FADI=3Dy=0ACONFIG=5FJOYSTIC=
K=5FCOBRA=3Dy=0ACONFIG=5FJOYSTICK=5FGF2K=3Dy=0ACONFIG=5FJOYSTICK=5FGRIP=3Dy=
=0ACONFIG=5FJOYSTICK=5FGRIP=5FMP=3Dy=0ACONFIG=5FJOYSTICK=5FGUILLEMOT=3Dy=0A=
CONFIG=5FJOYSTICK=5FINTERACT=3Dy=0ACONFIG=5FJOYSTICK=5FSIDEWINDER=3Dy=0ACON=
FIG=5FJOYSTICK=5FTMDC=3Dy=0ACONFIG=5FJOYSTICK=5FIFORCE=3Dy=0ACONFIG=5FJOYST=
ICK=5FIFORCE=5FUSB=3Dy=0ACONFIG=5FJOYSTICK=5FIFORCE=5F232=3Dy=0ACONFIG=5FJO=
YSTICK=5FWARRIOR=3Dy=0ACONFIG=5FJOYSTICK=5FMAGELLAN=3Dy=0ACONFIG=5FJOYSTICK=
=5FSPACEORB=3Dy=0ACONFIG=5FJOYSTICK=5FSPACEBALL=3Dy=0ACONFIG=5FJOYSTICK=5FS=
TINGER=3Dy=0ACONFIG=5FJOYSTICK=5FTWIDJOY=3Dy=0ACONFIG=5FJOYSTICK=5FZHENHUA=
=3Dy=0ACONFIG=5FJOYSTICK=5FDB9=3Dy=0ACONFIG=5FJOYSTICK=5FGAMECON=3Dy=0ACONF=
IG=5FJOYSTICK=5FTURBOGRAFX=3Dy=0ACONFIG=5FJOYSTICK=5FAS5011=3Dy=0ACONFIG=5F=
JOYSTICK=5FJOYDUMP=3Dy=0ACONFIG=5FJOYSTICK=5FXPAD=3Dy=0ACONFIG=5FJOYSTICK=
=5FXPAD=5FFF=3Dy=0ACONFIG=5FJOYSTICK=5FXPAD=5FLEDS=3Dy=0ACONFIG=5FJOYSTICK=
=5FWALKERA0701=3Dy=0ACONFIG=5FINPUT=5FTABLET=3Dy=0ACONFIG=5FTABLET=5FUSB=5F=
ACECAD=3Dy=0ACONFIG=5FTABLET=5FUSB=5FAIPTEK=3Dy=0ACONFIG=5FTABLET=5FUSB=5FG=
TCO=3Dy=0ACONFIG=5FTABLET=5FUSB=5FHANWANG=3Dy=0ACONFIG=5FTABLET=5FUSB=5FKBT=
AB=3Dy=0ACONFIG=5FTABLET=5FUSB=5FWACOM=3Dy=0ACONFIG=5FINPUT=5FTOUCHSCREEN=
=3Dy=0ACONFIG=5FTOUCHSCREEN=5F88PM860X=3Dy=0ACONFIG=5FTOUCHSCREEN=5FADS7846=
=3Dy=0ACONFIG=5FTOUCHSCREEN=5FAD7877=3Dy=0ACONFIG=5FTOUCHSCREEN=5FAD7879=3D=
y=0ACONFIG=5FTOUCHSCREEN=5FAD7879=5FI2C=3Dy=0ACONFIG=5FTOUCHSCREEN=5FAD7879=
=5FSPI=3Dy=0ACONFIG=5FTOUCHSCREEN=5FBU21013=3Dy=0ACONFIG=5FTOUCHSCREEN=5FCY=
8CTMG110=3Dy=0ACONFIG=5FTOUCHSCREEN=5FDA9034=3Dy=0ACONFIG=5FTOUCHSCREEN=5FD=
YNAPRO=3Dy=0ACONFIG=5FTOUCHSCREEN=5FHAMPSHIRE=3Dy=0ACONFIG=5FTOUCHSCREEN=5F=
EETI=3Dy=0ACONFIG=5FTOUCHSCREEN=5FFUJITSU=3Dy=0ACONFIG=5FTOUCHSCREEN=5FGUNZ=
E=3Dy=0ACONFIG=5FTOUCHSCREEN=5FELO=3Dy=0ACONFIG=5FTOUCHSCREEN=5FWACOM=5FW80=
01=3Dy=0ACONFIG=5FTOUCHSCREEN=5FMCS5000=3Dy=0ACONFIG=5FTOUCHSCREEN=5FMTOUCH=
=3Dy=0ACONFIG=5FTOUCHSCREEN=5FINEXIO=3Dy=0ACONFIG=5FTOUCHSCREEN=5FMK712=3Dy=
=0ACONFIG=5FTOUCHSCREEN=5FPENMOUNT=3Dy=0ACONFIG=5FTOUCHSCREEN=5FQT602240=3D=
y=0ACONFIG=5FTOUCHSCREEN=5FTOUCHRIGHT=3Dy=0ACONFIG=5FTOUCHSCREEN=5FTOUCHWIN=
=3Dy=0ACONFIG=5FTOUCHSCREEN=5FUCB1400=3Dy=0ACONFIG=5FTOUCHSCREEN=5FWM97XX=
=3Dy=0ACONFIG=5FTOUCHSCREEN=5FWM9705=3Dy=0ACONFIG=5FTOUCHSCREEN=5FWM9712=3D=
y=0ACONFIG=5FTOUCHSCREEN=5FWM9713=3Dy=0ACONFIG=5FTOUCHSCREEN=5FUSB=5FCOMPOS=
ITE=3Dy=0ACONFIG=5FTOUCHSCREEN=5FMC13783=3Dy=0ACONFIG=5FTOUCHSCREEN=5FUSB=
=5FEGALAX=3Dy=0ACONFIG=5FTOUCHSCREEN=5FUSB=5FPANJIT=3Dy=0ACONFIG=5FTOUCHSCR=
EEN=5FUSB=5F3M=3Dy=0ACONFIG=5FTOUCHSCREEN=5FUSB=5FITM=3Dy=0ACONFIG=5FTOUCHS=
CREEN=5FUSB=5FETURBO=3Dy=0ACONFIG=5FTOUCHSCREEN=5FUSB=5FGUNZE=3Dy=0ACONFIG=
=5FTOUCHSCREEN=5FUSB=5FDMC=5FTSC10=3Dy=0ACONFIG=5FTOUCHSCREEN=5FUSB=5FIRTOU=
CH=3Dy=0ACONFIG=5FTOUCHSCREEN=5FUSB=5FIDEALTEK=3Dy=0ACONFIG=5FTOUCHSCREEN=
=5FUSB=5FGENERAL=5FTOUCH=3Dy=0ACONFIG=5FTOUCHSCREEN=5FUSB=5FGOTOP=3Dy=0ACON=
FIG=5FTOUCHSCREEN=5FUSB=5FJASTEC=3Dy=0ACONFIG=5FTOUCHSCREEN=5FUSB=5FE2I=3Dy=
=0ACONFIG=5FTOUCHSCREEN=5FUSB=5FZYTRONIC=3Dy=0ACONFIG=5FTOUCHSCREEN=5FUSB=
=5FETT=5FTC45USB=3Dy=0ACONFIG=5FTOUCHSCREEN=5FUSB=5FNEXIO=3Dy=0ACONFIG=5FTO=
UCHSCREEN=5FTOUCHIT213=3Dy=0ACONFIG=5FTOUCHSCREEN=5FTSC2007=3Dy=0ACONFIG=5F=
TOUCHSCREEN=5FPCAP=3Dy=0ACONFIG=5FTOUCHSCREEN=5FST1232=3Dy=0ACONFIG=5FTOUCH=
SCREEN=5FSTMPE=3Dy=0ACONFIG=5FTOUCHSCREEN=5FTPS6507X=3Dy=0ACONFIG=5FINPUT=
=5FMISC=3Dy=0ACONFIG=5FINPUT=5F88PM860X=5FONKEY=3Dy=0ACONFIG=5FINPUT=5FAB85=
00=5FPONKEY=3Dy=0ACONFIG=5FINPUT=5FAD714X=3Dy=0ACONFIG=5FINPUT=5FAD714X=5FI=
2C=3Dy=0ACONFIG=5FINPUT=5FAD714X=5FSPI=3Dy=0ACONFIG=5FINPUT=5FPCSPKR=3Dy=0A=
CONFIG=5FINPUT=5FMAX8925=5FONKEY=3Dy=0ACONFIG=5FINPUT=5FAPANEL=3Dy=0ACONFIG=
=5FINPUT=5FATLAS=5FBTNS=3Dy=0ACONFIG=5FINPUT=5FATI=5FREMOTE=3Dy=0ACONFIG=5F=
INPUT=5FATI=5FREMOTE2=3Dy=0ACONFIG=5FINPUT=5FKEYSPAN=5FREMOTE=3Dy=0ACONFIG=
=5FINPUT=5FPOWERMATE=3Dy=0ACONFIG=5FINPUT=5FYEALINK=3Dy=0ACONFIG=5FINPUT=5F=
CM109=3Dy=0ACONFIG=5FINPUT=5FTWL4030=5FPWRBUTTON=3Dy=0ACONFIG=5FINPUT=5FTWL=
4030=5FVIBRA=3Dy=0ACONFIG=5FINPUT=5FUINPUT=3Dy=0ACONFIG=5FINPUT=5FPCF50633=
=5FPMU=3Dy=0ACONFIG=5FINPUT=5FPCF8574=3Dy=0ACONFIG=5FINPUT=5FGPIO=5FROTARY=
=5FENCODER=3Dy=0ACONFIG=5FINPUT=5FWM831X=5FON=3Dy=0ACONFIG=5FINPUT=5FPCAP=
=3Dy=0ACONFIG=5FINPUT=5FADXL34X=3Dy=0ACONFIG=5FINPUT=5FADXL34X=5FI2C=3Dy=0A=
CONFIG=5FINPUT=5FADXL34X=5FSPI=3Dy=0ACONFIG=5FINPUT=5FCMA3000=3Dy=0ACONFIG=
=5FINPUT=5FCMA3000=5FI2C=3Dy=0A=0A#=0A# Hardware I/O ports=0A#=0ACONFIG=5FS=
ERIO=3Dy=0ACONFIG=5FSERIO=5FI8042=3Dy=0ACONFIG=5FSERIO=5FSERPORT=3Dy=0ACONF=
IG=5FSERIO=5FCT82C710=3Dy=0ACONFIG=5FSERIO=5FPARKBD=3Dy=0ACONFIG=5FSERIO=5F=
PCIPS2=3Dy=0ACONFIG=5FSERIO=5FLIBPS2=3Dy=0ACONFIG=5FSERIO=5FRAW=3Dy=0ACONFI=
G=5FSERIO=5FALTERA=5FPS2=3Dy=0ACONFIG=5FSERIO=5FPS2MULT=3Dy=0ACONFIG=5FGAME=
PORT=3Dy=0ACONFIG=5FGAMEPORT=5FNS558=3Dy=0ACONFIG=5FGAMEPORT=5FL4=3Dy=0ACON=
FIG=5FGAMEPORT=5FEMU10K1=3Dy=0ACONFIG=5FGAMEPORT=5FFM801=3Dy=0A=0A#=0A# Cha=
racter devices=0A#=0ACONFIG=5FVT=3Dy=0ACONFIG=5FCONSOLE=5FTRANSLATIONS=3Dy=
=0ACONFIG=5FVT=5FCONSOLE=3Dy=0ACONFIG=5FHW=5FCONSOLE=3Dy=0ACONFIG=5FVT=5FHW=
=5FCONSOLE=5FBINDING=3Dy=0ACONFIG=5FDEVKMEM=3Dy=0ACONFIG=5FSERIAL=5FNONSTAN=
DARD=3Dy=0ACONFIG=5FCOMPUTONE=3Dy=0ACONFIG=5FROCKETPORT=3Dy=0ACONFIG=5FCYCL=
ADES=3Dy=0ACONFIG=5FCYZ=5FINTR=3Dy=0ACONFIG=5FDIGIEPCA=3Dy=0ACONFIG=5FMOXA=
=5FINTELLIO=3Dy=0ACONFIG=5FMOXA=5FSMARTIO=3Dy=0ACONFIG=5FISI=3Dy=0ACONFIG=
=5FSYNCLINK=3Dy=0ACONFIG=5FSYNCLINKMP=3Dy=0ACONFIG=5FSYNCLINK=5FGT=3Dy=0ACO=
NFIG=5FN=5FHDLC=3Dy=0ACONFIG=5FN=5FGSM=3Dy=0ACONFIG=5FRISCOM8=3Dy=0ACONFIG=
=5FSPECIALIX=3Dy=0ACONFIG=5FSTALDRV=3Dy=0ACONFIG=5FSTALLION=3Dy=0ACONFIG=5F=
ISTALLION=3Dy=0ACONFIG=5FNOZOMI=3Dy=0A=0A#=0A# Serial drivers=0A#=0ACONFIG=
=5FSERIAL=5F8250=3Dy=0ACONFIG=5FSERIAL=5F8250=5FCONSOLE=3Dy=0ACONFIG=5FFIX=
=5FEARLYCON=5FMEM=3Dy=0ACONFIG=5FSERIAL=5F8250=5FPCI=3Dy=0ACONFIG=5FSERIAL=
=5F8250=5FPNP=3Dy=0ACONFIG=5FSERIAL=5F8250=5FCS=3Dy=0ACONFIG=5FSERIAL=5F825=
0=5FNR=5FUARTS=3D4=0ACONFIG=5FSERIAL=5F8250=5FRUNTIME=5FUARTS=3D4=0ACONFIG=
=5FSERIAL=5F8250=5FEXTENDED=3Dy=0ACONFIG=5FSERIAL=5F8250=5FMANY=5FPORTS=3Dy=
=0ACONFIG=5FSERIAL=5F8250=5FSHARE=5FIRQ=3Dy=0ACONFIG=5FSERIAL=5F8250=5FDETE=
CT=5FIRQ=3Dy=0ACONFIG=5FSERIAL=5F8250=5FRSA=3Dy=0A=0A#=0A# Non-8250 serial =
port support=0A#=0ACONFIG=5FSERIAL=5FMAX3100=3Dy=0ACONFIG=5FSERIAL=5FMAX310=
7=3Dy=0ACONFIG=5FSERIAL=5FMRST=5FMAX3110=3Dy=0ACONFIG=5FSERIAL=5FMFD=5FHSU=
=3Dy=0ACONFIG=5FSERIAL=5FMFD=5FHSU=5FCONSOLE=3Dy=0ACONFIG=5FSERIAL=5FUARTLI=
TE=3Dy=0ACONFIG=5FSERIAL=5FUARTLITE=5FCONSOLE=3Dy=0ACONFIG=5FSERIAL=5FCORE=
=3Dy=0ACONFIG=5FSERIAL=5FCORE=5FCONSOLE=3Dy=0ACONFIG=5FCONSOLE=5FPOLL=3Dy=
=0ACONFIG=5FSERIAL=5FJSM=3Dy=0ACONFIG=5FSERIAL=5FTIMBERDALE=3Dy=0ACONFIG=5F=
SERIAL=5FALTERA=5FJTAGUART=3Dy=0ACONFIG=5FSERIAL=5FALTERA=5FJTAGUART=5FCONS=
OLE=3Dy=0ACONFIG=5FSERIAL=5FALTERA=5FJTAGUART=5FCONSOLE=5FBYPASS=3Dy=0ACONF=
IG=5FSERIAL=5FALTERA=5FUART=3Dy=0ACONFIG=5FSERIAL=5FALTERA=5FUART=5FMAXPORT=
S=3D4=0ACONFIG=5FSERIAL=5FALTERA=5FUART=5FBAUDRATE=3D115200=0ACONFIG=5FSERI=
AL=5FALTERA=5FUART=5FCONSOLE=3Dy=0ACONFIG=5FSERIAL=5FIFX6X60=3Dy=0ACONFIG=
=5FSERIAL=5FPCH=5FUART=3Dy=0ACONFIG=5FUNIX98=5FPTYS=3Dy=0ACONFIG=5FDEVPTS=
=5FMULTIPLE=5FINSTANCES=3Dy=0ACONFIG=5FLEGACY=5FPTYS=3Dy=0ACONFIG=5FLEGACY=
=5FPTY=5FCOUNT=3D256=0ACONFIG=5FTTY=5FPRINTK=3Dy=0ACONFIG=5FPRINTER=3Dy=0AC=
ONFIG=5FLP=5FCONSOLE=3Dy=0ACONFIG=5FPPDEV=3Dy=0ACONFIG=5FHVC=5FDRIVER=3Dy=
=0ACONFIG=5FHVC=5FIRQ=3Dy=0ACONFIG=5FHVC=5FXEN=3Dy=0ACONFIG=5FVIRTIO=5FCONS=
OLE=3Dy=0ACONFIG=5FIPMI=5FHANDLER=3Dy=0ACONFIG=5FIPMI=5FPANIC=5FEVENT=3Dy=
=0ACONFIG=5FIPMI=5FPANIC=5FSTRING=3Dy=0ACONFIG=5FIPMI=5FDEVICE=5FINTERFACE=
=3Dy=0ACONFIG=5FIPMI=5FSI=3Dy=0ACONFIG=5FIPMI=5FWATCHDOG=3Dy=0ACONFIG=5FIPM=
I=5FPOWEROFF=3Dy=0ACONFIG=5FHW=5FRANDOM=3Dy=0ACONFIG=5FHW=5FRANDOM=5FTIMERI=
OMEM=3Dy=0ACONFIG=5FHW=5FRANDOM=5FINTEL=3Dy=0ACONFIG=5FHW=5FRANDOM=5FAMD=3D=
y=0ACONFIG=5FHW=5FRANDOM=5FVIA=3Dy=0ACONFIG=5FHW=5FRANDOM=5FVIRTIO=3Dy=0ACO=
NFIG=5FNVRAM=3Dy=0ACONFIG=5FR3964=3Dy=0ACONFIG=5FAPPLICOM=3Dy=0A=0A#=0A# PC=
MCIA character devices=0A#=0ACONFIG=5FSYNCLINK=5FCS=3Dy=0ACONFIG=5FCARDMAN=
=5F4000=3Dy=0ACONFIG=5FCARDMAN=5F4040=3Dy=0ACONFIG=5FIPWIRELESS=3Dy=0ACONFI=
G=5FMWAVE=3Dy=0ACONFIG=5FRAW=5FDRIVER=3Dy=0ACONFIG=5FMAX=5FRAW=5FDEVS=3D256=
=0ACONFIG=5FHPET=3Dy=0ACONFIG=5FHPET=5FMMAP=3Dy=0ACONFIG=5FHANGCHECK=5FTIME=
R=3Dy=0ACONFIG=5FUV=5FMMTIMER=3Dy=0ACONFIG=5FTCG=5FTPM=3Dy=0ACONFIG=5FTCG=
=5FTIS=3Dy=0ACONFIG=5FTCG=5FNSC=3Dy=0ACONFIG=5FTCG=5FATMEL=3Dy=0ACONFIG=5FT=
CG=5FINFINEON=3Dy=0ACONFIG=5FTELCLOCK=3Dy=0ACONFIG=5FDEVPORT=3Dy=0ACONFIG=
=5FRAMOOPS=3Dy=0ACONFIG=5FI2C=3Dy=0ACONFIG=5FI2C=5FBOARDINFO=3Dy=0ACONFIG=
=5FI2C=5FCOMPAT=3Dy=0ACONFIG=5FI2C=5FCHARDEV=3Dy=0ACONFIG=5FI2C=5FMUX=3Dy=
=0A=0A#=0A# Multiplexer I2C Chip support=0A#=0ACONFIG=5FI2C=5FMUX=5FGPIO=3D=
y=0ACONFIG=5FI2C=5FMUX=5FPCA9541=3Dy=0ACONFIG=5FI2C=5FMUX=5FPCA954x=3Dy=0AC=
ONFIG=5FI2C=5FHELPER=5FAUTO=3Dy=0ACONFIG=5FI2C=5FSMBUS=3Dy=0ACONFIG=5FI2C=
=5FALGOBIT=3Dy=0ACONFIG=5FI2C=5FALGOPCA=3Dy=0A=0A#=0A# I2C Hardware Bus sup=
port=0A#=0A=0A#=0A# PC SMBus host controller drivers=0A#=0ACONFIG=5FI2C=5FA=
LI1535=3Dy=0ACONFIG=5FI2C=5FALI1563=3Dy=0ACONFIG=5FI2C=5FALI15X3=3Dy=0ACONF=
IG=5FI2C=5FAMD756=3Dy=0ACONFIG=5FI2C=5FAMD756=5FS4882=3Dy=0ACONFIG=5FI2C=5F=
AMD8111=3Dy=0ACONFIG=5FI2C=5FI801=3Dy=0ACONFIG=5FI2C=5FISCH=3Dy=0ACONFIG=5F=
I2C=5FPIIX4=3Dy=0ACONFIG=5FI2C=5FNFORCE2=3Dy=0ACONFIG=5FI2C=5FNFORCE2=5FS49=
85=3Dy=0ACONFIG=5FI2C=5FSIS5595=3Dy=0ACONFIG=5FI2C=5FSIS630=3Dy=0ACONFIG=5F=
I2C=5FSIS96X=3Dy=0ACONFIG=5FI2C=5FVIA=3Dy=0ACONFIG=5FI2C=5FVIAPRO=3Dy=0A=0A=
#=0A# ACPI drivers=0A#=0ACONFIG=5FI2C=5FSCMI=3Dy=0A=0A#=0A# I2C system bus =
drivers (mostly embedded / system-on-chip)=0A#=0ACONFIG=5FI2C=5FGPIO=3Dy=0A=
CONFIG=5FI2C=5FINTEL=5FMID=3Dy=0ACONFIG=5FI2C=5FOCORES=3Dy=0ACONFIG=5FI2C=
=5FPCA=5FPLATFORM=3Dy=0ACONFIG=5FI2C=5FSIMTEC=3Dy=0ACONFIG=5FI2C=5FXILINX=
=3Dy=0ACONFIG=5FI2C=5FEG20T=3Dy=0A=0A#=0A# External I2C/SMBus adapter drive=
rs=0A#=0ACONFIG=5FI2C=5FPARPORT=3Dy=0ACONFIG=5FI2C=5FPARPORT=5FLIGHT=3Dy=0A=
CONFIG=5FI2C=5FTAOS=5FEVM=3Dy=0ACONFIG=5FI2C=5FTINY=5FUSB=3Dy=0A=0A#=0A# Ot=
her I2C/SMBus bus drivers=0A#=0ACONFIG=5FI2C=5FSTUB=3Dm=0ACONFIG=5FI2C=5FDE=
BUG=5FCORE=3Dy=0ACONFIG=5FI2C=5FDEBUG=5FALGO=3Dy=0ACONFIG=5FI2C=5FDEBUG=5FB=
US=3Dy=0ACONFIG=5FSPI=3Dy=0ACONFIG=5FSPI=5FDEBUG=3Dy=0ACONFIG=5FSPI=5FMASTE=
R=3Dy=0A=0A#=0A# SPI Master Controller Drivers=0A#=0ACONFIG=5FSPI=5FBITBANG=
=3Dy=0ACONFIG=5FSPI=5FBUTTERFLY=3Dy=0ACONFIG=5FSPI=5FGPIO=3Dy=0ACONFIG=5FSP=
I=5FLM70=5FLLP=3Dy=0A# CONFIG=5FSPI=5FPXA2XX=5FPCI is not set=0ACONFIG=5FSP=
I=5FTOPCLIFF=5FPCH=3Dy=0ACONFIG=5FSPI=5FXILINX=3Dy=0ACONFIG=5FSPI=5FDESIGNW=
ARE=3Dy=0ACONFIG=5FSPI=5FDW=5FPCI=3Dy=0ACONFIG=5FSPI=5FDW=5FMID=5FDMA=3Dy=
=0A=0A#=0A# SPI Protocol Masters=0A#=0ACONFIG=5FSPI=5FSPIDEV=3Dy=0ACONFIG=
=5FSPI=5FTLE62X0=3Dy=0A=0A#=0A# PPS support=0A#=0ACONFIG=5FPPS=3Dy=0ACONFIG=
=5FPPS=5FDEBUG=3Dy=0A=0A#=0A# PPS clients support=0A#=0ACONFIG=5FPPS=5FCLIE=
NT=5FKTIMER=3Dy=0ACONFIG=5FPPS=5FCLIENT=5FLDISC=3Dy=0ACONFIG=5FPPS=5FCLIENT=
=5FPARPORT=3Dy=0A=0A#=0A# PPS generators support=0A#=0ACONFIG=5FPPS=5FGENER=
ATOR=5FPARPORT=3Dy=0ACONFIG=5FARCH=5FWANT=5FOPTIONAL=5FGPIOLIB=3Dy=0ACONFIG=
=5FGPIOLIB=3Dy=0ACONFIG=5FDEBUG=5FGPIO=3Dy=0ACONFIG=5FGPIO=5FSYSFS=3Dy=0ACO=
NFIG=5FGPIO=5FMAX730X=3Dy=0A=0A#=0A# Memory mapped GPIO expanders:=0A#=0ACO=
NFIG=5FGPIO=5FBASIC=5FMMIO=3Dy=0ACONFIG=5FGPIO=5FIT8761E=3Dy=0ACONFIG=5FGPI=
O=5FSCH=3Dy=0ACONFIG=5FGPIO=5FVX855=3Dy=0A=0A#=0A# I2C GPIO expanders:=0A#=
=0ACONFIG=5FGPIO=5FMAX7300=3Dy=0ACONFIG=5FGPIO=5FMAX732X=3Dy=0ACONFIG=5FGPI=
O=5FMAX732X=5FIRQ=3Dy=0ACONFIG=5FGPIO=5FPCA953X=3Dy=0ACONFIG=5FGPIO=5FPCA95=
3X=5FIRQ=3Dy=0ACONFIG=5FGPIO=5FPCF857X=3Dy=0ACONFIG=5FGPIO=5FSX150X=3Dy=0AC=
ONFIG=5FGPIO=5FSTMPE=3Dy=0ACONFIG=5FGPIO=5FTC3589X=3Dy=0ACONFIG=5FGPIO=5FTW=
L4030=3Dy=0ACONFIG=5FGPIO=5FWM831X=3Dy=0ACONFIG=5FGPIO=5FWM8350=3Dy=0ACONFI=
G=5FGPIO=5FWM8994=3Dy=0ACONFIG=5FGPIO=5FADP5520=3Dy=0ACONFIG=5FGPIO=5FADP55=
88=3Dy=0ACONFIG=5FGPIO=5FADP5588=5FIRQ=3Dy=0A=0A#=0A# PCI GPIO expanders:=
=0A#=0ACONFIG=5FGPIO=5FCS5535=3Dy=0ACONFIG=5FGPIO=5FLANGWELL=3Dy=0ACONFIG=
=5FGPIO=5FPCH=3Dy=0ACONFIG=5FGPIO=5FML=5FIOH=3Dy=0ACONFIG=5FGPIO=5FTIMBERDA=
LE=3Dy=0ACONFIG=5FGPIO=5FRDC321X=3Dy=0A=0A#=0A# SPI GPIO expanders:=0A#=0AC=
ONFIG=5FGPIO=5FMAX7301=3Dy=0ACONFIG=5FGPIO=5FMCP23S08=3Dy=0ACONFIG=5FGPIO=
=5FMC33880=3Dy=0ACONFIG=5FGPIO=5F74X164=3Dy=0A=0A#=0A# AC97 GPIO expanders:=
=0A#=0ACONFIG=5FGPIO=5FUCB1400=3Dy=0A=0A#=0A# MODULbus GPIO expanders:=0A#=
=0ACONFIG=5FGPIO=5FJANZ=5FTTL=3Dy=0ACONFIG=5FW1=3Dy=0ACONFIG=5FW1=5FCON=3Dy=
=0A=0A#=0A# 1-wire Bus Masters=0A#=0ACONFIG=5FW1=5FMASTER=5FMATROX=3Dy=0ACO=
NFIG=5FW1=5FMASTER=5FDS2490=3Dy=0ACONFIG=5FW1=5FMASTER=5FDS2482=3Dy=0ACONFI=
G=5FW1=5FMASTER=5FGPIO=3Dy=0A=0A#=0A# 1-wire Slaves=0A#=0ACONFIG=5FW1=5FSLA=
VE=5FTHERM=3Dy=0ACONFIG=5FW1=5FSLAVE=5FSMEM=3Dy=0ACONFIG=5FW1=5FSLAVE=5FDS2=
423=3Dy=0ACONFIG=5FW1=5FSLAVE=5FDS2431=3Dy=0ACONFIG=5FW1=5FSLAVE=5FDS2433=
=3Dy=0ACONFIG=5FW1=5FSLAVE=5FDS2433=5FCRC=3Dy=0ACONFIG=5FW1=5FSLAVE=5FDS276=
0=3Dy=0ACONFIG=5FW1=5FSLAVE=5FBQ27000=3Dy=0ACONFIG=5FPOWER=5FSUPPLY=3Dy=0AC=
ONFIG=5FPOWER=5FSUPPLY=5FDEBUG=3Dy=0ACONFIG=5FPDA=5FPOWER=3Dy=0ACONFIG=5FMA=
X8925=5FPOWER=3Dy=0ACONFIG=5FWM831X=5FBACKUP=3Dy=0ACONFIG=5FWM831X=5FPOWER=
=3Dy=0ACONFIG=5FWM8350=5FPOWER=3Dy=0ACONFIG=5FTEST=5FPOWER=3Dy=0ACONFIG=5FB=
ATTERY=5FDS2760=3Dy=0ACONFIG=5FBATTERY=5FDS2782=3Dy=0ACONFIG=5FBATTERY=5FWM=
97XX=3Dy=0ACONFIG=5FBATTERY=5FBQ20Z75=3Dy=0ACONFIG=5FBATTERY=5FBQ27x00=3Dy=
=0ACONFIG=5FBATTERY=5FDA9030=3Dy=0ACONFIG=5FBATTERY=5FMAX17040=3Dy=0ACONFIG=
=5FBATTERY=5FMAX17042=3Dy=0ACONFIG=5FCHARGER=5FPCF50633=3Dy=0ACONFIG=5FCHAR=
GER=5FISP1704=3Dy=0ACONFIG=5FCHARGER=5FTWL4030=3Dy=0ACONFIG=5FCHARGER=5FGPI=
O=3Dy=0ACONFIG=5FHWMON=3Dy=0ACONFIG=5FHWMON=5FVID=3Dy=0ACONFIG=5FHWMON=5FDE=
BUG=5FCHIP=3Dy=0A=0A#=0A# Native drivers=0A#=0ACONFIG=5FSENSORS=5FABITUGURU=
=3Dy=0ACONFIG=5FSENSORS=5FABITUGURU3=3Dy=0ACONFIG=5FSENSORS=5FAD7414=3Dy=0A=
CONFIG=5FSENSORS=5FAD7418=3Dy=0ACONFIG=5FSENSORS=5FADCXX=3Dy=0ACONFIG=5FSEN=
SORS=5FADM1021=3Dy=0ACONFIG=5FSENSORS=5FADM1025=3Dy=0ACONFIG=5FSENSORS=5FAD=
M1026=3Dy=0ACONFIG=5FSENSORS=5FADM1029=3Dy=0ACONFIG=5FSENSORS=5FADM1031=3Dy=
=0ACONFIG=5FSENSORS=5FADM9240=3Dy=0ACONFIG=5FSENSORS=5FADT7411=3Dy=0ACONFIG=
=5FSENSORS=5FADT7462=3Dy=0ACONFIG=5FSENSORS=5FADT7470=3Dy=0ACONFIG=5FSENSOR=
S=5FADT7475=3Dy=0ACONFIG=5FSENSORS=5FASC7621=3Dy=0ACONFIG=5FSENSORS=5FK8TEM=
P=3Dy=0ACONFIG=5FSENSORS=5FK10TEMP=3Dy=0ACONFIG=5FSENSORS=5FASB100=3Dy=0ACO=
NFIG=5FSENSORS=5FATXP1=3Dy=0ACONFIG=5FSENSORS=5FDS620=3Dy=0ACONFIG=5FSENSOR=
S=5FDS1621=3Dy=0ACONFIG=5FSENSORS=5FI5K=5FAMB=3Dy=0ACONFIG=5FSENSORS=5FF718=
05F=3Dy=0ACONFIG=5FSENSORS=5FF71882FG=3Dy=0ACONFIG=5FSENSORS=5FF75375S=3Dy=
=0ACONFIG=5FSENSORS=5FFSCHMD=3Dy=0ACONFIG=5FSENSORS=5FG760A=3Dy=0ACONFIG=5F=
SENSORS=5FGL518SM=3Dy=0ACONFIG=5FSENSORS=5FGL520SM=3Dy=0ACONFIG=5FSENSORS=
=5FGPIO=5FFAN=3Dy=0ACONFIG=5FSENSORS=5FCORETEMP=3Dy=0ACONFIG=5FSENSORS=5FPK=
GTEMP=3Dy=0ACONFIG=5FSENSORS=5FIBMAEM=3Dy=0ACONFIG=5FSENSORS=5FIBMPEX=3Dy=
=0ACONFIG=5FSENSORS=5FIT87=3Dy=0ACONFIG=5FSENSORS=5FJC42=3Dy=0ACONFIG=5FSEN=
SORS=5FLM63=3Dy=0ACONFIG=5FSENSORS=5FLM70=3Dy=0ACONFIG=5FSENSORS=5FLM73=3Dy=
=0ACONFIG=5FSENSORS=5FLM75=3Dy=0ACONFIG=5FSENSORS=5FLM77=3Dy=0ACONFIG=5FSEN=
SORS=5FLM78=3Dy=0ACONFIG=5FSENSORS=5FLM80=3Dy=0ACONFIG=5FSENSORS=5FLM83=3Dy=
=0ACONFIG=5FSENSORS=5FLM85=3Dy=0ACONFIG=5FSENSORS=5FLM87=3Dy=0ACONFIG=5FSEN=
SORS=5FLM90=3Dy=0ACONFIG=5FSENSORS=5FLM92=3Dy=0ACONFIG=5FSENSORS=5FLM93=3Dy=
=0ACONFIG=5FSENSORS=5FLTC4215=3Dy=0ACONFIG=5FSENSORS=5FLTC4245=3Dy=0ACONFIG=
=5FSENSORS=5FLTC4261=3Dy=0ACONFIG=5FSENSORS=5FLM95241=3Dy=0ACONFIG=5FSENSOR=
S=5FMAX1111=3Dy=0ACONFIG=5FSENSORS=5FMAX1619=3Dy=0ACONFIG=5FSENSORS=5FMAX66=
50=3Dy=0ACONFIG=5FSENSORS=5FPC87360=3Dy=0ACONFIG=5FSENSORS=5FPC87427=3Dy=0A=
CONFIG=5FSENSORS=5FPCF8591=3Dy=0ACONFIG=5FSENSORS=5FSHT15=3Dy=0ACONFIG=5FSE=
NSORS=5FSHT21=3Dy=0ACONFIG=5FSENSORS=5FSIS5595=3Dy=0ACONFIG=5FSENSORS=5FSMM=
665=3Dy=0ACONFIG=5FSENSORS=5FDME1737=3Dy=0ACONFIG=5FSENSORS=5FEMC1403=3Dy=
=0ACONFIG=5FSENSORS=5FEMC2103=3Dy=0ACONFIG=5FSENSORS=5FSMSC47M1=3Dy=0ACONFI=
G=5FSENSORS=5FSMSC47M192=3Dy=0ACONFIG=5FSENSORS=5FSMSC47B397=3Dy=0ACONFIG=
=5FSENSORS=5FADS7828=3Dy=0ACONFIG=5FSENSORS=5FADS7871=3Dy=0ACONFIG=5FSENSOR=
S=5FAMC6821=3Dy=0ACONFIG=5FSENSORS=5FTHMC50=3Dy=0ACONFIG=5FSENSORS=5FTMP102=
=3Dy=0ACONFIG=5FSENSORS=5FTMP401=3Dy=0ACONFIG=5FSENSORS=5FTMP421=3Dy=0ACONF=
IG=5FSENSORS=5FVIA=5FCPUTEMP=3Dy=0ACONFIG=5FSENSORS=5FVIA686A=3Dy=0ACONFIG=
=5FSENSORS=5FVT1211=3Dy=0ACONFIG=5FSENSORS=5FVT8231=3Dy=0ACONFIG=5FSENSORS=
=5FW83781D=3Dy=0ACONFIG=5FSENSORS=5FW83791D=3Dy=0ACONFIG=5FSENSORS=5FW83792=
D=3Dy=0ACONFIG=5FSENSORS=5FW83793=3Dy=0ACONFIG=5FSENSORS=5FW83795=3Dy=0ACON=
FIG=5FSENSORS=5FW83795=5FFANCTRL=3Dy=0ACONFIG=5FSENSORS=5FW83L785TS=3Dy=0AC=
ONFIG=5FSENSORS=5FW83L786NG=3Dy=0ACONFIG=5FSENSORS=5FW83627HF=3Dy=0ACONFIG=
=5FSENSORS=5FW83627EHF=3Dy=0ACONFIG=5FSENSORS=5FWM831X=3Dy=0ACONFIG=5FSENSO=
RS=5FWM8350=3Dy=0ACONFIG=5FSENSORS=5FLIS3=5FI2C=3Dy=0ACONFIG=5FSENSORS=5FAP=
PLESMC=3Dy=0ACONFIG=5FSENSORS=5FMC13783=5FADC=3Dy=0A=0A#=0A# ACPI drivers=
=0A#=0ACONFIG=5FSENSORS=5FATK0110=3Dy=0ACONFIG=5FSENSORS=5FLIS3LV02D=3Dy=0A=
CONFIG=5FTHERMAL=3Dy=0ACONFIG=5FTHERMAL=5FHWMON=3Dy=0ACONFIG=5FWATCHDOG=3Dy=
=0ACONFIG=5FWATCHDOG=5FNOWAYOUT=3Dy=0A=0A#=0A# Watchdog Device Drivers=0A#=
=0ACONFIG=5FSOFT=5FWATCHDOG=3Dy=0ACONFIG=5FWM831X=5FWATCHDOG=3Dy=0ACONFIG=
=5FWM8350=5FWATCHDOG=3Dy=0ACONFIG=5FTWL4030=5FWATCHDOG=3Dy=0ACONFIG=5FACQUI=
RE=5FWDT=3Dy=0ACONFIG=5FADVANTECH=5FWDT=3Dy=0ACONFIG=5FALIM1535=5FWDT=3Dy=
=0ACONFIG=5FALIM7101=5FWDT=3Dy=0ACONFIG=5FF71808E=5FWDT=3Dy=0ACONFIG=5FSP51=
00=5FTCO=3Dy=0ACONFIG=5FGEODE=5FWDT=3Dy=0ACONFIG=5FSC520=5FWDT=3Dy=0ACONFIG=
=5FSBC=5FFITPC2=5FWATCHDOG=3Dy=0ACONFIG=5FEUROTECH=5FWDT=3Dy=0ACONFIG=5FIB7=
00=5FWDT=3Dy=0ACONFIG=5FIBMASR=3Dy=0ACONFIG=5FWAFER=5FWDT=3Dy=0ACONFIG=5FI6=
300ESB=5FWDT=3Dy=0ACONFIG=5FITCO=5FWDT=3Dy=0ACONFIG=5FITCO=5FVENDOR=5FSUPPO=
RT=3Dy=0ACONFIG=5FIT8712F=5FWDT=3Dy=0ACONFIG=5FIT87=5FWDT=3Dy=0ACONFIG=5FHP=
=5FWATCHDOG=3Dy=0ACONFIG=5FHPWDT=5FNMI=5FDECODING=3Dy=0ACONFIG=5FSC1200=5FW=
DT=3Dy=0ACONFIG=5FPC87413=5FWDT=3Dy=0ACONFIG=5FNV=5FTCO=3Dy=0ACONFIG=5F60XX=
=5FWDT=3Dy=0ACONFIG=5FSBC8360=5FWDT=3Dy=0ACONFIG=5FCPU5=5FWDT=3Dy=0ACONFIG=
=5FSMSC=5FSCH311X=5FWDT=3Dy=0ACONFIG=5FSMSC37B787=5FWDT=3Dy=0ACONFIG=5FW836=
27HF=5FWDT=3Dy=0ACONFIG=5FW83697HF=5FWDT=3Dy=0ACONFIG=5FW83697UG=5FWDT=3Dy=
=0ACONFIG=5FW83877F=5FWDT=3Dy=0ACONFIG=5FW83977F=5FWDT=3Dy=0ACONFIG=5FMACHZ=
=5FWDT=3Dy=0ACONFIG=5FSBC=5FEPX=5FC3=5FWATCHDOG=3Dy=0A=0A#=0A# PCI-based Wa=
tchdog Cards=0A#=0ACONFIG=5FPCIPCWATCHDOG=3Dy=0ACONFIG=5FWDTPCI=3Dy=0A=0A#=
=0A# USB-based Watchdog Cards=0A#=0ACONFIG=5FUSBPCWATCHDOG=3Dy=0ACONFIG=5FS=
SB=5FPOSSIBLE=3Dy=0A=0A#=0A# Sonics Silicon Backplane=0A#=0ACONFIG=5FSSB=3D=
y=0ACONFIG=5FSSB=5FSPROM=3Dy=0ACONFIG=5FSSB=5FBLOCKIO=3Dy=0ACONFIG=5FSSB=5F=
PCIHOST=5FPOSSIBLE=3Dy=0ACONFIG=5FSSB=5FPCIHOST=3Dy=0ACONFIG=5FSSB=5FB43=5F=
PCI=5FBRIDGE=3Dy=0ACONFIG=5FSSB=5FPCMCIAHOST=5FPOSSIBLE=3Dy=0ACONFIG=5FSSB=
=5FPCMCIAHOST=3Dy=0ACONFIG=5FSSB=5FSDIOHOST=5FPOSSIBLE=3Dy=0ACONFIG=5FSSB=
=5FSDIOHOST=3Dy=0ACONFIG=5FSSB=5FSILENT=3Dy=0ACONFIG=5FSSB=5FDRIVER=5FPCICO=
RE=5FPOSSIBLE=3Dy=0ACONFIG=5FSSB=5FDRIVER=5FPCICORE=3Dy=0ACONFIG=5FMFD=5FSU=
PPORT=3Dy=0ACONFIG=5FMFD=5FCORE=3Dy=0ACONFIG=5FMFD=5F88PM860X=3Dy=0ACONFIG=
=5FMFD=5FSM501=3Dy=0ACONFIG=5FMFD=5FSM501=5FGPIO=3Dy=0ACONFIG=5FHTC=5FPASIC=
3=3Dy=0ACONFIG=5FHTC=5FI2CPLD=3Dy=0ACONFIG=5FUCB1400=5FCORE=3Dy=0ACONFIG=5F=
TPS65010=3Dy=0ACONFIG=5FTPS6507X=3Dy=0ACONFIG=5FTWL4030=5FCORE=3Dy=0ACONFIG=
=5FTWL4030=5FCODEC=3Dy=0ACONFIG=5FTWL6030=5FPWM=3Dy=0ACONFIG=5FMFD=5FSTMPE=
=3Dy=0ACONFIG=5FMFD=5FTC3589X=3Dy=0A# CONFIG=5FMFD=5FTMIO is not set=0ACONF=
IG=5FPMIC=5FDA903X=3Dy=0ACONFIG=5FPMIC=5FADP5520=3Dy=0ACONFIG=5FMFD=5FMAX89=
25=3Dy=0ACONFIG=5FMFD=5FMAX8998=3Dy=0ACONFIG=5FMFD=5FWM8400=3Dy=0ACONFIG=5F=
MFD=5FWM831X=3Dy=0ACONFIG=5FMFD=5FWM831X=5FI2C=3Dy=0ACONFIG=5FMFD=5FWM831X=
=5FSPI=3Dy=0ACONFIG=5FMFD=5FWM8350=3Dy=0ACONFIG=5FMFD=5FWM8350=5FI2C=3Dy=0A=
CONFIG=5FMFD=5FWM8994=3Dy=0ACONFIG=5FMFD=5FPCF50633=3Dy=0ACONFIG=5FMFD=5FMC=
13783=3Dy=0ACONFIG=5FMFD=5FMC13XXX=3Dy=0ACONFIG=5FPCF50633=5FADC=3Dy=0ACONF=
IG=5FPCF50633=5FGPIO=3Dy=0ACONFIG=5FABX500=5FCORE=3Dy=0ACONFIG=5FAB3100=5FC=
ORE=3Dy=0ACONFIG=5FAB3100=5FOTP=3Dy=0ACONFIG=5FEZX=5FPCAP=3Dy=0ACONFIG=5FAB=
8500=5FCORE=3Dy=0ACONFIG=5FAB8500=5FDEBUG=3Dy=0ACONFIG=5FAB3550=5FCORE=3Dy=
=0ACONFIG=5FMFD=5FCS5535=3Dy=0ACONFIG=5FMFD=5FTIMBERDALE=3Dy=0ACONFIG=5FLPC=
=5FSCH=3Dy=0ACONFIG=5FMFD=5FRDC321X=3Dy=0ACONFIG=5FMFD=5FJANZ=5FCMODIO=3Dy=
=0ACONFIG=5FMFD=5FTPS6586X=3Dy=0ACONFIG=5FMFD=5FVX855=3Dy=0ACONFIG=5FMFD=5F=
WL1273=5FCORE=3Dy=0ACONFIG=5FREGULATOR=3Dy=0ACONFIG=5FREGULATOR=5FDEBUG=3Dy=
=0ACONFIG=5FREGULATOR=5FDUMMY=3Dy=0ACONFIG=5FREGULATOR=5FFIXED=5FVOLTAGE=3D=
y=0ACONFIG=5FREGULATOR=5FVIRTUAL=5FCONSUMER=3Dy=0ACONFIG=5FREGULATOR=5FUSER=
SPACE=5FCONSUMER=3Dy=0ACONFIG=5FREGULATOR=5FBQ24022=3Dy=0ACONFIG=5FREGULATO=
R=5FMAX1586=3Dy=0ACONFIG=5FREGULATOR=5FMAX8649=3Dy=0ACONFIG=5FREGULATOR=5FM=
AX8660=3Dy=0ACONFIG=5FREGULATOR=5FMAX8925=3Dy=0ACONFIG=5FREGULATOR=5FMAX895=
2=3Dy=0ACONFIG=5FREGULATOR=5FMAX8998=3Dy=0ACONFIG=5FREGULATOR=5FTWL4030=3Dy=
=0ACONFIG=5FREGULATOR=5FWM831X=3Dy=0ACONFIG=5FREGULATOR=5FWM8350=3Dy=0ACONF=
IG=5FREGULATOR=5FWM8400=3Dy=0ACONFIG=5FREGULATOR=5FWM8994=3Dy=0ACONFIG=5FRE=
GULATOR=5FDA903X=3Dy=0ACONFIG=5FREGULATOR=5FPCF50633=3Dy=0ACONFIG=5FREGULAT=
OR=5FLP3971=3Dy=0ACONFIG=5FREGULATOR=5FLP3972=3Dy=0ACONFIG=5FREGULATOR=5FPC=
AP=3Dy=0ACONFIG=5FREGULATOR=5FMC13XXX=5FCORE=3Dy=0ACONFIG=5FREGULATOR=5FMC1=
3783=3Dy=0ACONFIG=5FREGULATOR=5FMC13892=3Dy=0ACONFIG=5FREGULATOR=5FAB3100=
=3Dy=0ACONFIG=5FREGULATOR=5FTPS65023=3Dy=0ACONFIG=5FREGULATOR=5FTPS6507X=3D=
y=0ACONFIG=5FREGULATOR=5F88PM8607=3Dy=0ACONFIG=5FREGULATOR=5FISL6271A=3Dy=
=0ACONFIG=5FREGULATOR=5FAD5398=3Dy=0ACONFIG=5FREGULATOR=5FAB8500=3Dy=0ACONF=
IG=5FREGULATOR=5FTPS6586X=3Dy=0ACONFIG=5FREGULATOR=5FTPS6524X=3Dy=0ACONFIG=
=5FMEDIA=5FSUPPORT=3Dy=0A=0A#=0A# Multimedia core support=0A#=0ACONFIG=5FVI=
DEO=5FDEV=3Dy=0ACONFIG=5FVIDEO=5FV4L2=5FCOMMON=3Dy=0ACONFIG=5FDVB=5FCORE=3D=
y=0ACONFIG=5FVIDEO=5FMEDIA=3Dy=0A=0A#=0A# Multimedia drivers=0A#=0ACONFIG=
=5FVIDEO=5FSAA7146=3Dy=0ACONFIG=5FVIDEO=5FSAA7146=5FVV=3Dy=0ACONFIG=5FRC=5F=
CORE=3Dy=0ACONFIG=5FLIRC=3Dy=0ACONFIG=5FRC=5FMAP=3Dy=0ACONFIG=5FIR=5FNEC=5F=
DECODER=3Dy=0ACONFIG=5FIR=5FRC5=5FDECODER=3Dy=0ACONFIG=5FIR=5FRC6=5FDECODER=
=3Dy=0ACONFIG=5FIR=5FJVC=5FDECODER=3Dy=0ACONFIG=5FIR=5FSONY=5FDECODER=3Dy=
=0ACONFIG=5FIR=5FRC5=5FSZ=5FDECODER=3Dy=0ACONFIG=5FIR=5FLIRC=5FCODEC=3Dy=0A=
CONFIG=5FIR=5FENE=3Dy=0ACONFIG=5FIR=5FIMON=3Dy=0ACONFIG=5FIR=5FMCEUSB=3Dy=
=0ACONFIG=5FIR=5FNUVOTON=3Dy=0ACONFIG=5FIR=5FSTREAMZAP=3Dy=0ACONFIG=5FIR=5F=
WINBOND=5FCIR=3Dy=0ACONFIG=5FRC=5FLOOPBACK=3Dy=0ACONFIG=5FMEDIA=5FATTACH=3D=
y=0ACONFIG=5FMEDIA=5FTUNER=3Dy=0ACONFIG=5FMEDIA=5FTUNER=5FCUSTOMISE=3Dy=0A=
=0A#=0A# Customize TV tuners=0A#=0ACONFIG=5FMEDIA=5FTUNER=5FSIMPLE=3Dy=0ACO=
NFIG=5FMEDIA=5FTUNER=5FTDA8290=3Dy=0ACONFIG=5FMEDIA=5FTUNER=5FTDA827X=3Dy=
=0ACONFIG=5FMEDIA=5FTUNER=5FTDA18271=3Dy=0ACONFIG=5FMEDIA=5FTUNER=5FTDA9887=
=3Dy=0ACONFIG=5FMEDIA=5FTUNER=5FTEA5761=3Dy=0ACONFIG=5FMEDIA=5FTUNER=5FTEA5=
767=3Dy=0ACONFIG=5FMEDIA=5FTUNER=5FMT20XX=3Dy=0ACONFIG=5FMEDIA=5FTUNER=5FMT=
2060=3Dy=0ACONFIG=5FMEDIA=5FTUNER=5FMT2266=3Dy=0ACONFIG=5FMEDIA=5FTUNER=5FM=
T2131=3Dy=0ACONFIG=5FMEDIA=5FTUNER=5FQT1010=3Dy=0ACONFIG=5FMEDIA=5FTUNER=5F=
XC2028=3Dy=0ACONFIG=5FMEDIA=5FTUNER=5FXC5000=3Dy=0ACONFIG=5FMEDIA=5FTUNER=
=5FMXL5005S=3Dy=0ACONFIG=5FMEDIA=5FTUNER=5FMXL5007T=3Dy=0ACONFIG=5FMEDIA=5F=
TUNER=5FMC44S803=3Dy=0ACONFIG=5FMEDIA=5FTUNER=5FMAX2165=3Dy=0ACONFIG=5FMEDI=
A=5FTUNER=5FTDA18218=3Dy=0ACONFIG=5FVIDEO=5FV4L2=3Dy=0ACONFIG=5FVIDEOBUF=5F=
GEN=3Dy=0ACONFIG=5FVIDEOBUF=5FDMA=5FSG=3Dy=0ACONFIG=5FVIDEOBUF=5FVMALLOC=3D=
y=0ACONFIG=5FVIDEOBUF=5FDMA=5FCONTIG=3Dy=0ACONFIG=5FVIDEOBUF=5FDVB=3Dy=0ACO=
NFIG=5FVIDEO=5FBTCX=3Dy=0ACONFIG=5FVIDEO=5FTVEEPROM=3Dy=0ACONFIG=5FVIDEO=5F=
TUNER=3Dy=0ACONFIG=5FV4L2=5FMEM2MEM=5FDEV=3Dy=0ACONFIG=5FVIDEO=5FCAPTURE=5F=
DRIVERS=3Dy=0ACONFIG=5FVIDEO=5FADV=5FDEBUG=3Dy=0ACONFIG=5FVIDEO=5FFIXED=5FM=
INOR=5FRANGES=3Dy=0ACONFIG=5FVIDEO=5FHELPER=5FCHIPS=5FAUTO=3Dy=0ACONFIG=5FV=
IDEO=5FIR=5FI2C=3Dy=0A=0A#=0A# Audio decoders=0A#=0ACONFIG=5FVIDEO=5FTVAUDI=
O=3Dy=0ACONFIG=5FVIDEO=5FTDA7432=3Dy=0ACONFIG=5FVIDEO=5FTDA9840=3Dy=0ACONFI=
G=5FVIDEO=5FTEA6415C=3Dy=0ACONFIG=5FVIDEO=5FTEA6420=3Dy=0ACONFIG=5FVIDEO=5F=
MSP3400=3Dy=0ACONFIG=5FVIDEO=5FCS5345=3Dy=0ACONFIG=5FVIDEO=5FCS53L32A=3Dy=
=0ACONFIG=5FVIDEO=5FM52790=3Dy=0ACONFIG=5FVIDEO=5FWM8775=3Dy=0ACONFIG=5FVID=
EO=5FWM8739=3Dy=0ACONFIG=5FVIDEO=5FVP27SMPX=3Dy=0A=0A#=0A# RDS decoders=0A#=
=0ACONFIG=5FVIDEO=5FSAA6588=3Dy=0A=0A#=0A# Video decoders=0A#=0ACONFIG=5FVI=
DEO=5FADV7180=3Dy=0ACONFIG=5FVIDEO=5FBT819=3Dy=0ACONFIG=5FVIDEO=5FBT856=3Dy=
=0ACONFIG=5FVIDEO=5FBT866=3Dy=0ACONFIG=5FVIDEO=5FKS0127=3Dy=0ACONFIG=5FVIDE=
O=5FOV7670=3Dy=0ACONFIG=5FVIDEO=5FMT9V011=3Dy=0ACONFIG=5FVIDEO=5FSAA7110=3D=
y=0ACONFIG=5FVIDEO=5FSAA711X=3Dy=0ACONFIG=5FVIDEO=5FSAA717X=3Dy=0ACONFIG=5F=
VIDEO=5FTVP5150=3Dy=0ACONFIG=5FVIDEO=5FVPX3220=3Dy=0A=0A#=0A# Video and aud=
io decoders=0A#=0ACONFIG=5FVIDEO=5FCX25840=3Dy=0A=0A#=0A# MPEG video encode=
rs=0A#=0ACONFIG=5FVIDEO=5FCX2341X=3Dy=0A=0A#=0A# Video encoders=0A#=0ACONFI=
G=5FVIDEO=5FSAA7127=3Dy=0ACONFIG=5FVIDEO=5FSAA7185=3Dy=0ACONFIG=5FVIDEO=5FA=
DV7170=3Dy=0ACONFIG=5FVIDEO=5FADV7175=3Dy=0A=0A#=0A# Video improvement chip=
s=0A#=0ACONFIG=5FVIDEO=5FUPD64031A=3Dy=0ACONFIG=5FVIDEO=5FUPD64083=3Dy=0ACO=
NFIG=5FVIDEO=5FVIVI=3Dy=0ACONFIG=5FVIDEO=5FBT848=3Dy=0ACONFIG=5FVIDEO=5FBT8=
48=5FDVB=3Dy=0ACONFIG=5FVIDEO=5FBWQCAM=3Dy=0ACONFIG=5FVIDEO=5FCQCAM=3Dy=0AC=
ONFIG=5FVIDEO=5FW9966=3Dy=0ACONFIG=5FVIDEO=5FCPIA2=3Dy=0ACONFIG=5FVIDEO=5FZ=
ORAN=3Dy=0ACONFIG=5FVIDEO=5FZORAN=5FDC30=3Dy=0ACONFIG=5FVIDEO=5FZORAN=5FZR3=
6060=3Dy=0ACONFIG=5FVIDEO=5FZORAN=5FBUZ=3Dy=0ACONFIG=5FVIDEO=5FZORAN=5FDC10=
=3Dy=0ACONFIG=5FVIDEO=5FZORAN=5FLML33=3Dy=0ACONFIG=5FVIDEO=5FZORAN=5FLML33R=
10=3Dy=0ACONFIG=5FVIDEO=5FZORAN=5FAVS6EYES=3Dy=0ACONFIG=5FVIDEO=5FMEYE=3Dy=
=0ACONFIG=5FVIDEO=5FSAA7134=3Dy=0ACONFIG=5FVIDEO=5FSAA7134=5FALSA=3Dy=0ACON=
FIG=5FVIDEO=5FSAA7134=5FRC=3Dy=0ACONFIG=5FVIDEO=5FSAA7134=5FDVB=3Dy=0ACONFI=
G=5FVIDEO=5FMXB=3Dy=0ACONFIG=5FVIDEO=5FHEXIUM=5FORION=3Dy=0ACONFIG=5FVIDEO=
=5FHEXIUM=5FGEMINI=3Dy=0ACONFIG=5FVIDEO=5FTIMBERDALE=3Dy=0ACONFIG=5FVIDEO=
=5FCX88=3Dy=0ACONFIG=5FVIDEO=5FCX88=5FALSA=3Dy=0ACONFIG=5FVIDEO=5FCX88=5FBL=
ACKBIRD=3Dy=0ACONFIG=5FVIDEO=5FCX88=5FDVB=3Dy=0ACONFIG=5FVIDEO=5FCX88=5FMPE=
G=3Dy=0ACONFIG=5FVIDEO=5FCX88=5FVP3054=3Dy=0ACONFIG=5FVIDEO=5FCX23885=3Dy=
=0ACONFIG=5FVIDEO=5FAU0828=3Dy=0ACONFIG=5FVIDEO=5FIVTV=3Dy=0ACONFIG=5FVIDEO=
=5FFB=5FIVTV=3Dy=0ACONFIG=5FVIDEO=5FCX18=3Dy=0ACONFIG=5FVIDEO=5FCX18=5FALSA=
=3Dy=0ACONFIG=5FVIDEO=5FSAA7164=3Dy=0ACONFIG=5FVIDEO=5FCAFE=5FCCIC=3Dy=0ACO=
NFIG=5FVIDEO=5FSR030PC30=3Dy=0ACONFIG=5FVIDEO=5FVIA=5FCAMERA=3Dy=0ACONFIG=
=5FSOC=5FCAMERA=3Dy=0ACONFIG=5FSOC=5FCAMERA=5FIMX074=3Dy=0ACONFIG=5FSOC=5FC=
AMERA=5FMT9M001=3Dy=0ACONFIG=5FSOC=5FCAMERA=5FMT9M111=3Dy=0ACONFIG=5FSOC=5F=
CAMERA=5FMT9T031=3Dy=0ACONFIG=5FSOC=5FCAMERA=5FMT9T112=3Dy=0ACONFIG=5FSOC=
=5FCAMERA=5FMT9V022=3Dy=0ACONFIG=5FSOC=5FCAMERA=5FRJ54N1=3Dy=0ACONFIG=5FSOC=
=5FCAMERA=5FTW9910=3Dy=0ACONFIG=5FSOC=5FCAMERA=5FPLATFORM=3Dy=0ACONFIG=5FSO=
C=5FCAMERA=5FOV2640=3Dy=0ACONFIG=5FSOC=5FCAMERA=5FOV6650=3Dy=0ACONFIG=5FSOC=
=5FCAMERA=5FOV772X=3Dy=0ACONFIG=5FSOC=5FCAMERA=5FOV9640=3Dy=0ACONFIG=5FV4L=
=5FUSB=5FDRIVERS=3Dy=0ACONFIG=5FUSB=5FVIDEO=5FCLASS=3Dy=0ACONFIG=5FUSB=5FVI=
DEO=5FCLASS=5FINPUT=5FEVDEV=3Dy=0ACONFIG=5FUSB=5FGSPCA=3Dy=0ACONFIG=5FUSB=
=5FM5602=3Dy=0ACONFIG=5FUSB=5FSTV06XX=3Dy=0ACONFIG=5FUSB=5FGL860=3Dy=0ACONF=
IG=5FUSB=5FGSPCA=5FBENQ=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FCONEX=3Dy=0ACONFIG=5FU=
SB=5FGSPCA=5FCPIA1=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FETOMS=3Dy=0ACONFIG=5FUSB=5F=
GSPCA=5FFINEPIX=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FJEILINJ=3Dy=0ACONFIG=5FUSB=5FG=
SPCA=5FKONICA=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FMARS=3Dy=0ACONFIG=5FUSB=5FGSPCA=
=5FMR97310A=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FOV519=3Dy=0ACONFIG=5FUSB=5FGSPCA=
=5FOV534=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FOV534=5F9=3Dy=0ACONFIG=5FUSB=5FGSPCA=
=5FPAC207=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FPAC7302=3Dy=0ACONFIG=5FUSB=5FGSPCA=
=5FPAC7311=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FSN9C2028=3Dy=0ACONFIG=5FUSB=5FGSPCA=
=5FSN9C20X=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FSONIXB=3Dy=0ACONFIG=5FUSB=5FGSPCA=
=5FSONIXJ=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FSPCA500=3Dy=0ACONFIG=5FUSB=5FGSPCA=
=5FSPCA501=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FSPCA505=3Dy=0ACONFIG=5FUSB=5FGSPCA=
=5FSPCA506=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FSPCA508=3Dy=0ACONFIG=5FUSB=5FGSPCA=
=5FSPCA561=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FSPCA1528=3Dy=0ACONFIG=5FUSB=5FGSPCA=
=5FSQ905=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FSQ905C=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FS=
Q930X=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FSTK014=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FSTV0=
680=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FSUNPLUS=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FT613=
=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FTV8532=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FVC032X=3D=
y=0ACONFIG=5FUSB=5FGSPCA=5FXIRLINK=5FCIT=3Dy=0ACONFIG=5FUSB=5FGSPCA=5FZC3XX=
=3Dy=0ACONFIG=5FVIDEO=5FPVRUSB2=3Dy=0ACONFIG=5FVIDEO=5FPVRUSB2=5FSYSFS=3Dy=
=0ACONFIG=5FVIDEO=5FPVRUSB2=5FDVB=3Dy=0ACONFIG=5FVIDEO=5FPVRUSB2=5FDEBUGIFC=
=3Dy=0ACONFIG=5FVIDEO=5FHDPVR=3Dy=0ACONFIG=5FVIDEO=5FEM28XX=3Dy=0ACONFIG=5F=
VIDEO=5FEM28XX=5FALSA=3Dy=0ACONFIG=5FVIDEO=5FEM28XX=5FDVB=3Dy=0ACONFIG=5FVI=
DEO=5FTLG2300=3Dy=0ACONFIG=5FVIDEO=5FCX231XX=3Dy=0ACONFIG=5FVIDEO=5FCX231XX=
=5FRC=3Dy=0ACONFIG=5FVIDEO=5FCX231XX=5FALSA=3Dy=0ACONFIG=5FVIDEO=5FCX231XX=
=5FDVB=3Dy=0ACONFIG=5FVIDEO=5FUSBVISION=3Dy=0ACONFIG=5FUSB=5FET61X251=3Dy=
=0ACONFIG=5FUSB=5FSN9C102=3Dy=0ACONFIG=5FUSB=5FPWC=3Dy=0ACONFIG=5FUSB=5FPWC=
=5FDEBUG=3Dy=0ACONFIG=5FUSB=5FPWC=5FINPUT=5FEVDEV=3Dy=0ACONFIG=5FUSB=5FZR36=
4XX=3Dy=0ACONFIG=5FUSB=5FSTKWEBCAM=3Dy=0ACONFIG=5FUSB=5FS2255=3Dy=0ACONFIG=
=5FV4L=5FMEM2MEM=5FDRIVERS=3Dy=0ACONFIG=5FVIDEO=5FMEM2MEM=5FTESTDEV=3Dy=0AC=
ONFIG=5FRADIO=5FADAPTERS=3Dy=0ACONFIG=5FRADIO=5FMAXIRADIO=3Dy=0ACONFIG=5FRA=
DIO=5FMAESTRO=3Dy=0ACONFIG=5FI2C=5FSI4713=3Dy=0ACONFIG=5FRADIO=5FSI4713=3Dy=
=0ACONFIG=5FUSB=5FDSBR=3Dy=0ACONFIG=5FRADIO=5FSI470X=3Dy=0ACONFIG=5FUSB=5FS=
I470X=3Dy=0ACONFIG=5FUSB=5FMR800=3Dy=0ACONFIG=5FRADIO=5FTEA5764=3Dy=0ACONFI=
G=5FRADIO=5FTEA5764=5FXTAL=3Dy=0ACONFIG=5FRADIO=5FSAA7706H=3Dy=0ACONFIG=5FR=
ADIO=5FTEF6862=3Dy=0ACONFIG=5FRADIO=5FTIMBERDALE=3Dy=0ACONFIG=5FRADIO=5FWL1=
273=3Dy=0ACONFIG=5FDVB=5FMAX=5FADAPTERS=3D8=0ACONFIG=5FDVB=5FDYNAMIC=5FMINO=
RS=3Dy=0ACONFIG=5FDVB=5FCAPTURE=5FDRIVERS=3Dy=0A=0A#=0A# Supported SAA7146 =
based PCI Adapters=0A#=0ACONFIG=5FTTPCI=5FEEPROM=3Dy=0ACONFIG=5FDVB=5FAV711=
0=3Dy=0ACONFIG=5FDVB=5FAV7110=5FOSD=3Dy=0ACONFIG=5FDVB=5FBUDGET=5FCORE=3Dy=
=0ACONFIG=5FDVB=5FBUDGET=3Dy=0ACONFIG=5FDVB=5FBUDGET=5FCI=3Dy=0ACONFIG=5FDV=
B=5FBUDGET=5FAV=3Dy=0ACONFIG=5FDVB=5FBUDGET=5FPATCH=3Dy=0A=0A#=0A# Supporte=
d USB Adapters=0A#=0ACONFIG=5FDVB=5FUSB=3Dy=0ACONFIG=5FDVB=5FUSB=5FDEBUG=3D=
y=0ACONFIG=5FDVB=5FUSB=5FA800=3Dy=0ACONFIG=5FDVB=5FUSB=5FDIBUSB=5FMB=3Dy=0A=
CONFIG=5FDVB=5FUSB=5FDIBUSB=5FMB=5FFAULTY=3Dy=0ACONFIG=5FDVB=5FUSB=5FDIBUSB=
=5FMC=3Dy=0ACONFIG=5FDVB=5FUSB=5FDIB0700=3Dy=0ACONFIG=5FDVB=5FUSB=5FUMT=5F0=
10=3Dy=0ACONFIG=5FDVB=5FUSB=5FCXUSB=3Dy=0ACONFIG=5FDVB=5FUSB=5FM920X=3Dy=0A=
CONFIG=5FDVB=5FUSB=5FGL861=3Dy=0ACONFIG=5FDVB=5FUSB=5FAU6610=3Dy=0ACONFIG=
=5FDVB=5FUSB=5FDIGITV=3Dy=0ACONFIG=5FDVB=5FUSB=5FVP7045=3Dy=0ACONFIG=5FDVB=
=5FUSB=5FVP702X=3Dy=0ACONFIG=5FDVB=5FUSB=5FGP8PSK=3Dy=0ACONFIG=5FDVB=5FUSB=
=5FNOVA=5FT=5FUSB2=3Dy=0ACONFIG=5FDVB=5FUSB=5FTTUSB2=3Dy=0ACONFIG=5FDVB=5FU=
SB=5FDTT200U=3Dy=0ACONFIG=5FDVB=5FUSB=5FOPERA1=3Dy=0ACONFIG=5FDVB=5FUSB=5FA=
F9005=3Dy=0ACONFIG=5FDVB=5FUSB=5FAF9005=5FREMOTE=3Dy=0ACONFIG=5FDVB=5FUSB=
=5FDW2102=3Dy=0ACONFIG=5FDVB=5FUSB=5FCINERGY=5FT2=3Dy=0ACONFIG=5FDVB=5FUSB=
=5FANYSEE=3Dy=0ACONFIG=5FDVB=5FUSB=5FDTV5100=3Dy=0ACONFIG=5FDVB=5FUSB=5FAF9=
015=3Dy=0ACONFIG=5FDVB=5FUSB=5FCE6230=3Dy=0ACONFIG=5FDVB=5FUSB=5FFRIIO=3Dy=
=0ACONFIG=5FDVB=5FUSB=5FEC168=3Dy=0ACONFIG=5FDVB=5FUSB=5FAZ6027=3Dy=0ACONFI=
G=5FDVB=5FUSB=5FLME2510=3Dy=0ACONFIG=5FDVB=5FTTUSB=5FBUDGET=3Dy=0ACONFIG=5F=
DVB=5FTTUSB=5FDEC=3Dy=0ACONFIG=5FSMS=5FSIANO=5FMDTV=3Dy=0A=0A#=0A# Siano mo=
dule components=0A#=0ACONFIG=5FSMS=5FUSB=5FDRV=3Dy=0ACONFIG=5FSMS=5FSDIO=5F=
DRV=3Dy=0A=0A#=0A# Supported FlexCopII (B2C2) Adapters=0A#=0ACONFIG=5FDVB=
=5FB2C2=5FFLEXCOP=3Dy=0ACONFIG=5FDVB=5FB2C2=5FFLEXCOP=5FPCI=3Dy=0ACONFIG=5F=
DVB=5FB2C2=5FFLEXCOP=5FUSB=3Dy=0ACONFIG=5FDVB=5FB2C2=5FFLEXCOP=5FDEBUG=3Dy=
=0A=0A#=0A# Supported BT878 Adapters=0A#=0ACONFIG=5FDVB=5FBT8XX=3Dy=0A=0A#=
=0A# Supported Pluto2 Adapters=0A#=0ACONFIG=5FDVB=5FPLUTO2=3Dy=0A=0A#=0A# S=
upported SDMC DM1105 Adapters=0A#=0ACONFIG=5FDVB=5FDM1105=3Dy=0ACONFIG=5FDV=
B=5FFIREDTV=3Dy=0ACONFIG=5FDVB=5FFIREDTV=5FFIREWIRE=3Dy=0A# CONFIG=5FDVB=5F=
FIREDTV=5FIEEE1394 is not set=0ACONFIG=5FDVB=5FFIREDTV=5FINPUT=3Dy=0A=0A#=
=0A# Supported Earthsoft PT1 Adapters=0A#=0ACONFIG=5FDVB=5FPT1=3Dy=0A=0A#=
=0A# Supported Mantis Adapters=0A#=0ACONFIG=5FMANTIS=5FCORE=3Dy=0ACONFIG=5F=
DVB=5FMANTIS=3Dy=0ACONFIG=5FDVB=5FHOPPER=3Dy=0A=0A#=0A# Supported nGene Ada=
pters=0A#=0ACONFIG=5FDVB=5FNGENE=3Dy=0A=0A#=0A# Supported DVB Frontends=0A#=
=0ACONFIG=5FDVB=5FFE=5FCUSTOMISE=3Dy=0A=0A#=0A# Customise DVB Frontends=0A#=
=0A=0A#=0A# Multistandard (satellite) frontends=0A#=0ACONFIG=5FDVB=5FSTB089=
9=3Dy=0ACONFIG=5FDVB=5FSTB6100=3Dy=0ACONFIG=5FDVB=5FSTV090x=3Dy=0ACONFIG=5F=
DVB=5FSTV6110x=3Dy=0A=0A#=0A# DVB-S (satellite) frontends=0A#=0ACONFIG=5FDV=
B=5FCX24110=3Dy=0ACONFIG=5FDVB=5FCX24123=3Dy=0ACONFIG=5FDVB=5FMT312=3Dy=0AC=
ONFIG=5FDVB=5FZL10036=3Dy=0ACONFIG=5FDVB=5FZL10039=3Dy=0ACONFIG=5FDVB=5FS5H=
1420=3Dy=0ACONFIG=5FDVB=5FSTV0288=3Dy=0ACONFIG=5FDVB=5FSTB6000=3Dy=0ACONFIG=
=5FDVB=5FSTV0299=3Dy=0ACONFIG=5FDVB=5FSTV6110=3Dy=0ACONFIG=5FDVB=5FSTV0900=
=3Dy=0ACONFIG=5FDVB=5FTDA8083=3Dy=0ACONFIG=5FDVB=5FTDA10086=3Dy=0ACONFIG=5F=
DVB=5FTDA8261=3Dy=0ACONFIG=5FDVB=5FVES1X93=3Dy=0ACONFIG=5FDVB=5FTUNER=5FITD=
1000=3Dy=0ACONFIG=5FDVB=5FTUNER=5FCX24113=3Dy=0ACONFIG=5FDVB=5FTDA826X=3Dy=
=0ACONFIG=5FDVB=5FTUA6100=3Dy=0ACONFIG=5FDVB=5FCX24116=3Dy=0ACONFIG=5FDVB=
=5FSI21XX=3Dy=0ACONFIG=5FDVB=5FDS3000=3Dy=0ACONFIG=5FDVB=5FMB86A16=3Dy=0A=
=0A#=0A# DVB-T (terrestrial) frontends=0A#=0ACONFIG=5FDVB=5FSP8870=3Dy=0ACO=
NFIG=5FDVB=5FSP887X=3Dy=0ACONFIG=5FDVB=5FCX22700=3Dy=0ACONFIG=5FDVB=5FCX227=
02=3Dy=0ACONFIG=5FDVB=5FS5H1432=3Dy=0ACONFIG=5FDVB=5FDRX397XD=3Dy=0ACONFIG=
=5FDVB=5FL64781=3Dy=0ACONFIG=5FDVB=5FTDA1004X=3Dy=0ACONFIG=5FDVB=5FNXT6000=
=3Dy=0ACONFIG=5FDVB=5FMT352=3Dy=0ACONFIG=5FDVB=5FZL10353=3Dy=0ACONFIG=5FDVB=
=5FDIB3000MB=3Dy=0ACONFIG=5FDVB=5FDIB3000MC=3Dy=0ACONFIG=5FDVB=5FDIB7000M=
=3Dy=0ACONFIG=5FDVB=5FDIB7000P=3Dy=0ACONFIG=5FDVB=5FTDA10048=3Dy=0ACONFIG=
=5FDVB=5FAF9013=3Dy=0ACONFIG=5FDVB=5FEC100=3Dy=0A=0A#=0A# DVB-C (cable) fro=
ntends=0A#=0ACONFIG=5FDVB=5FVES1820=3Dy=0ACONFIG=5FDVB=5FTDA10021=3Dy=0ACON=
FIG=5FDVB=5FTDA10023=3Dy=0ACONFIG=5FDVB=5FSTV0297=3Dy=0A=0A#=0A# ATSC (Nort=
h American/Korean Terrestrial/Cable DTV) frontends=0A#=0ACONFIG=5FDVB=5FNXT=
200X=3Dy=0ACONFIG=5FDVB=5FOR51211=3Dy=0ACONFIG=5FDVB=5FOR51132=3Dy=0ACONFIG=
=5FDVB=5FBCM3510=3Dy=0ACONFIG=5FDVB=5FLGDT330X=3Dy=0ACONFIG=5FDVB=5FLGDT330=
5=3Dy=0ACONFIG=5FDVB=5FS5H1409=3Dy=0ACONFIG=5FDVB=5FAU8522=3Dy=0ACONFIG=5FD=
VB=5FS5H1411=3Dy=0A=0A#=0A# ISDB-T (terrestrial) frontends=0A#=0ACONFIG=5FD=
VB=5FS921=3Dy=0ACONFIG=5FDVB=5FDIB8000=3Dy=0ACONFIG=5FDVB=5FMB86A20S=3Dy=0A=
=0A#=0A# Digital terrestrial only tuners/PLL=0A#=0ACONFIG=5FDVB=5FPLL=3Dy=
=0ACONFIG=5FDVB=5FTUNER=5FDIB0070=3Dy=0ACONFIG=5FDVB=5FTUNER=5FDIB0090=3Dy=
=0A=0A#=0A# SEC control devices for DVB-S=0A#=0ACONFIG=5FDVB=5FLNBP21=3Dy=
=0ACONFIG=5FDVB=5FISL6405=3Dy=0ACONFIG=5FDVB=5FISL6421=3Dy=0ACONFIG=5FDVB=
=5FISL6423=3Dy=0ACONFIG=5FDVB=5FLGS8GL5=3Dy=0ACONFIG=5FDVB=5FLGS8GXX=3Dy=0A=
CONFIG=5FDVB=5FATBM8830=3Dy=0ACONFIG=5FDVB=5FTDA665x=3Dy=0ACONFIG=5FDVB=5FI=
X2505V=3Dy=0A=0A#=0A# Tools to develop new frontends=0A#=0ACONFIG=5FDVB=5FD=
UMMY=5FFE=3Dy=0A=0A#=0A# Graphics support=0A#=0ACONFIG=5FAGP=3Dy=0ACONFIG=
=5FAGP=5FAMD64=3Dy=0ACONFIG=5FAGP=5FINTEL=3Dy=0ACONFIG=5FAGP=5FSIS=3Dy=0ACO=
NFIG=5FAGP=5FVIA=3Dy=0ACONFIG=5FVGA=5FARB=3Dy=0ACONFIG=5FVGA=5FARB=5FMAX=5F=
GPUS=3D16=0ACONFIG=5FVGA=5FSWITCHEROO=3Dy=0ACONFIG=5FDRM=3Dy=0ACONFIG=5FDRM=
=5FKMS=5FHELPER=3Dy=0ACONFIG=5FDRM=5FTTM=3Dy=0ACONFIG=5FDRM=5FTDFX=3Dy=0ACO=
NFIG=5FDRM=5FR128=3Dy=0ACONFIG=5FDRM=5FRADEON=3Dy=0ACONFIG=5FDRM=5FRADEON=
=5FKMS=3Dy=0ACONFIG=5FDRM=5FI810=3Dy=0ACONFIG=5FDRM=5FI830=3Dy=0A# CONFIG=
=5FDRM=5FI915 is not set=0ACONFIG=5FDRM=5FMGA=3Dy=0ACONFIG=5FDRM=5FSIS=3Dy=
=0ACONFIG=5FDRM=5FVIA=3Dy=0ACONFIG=5FDRM=5FSAVAGE=3Dy=0ACONFIG=5FSTUB=5FPOU=
LSBO=3Dy=0ACONFIG=5FVGASTATE=3Dy=0ACONFIG=5FVIDEO=5FOUTPUT=5FCONTROL=3Dy=0A=
CONFIG=5FFB=3Dy=0ACONFIG=5FFIRMWARE=5FEDID=3Dy=0ACONFIG=5FFB=5FDDC=3Dy=0ACO=
NFIG=5FFB=5FBOOT=5FVESA=5FSUPPORT=3Dy=0ACONFIG=5FFB=5FCFB=5FFILLRECT=3Dy=0A=
CONFIG=5FFB=5FCFB=5FCOPYAREA=3Dy=0ACONFIG=5FFB=5FCFB=5FIMAGEBLIT=3Dy=0A# CO=
NFIG=5FFB=5FCFB=5FREV=5FPIXELS=5FIN=5FBYTE is not set=0ACONFIG=5FFB=5FSYS=
=5FFILLRECT=3Dy=0ACONFIG=5FFB=5FSYS=5FCOPYAREA=3Dy=0ACONFIG=5FFB=5FSYS=5FIM=
AGEBLIT=3Dy=0ACONFIG=5FFB=5FFOREIGN=5FENDIAN=3Dy=0ACONFIG=5FFB=5FBOTH=5FEND=
IAN=3Dy=0A# CONFIG=5FFB=5FBIG=5FENDIAN is not set=0A# CONFIG=5FFB=5FLITTLE=
=5FENDIAN is not set=0ACONFIG=5FFB=5FSYS=5FFOPS=3Dy=0A# CONFIG=5FFB=5FWMT=
=5FGE=5FROPS is not set=0ACONFIG=5FFB=5FDEFERRED=5FIO=3Dy=0ACONFIG=5FFB=5FH=
ECUBA=3Dy=0ACONFIG=5FFB=5FSVGALIB=3Dy=0A# CONFIG=5FFB=5FMACMODES is not set=
=0ACONFIG=5FFB=5FBACKLIGHT=3Dy=0ACONFIG=5FFB=5FMODE=5FHELPERS=3Dy=0ACONFIG=
=5FFB=5FTILEBLITTING=3Dy=0A=0A#=0A# Frame buffer hardware drivers=0A#=0ACON=
FIG=5FFB=5FCIRRUS=3Dy=0ACONFIG=5FFB=5FPM2=3Dy=0ACONFIG=5FFB=5FPM2=5FFIFO=5F=
DISCONNECT=3Dy=0ACONFIG=5FFB=5FCYBER2000=3Dy=0ACONFIG=5FFB=5FARC=3Dy=0ACONF=
IG=5FFB=5FASILIANT=3Dy=0ACONFIG=5FFB=5FIMSTT=3Dy=0ACONFIG=5FFB=5FVGA16=3Dy=
=0ACONFIG=5FFB=5FUVESA=3Dy=0ACONFIG=5FFB=5FVESA=3Dy=0ACONFIG=5FFB=5FEFI=3Dy=
=0ACONFIG=5FFB=5FN411=3Dy=0ACONFIG=5FFB=5FHGA=3Dy=0ACONFIG=5FFB=5FS1D13XXX=
=3Dy=0ACONFIG=5FFB=5FNVIDIA=3Dy=0ACONFIG=5FFB=5FNVIDIA=5FI2C=3Dy=0ACONFIG=
=5FFB=5FNVIDIA=5FDEBUG=3Dy=0ACONFIG=5FFB=5FNVIDIA=5FBACKLIGHT=3Dy=0ACONFIG=
=5FFB=5FRIVA=3Dy=0ACONFIG=5FFB=5FRIVA=5FI2C=3Dy=0ACONFIG=5FFB=5FRIVA=5FDEBU=
G=3Dy=0ACONFIG=5FFB=5FRIVA=5FBACKLIGHT=3Dy=0ACONFIG=5FFB=5FLE80578=3Dy=0ACO=
NFIG=5FFB=5FCARILLO=5FRANCH=3Dy=0ACONFIG=5FFB=5FINTEL=3Dy=0ACONFIG=5FFB=5FI=
NTEL=5FDEBUG=3Dy=0ACONFIG=5FFB=5FINTEL=5FI2C=3Dy=0ACONFIG=5FFB=5FMATROX=3Dy=
=0ACONFIG=5FFB=5FMATROX=5FMILLENIUM=3Dy=0ACONFIG=5FFB=5FMATROX=5FMYSTIQUE=
=3Dy=0ACONFIG=5FFB=5FMATROX=5FG=3Dy=0ACONFIG=5FFB=5FMATROX=5FI2C=3Dy=0ACONF=
IG=5FFB=5FMATROX=5FMAVEN=3Dy=0ACONFIG=5FFB=5FRADEON=3Dy=0ACONFIG=5FFB=5FRAD=
EON=5FI2C=3Dy=0ACONFIG=5FFB=5FRADEON=5FBACKLIGHT=3Dy=0ACONFIG=5FFB=5FRADEON=
=5FDEBUG=3Dy=0ACONFIG=5FFB=5FATY128=3Dy=0ACONFIG=5FFB=5FATY128=5FBACKLIGHT=
=3Dy=0ACONFIG=5FFB=5FATY=3Dy=0ACONFIG=5FFB=5FATY=5FCT=3Dy=0ACONFIG=5FFB=5FA=
TY=5FGENERIC=5FLCD=3Dy=0ACONFIG=5FFB=5FATY=5FGX=3Dy=0ACONFIG=5FFB=5FATY=5FB=
ACKLIGHT=3Dy=0ACONFIG=5FFB=5FS3=3Dy=0ACONFIG=5FFB=5FSAVAGE=3Dy=0ACONFIG=5FF=
B=5FSAVAGE=5FI2C=3Dy=0ACONFIG=5FFB=5FSAVAGE=5FACCEL=3Dy=0ACONFIG=5FFB=5FSIS=
=3Dy=0ACONFIG=5FFB=5FSIS=5F300=3Dy=0ACONFIG=5FFB=5FSIS=5F315=3Dy=0ACONFIG=
=5FFB=5FVIA=3Dy=0ACONFIG=5FFB=5FVIA=5FDIRECT=5FPROCFS=3Dy=0ACONFIG=5FFB=5FN=
EOMAGIC=3Dy=0ACONFIG=5FFB=5FKYRO=3Dy=0ACONFIG=5FFB=5F3DFX=3Dy=0ACONFIG=5FFB=
=5F3DFX=5FACCEL=3Dy=0ACONFIG=5FFB=5F3DFX=5FI2C=3Dy=0ACONFIG=5FFB=5FVOODOO1=
=3Dy=0ACONFIG=5FFB=5FVT8623=3Dy=0ACONFIG=5FFB=5FTRIDENT=3Dy=0ACONFIG=5FFB=
=5FARK=3Dy=0ACONFIG=5FFB=5FPM3=3Dy=0ACONFIG=5FFB=5FCARMINE=3Dy=0ACONFIG=5FF=
B=5FCARMINE=5FDRAM=5FEVAL=3Dy=0A# CONFIG=5FCARMINE=5FDRAM=5FCUSTOM is not s=
et=0ACONFIG=5FFB=5FGEODE=3Dy=0ACONFIG=5FFB=5FGEODE=5FLX=3Dy=0ACONFIG=5FFB=
=5FGEODE=5FGX=3Dy=0ACONFIG=5FFB=5FGEODE=5FGX1=3Dy=0ACONFIG=5FFB=5FTMIO=3Dy=
=0ACONFIG=5FFB=5FTMIO=5FACCELL=3Dy=0ACONFIG=5FFB=5FSM501=3Dy=0ACONFIG=5FFB=
=5FUDL=3Dy=0ACONFIG=5FFB=5FVIRTUAL=3Dy=0ACONFIG=5FXEN=5FFBDEV=5FFRONTEND=3D=
y=0ACONFIG=5FFB=5FMETRONOME=3Dy=0ACONFIG=5FFB=5FMB862XX=3Dy=0ACONFIG=5FFB=
=5FMB862XX=5FPCI=5FGDC=3Dy=0ACONFIG=5FFB=5FBROADSHEET=3Dy=0ACONFIG=5FBACKLI=
GHT=5FLCD=5FSUPPORT=3Dy=0ACONFIG=5FLCD=5FCLASS=5FDEVICE=3Dy=0ACONFIG=5FLCD=
=5FL4F00242T03=3Dy=0ACONFIG=5FLCD=5FLMS283GF05=3Dy=0ACONFIG=5FLCD=5FLTV350Q=
V=3Dy=0ACONFIG=5FLCD=5FILI9320=3Dy=0ACONFIG=5FLCD=5FTDO24M=3Dy=0ACONFIG=5FL=
CD=5FVGG2432A4=3Dy=0ACONFIG=5FLCD=5FPLATFORM=3Dy=0ACONFIG=5FLCD=5FS6E63M0=
=3Dy=0ACONFIG=5FBACKLIGHT=5FCLASS=5FDEVICE=3Dy=0ACONFIG=5FBACKLIGHT=5FGENER=
IC=3Dy=0ACONFIG=5FBACKLIGHT=5FPROGEAR=3Dy=0ACONFIG=5FBACKLIGHT=5FCARILLO=5F=
RANCH=3Dy=0ACONFIG=5FBACKLIGHT=5FDA903X=3Dy=0ACONFIG=5FBACKLIGHT=5FMAX8925=
=3Dy=0ACONFIG=5FBACKLIGHT=5FMBP=5FNVIDIA=3Dy=0ACONFIG=5FBACKLIGHT=5FSAHARA=
=3Dy=0ACONFIG=5FBACKLIGHT=5FWM831X=3Dy=0ACONFIG=5FBACKLIGHT=5FADP5520=3Dy=
=0ACONFIG=5FBACKLIGHT=5FADP8860=3Dy=0ACONFIG=5FBACKLIGHT=5F88PM860X=3Dy=0AC=
ONFIG=5FBACKLIGHT=5FPCF50633=3Dy=0A=0A#=0A# Display device support=0A#=0ACO=
NFIG=5FDISPLAY=5FSUPPORT=3Dy=0A=0A#=0A# Display hardware drivers=0A#=0A=0A#=
=0A# Console display driver support=0A#=0ACONFIG=5FVGA=5FCONSOLE=3Dy=0ACONF=
IG=5FVGACON=5FSOFT=5FSCROLLBACK=3Dy=0ACONFIG=5FVGACON=5FSOFT=5FSCROLLBACK=
=5FSIZE=3D64=0ACONFIG=5FDUMMY=5FCONSOLE=3Dy=0ACONFIG=5FFRAMEBUFFER=5FCONSOL=
E=3Dy=0ACONFIG=5FFRAMEBUFFER=5FCONSOLE=5FDETECT=5FPRIMARY=3Dy=0ACONFIG=5FFR=
AMEBUFFER=5FCONSOLE=5FROTATION=3Dy=0ACONFIG=5FFONTS=3Dy=0ACONFIG=5FFONT=5F8=
x8=3Dy=0ACONFIG=5FFONT=5F8x16=3Dy=0ACONFIG=5FFONT=5F6x11=3Dy=0ACONFIG=5FFON=
T=5F7x14=3Dy=0ACONFIG=5FFONT=5FPEARL=5F8x8=3Dy=0ACONFIG=5FFONT=5FACORN=5F8x=
8=3Dy=0ACONFIG=5FFONT=5FMINI=5F4x6=3Dy=0ACONFIG=5FFONT=5FSUN8x16=3Dy=0ACONF=
IG=5FFONT=5FSUN12x22=3Dy=0ACONFIG=5FFONT=5F10x18=3Dy=0ACONFIG=5FLOGO=3Dy=0A=
CONFIG=5FLOGO=5FLINUX=5FMONO=3Dy=0ACONFIG=5FLOGO=5FLINUX=5FVGA16=3Dy=0ACONF=
IG=5FLOGO=5FLINUX=5FCLUT224=3Dy=0ACONFIG=5FSOUND=3Dy=0ACONFIG=5FSOUND=5FOSS=
=5FCORE=3Dy=0ACONFIG=5FSOUND=5FOSS=5FCORE=5FPRECLAIM=3Dy=0ACONFIG=5FSND=3Dy=
=0ACONFIG=5FSND=5FTIMER=3Dy=0ACONFIG=5FSND=5FPCM=3Dy=0ACONFIG=5FSND=5FHWDEP=
=3Dy=0ACONFIG=5FSND=5FRAWMIDI=3Dy=0ACONFIG=5FSND=5FJACK=3Dy=0ACONFIG=5FSND=
=5FSEQUENCER=3Dy=0ACONFIG=5FSND=5FSEQ=5FDUMMY=3Dy=0ACONFIG=5FSND=5FOSSEMUL=
=3Dy=0ACONFIG=5FSND=5FMIXER=5FOSS=3Dy=0ACONFIG=5FSND=5FPCM=5FOSS=3Dy=0ACONF=
IG=5FSND=5FPCM=5FOSS=5FPLUGINS=3Dy=0ACONFIG=5FSND=5FSEQUENCER=5FOSS=3Dy=0AC=
ONFIG=5FSND=5FHRTIMER=3Dy=0ACONFIG=5FSND=5FSEQ=5FHRTIMER=5FDEFAULT=3Dy=0ACO=
NFIG=5FSND=5FDYNAMIC=5FMINORS=3Dy=0ACONFIG=5FSND=5FSUPPORT=5FOLD=5FAPI=3Dy=
=0ACONFIG=5FSND=5FVERBOSE=5FPROCFS=3Dy=0ACONFIG=5FSND=5FVERBOSE=5FPRINTK=3D=
y=0ACONFIG=5FSND=5FDEBUG=3Dy=0ACONFIG=5FSND=5FDEBUG=5FVERBOSE=3Dy=0ACONFIG=
=5FSND=5FPCM=5FXRUN=5FDEBUG=3Dy=0ACONFIG=5FSND=5FVMASTER=3Dy=0ACONFIG=5FSND=
=5FDMA=5FSGBUF=3Dy=0ACONFIG=5FSND=5FRAWMIDI=5FSEQ=3Dy=0ACONFIG=5FSND=5FOPL3=
=5FLIB=5FSEQ=3Dy=0A# CONFIG=5FSND=5FOPL4=5FLIB=5FSEQ is not set=0A# CONFIG=
=5FSND=5FSBAWE=5FSEQ is not set=0ACONFIG=5FSND=5FEMU10K1=5FSEQ=3Dy=0ACONFIG=
=5FSND=5FMPU401=5FUART=3Dy=0ACONFIG=5FSND=5FOPL3=5FLIB=3Dy=0ACONFIG=5FSND=
=5FVX=5FLIB=3Dy=0ACONFIG=5FSND=5FAC97=5FCODEC=3Dy=0ACONFIG=5FSND=5FDRIVERS=
=3Dy=0ACONFIG=5FSND=5FPCSP=3Dy=0ACONFIG=5FSND=5FDUMMY=3Dy=0ACONFIG=5FSND=5F=
ALOOP=3Dy=0ACONFIG=5FSND=5FVIRMIDI=3Dy=0ACONFIG=5FSND=5FMTPAV=3Dy=0ACONFIG=
=5FSND=5FMTS64=3Dy=0ACONFIG=5FSND=5FSERIAL=5FU16550=3Dy=0ACONFIG=5FSND=5FMP=
U401=3Dy=0ACONFIG=5FSND=5FPORTMAN2X4=3Dy=0ACONFIG=5FSND=5FAC97=5FPOWER=5FSA=
VE=3Dy=0ACONFIG=5FSND=5FAC97=5FPOWER=5FSAVE=5FDEFAULT=3D0=0ACONFIG=5FSND=5F=
SB=5FCOMMON=3Dy=0ACONFIG=5FSND=5FSB16=5FDSP=3Dy=0ACONFIG=5FSND=5FPCI=3Dy=0A=
CONFIG=5FSND=5FAD1889=3Dy=0ACONFIG=5FSND=5FALS300=3Dy=0ACONFIG=5FSND=5FALS4=
000=3Dy=0ACONFIG=5FSND=5FALI5451=3Dy=0ACONFIG=5FSND=5FASIHPI=3Dy=0ACONFIG=
=5FSND=5FATIIXP=3Dy=0ACONFIG=5FSND=5FATIIXP=5FMODEM=3Dy=0ACONFIG=5FSND=5FAU=
8810=3Dy=0ACONFIG=5FSND=5FAU8820=3Dy=0ACONFIG=5FSND=5FAU8830=3Dy=0ACONFIG=
=5FSND=5FAW2=3Dy=0ACONFIG=5FSND=5FAZT3328=3Dy=0ACONFIG=5FSND=5FBT87X=3Dy=0A=
CONFIG=5FSND=5FBT87X=5FOVERCLOCK=3Dy=0ACONFIG=5FSND=5FCA0106=3Dy=0ACONFIG=
=5FSND=5FCMIPCI=3Dy=0ACONFIG=5FSND=5FOXYGEN=5FLIB=3Dy=0ACONFIG=5FSND=5FOXYG=
EN=3Dy=0ACONFIG=5FSND=5FCS4281=3Dy=0ACONFIG=5FSND=5FCS46XX=3Dy=0ACONFIG=5FS=
ND=5FCS46XX=5FNEW=5FDSP=3Dy=0ACONFIG=5FSND=5FCS5530=3Dy=0ACONFIG=5FSND=5FCS=
5535AUDIO=3Dy=0ACONFIG=5FSND=5FCTXFI=3Dy=0ACONFIG=5FSND=5FDARLA20=3Dy=0ACON=
FIG=5FSND=5FGINA20=3Dy=0ACONFIG=5FSND=5FLAYLA20=3Dy=0ACONFIG=5FSND=5FDARLA2=
4=3Dy=0ACONFIG=5FSND=5FGINA24=3Dy=0ACONFIG=5FSND=5FLAYLA24=3Dy=0ACONFIG=5FS=
ND=5FMONA=3Dy=0ACONFIG=5FSND=5FMIA=3Dy=0ACONFIG=5FSND=5FECHO3G=3Dy=0ACONFIG=
=5FSND=5FINDIGO=3Dy=0ACONFIG=5FSND=5FINDIGOIO=3Dy=0ACONFIG=5FSND=5FINDIGODJ=
=3Dy=0ACONFIG=5FSND=5FINDIGOIOX=3Dy=0ACONFIG=5FSND=5FINDIGODJX=3Dy=0ACONFIG=
=5FSND=5FEMU10K1=3Dy=0ACONFIG=5FSND=5FEMU10K1X=3Dy=0ACONFIG=5FSND=5FENS1370=
=3Dy=0ACONFIG=5FSND=5FENS1371=3Dy=0ACONFIG=5FSND=5FES1938=3Dy=0ACONFIG=5FSN=
D=5FES1968=3Dy=0ACONFIG=5FSND=5FES1968=5FINPUT=3Dy=0ACONFIG=5FSND=5FFM801=
=3Dy=0ACONFIG=5FSND=5FFM801=5FTEA575X=5FBOOL=3Dy=0ACONFIG=5FSND=5FFM801=5FT=
EA575X=3Dy=0ACONFIG=5FSND=5FHDA=5FINTEL=3Dy=0ACONFIG=5FSND=5FHDA=5FHWDEP=3D=
y=0ACONFIG=5FSND=5FHDA=5FRECONFIG=3Dy=0ACONFIG=5FSND=5FHDA=5FINPUT=5FBEEP=
=3Dy=0ACONFIG=5FSND=5FHDA=5FINPUT=5FBEEP=5FMODE=3D1=0ACONFIG=5FSND=5FHDA=5F=
INPUT=5FJACK=3Dy=0ACONFIG=5FSND=5FHDA=5FPATCH=5FLOADER=3Dy=0ACONFIG=5FSND=
=5FHDA=5FCODEC=5FREALTEK=3Dy=0ACONFIG=5FSND=5FHDA=5FCODEC=5FANALOG=3Dy=0ACO=
NFIG=5FSND=5FHDA=5FCODEC=5FSIGMATEL=3Dy=0ACONFIG=5FSND=5FHDA=5FCODEC=5FVIA=
=3Dy=0ACONFIG=5FSND=5FHDA=5FCODEC=5FHDMI=3Dy=0ACONFIG=5FSND=5FHDA=5FCODEC=
=5FCIRRUS=3Dy=0ACONFIG=5FSND=5FHDA=5FCODEC=5FCONEXANT=3Dy=0ACONFIG=5FSND=5F=
HDA=5FCODEC=5FCA0110=3Dy=0ACONFIG=5FSND=5FHDA=5FCODEC=5FCMEDIA=3Dy=0ACONFIG=
=5FSND=5FHDA=5FCODEC=5FSI3054=3Dy=0ACONFIG=5FSND=5FHDA=5FGENERIC=3Dy=0ACONF=
IG=5FSND=5FHDA=5FPOWER=5FSAVE=3Dy=0ACONFIG=5FSND=5FHDA=5FPOWER=5FSAVE=5FDEF=
AULT=3D0=0ACONFIG=5FSND=5FHDSP=3Dy=0A=0A#=0A# Don't forget to add built-in =
firmwares for HDSP driver=0A#=0ACONFIG=5FSND=5FHDSPM=3Dy=0ACONFIG=5FSND=5FI=
CE1712=3Dy=0ACONFIG=5FSND=5FICE1724=3Dy=0ACONFIG=5FSND=5FINTEL8X0=3Dy=0ACON=
FIG=5FSND=5FINTEL8X0M=3Dy=0ACONFIG=5FSND=5FKORG1212=3Dy=0ACONFIG=5FSND=5FLX=
6464ES=3Dy=0ACONFIG=5FSND=5FMAESTRO3=3Dy=0ACONFIG=5FSND=5FMAESTRO3=5FINPUT=
=3Dy=0ACONFIG=5FSND=5FMIXART=3Dy=0ACONFIG=5FSND=5FNM256=3Dy=0ACONFIG=5FSND=
=5FPCXHR=3Dy=0ACONFIG=5FSND=5FRIPTIDE=3Dy=0ACONFIG=5FSND=5FRME32=3Dy=0ACONF=
IG=5FSND=5FRME96=3Dy=0ACONFIG=5FSND=5FRME9652=3Dy=0ACONFIG=5FSND=5FSONICVIB=
ES=3Dy=0ACONFIG=5FSND=5FTRIDENT=3Dy=0ACONFIG=5FSND=5FVIA82XX=3Dy=0ACONFIG=
=5FSND=5FVIA82XX=5FMODEM=3Dy=0ACONFIG=5FSND=5FVIRTUOSO=3Dy=0ACONFIG=5FSND=
=5FVX222=3Dy=0ACONFIG=5FSND=5FYMFPCI=3Dy=0ACONFIG=5FSND=5FSPI=3Dy=0ACONFIG=
=5FSND=5FUSB=3Dy=0ACONFIG=5FSND=5FUSB=5FAUDIO=3Dy=0ACONFIG=5FSND=5FUSB=5FUA=
101=3Dy=0ACONFIG=5FSND=5FUSB=5FUSX2Y=3Dy=0ACONFIG=5FSND=5FUSB=5FCAIAQ=3Dy=
=0ACONFIG=5FSND=5FUSB=5FCAIAQ=5FINPUT=3Dy=0ACONFIG=5FSND=5FUSB=5FUS122L=3Dy=
=0ACONFIG=5FSND=5FPCMCIA=3Dy=0ACONFIG=5FSND=5FVXPOCKET=3Dy=0ACONFIG=5FSND=
=5FPDAUDIOCF=3Dy=0ACONFIG=5FSND=5FSOC=3Dy=0ACONFIG=5FSND=5FSOC=5FCACHE=5FLZ=
O=3Dy=0ACONFIG=5FSND=5FSOC=5FI2C=5FAND=5FSPI=3Dy=0ACONFIG=5FSND=5FSOC=5FALL=
=5FCODECS=3Dy=0ACONFIG=5FSND=5FSOC=5F88PM860X=3Dy=0ACONFIG=5FSND=5FSOC=5FWM=
=5FHUBS=3Dy=0ACONFIG=5FSND=5FSOC=5FAD1836=3Dy=0ACONFIG=5FSND=5FSOC=5FAD193X=
=3Dy=0ACONFIG=5FSND=5FSOC=5FAD73311=3Dy=0ACONFIG=5FSND=5FSOC=5FADS117X=3Dy=
=0ACONFIG=5FSND=5FSOC=5FAK4104=3Dy=0ACONFIG=5FSND=5FSOC=5FAK4535=3Dy=0ACONF=
IG=5FSND=5FSOC=5FAK4642=3Dy=0ACONFIG=5FSND=5FSOC=5FAK4671=3Dy=0ACONFIG=5FSN=
D=5FSOC=5FALC5623=3Dy=0ACONFIG=5FSND=5FSOC=5FCS42L51=3Dy=0ACONFIG=5FSND=5FS=
OC=5FCS4270=3Dy=0ACONFIG=5FSND=5FSOC=5FCX20442=3Dy=0ACONFIG=5FSND=5FSOC=5FL=
3=3Dy=0ACONFIG=5FSND=5FSOC=5FDA7210=3Dy=0ACONFIG=5FSND=5FSOC=5FMAX98088=3Dy=
=0ACONFIG=5FSND=5FSOC=5FPCM3008=3Dy=0ACONFIG=5FSND=5FSOC=5FSPDIF=3Dy=0ACONF=
IG=5FSND=5FSOC=5FSSM2602=3Dy=0ACONFIG=5FSND=5FSOC=5FTLV320AIC23=3Dy=0ACONFI=
G=5FSND=5FSOC=5FTLV320AIC26=3Dy=0ACONFIG=5FSND=5FSOC=5FTLV320AIC3X=3Dy=0ACO=
NFIG=5FSND=5FSOC=5FTLV320DAC33=3Dy=0ACONFIG=5FSND=5FSOC=5FTWL4030=3Dy=0ACON=
FIG=5FSND=5FSOC=5FTWL6040=3Dy=0ACONFIG=5FSND=5FSOC=5FUDA134X=3Dy=0ACONFIG=
=5FSND=5FSOC=5FUDA1380=3Dy=0ACONFIG=5FSND=5FSOC=5FWL1273=3Dy=0ACONFIG=5FSND=
=5FSOC=5FWM8350=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8400=3Dy=0ACONFIG=5FSND=5FSOC=
=5FWM8510=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8523=3Dy=0ACONFIG=5FSND=5FSOC=5FWM85=
80=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8711=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8727=3Dy=
=0ACONFIG=5FSND=5FSOC=5FWM8728=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8731=3Dy=0ACONF=
IG=5FSND=5FSOC=5FWM8737=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8741=3Dy=0ACONFIG=5FSN=
D=5FSOC=5FWM8750=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8753=3Dy=0ACONFIG=5FSND=5FSOC=
=5FWM8770=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8776=3Dy=0ACONFIG=5FSND=5FSOC=5FWM88=
04=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8900=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8903=3Dy=
=0ACONFIG=5FSND=5FSOC=5FWM8904=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8940=3Dy=0ACONF=
IG=5FSND=5FSOC=5FWM8955=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8960=3Dy=0ACONFIG=5FSN=
D=5FSOC=5FWM8961=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8962=3Dy=0ACONFIG=5FSND=5FSOC=
=5FWM8971=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8974=3Dy=0ACONFIG=5FSND=5FSOC=5FWM89=
78=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8985=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8988=3Dy=
=0ACONFIG=5FSND=5FSOC=5FWM8990=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8993=3Dy=0ACONF=
IG=5FSND=5FSOC=5FWM8994=3Dy=0ACONFIG=5FSND=5FSOC=5FWM8995=3Dy=0ACONFIG=5FSN=
D=5FSOC=5FWM9081=3Dy=0ACONFIG=5FSND=5FSOC=5FMAX9877=3Dy=0ACONFIG=5FSND=5FSO=
C=5FTPA6130A2=3Dy=0ACONFIG=5FSND=5FSOC=5FWM2000=3Dy=0ACONFIG=5FSND=5FSOC=5F=
WM9090=3Dy=0ACONFIG=5FSOUND=5FPRIME=3Dy=0ACONFIG=5FSOUND=5FOSS=3Dy=0ACONFIG=
=5FSOUND=5FTRACEINIT=3Dy=0ACONFIG=5FSOUND=5FDMAP=3Dy=0ACONFIG=5FSOUND=5FVMI=
DI=3Dy=0ACONFIG=5FSOUND=5FTRIX=3Dy=0ACONFIG=5FSOUND=5FMSS=3Dy=0ACONFIG=5FSO=
UND=5FMPU401=3Dy=0ACONFIG=5FSOUND=5FPAS=3Dy=0ACONFIG=5FPAS=5FJOYSTICK=3Dy=
=0ACONFIG=5FSOUND=5FPSS=3Dy=0ACONFIG=5FPSS=5FMIXER=3Dy=0ACONFIG=5FSOUND=5FS=
B=3Dy=0ACONFIG=5FSOUND=5FYM3812=3Dy=0ACONFIG=5FSOUND=5FUART6850=3Dy=0ACONFI=
G=5FSOUND=5FAEDSP16=3Dy=0ACONFIG=5FSC6600=3Dy=0ACONFIG=5FSC6600=5FJOY=3Dy=
=0ACONFIG=5FSC6600=5FCDROM=3D4=0ACONFIG=5FSC6600=5FCDROMBASE=3D0=0ACONFIG=
=5FSOUND=5FKAHLUA=3Dy=0ACONFIG=5FAC97=5FBUS=3Dy=0ACONFIG=5FHID=5FSUPPORT=3D=
y=0ACONFIG=5FHID=3Dy=0ACONFIG=5FHIDRAW=3Dy=0A=0A#=0A# USB Input Devices=0A#=
=0ACONFIG=5FUSB=5FHID=3Dy=0ACONFIG=5FHID=5FPID=3Dy=0ACONFIG=5FUSB=5FHIDDEV=
=3Dy=0A=0A#=0A# Special HID drivers=0A#=0ACONFIG=5FHID=5F3M=5FPCT=3Dy=0ACON=
FIG=5FHID=5FA4TECH=3Dy=0ACONFIG=5FHID=5FACRUX=5FFF=3Dy=0ACONFIG=5FHID=5FAPP=
LE=3Dy=0ACONFIG=5FHID=5FBELKIN=3Dy=0ACONFIG=5FHID=5FCANDO=3Dy=0ACONFIG=5FHI=
D=5FCHERRY=3Dy=0ACONFIG=5FHID=5FCHICONY=3Dy=0ACONFIG=5FHID=5FPRODIKEYS=3Dy=
=0ACONFIG=5FHID=5FCYPRESS=3Dy=0ACONFIG=5FHID=5FDRAGONRISE=3Dy=0ACONFIG=5FDR=
AGONRISE=5FFF=3Dy=0ACONFIG=5FHID=5FEMS=5FFF=3Dy=0ACONFIG=5FHID=5FEGALAX=3Dy=
=0ACONFIG=5FHID=5FELECOM=3Dy=0ACONFIG=5FHID=5FEZKEY=3Dy=0ACONFIG=5FHID=5FKY=
E=3Dy=0ACONFIG=5FHID=5FUCLOGIC=3Dy=0ACONFIG=5FHID=5FWALTOP=3Dy=0ACONFIG=5FH=
ID=5FGYRATION=3Dy=0ACONFIG=5FHID=5FTWINHAN=3Dy=0ACONFIG=5FHID=5FKENSINGTON=
=3Dy=0ACONFIG=5FHID=5FLOGITECH=3Dy=0ACONFIG=5FLOGITECH=5FFF=3Dy=0ACONFIG=5F=
LOGIRUMBLEPAD2=5FFF=3Dy=0ACONFIG=5FLOGIG940=5FFF=3Dy=0ACONFIG=5FLOGIWII=5FF=
F=3Dy=0ACONFIG=5FHID=5FMAGICMOUSE=3Dy=0ACONFIG=5FHID=5FMICROSOFT=3Dy=0ACONF=
IG=5FHID=5FMOSART=3Dy=0ACONFIG=5FHID=5FMONTEREY=3Dy=0ACONFIG=5FHID=5FMULTIT=
OUCH=3Dy=0ACONFIG=5FHID=5FNTRIG=3Dy=0ACONFIG=5FHID=5FORTEK=3Dy=0ACONFIG=5FH=
ID=5FPANTHERLORD=3Dy=0ACONFIG=5FPANTHERLORD=5FFF=3Dy=0ACONFIG=5FHID=5FPETAL=
YNX=3Dy=0ACONFIG=5FHID=5FPICOLCD=3Dy=0ACONFIG=5FHID=5FPICOLCD=5FFB=3Dy=0ACO=
NFIG=5FHID=5FPICOLCD=5FBACKLIGHT=3Dy=0ACONFIG=5FHID=5FPICOLCD=5FLCD=3Dy=0AC=
ONFIG=5FHID=5FPICOLCD=5FLEDS=3Dy=0ACONFIG=5FHID=5FQUANTA=3Dy=0ACONFIG=5FHID=
=5FROCCAT=3Dy=0ACONFIG=5FHID=5FROCCAT=5FKONE=3Dy=0ACONFIG=5FHID=5FROCCAT=5F=
KONEPLUS=3Dy=0ACONFIG=5FHID=5FROCCAT=5FPYRA=3Dy=0ACONFIG=5FHID=5FSAMSUNG=3D=
y=0ACONFIG=5FHID=5FSONY=3Dy=0ACONFIG=5FHID=5FSTANTUM=3Dy=0ACONFIG=5FHID=5FS=
UNPLUS=3Dy=0ACONFIG=5FHID=5FGREENASIA=3Dy=0ACONFIG=5FGREENASIA=5FFF=3Dy=0AC=
ONFIG=5FHID=5FSMARTJOYPLUS=3Dy=0ACONFIG=5FSMARTJOYPLUS=5FFF=3Dy=0ACONFIG=5F=
HID=5FTOPSEED=3Dy=0ACONFIG=5FHID=5FTHRUSTMASTER=3Dy=0ACONFIG=5FTHRUSTMASTER=
=5FFF=3Dy=0ACONFIG=5FHID=5FWACOM=3Dy=0ACONFIG=5FHID=5FWACOM=5FPOWER=5FSUPPL=
Y=3Dy=0ACONFIG=5FHID=5FZEROPLUS=3Dy=0ACONFIG=5FZEROPLUS=5FFF=3Dy=0ACONFIG=
=5FHID=5FZYDACRON=3Dy=0ACONFIG=5FUSB=5FSUPPORT=3Dy=0ACONFIG=5FUSB=5FARCH=5F=
HAS=5FHCD=3Dy=0ACONFIG=5FUSB=5FARCH=5FHAS=5FOHCI=3Dy=0ACONFIG=5FUSB=5FARCH=
=5FHAS=5FEHCI=3Dy=0ACONFIG=5FUSB=3Dy=0ACONFIG=5FUSB=5FDEBUG=3Dy=0ACONFIG=5F=
USB=5FANNOUNCE=5FNEW=5FDEVICES=3Dy=0A=0A#=0A# Miscellaneous USB options=0A#=
=0ACONFIG=5FUSB=5FDEVICEFS=3Dy=0ACONFIG=5FUSB=5FDEVICE=5FCLASS=3Dy=0ACONFIG=
=5FUSB=5FDYNAMIC=5FMINORS=3Dy=0ACONFIG=5FUSB=5FSUSPEND=3Dy=0ACONFIG=5FUSB=
=5FOTG=3Dy=0ACONFIG=5FUSB=5FOTG=5FWHITELIST=3Dy=0ACONFIG=5FUSB=5FOTG=5FBLAC=
KLIST=5FHUB=3Dy=0ACONFIG=5FUSB=5FMON=3Dy=0ACONFIG=5FUSB=5FWUSB=3Dy=0ACONFIG=
=5FUSB=5FWUSB=5FCBAF=3Dy=0ACONFIG=5FUSB=5FWUSB=5FCBAF=5FDEBUG=3Dy=0A=0A#=0A=
# USB Host Controller Drivers=0A#=0ACONFIG=5FUSB=5FC67X00=5FHCD=3Dy=0ACONFI=
G=5FUSB=5FXHCI=5FHCD=3Dy=0ACONFIG=5FUSB=5FXHCI=5FHCD=5FDEBUGGING=3Dy=0ACONF=
IG=5FUSB=5FEHCI=5FHCD=3Dy=0ACONFIG=5FUSB=5FEHCI=5FROOT=5FHUB=5FTT=3Dy=0ACON=
FIG=5FUSB=5FEHCI=5FTT=5FNEWSCHED=3Dy=0ACONFIG=5FUSB=5FOXU210HP=5FHCD=3Dy=0A=
CONFIG=5FUSB=5FISP116X=5FHCD=3Dy=0ACONFIG=5FUSB=5FISP1760=5FHCD=3Dy=0ACONFI=
G=5FUSB=5FISP1362=5FHCD=3Dy=0ACONFIG=5FUSB=5FOHCI=5FHCD=3Dy=0ACONFIG=5FUSB=
=5FOHCI=5FHCD=5FSSB=3Dy=0A# CONFIG=5FUSB=5FOHCI=5FBIG=5FENDIAN=5FDESC is no=
t set=0A# CONFIG=5FUSB=5FOHCI=5FBIG=5FENDIAN=5FMMIO is not set=0ACONFIG=5FU=
SB=5FOHCI=5FLITTLE=5FENDIAN=3Dy=0ACONFIG=5FUSB=5FUHCI=5FHCD=3Dy=0ACONFIG=5F=
USB=5FU132=5FHCD=3Dy=0ACONFIG=5FUSB=5FSL811=5FHCD=3Dy=0ACONFIG=5FUSB=5FSL81=
1=5FCS=3Dy=0ACONFIG=5FUSB=5FR8A66597=5FHCD=3Dy=0ACONFIG=5FUSB=5FWHCI=5FHCD=
=3Dy=0ACONFIG=5FUSB=5FHWA=5FHCD=3Dy=0A=0A#=0A# USB Device Class drivers=0A#=
=0ACONFIG=5FUSB=5FACM=3Dy=0ACONFIG=5FUSB=5FPRINTER=3Dy=0ACONFIG=5FUSB=5FWDM=
=3Dy=0ACONFIG=5FUSB=5FTMC=3Dy=0A=0A#=0A# NOTE: USB=5FSTORAGE depends on SCS=
I but BLK=5FDEV=5FSD may=0A#=0A=0A#=0A# also be needed; see USB=5FSTORAGE H=
elp for more info=0A#=0ACONFIG=5FUSB=5FSTORAGE=3Dy=0ACONFIG=5FUSB=5FSTORAGE=
=5FDEBUG=3Dy=0ACONFIG=5FUSB=5FSTORAGE=5FDATAFAB=3Dy=0ACONFIG=5FUSB=5FSTORAG=
E=5FFREECOM=3Dy=0ACONFIG=5FUSB=5FSTORAGE=5FISD200=3Dy=0ACONFIG=5FUSB=5FSTOR=
AGE=5FUSBAT=3Dy=0ACONFIG=5FUSB=5FSTORAGE=5FSDDR09=3Dy=0ACONFIG=5FUSB=5FSTOR=
AGE=5FSDDR55=3Dy=0ACONFIG=5FUSB=5FSTORAGE=5FJUMPSHOT=3Dy=0ACONFIG=5FUSB=5FS=
TORAGE=5FALAUDA=3Dy=0ACONFIG=5FUSB=5FSTORAGE=5FONETOUCH=3Dy=0ACONFIG=5FUSB=
=5FSTORAGE=5FKARMA=3Dy=0ACONFIG=5FUSB=5FSTORAGE=5FCYPRESS=5FATACB=3Dy=0ACON=
FIG=5FUSB=5FUAS=3Dy=0ACONFIG=5FUSB=5FLIBUSUAL=3Dy=0A=0A#=0A# USB Imaging de=
vices=0A#=0ACONFIG=5FUSB=5FMDC800=3Dy=0ACONFIG=5FUSB=5FMICROTEK=3Dy=0A=0A#=
=0A# USB port drivers=0A#=0ACONFIG=5FUSB=5FUSS720=3Dy=0ACONFIG=5FUSB=5FSERI=
AL=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FCONSOLE=3Dy=0ACONFIG=5FUSB=5FEZUSB=3Dy=0AC=
ONFIG=5FUSB=5FSERIAL=5FGENERIC=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FAIRCABLE=3Dy=
=0ACONFIG=5FUSB=5FSERIAL=5FARK3116=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FBELKIN=3Dy=
=0ACONFIG=5FUSB=5FSERIAL=5FCH341=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FWHITEHEAT=3D=
y=0ACONFIG=5FUSB=5FSERIAL=5FDIGI=5FACCELEPORT=3Dy=0ACONFIG=5FUSB=5FSERIAL=
=5FCP210X=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FCYPRESS=5FM8=3Dy=0ACONFIG=5FUSB=5FS=
ERIAL=5FEMPEG=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FFTDI=5FSIO=3Dy=0ACONFIG=5FUSB=
=5FSERIAL=5FFUNSOFT=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FVISOR=3Dy=0ACONFIG=5FUSB=
=5FSERIAL=5FIPAQ=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FIR=3Dy=0ACONFIG=5FUSB=5FSERI=
AL=5FEDGEPORT=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FEDGEPORT=5FTI=3Dy=0ACONFIG=5FUS=
B=5FSERIAL=5FGARMIN=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FIPW=3Dy=0ACONFIG=5FUSB=5F=
SERIAL=5FIUU=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FKEYSPAN=5FPDA=3Dy=0ACONFIG=5FUSB=
=5FSERIAL=5FKEYSPAN=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FKEYSPAN=5FMPR=3Dy=0ACONFI=
G=5FUSB=5FSERIAL=5FKEYSPAN=5FUSA28=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FKEYSPAN=5F=
USA28X=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FKEYSPAN=5FUSA28XA=3Dy=0ACONFIG=5FUSB=
=5FSERIAL=5FKEYSPAN=5FUSA28XB=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FKEYSPAN=5FUSA19=
=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FKEYSPAN=5FUSA18X=3Dy=0ACONFIG=5FUSB=5FSERIAL=
=5FKEYSPAN=5FUSA19W=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FKEYSPAN=5FUSA19QW=3Dy=0AC=
ONFIG=5FUSB=5FSERIAL=5FKEYSPAN=5FUSA19QI=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FKEYS=
PAN=5FUSA49W=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FKEYSPAN=5FUSA49WLC=3Dy=0ACONFIG=
=5FUSB=5FSERIAL=5FKLSI=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FKOBIL=5FSCT=3Dy=0ACONF=
IG=5FUSB=5FSERIAL=5FMCT=5FU232=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FMOS7720=3Dy=0A=
CONFIG=5FUSB=5FSERIAL=5FMOS7715=5FPARPORT=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FMOS=
7840=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FMOTOROLA=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FN=
AVMAN=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FPL2303=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FOT=
I6858=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FQCAUX=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FQUA=
LCOMM=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FSPCP8X5=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FH=
P4X=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FSAFE=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FSAFE=
=5FPADDED=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FSAMBA=3Dy=0ACONFIG=5FUSB=5FSERIAL=
=5FSIEMENS=5FMPI=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FSIERRAWIRELESS=3Dy=0ACONFIG=
=5FUSB=5FSERIAL=5FSYMBOL=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FTI=3Dy=0ACONFIG=5FUS=
B=5FSERIAL=5FCYBERJACK=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FXIRCOM=3Dy=0ACONFIG=5F=
USB=5FSERIAL=5FWWAN=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FOPTION=3Dy=0ACONFIG=5FUSB=
=5FSERIAL=5FOMNINET=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FOPTICON=3Dy=0ACONFIG=5FUS=
B=5FSERIAL=5FVIVOPAY=5FSERIAL=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FZIO=3Dy=0ACONFI=
G=5FUSB=5FSERIAL=5FSSU100=3Dy=0ACONFIG=5FUSB=5FSERIAL=5FDEBUG=3Dy=0A=0A#=0A=
# USB Miscellaneous drivers=0A#=0ACONFIG=5FUSB=5FEMI62=3Dy=0ACONFIG=5FUSB=
=5FEMI26=3Dy=0ACONFIG=5FUSB=5FADUTUX=3Dy=0ACONFIG=5FUSB=5FSEVSEG=3Dy=0ACONF=
IG=5FUSB=5FRIO500=3Dy=0ACONFIG=5FUSB=5FLEGOTOWER=3Dy=0ACONFIG=5FUSB=5FLCD=
=3Dy=0ACONFIG=5FUSB=5FLED=3Dy=0ACONFIG=5FUSB=5FCYPRESS=5FCY7C63=3Dy=0ACONFI=
G=5FUSB=5FCYTHERM=3Dy=0ACONFIG=5FUSB=5FIDMOUSE=3Dy=0ACONFIG=5FUSB=5FFTDI=5F=
ELAN=3Dy=0ACONFIG=5FUSB=5FAPPLEDISPLAY=3Dy=0ACONFIG=5FUSB=5FSISUSBVGA=3Dy=
=0ACONFIG=5FUSB=5FSISUSBVGA=5FCON=3Dy=0ACONFIG=5FUSB=5FLD=3Dy=0ACONFIG=5FUS=
B=5FTRANCEVIBRATOR=3Dy=0ACONFIG=5FUSB=5FIOWARRIOR=3Dy=0ACONFIG=5FUSB=5FTEST=
=3Dy=0ACONFIG=5FUSB=5FISIGHTFW=3Dy=0ACONFIG=5FUSB=5FYUREX=3Dy=0ACONFIG=5FUS=
B=5FATM=3Dy=0ACONFIG=5FUSB=5FSPEEDTOUCH=3Dy=0ACONFIG=5FUSB=5FCXACRU=3Dy=0AC=
ONFIG=5FUSB=5FUEAGLEATM=3Dy=0ACONFIG=5FUSB=5FXUSBATM=3Dy=0ACONFIG=5FUSB=5FG=
ADGET=3Dy=0ACONFIG=5FUSB=5FGADGET=5FDEBUG=3Dy=0ACONFIG=5FUSB=5FGADGET=5FDEB=
UG=5FFILES=3Dy=0ACONFIG=5FUSB=5FGADGET=5FDEBUG=5FFS=3Dy=0ACONFIG=5FUSB=5FGA=
DGET=5FVBUS=5FDRAW=3D2=0ACONFIG=5FUSB=5FGADGET=5FSELECTED=3Dy=0ACONFIG=5FUS=
B=5FGADGET=5FR8A66597=3Dy=0ACONFIG=5FUSB=5FR8A66597=3Dy=0A# CONFIG=5FUSB=5F=
GADGET=5FPXA=5FU2O is not set=0A# CONFIG=5FUSB=5FGADGET=5FM66592 is not set=
=0A# CONFIG=5FUSB=5FGADGET=5FAMD5536UDC is not set=0A# CONFIG=5FUSB=5FGADGE=
T=5FCI13XXX=5FPCI is not set=0A# CONFIG=5FUSB=5FGADGET=5FNET2280 is not set=
=0A# CONFIG=5FUSB=5FGADGET=5FGOKU is not set=0A# CONFIG=5FUSB=5FGADGET=5FLA=
NGWELL is not set=0A# CONFIG=5FUSB=5FGADGET=5FEG20T is not set=0A# CONFIG=
=5FUSB=5FGADGET=5FDUMMY=5FHCD is not set=0ACONFIG=5FUSB=5FGADGET=5FDUALSPEE=
D=3Dy=0A# CONFIG=5FUSB=5FZERO is not set=0A# CONFIG=5FUSB=5FAUDIO is not se=
t=0ACONFIG=5FUSB=5FETH=3Dy=0ACONFIG=5FUSB=5FETH=5FRNDIS=3Dy=0ACONFIG=5FUSB=
=5FETH=5FEEM=3Dy=0A# CONFIG=5FUSB=5FG=5FNCM is not set=0A# CONFIG=5FUSB=5FG=
ADGETFS is not set=0A# CONFIG=5FUSB=5FFUNCTIONFS is not set=0A# CONFIG=5FUS=
B=5FFILE=5FSTORAGE is not set=0A# CONFIG=5FUSB=5FMASS=5FSTORAGE is not set=
=0A# CONFIG=5FUSB=5FG=5FSERIAL is not set=0A# CONFIG=5FUSB=5FMIDI=5FGADGET =
is not set=0A# CONFIG=5FUSB=5FG=5FPRINTER is not set=0A# CONFIG=5FUSB=5FCDC=
=5FCOMPOSITE is not set=0A# CONFIG=5FUSB=5FG=5FNOKIA is not set=0A# CONFIG=
=5FUSB=5FG=5FMULTI is not set=0A# CONFIG=5FUSB=5FG=5FHID is not set=0A# CON=
FIG=5FUSB=5FG=5FDBGP is not set=0A# CONFIG=5FUSB=5FG=5FWEBCAM is not set=0A=
=0A#=0A# OTG and related infrastructure=0A#=0ACONFIG=5FUSB=5FOTG=5FUTILS=3D=
y=0ACONFIG=5FUSB=5FGPIO=5FVBUS=3Dy=0ACONFIG=5FTWL4030=5FUSB=3Dy=0ACONFIG=5F=
TWL6030=5FUSB=3Dy=0ACONFIG=5FNOP=5FUSB=5FXCEIV=3Dy=0ACONFIG=5FAB8500=5FUSB=
=3Dy=0ACONFIG=5FUWB=3Dy=0ACONFIG=5FUWB=5FHWA=3Dy=0ACONFIG=5FUWB=5FWHCI=3Dy=
=0ACONFIG=5FUWB=5FI1480U=3Dy=0ACONFIG=5FMMC=3Dy=0ACONFIG=5FMMC=5FDEBUG=3Dy=
=0ACONFIG=5FMMC=5FUNSAFE=5FRESUME=3Dy=0ACONFIG=5FMMC=5FCLKGATE=3Dy=0A=0A#=
=0A# MMC/SD/SDIO Card Drivers=0A#=0ACONFIG=5FMMC=5FBLOCK=3Dy=0ACONFIG=5FMMC=
=5FBLOCK=5FMINORS=3D8=0ACONFIG=5FMMC=5FBLOCK=5FBOUNCE=3Dy=0ACONFIG=5FSDIO=
=5FUART=3Dy=0ACONFIG=5FMMC=5FTEST=3Dy=0A=0A#=0A# MMC/SD/SDIO Host Controlle=
r Drivers=0A#=0ACONFIG=5FMMC=5FSDHCI=3Dy=0ACONFIG=5FMMC=5FSDHCI=5FPCI=3Dy=
=0ACONFIG=5FMMC=5FRICOH=5FMMC=3Dy=0ACONFIG=5FMMC=5FSDHCI=5FPLTFM=3Dy=0ACONF=
IG=5FMMC=5FWBSD=3Dy=0ACONFIG=5FMMC=5FTIFM=5FSD=3Dy=0ACONFIG=5FMMC=5FSPI=3Dy=
=0ACONFIG=5FMMC=5FSDRICOH=5FCS=3Dy=0ACONFIG=5FMMC=5FCB710=3Dy=0ACONFIG=5FMM=
C=5FVIA=5FSDMMC=3Dy=0ACONFIG=5FMMC=5FUSHC=3Dy=0ACONFIG=5FMEMSTICK=3Dy=0ACON=
FIG=5FMEMSTICK=5FDEBUG=3Dy=0A=0A#=0A# MemoryStick drivers=0A#=0ACONFIG=5FME=
MSTICK=5FUNSAFE=5FRESUME=3Dy=0ACONFIG=5FMSPRO=5FBLOCK=3Dy=0A=0A#=0A# Memory=
Stick Host Controller Drivers=0A#=0ACONFIG=5FMEMSTICK=5FTIFM=5FMS=3Dy=0ACON=
FIG=5FMEMSTICK=5FJMICRON=5F38X=3Dy=0ACONFIG=5FNEW=5FLEDS=3Dy=0ACONFIG=5FLED=
S=5FCLASS=3Dy=0A=0A#=0A# LED drivers=0A#=0ACONFIG=5FLEDS=5F88PM860X=3Dy=0AC=
ONFIG=5FLEDS=5FNET5501=3Dy=0ACONFIG=5FLEDS=5FPCA9532=3Dy=0ACONFIG=5FLEDS=5F=
GPIO=3Dy=0ACONFIG=5FLEDS=5FGPIO=5FPLATFORM=3Dy=0ACONFIG=5FLEDS=5FLP3944=3Dy=
=0ACONFIG=5FLEDS=5FLP5521=3Dy=0ACONFIG=5FLEDS=5FLP5523=3Dy=0ACONFIG=5FLEDS=
=5FCLEVO=5FMAIL=3Dy=0ACONFIG=5FLEDS=5FPCA955X=3Dy=0ACONFIG=5FLEDS=5FWM831X=
=5FSTATUS=3Dy=0ACONFIG=5FLEDS=5FWM8350=3Dy=0ACONFIG=5FLEDS=5FDA903X=3Dy=0AC=
ONFIG=5FLEDS=5FDAC124S085=3Dy=0ACONFIG=5FLEDS=5FREGULATOR=3Dy=0ACONFIG=5FLE=
DS=5FBD2802=3Dy=0ACONFIG=5FLEDS=5FINTEL=5FSS4200=3Dy=0ACONFIG=5FLEDS=5FLT35=
93=3Dy=0ACONFIG=5FLEDS=5FADP5520=3Dy=0ACONFIG=5FLEDS=5FDELL=5FNETBOOKS=3Dy=
=0ACONFIG=5FLEDS=5FMC13783=3Dy=0ACONFIG=5FLEDS=5FTRIGGERS=3Dy=0A=0A#=0A# LE=
D Triggers=0A#=0ACONFIG=5FLEDS=5FTRIGGER=5FTIMER=3Dy=0ACONFIG=5FLEDS=5FTRIG=
GER=5FIDE=5FDISK=3Dy=0ACONFIG=5FLEDS=5FTRIGGER=5FHEARTBEAT=3Dy=0ACONFIG=5FL=
EDS=5FTRIGGER=5FBACKLIGHT=3Dy=0ACONFIG=5FLEDS=5FTRIGGER=5FGPIO=3Dy=0ACONFIG=
=5FLEDS=5FTRIGGER=5FDEFAULT=5FON=3Dy=0A=0A#=0A# iptables trigger is under N=
etfilter config (LED target)=0A#=0ACONFIG=5FNFC=5FDEVICES=3Dy=0ACONFIG=5FPN=
544=5FNFC=3Dy=0ACONFIG=5FACCESSIBILITY=3Dy=0ACONFIG=5FA11Y=5FBRAILLE=5FCONS=
OLE=3Dy=0ACONFIG=5FINFINIBAND=3Dy=0ACONFIG=5FINFINIBAND=5FUSER=5FMAD=3Dy=0A=
CONFIG=5FINFINIBAND=5FUSER=5FACCESS=3Dy=0ACONFIG=5FINFINIBAND=5FUSER=5FMEM=
=3Dy=0ACONFIG=5FINFINIBAND=5FADDR=5FTRANS=3Dy=0ACONFIG=5FINFINIBAND=5FMTHCA=
=3Dy=0ACONFIG=5FINFINIBAND=5FMTHCA=5FDEBUG=3Dy=0ACONFIG=5FINFINIBAND=5FIPAT=
H=3Dy=0ACONFIG=5FINFINIBAND=5FQIB=3Dy=0ACONFIG=5FINFINIBAND=5FAMSO1100=3Dy=
=0ACONFIG=5FINFINIBAND=5FAMSO1100=5FDEBUG=3Dy=0ACONFIG=5FINFINIBAND=5FCXGB3=
=3Dy=0ACONFIG=5FINFINIBAND=5FCXGB3=5FDEBUG=3Dy=0ACONFIG=5FINFINIBAND=5FCXGB=
4=3Dy=0ACONFIG=5FMLX4=5FINFINIBAND=3Dy=0ACONFIG=5FINFINIBAND=5FNES=3Dy=0ACO=
NFIG=5FINFINIBAND=5FNES=5FDEBUG=3Dy=0ACONFIG=5FINFINIBAND=5FIPOIB=3Dy=0ACON=
FIG=5FINFINIBAND=5FIPOIB=5FCM=3Dy=0ACONFIG=5FINFINIBAND=5FIPOIB=5FDEBUG=3Dy=
=0ACONFIG=5FINFINIBAND=5FIPOIB=5FDEBUG=5FDATA=3Dy=0ACONFIG=5FINFINIBAND=5FS=
RP=3Dy=0ACONFIG=5FINFINIBAND=5FISER=3Dy=0ACONFIG=5FEDAC=3Dy=0A=0A#=0A# Repo=
rting subsystems=0A#=0ACONFIG=5FEDAC=5FDEBUG=3Dy=0ACONFIG=5FEDAC=5FDECODE=
=5FMCE=3Dy=0ACONFIG=5FEDAC=5FMCE=5FINJ=3Dy=0ACONFIG=5FEDAC=5FMM=5FEDAC=3Dy=
=0ACONFIG=5FEDAC=5FMCE=3Dy=0ACONFIG=5FEDAC=5FAMD64=3Dy=0ACONFIG=5FEDAC=5FAM=
D64=5FERROR=5FINJECTION=3Dy=0ACONFIG=5FEDAC=5FE752X=3Dy=0ACONFIG=5FEDAC=5FI=
82975X=3Dy=0ACONFIG=5FEDAC=5FI3000=3Dy=0ACONFIG=5FEDAC=5FI3200=3Dy=0ACONFIG=
=5FEDAC=5FX38=3Dy=0ACONFIG=5FEDAC=5FI5400=3Dy=0ACONFIG=5FEDAC=5FI7CORE=3Dy=
=0ACONFIG=5FEDAC=5FI5000=3Dy=0ACONFIG=5FEDAC=5FI5100=3Dy=0ACONFIG=5FEDAC=5F=
I7300=3Dy=0ACONFIG=5FRTC=5FLIB=3Dy=0ACONFIG=5FRTC=5FCLASS=3Dy=0ACONFIG=5FRT=
C=5FHCTOSYS=3Dy=0ACONFIG=5FRTC=5FHCTOSYS=5FDEVICE=3D"rtc0"=0ACONFIG=5FRTC=
=5FDEBUG=3Dy=0A=0A#=0A# RTC interfaces=0A#=0ACONFIG=5FRTC=5FINTF=5FSYSFS=3D=
y=0ACONFIG=5FRTC=5FINTF=5FPROC=3Dy=0ACONFIG=5FRTC=5FINTF=5FDEV=3Dy=0ACONFIG=
=5FRTC=5FINTF=5FDEV=5FUIE=5FEMUL=3Dy=0ACONFIG=5FRTC=5FDRV=5FTEST=3Dy=0A=0A#=
=0A# I2C RTC drivers=0A#=0ACONFIG=5FRTC=5FDRV=5FDS1307=3Dy=0ACONFIG=5FRTC=
=5FDRV=5FDS1374=3Dy=0ACONFIG=5FRTC=5FDRV=5FDS1672=3Dy=0ACONFIG=5FRTC=5FDRV=
=5FDS3232=3Dy=0ACONFIG=5FRTC=5FDRV=5FMAX6900=3Dy=0ACONFIG=5FRTC=5FDRV=5FMAX=
8925=3Dy=0ACONFIG=5FRTC=5FDRV=5FMAX8998=3Dy=0ACONFIG=5FRTC=5FDRV=5FRS5C372=
=3Dy=0ACONFIG=5FRTC=5FDRV=5FISL1208=3Dy=0ACONFIG=5FRTC=5FDRV=5FISL12022=3Dy=
=0ACONFIG=5FRTC=5FDRV=5FX1205=3Dy=0ACONFIG=5FRTC=5FDRV=5FPCF8563=3Dy=0ACONF=
IG=5FRTC=5FDRV=5FPCF8583=3Dy=0ACONFIG=5FRTC=5FDRV=5FM41T80=3Dy=0ACONFIG=5FR=
TC=5FDRV=5FM41T80=5FWDT=3Dy=0ACONFIG=5FRTC=5FDRV=5FBQ32K=3Dy=0ACONFIG=5FRTC=
=5FDRV=5FTWL4030=3Dy=0ACONFIG=5FRTC=5FDRV=5FS35390A=3Dy=0ACONFIG=5FRTC=5FDR=
V=5FFM3130=3Dy=0ACONFIG=5FRTC=5FDRV=5FRX8581=3Dy=0ACONFIG=5FRTC=5FDRV=5FRX8=
025=3Dy=0A=0A#=0A# SPI RTC drivers=0A#=0ACONFIG=5FRTC=5FDRV=5FM41T94=3Dy=0A=
CONFIG=5FRTC=5FDRV=5FDS1305=3Dy=0ACONFIG=5FRTC=5FDRV=5FDS1390=3Dy=0ACONFIG=
=5FRTC=5FDRV=5FMAX6902=3Dy=0ACONFIG=5FRTC=5FDRV=5FR9701=3Dy=0ACONFIG=5FRTC=
=5FDRV=5FRS5C348=3Dy=0ACONFIG=5FRTC=5FDRV=5FDS3234=3Dy=0ACONFIG=5FRTC=5FDRV=
=5FPCF2123=3Dy=0A=0A#=0A# Platform RTC drivers=0A#=0ACONFIG=5FRTC=5FDRV=5FC=
MOS=3Dy=0ACONFIG=5FRTC=5FDRV=5FDS1286=3Dy=0ACONFIG=5FRTC=5FDRV=5FDS1511=3Dy=
=0ACONFIG=5FRTC=5FDRV=5FDS1553=3Dy=0ACONFIG=5FRTC=5FDRV=5FDS1742=3Dy=0ACONF=
IG=5FRTC=5FDRV=5FSTK17TA8=3Dy=0ACONFIG=5FRTC=5FDRV=5FM48T86=3Dy=0ACONFIG=5F=
RTC=5FDRV=5FM48T35=3Dy=0ACONFIG=5FRTC=5FDRV=5FM48T59=3Dy=0ACONFIG=5FRTC=5FD=
RV=5FMSM6242=3Dy=0ACONFIG=5FRTC=5FDRV=5FBQ4802=3Dy=0ACONFIG=5FRTC=5FDRV=5FR=
P5C01=3Dy=0ACONFIG=5FRTC=5FDRV=5FV3020=3Dy=0ACONFIG=5FRTC=5FDRV=5FWM831X=3D=
y=0ACONFIG=5FRTC=5FDRV=5FWM8350=3Dy=0ACONFIG=5FRTC=5FDRV=5FPCF50633=3Dy=0AC=
ONFIG=5FRTC=5FDRV=5FAB3100=3Dy=0ACONFIG=5FRTC=5FDRV=5FAB8500=3Dy=0A=0A#=0A#=
 on-CPU RTC drivers=0A#=0ACONFIG=5FRTC=5FDRV=5FPCAP=3Dy=0ACONFIG=5FRTC=5FDR=
V=5FMC13XXX=3Dy=0ACONFIG=5FDMADEVICES=3Dy=0ACONFIG=5FDMADEVICES=5FDEBUG=3Dy=
=0ACONFIG=5FDMADEVICES=5FVDEBUG=3Dy=0A=0A#=0A# DMA Devices=0A#=0ACONFIG=5FI=
NTEL=5FMID=5FDMAC=3Dy=0ACONFIG=5FINTEL=5FIOATDMA=3Dy=0ACONFIG=5FTIMB=5FDMA=
=3Dy=0ACONFIG=5FPCH=5FDMA=3Dy=0ACONFIG=5FDMA=5FENGINE=3Dy=0A=0A#=0A# DMA Cl=
ients=0A#=0ACONFIG=5FNET=5FDMA=3Dy=0ACONFIG=5FASYNC=5FTX=5FDMA=3Dy=0ACONFIG=
=5FDMATEST=3Dy=0ACONFIG=5FDCA=3Dy=0ACONFIG=5FAUXDISPLAY=3Dy=0ACONFIG=5FKS01=
08=3Dy=0ACONFIG=5FKS0108=5FPORT=3D0x378=0ACONFIG=5FKS0108=5FDELAY=3D2=0ACON=
FIG=5FCFAG12864B=3Dy=0ACONFIG=5FCFAG12864B=5FRATE=3D20=0ACONFIG=5FUIO=3Dy=
=0ACONFIG=5FUIO=5FCIF=3Dy=0ACONFIG=5FUIO=5FPDRV=3Dy=0ACONFIG=5FUIO=5FPDRV=
=5FGENIRQ=3Dy=0ACONFIG=5FUIO=5FAEC=3Dy=0ACONFIG=5FUIO=5FSERCOS3=3Dy=0ACONFI=
G=5FUIO=5FPCI=5FGENERIC=3Dy=0ACONFIG=5FUIO=5FNETX=3Dy=0A=0A#=0A# Xen driver=
 support=0A#=0ACONFIG=5FXEN=5FBALLOON=3Dy=0ACONFIG=5FXEN=5FSCRUB=5FPAGES=3D=
y=0ACONFIG=5FXEN=5FDEV=5FEVTCHN=3Dy=0ACONFIG=5FXEN=5FBACKEND=3Dy=0ACONFIG=
=5FXENFS=3Dy=0ACONFIG=5FXEN=5FCOMPAT=5FXENFS=3Dy=0ACONFIG=5FXEN=5FSYS=5FHYP=
ERVISOR=3Dy=0ACONFIG=5FXEN=5FXENBUS=5FFRONTEND=3Dy=0ACONFIG=5FXEN=5FGNTDEV=
=3Dy=0ACONFIG=5FXEN=5FPLATFORM=5FPCI=3Dy=0ACONFIG=5FSWIOTLB=5FXEN=3Dy=0ACON=
FIG=5FSTAGING=3Dy=0ACONFIG=5FSTAGING=5FEXCLUDE=5FBUILD=3Dy=0ACONFIG=5FX86=
=5FPLATFORM=5FDEVICES=3Dy=0ACONFIG=5FACER=5FWMI=3Dy=0ACONFIG=5FACERHDF=3Dy=
=0ACONFIG=5FDELL=5FLAPTOP=3Dy=0ACONFIG=5FDELL=5FWMI=3Dy=0ACONFIG=5FFUJITSU=
=5FLAPTOP=3Dy=0ACONFIG=5FFUJITSU=5FLAPTOP=5FDEBUG=3Dy=0ACONFIG=5FHP=5FWMI=
=3Dy=0ACONFIG=5FMSI=5FLAPTOP=3Dy=0ACONFIG=5FPANASONIC=5FLAPTOP=3Dy=0ACONFIG=
=5FCOMPAL=5FLAPTOP=3Dy=0ACONFIG=5FSONY=5FLAPTOP=3Dy=0ACONFIG=5FSONYPI=5FCOM=
PAT=3Dy=0ACONFIG=5FIDEAPAD=5FLAPTOP=3Dy=0ACONFIG=5FTHINKPAD=5FACPI=3Dy=0ACO=
NFIG=5FTHINKPAD=5FACPI=5FALSA=5FSUPPORT=3Dy=0ACONFIG=5FTHINKPAD=5FACPI=5FDE=
BUGFACILITIES=3Dy=0ACONFIG=5FTHINKPAD=5FACPI=5FDEBUG=3Dy=0ACONFIG=5FTHINKPA=
D=5FACPI=5FUNSAFE=5FLEDS=3Dy=0ACONFIG=5FTHINKPAD=5FACPI=5FVIDEO=3Dy=0ACONFI=
G=5FTHINKPAD=5FACPI=5FHOTKEY=5FPOLL=3Dy=0ACONFIG=5FSENSORS=5FHDAPS=3Dy=0ACO=
NFIG=5FINTEL=5FMENLOW=3Dy=0ACONFIG=5FEEEPC=5FLAPTOP=3Dy=0ACONFIG=5FEEEPC=5F=
WMI=3Dy=0ACONFIG=5FACPI=5FWMI=3Dy=0ACONFIG=5FMSI=5FWMI=3Dy=0ACONFIG=5FACPI=
=5FASUS=3Dy=0ACONFIG=5FTOPSTAR=5FLAPTOP=3Dy=0ACONFIG=5FACPI=5FTOSHIBA=3Dy=
=0ACONFIG=5FTOSHIBA=5FBT=5FRFKILL=3Dy=0ACONFIG=5FACPI=5FCMPC=3Dy=0ACONFIG=
=5FINTEL=5FIPS=3Dy=0ACONFIG=5FIBM=5FRTL=3Dy=0A=0A#=0A# Firmware Drivers=0A#=
=0ACONFIG=5FEDD=3Dy=0ACONFIG=5FEDD=5FOFF=3Dy=0ACONFIG=5FFIRMWARE=5FMEMMAP=
=3Dy=0ACONFIG=5FEFI=5FVARS=3Dy=0ACONFIG=5FDELL=5FRBU=3Dy=0ACONFIG=5FDCDBAS=
=3Dy=0ACONFIG=5FDMIID=3Dy=0ACONFIG=5FISCSI=5FIBFT=5FFIND=3Dy=0ACONFIG=5FISC=
SI=5FIBFT=3Dy=0A=0A#=0A# File systems=0A#=0ACONFIG=5FEXT2=5FFS=3Dy=0ACONFIG=
=5FEXT2=5FFS=5FXATTR=3Dy=0ACONFIG=5FEXT2=5FFS=5FPOSIX=5FACL=3Dy=0ACONFIG=5F=
EXT2=5FFS=5FSECURITY=3Dy=0ACONFIG=5FEXT2=5FFS=5FXIP=3Dy=0ACONFIG=5FEXT3=5FF=
S=3Dy=0ACONFIG=5FEXT3=5FDEFAULTS=5FTO=5FORDERED=3Dy=0ACONFIG=5FEXT3=5FFS=5F=
XATTR=3Dy=0ACONFIG=5FEXT3=5FFS=5FPOSIX=5FACL=3Dy=0ACONFIG=5FEXT3=5FFS=5FSEC=
URITY=3Dy=0ACONFIG=5FEXT4=5FFS=3Dy=0ACONFIG=5FEXT4=5FFS=5FXATTR=3Dy=0ACONFI=
G=5FEXT4=5FFS=5FPOSIX=5FACL=3Dy=0ACONFIG=5FEXT4=5FFS=5FSECURITY=3Dy=0ACONFI=
G=5FEXT4=5FDEBUG=3Dy=0ACONFIG=5FFS=5FXIP=3Dy=0ACONFIG=5FJBD=3Dy=0ACONFIG=5F=
JBD=5FDEBUG=3Dy=0ACONFIG=5FJBD2=3Dy=0ACONFIG=5FJBD2=5FDEBUG=3Dy=0ACONFIG=5F=
FS=5FMBCACHE=3Dy=0ACONFIG=5FREISERFS=5FFS=3Dy=0ACONFIG=5FREISERFS=5FCHECK=
=3Dy=0ACONFIG=5FREISERFS=5FPROC=5FINFO=3Dy=0ACONFIG=5FREISERFS=5FFS=5FXATTR=
=3Dy=0ACONFIG=5FREISERFS=5FFS=5FPOSIX=5FACL=3Dy=0ACONFIG=5FREISERFS=5FFS=5F=
SECURITY=3Dy=0ACONFIG=5FJFS=5FFS=3Dy=0ACONFIG=5FJFS=5FPOSIX=5FACL=3Dy=0ACON=
FIG=5FJFS=5FSECURITY=3Dy=0ACONFIG=5FJFS=5FDEBUG=3Dy=0ACONFIG=5FJFS=5FSTATIS=
TICS=3Dy=0ACONFIG=5FXFS=5FFS=3Dy=0ACONFIG=5FXFS=5FQUOTA=3Dy=0ACONFIG=5FXFS=
=5FPOSIX=5FACL=3Dy=0ACONFIG=5FXFS=5FRT=3Dy=0ACONFIG=5FXFS=5FDEBUG=3Dy=0ACON=
FIG=5FGFS2=5FFS=3Dy=0ACONFIG=5FGFS2=5FFS=5FLOCKING=5FDLM=3Dy=0ACONFIG=5FOCF=
S2=5FFS=3Dy=0ACONFIG=5FOCFS2=5FFS=5FO2CB=3Dy=0ACONFIG=5FOCFS2=5FFS=5FUSERSP=
ACE=5FCLUSTER=3Dy=0ACONFIG=5FOCFS2=5FFS=5FSTATS=3Dy=0ACONFIG=5FOCFS2=5FDEBU=
G=5FMASKLOG=3Dy=0ACONFIG=5FOCFS2=5FDEBUG=5FFS=3Dy=0ACONFIG=5FBTRFS=5FFS=3Dy=
=0ACONFIG=5FBTRFS=5FFS=5FPOSIX=5FACL=3Dy=0ACONFIG=5FNILFS2=5FFS=3Dy=0ACONFI=
G=5FFS=5FPOSIX=5FACL=3Dy=0ACONFIG=5FEXPORTFS=3Dy=0ACONFIG=5FFILE=5FLOCKING=
=3Dy=0ACONFIG=5FFSNOTIFY=3Dy=0ACONFIG=5FDNOTIFY=3Dy=0ACONFIG=5FINOTIFY=5FUS=
ER=3Dy=0ACONFIG=5FFANOTIFY=3Dy=0ACONFIG=5FFANOTIFY=5FACCESS=5FPERMISSIONS=
=3Dy=0ACONFIG=5FQUOTA=3Dy=0ACONFIG=5FQUOTA=5FNETLINK=5FINTERFACE=3Dy=0ACONF=
IG=5FPRINT=5FQUOTA=5FWARNING=3Dy=0ACONFIG=5FQUOTA=5FDEBUG=3Dy=0ACONFIG=5FQU=
OTA=5FTREE=3Dy=0ACONFIG=5FQFMT=5FV1=3Dy=0ACONFIG=5FQFMT=5FV2=3Dy=0ACONFIG=
=5FQUOTACTL=3Dy=0ACONFIG=5FQUOTACTL=5FCOMPAT=3Dy=0ACONFIG=5FAUTOFS4=5FFS=3D=
y=0ACONFIG=5FFUSE=5FFS=3Dy=0ACONFIG=5FCUSE=3Dy=0ACONFIG=5FGENERIC=5FACL=3Dy=
=0A=0A#=0A# Caches=0A#=0ACONFIG=5FFSCACHE=3Dy=0ACONFIG=5FFSCACHE=5FSTATS=3D=
y=0ACONFIG=5FFSCACHE=5FHISTOGRAM=3Dy=0ACONFIG=5FFSCACHE=5FDEBUG=3Dy=0ACONFI=
G=5FFSCACHE=5FOBJECT=5FLIST=3Dy=0ACONFIG=5FCACHEFILES=3Dy=0ACONFIG=5FCACHEF=
ILES=5FDEBUG=3Dy=0ACONFIG=5FCACHEFILES=5FHISTOGRAM=3Dy=0A=0A#=0A# CD-ROM/DV=
D Filesystems=0A#=0ACONFIG=5FISO9660=5FFS=3Dy=0ACONFIG=5FJOLIET=3Dy=0ACONFI=
G=5FZISOFS=3Dy=0ACONFIG=5FUDF=5FFS=3Dy=0ACONFIG=5FUDF=5FNLS=3Dy=0A=0A#=0A# =
DOS/FAT/NT Filesystems=0A#=0ACONFIG=5FFAT=5FFS=3Dy=0ACONFIG=5FMSDOS=5FFS=3D=
y=0ACONFIG=5FVFAT=5FFS=3Dy=0ACONFIG=5FFAT=5FDEFAULT=5FCODEPAGE=3D437=0ACONF=
IG=5FFAT=5FDEFAULT=5FIOCHARSET=3D"iso8859-1"=0ACONFIG=5FNTFS=5FFS=3Dy=0ACON=
FIG=5FNTFS=5FDEBUG=3Dy=0ACONFIG=5FNTFS=5FRW=3Dy=0A=0A#=0A# Pseudo filesyste=
ms=0A#=0ACONFIG=5FPROC=5FFS=3Dy=0ACONFIG=5FPROC=5FKCORE=3Dy=0ACONFIG=5FPROC=
=5FVMCORE=3Dy=0ACONFIG=5FPROC=5FSYSCTL=3Dy=0ACONFIG=5FPROC=5FPAGE=5FMONITOR=
=3Dy=0ACONFIG=5FSYSFS=3Dy=0ACONFIG=5FTMPFS=3Dy=0ACONFIG=5FTMPFS=5FPOSIX=5FA=
CL=3Dy=0ACONFIG=5FHUGETLBFS=3Dy=0ACONFIG=5FHUGETLB=5FPAGE=3Dy=0ACONFIG=5FCO=
NFIGFS=5FFS=3Dy=0ACONFIG=5FMISC=5FFILESYSTEMS=3Dy=0ACONFIG=5FADFS=5FFS=3Dy=
=0ACONFIG=5FADFS=5FFS=5FRW=3Dy=0ACONFIG=5FAFFS=5FFS=3Dy=0ACONFIG=5FECRYPT=
=5FFS=3Dy=0ACONFIG=5FHFS=5FFS=3Dy=0ACONFIG=5FHFSPLUS=5FFS=3Dy=0ACONFIG=5FBE=
FS=5FFS=3Dy=0ACONFIG=5FBEFS=5FDEBUG=3Dy=0ACONFIG=5FBFS=5FFS=3Dy=0ACONFIG=5F=
EFS=5FFS=3Dy=0ACONFIG=5FJFFS2=5FFS=3Dy=0ACONFIG=5FJFFS2=5FFS=5FDEBUG=3D0=0A=
CONFIG=5FJFFS2=5FFS=5FWRITEBUFFER=3Dy=0ACONFIG=5FJFFS2=5FFS=5FWBUF=5FVERIFY=
=3Dy=0ACONFIG=5FJFFS2=5FSUMMARY=3Dy=0ACONFIG=5FJFFS2=5FFS=5FXATTR=3Dy=0ACON=
FIG=5FJFFS2=5FFS=5FPOSIX=5FACL=3Dy=0ACONFIG=5FJFFS2=5FFS=5FSECURITY=3Dy=0AC=
ONFIG=5FJFFS2=5FCOMPRESSION=5FOPTIONS=3Dy=0ACONFIG=5FJFFS2=5FZLIB=3Dy=0ACON=
FIG=5FJFFS2=5FLZO=3Dy=0ACONFIG=5FJFFS2=5FRTIME=3Dy=0ACONFIG=5FJFFS2=5FRUBIN=
=3Dy=0A# CONFIG=5FJFFS2=5FCMODE=5FNONE is not set=0ACONFIG=5FJFFS2=5FCMODE=
=5FPRIORITY=3Dy=0A# CONFIG=5FJFFS2=5FCMODE=5FSIZE is not set=0A# CONFIG=5FJ=
FFS2=5FCMODE=5FFAVOURLZO is not set=0ACONFIG=5FUBIFS=5FFS=3Dy=0ACONFIG=5FUB=
IFS=5FFS=5FXATTR=3Dy=0ACONFIG=5FUBIFS=5FFS=5FADVANCED=5FCOMPR=3Dy=0ACONFIG=
=5FUBIFS=5FFS=5FLZO=3Dy=0ACONFIG=5FUBIFS=5FFS=5FZLIB=3Dy=0ACONFIG=5FUBIFS=
=5FFS=5FDEBUG=3Dy=0ACONFIG=5FUBIFS=5FFS=5FDEBUG=5FMSG=5FLVL=3D0=0ACONFIG=5F=
UBIFS=5FFS=5FDEBUG=5FCHKS=3Dy=0ACONFIG=5FLOGFS=3Dy=0ACONFIG=5FCRAMFS=3Dy=0A=
CONFIG=5FSQUASHFS=3Dy=0ACONFIG=5FSQUASHFS=5FXATTR=3Dy=0ACONFIG=5FSQUASHFS=
=5FLZO=3Dy=0ACONFIG=5FSQUASHFS=5FXZ=3Dy=0ACONFIG=5FSQUASHFS=5FEMBEDDED=3Dy=
=0ACONFIG=5FSQUASHFS=5FFRAGMENT=5FCACHE=5FSIZE=3D3=0ACONFIG=5FVXFS=5FFS=3Dy=
=0ACONFIG=5FMINIX=5FFS=3Dy=0ACONFIG=5FOMFS=5FFS=3Dy=0ACONFIG=5FHPFS=5FFS=3D=
y=0ACONFIG=5FQNX4FS=5FFS=3Dy=0ACONFIG=5FROMFS=5FFS=3Dy=0ACONFIG=5FROMFS=5FB=
ACKED=5FBY=5FBLOCK=3Dy=0A# CONFIG=5FROMFS=5FBACKED=5FBY=5FMTD is not set=0A=
# CONFIG=5FROMFS=5FBACKED=5FBY=5FBOTH is not set=0ACONFIG=5FROMFS=5FON=5FBL=
OCK=3Dy=0ACONFIG=5FSYSV=5FFS=3Dy=0ACONFIG=5FUFS=5FFS=3Dy=0ACONFIG=5FUFS=5FF=
S=5FWRITE=3Dy=0ACONFIG=5FUFS=5FDEBUG=3Dy=0ACONFIG=5FEXOFS=5FFS=3Dy=0ACONFIG=
=5FEXOFS=5FDEBUG=3Dy=0ACONFIG=5FNETWORK=5FFILESYSTEMS=3Dy=0ACONFIG=5FNFS=5F=
FS=3Dy=0ACONFIG=5FNFS=5FV3=3Dy=0ACONFIG=5FNFS=5FV3=5FACL=3Dy=0ACONFIG=5FNFS=
=5FV4=3Dy=0ACONFIG=5FNFS=5FV4=5F1=3Dy=0ACONFIG=5FPNFS=5FFILE=5FLAYOUT=3Dy=
=0ACONFIG=5FROOT=5FNFS=3Dy=0ACONFIG=5FNFS=5FFSCACHE=3Dy=0ACONFIG=5FNFS=5FUS=
E=5FLEGACY=5FDNS=3Dy=0ACONFIG=5FNFS=5FUSE=5FNEW=5FIDMAPPER=3Dy=0ACONFIG=5FN=
FSD=3Dy=0ACONFIG=5FNFSD=5FDEPRECATED=3Dy=0ACONFIG=5FNFSD=5FV2=5FACL=3Dy=0AC=
ONFIG=5FNFSD=5FV3=3Dy=0ACONFIG=5FNFSD=5FV3=5FACL=3Dy=0ACONFIG=5FNFSD=5FV4=
=3Dy=0ACONFIG=5FLOCKD=3Dy=0ACONFIG=5FLOCKD=5FV4=3Dy=0ACONFIG=5FNFS=5FACL=5F=
SUPPORT=3Dy=0ACONFIG=5FNFS=5FCOMMON=3Dy=0ACONFIG=5FSUNRPC=3Dy=0ACONFIG=5FSU=
NRPC=5FGSS=3Dy=0ACONFIG=5FSUNRPC=5FXPRT=5FRDMA=3Dy=0ACONFIG=5FRPCSEC=5FGSS=
=5FKRB5=3Dy=0ACONFIG=5FCEPH=5FFS=3Dy=0ACONFIG=5FCIFS=3Dy=0ACONFIG=5FCIFS=5F=
STATS=3Dy=0ACONFIG=5FCIFS=5FSTATS2=3Dy=0ACONFIG=5FCIFS=5FWEAK=5FPW=5FHASH=
=3Dy=0ACONFIG=5FCIFS=5FUPCALL=3Dy=0ACONFIG=5FCIFS=5FXATTR=3Dy=0ACONFIG=5FCI=
FS=5FPOSIX=3Dy=0ACONFIG=5FCIFS=5FDEBUG2=3Dy=0ACONFIG=5FCIFS=5FDFS=5FUPCALL=
=3Dy=0ACONFIG=5FCIFS=5FFSCACHE=3Dy=0ACONFIG=5FCIFS=5FACL=3Dy=0ACONFIG=5FCIF=
S=5FEXPERIMENTAL=3Dy=0ACONFIG=5FNCP=5FFS=3Dy=0ACONFIG=5FNCPFS=5FPACKET=5FSI=
GNING=3Dy=0ACONFIG=5FNCPFS=5FIOCTL=5FLOCKING=3Dy=0ACONFIG=5FNCPFS=5FSTRONG=
=3Dy=0ACONFIG=5FNCPFS=5FNFS=5FNS=3Dy=0ACONFIG=5FNCPFS=5FOS2=5FNS=3Dy=0ACONF=
IG=5FNCPFS=5FSMALLDOS=3Dy=0ACONFIG=5FNCPFS=5FNLS=3Dy=0ACONFIG=5FNCPFS=5FEXT=
RAS=3Dy=0ACONFIG=5FCODA=5FFS=3Dy=0ACONFIG=5FAFS=5FFS=3Dy=0ACONFIG=5FAFS=5FD=
EBUG=3Dy=0ACONFIG=5FAFS=5FFSCACHE=3Dy=0ACONFIG=5F9P=5FFS=3Dy=0ACONFIG=5F9P=
=5FFSCACHE=3Dy=0ACONFIG=5F9P=5FFS=5FPOSIX=5FACL=3Dy=0A=0A#=0A# Partition Ty=
pes=0A#=0ACONFIG=5FPARTITION=5FADVANCED=3Dy=0ACONFIG=5FACORN=5FPARTITION=3D=
y=0ACONFIG=5FACORN=5FPARTITION=5FCUMANA=3Dy=0ACONFIG=5FACORN=5FPARTITION=5F=
EESOX=3Dy=0ACONFIG=5FACORN=5FPARTITION=5FICS=3Dy=0ACONFIG=5FACORN=5FPARTITI=
ON=5FADFS=3Dy=0ACONFIG=5FACORN=5FPARTITION=5FPOWERTEC=3Dy=0ACONFIG=5FACORN=
=5FPARTITION=5FRISCIX=3Dy=0ACONFIG=5FOSF=5FPARTITION=3Dy=0ACONFIG=5FAMIGA=
=5FPARTITION=3Dy=0ACONFIG=5FATARI=5FPARTITION=3Dy=0ACONFIG=5FMAC=5FPARTITIO=
N=3Dy=0ACONFIG=5FMSDOS=5FPARTITION=3Dy=0ACONFIG=5FBSD=5FDISKLABEL=3Dy=0ACON=
FIG=5FMINIX=5FSUBPARTITION=3Dy=0ACONFIG=5FSOLARIS=5FX86=5FPARTITION=3Dy=0AC=
ONFIG=5FUNIXWARE=5FDISKLABEL=3Dy=0ACONFIG=5FLDM=5FPARTITION=3Dy=0ACONFIG=5F=
LDM=5FDEBUG=3Dy=0ACONFIG=5FSGI=5FPARTITION=3Dy=0ACONFIG=5FULTRIX=5FPARTITIO=
N=3Dy=0ACONFIG=5FSUN=5FPARTITION=3Dy=0ACONFIG=5FKARMA=5FPARTITION=3Dy=0ACON=
FIG=5FEFI=5FPARTITION=3Dy=0ACONFIG=5FSYSV68=5FPARTITION=3Dy=0ACONFIG=5FNLS=
=3Dy=0ACONFIG=5FNLS=5FDEFAULT=3D"iso8859-1"=0ACONFIG=5FNLS=5FCODEPAGE=5F437=
=3Dy=0ACONFIG=5FNLS=5FCODEPAGE=5F737=3Dy=0ACONFIG=5FNLS=5FCODEPAGE=5F775=3D=
y=0ACONFIG=5FNLS=5FCODEPAGE=5F850=3Dy=0ACONFIG=5FNLS=5FCODEPAGE=5F852=3Dy=
=0ACONFIG=5FNLS=5FCODEPAGE=5F855=3Dy=0ACONFIG=5FNLS=5FCODEPAGE=5F857=3Dy=0A=
CONFIG=5FNLS=5FCODEPAGE=5F860=3Dy=0ACONFIG=5FNLS=5FCODEPAGE=5F861=3Dy=0ACON=
FIG=5FNLS=5FCODEPAGE=5F862=3Dy=0ACONFIG=5FNLS=5FCODEPAGE=5F863=3Dy=0ACONFIG=
=5FNLS=5FCODEPAGE=5F864=3Dy=0ACONFIG=5FNLS=5FCODEPAGE=5F865=3Dy=0ACONFIG=5F=
NLS=5FCODEPAGE=5F866=3Dy=0ACONFIG=5FNLS=5FCODEPAGE=5F869=3Dy=0ACONFIG=5FNLS=
=5FCODEPAGE=5F936=3Dy=0ACONFIG=5FNLS=5FCODEPAGE=5F950=3Dy=0ACONFIG=5FNLS=5F=
CODEPAGE=5F932=3Dy=0ACONFIG=5FNLS=5FCODEPAGE=5F949=3Dy=0ACONFIG=5FNLS=5FCOD=
EPAGE=5F874=3Dy=0ACONFIG=5FNLS=5FISO8859=5F8=3Dy=0ACONFIG=5FNLS=5FCODEPAGE=
=5F1250=3Dy=0ACONFIG=5FNLS=5FCODEPAGE=5F1251=3Dy=0ACONFIG=5FNLS=5FASCII=3Dy=
=0ACONFIG=5FNLS=5FISO8859=5F1=3Dy=0ACONFIG=5FNLS=5FISO8859=5F2=3Dy=0ACONFIG=
=5FNLS=5FISO8859=5F3=3Dy=0ACONFIG=5FNLS=5FISO8859=5F4=3Dy=0ACONFIG=5FNLS=5F=
ISO8859=5F5=3Dy=0ACONFIG=5FNLS=5FISO8859=5F6=3Dy=0ACONFIG=5FNLS=5FISO8859=
=5F7=3Dy=0ACONFIG=5FNLS=5FISO8859=5F9=3Dy=0ACONFIG=5FNLS=5FISO8859=5F13=3Dy=
=0ACONFIG=5FNLS=5FISO8859=5F14=3Dy=0ACONFIG=5FNLS=5FISO8859=5F15=3Dy=0ACONF=
IG=5FNLS=5FKOI8=5FR=3Dy=0ACONFIG=5FNLS=5FKOI8=5FU=3Dy=0ACONFIG=5FNLS=5FUTF8=
=3Dy=0ACONFIG=5FDLM=3Dy=0ACONFIG=5FDLM=5FDEBUG=3Dy=0A=0A#=0A# Kernel hackin=
g=0A#=0ACONFIG=5FTRACE=5FIRQFLAGS=5FSUPPORT=3Dy=0ACONFIG=5FPRINTK=5FTIME=3D=
y=0ACONFIG=5FENABLE=5FWARN=5FDEPRECATED=3Dy=0ACONFIG=5FENABLE=5FMUST=5FCHEC=
K=3Dy=0ACONFIG=5FFRAME=5FWARN=3D2048=0ACONFIG=5FMAGIC=5FSYSRQ=3Dy=0ACONFIG=
=5FSTRIP=5FASM=5FSYMS=3Dy=0ACONFIG=5FUNUSED=5FSYMBOLS=3Dy=0ACONFIG=5FDEBUG=
=5FFS=3Dy=0ACONFIG=5FHEADERS=5FCHECK=3Dy=0ACONFIG=5FDEBUG=5FKERNEL=3Dy=0ACO=
NFIG=5FDEBUG=5FSHIRQ=3Dy=0ACONFIG=5FLOCKUP=5FDETECTOR=3Dy=0ACONFIG=5FHARDLO=
CKUP=5FDETECTOR=3Dy=0ACONFIG=5FBOOTPARAM=5FSOFTLOCKUP=5FPANIC=3Dy=0ACONFIG=
=5FBOOTPARAM=5FSOFTLOCKUP=5FPANIC=5FVALUE=3D1=0ACONFIG=5FDETECT=5FHUNG=5FTA=
SK=3Dy=0ACONFIG=5FBOOTPARAM=5FHUNG=5FTASK=5FPANIC=3Dy=0ACONFIG=5FBOOTPARAM=
=5FHUNG=5FTASK=5FPANIC=5FVALUE=3D1=0ACONFIG=5FSCHED=5FDEBUG=3Dy=0ACONFIG=5F=
SCHEDSTATS=3Dy=0ACONFIG=5FTIMER=5FSTATS=3Dy=0ACONFIG=5FDEBUG=5FOBJECTS=3Dy=
=0ACONFIG=5FDEBUG=5FOBJECTS=5FSELFTEST=3Dy=0ACONFIG=5FDEBUG=5FOBJECTS=5FFRE=
E=3Dy=0ACONFIG=5FDEBUG=5FOBJECTS=5FTIMERS=3Dy=0ACONFIG=5FDEBUG=5FOBJECTS=5F=
WORK=3Dy=0ACONFIG=5FDEBUG=5FOBJECTS=5FPERCPU=5FCOUNTER=3Dy=0ACONFIG=5FDEBUG=
=5FOBJECTS=5FENABLE=5FDEFAULT=3D1=0ACONFIG=5FSLUB=5FDEBUG=5FON=3Dy=0ACONFIG=
=5FSLUB=5FSTATS=3Dy=0ACONFIG=5FDEBUG=5FRT=5FMUTEXES=3Dy=0ACONFIG=5FDEBUG=5F=
PI=5FLIST=3Dy=0ACONFIG=5FRT=5FMUTEX=5FTESTER=3Dy=0ACONFIG=5FDEBUG=5FSPINLOC=
K=3Dy=0ACONFIG=5FDEBUG=5FMUTEXES=3Dy=0ACONFIG=5FBKL=3Dy=0ACONFIG=5FDEBUG=5F=
LOCK=5FALLOC=3Dy=0ACONFIG=5FPROVE=5FLOCKING=3Dy=0ACONFIG=5FPROVE=5FRCU=3Dy=
=0ACONFIG=5FPROVE=5FRCU=5FREPEATEDLY=3Dy=0ACONFIG=5FSPARSE=5FRCU=5FPOINTER=
=3Dy=0ACONFIG=5FLOCKDEP=3Dy=0ACONFIG=5FLOCK=5FSTAT=3Dy=0ACONFIG=5FDEBUG=5FL=
OCKDEP=3Dy=0ACONFIG=5FTRACE=5FIRQFLAGS=3Dy=0ACONFIG=5FDEBUG=5FSPINLOCK=5FSL=
EEP=3Dy=0ACONFIG=5FDEBUG=5FLOCKING=5FAPI=5FSELFTESTS=3Dy=0ACONFIG=5FSTACKTR=
ACE=3Dy=0ACONFIG=5FDEBUG=5FKOBJECT=3Dy=0ACONFIG=5FDEBUG=5FBUGVERBOSE=3Dy=0A=
CONFIG=5FDEBUG=5FINFO=3Dy=0ACONFIG=5FDEBUG=5FINFO=5FREDUCED=3Dy=0ACONFIG=5F=
DEBUG=5FVM=3Dy=0ACONFIG=5FDEBUG=5FVIRTUAL=3Dy=0ACONFIG=5FDEBUG=5FWRITECOUNT=
=3Dy=0ACONFIG=5FDEBUG=5FMEMORY=5FINIT=3Dy=0ACONFIG=5FDEBUG=5FLIST=3Dy=0ACON=
FIG=5FTEST=5FLIST=5FSORT=3Dy=0ACONFIG=5FDEBUG=5FSG=3Dy=0ACONFIG=5FDEBUG=5FN=
OTIFIERS=3Dy=0ACONFIG=5FDEBUG=5FCREDENTIALS=3Dy=0ACONFIG=5FARCH=5FWANT=5FFR=
AME=5FPOINTERS=3Dy=0ACONFIG=5FFRAME=5FPOINTER=3Dy=0ACONFIG=5FBOOT=5FPRINTK=
=5FDELAY=3Dy=0ACONFIG=5FRCU=5FTORTURE=5FTEST=3Dy=0ACONFIG=5FRCU=5FTORTURE=
=5FTEST=5FRUNNABLE=3Dy=0ACONFIG=5FRCU=5FCPU=5FSTALL=5FDETECTOR=3Dy=0ACONFIG=
=5FRCU=5FCPU=5FSTALL=5FTIMEOUT=3D60=0ACONFIG=5FRCU=5FCPU=5FSTALL=5FDETECTOR=
=5FRUNNABLE=3Dy=0ACONFIG=5FKPROBES=5FSANITY=5FTEST=3Dy=0ACONFIG=5FBACKTRACE=
=5FSELF=5FTEST=3Dy=0ACONFIG=5FDEBUG=5FBLOCK=5FEXT=5FDEVT=3Dy=0ACONFIG=5FDEB=
UG=5FFORCE=5FWEAK=5FPER=5FCPU=3Dy=0ACONFIG=5FLKDTM=3Dy=0ACONFIG=5FCPU=5FNOT=
IFIER=5FERROR=5FINJECT=3Dy=0ACONFIG=5FFAULT=5FINJECTION=3Dy=0ACONFIG=5FFAIL=
SLAB=3Dy=0ACONFIG=5FFAIL=5FPAGE=5FALLOC=3Dy=0ACONFIG=5FFAIL=5FMAKE=5FREQUES=
T=3Dy=0ACONFIG=5FFAIL=5FIO=5FTIMEOUT=3Dy=0ACONFIG=5FFAULT=5FINJECTION=5FDEB=
UG=5FFS=3Dy=0ACONFIG=5FLATENCYTOP=3Dy=0ACONFIG=5FSYSCTL=5FSYSCALL=5FCHECK=
=3Dy=0ACONFIG=5FDEBUG=5FPAGEALLOC=3Dy=0ACONFIG=5FUSER=5FSTACKTRACE=5FSUPPOR=
T=3Dy=0ACONFIG=5FNOP=5FTRACER=3Dy=0ACONFIG=5FHAVE=5FFTRACE=5FNMI=5FENTER=3D=
y=0ACONFIG=5FHAVE=5FFUNCTION=5FTRACER=3Dy=0ACONFIG=5FHAVE=5FFUNCTION=5FGRAP=
H=5FTRACER=3Dy=0ACONFIG=5FHAVE=5FFUNCTION=5FGRAPH=5FFP=5FTEST=3Dy=0ACONFIG=
=5FHAVE=5FFUNCTION=5FTRACE=5FMCOUNT=5FTEST=3Dy=0ACONFIG=5FHAVE=5FDYNAMIC=5F=
FTRACE=3Dy=0ACONFIG=5FHAVE=5FFTRACE=5FMCOUNT=5FRECORD=3Dy=0ACONFIG=5FHAVE=
=5FSYSCALL=5FTRACEPOINTS=3Dy=0ACONFIG=5FHAVE=5FC=5FRECORDMCOUNT=3Dy=0ACONFI=
G=5FTRACER=5FMAX=5FTRACE=3Dy=0ACONFIG=5FRING=5FBUFFER=3Dy=0ACONFIG=5FFTRACE=
=5FNMI=5FENTER=3Dy=0ACONFIG=5FEVENT=5FTRACING=3Dy=0ACONFIG=5FEVENT=5FPOWER=
=5FTRACING=5FDEPRECATED=3Dy=0ACONFIG=5FCONTEXT=5FSWITCH=5FTRACER=3Dy=0ACONF=
IG=5FRING=5FBUFFER=5FALLOW=5FSWAP=3Dy=0ACONFIG=5FTRACING=3Dy=0ACONFIG=5FGEN=
ERIC=5FTRACER=3Dy=0ACONFIG=5FTRACING=5FSUPPORT=3Dy=0ACONFIG=5FFTRACE=3Dy=0A=
CONFIG=5FFUNCTION=5FTRACER=3Dy=0ACONFIG=5FFUNCTION=5FGRAPH=5FTRACER=3Dy=0AC=
ONFIG=5FIRQSOFF=5FTRACER=3Dy=0ACONFIG=5FSCHED=5FTRACER=3Dy=0ACONFIG=5FFTRAC=
E=5FSYSCALLS=3Dy=0ACONFIG=5FBRANCH=5FPROFILE=5FNONE=3Dy=0A# CONFIG=5FPROFIL=
E=5FANNOTATED=5FBRANCHES is not set=0A# CONFIG=5FPROFILE=5FALL=5FBRANCHES i=
s not set=0ACONFIG=5FSTACK=5FTRACER=3Dy=0ACONFIG=5FBLK=5FDEV=5FIO=5FTRACE=
=3Dy=0ACONFIG=5FKPROBE=5FEVENT=3Dy=0ACONFIG=5FDYNAMIC=5FFTRACE=3Dy=0ACONFIG=
=5FFUNCTION=5FPROFILER=3Dy=0ACONFIG=5FFTRACE=5FMCOUNT=5FRECORD=3Dy=0ACONFIG=
=5FFTRACE=5FSELFTEST=3Dy=0ACONFIG=5FFTRACE=5FSTARTUP=5FTEST=3Dy=0ACONFIG=5F=
EVENT=5FTRACE=5FTEST=5FSYSCALLS=3Dy=0ACONFIG=5FMMIOTRACE=3Dy=0ACONFIG=5FMMI=
OTRACE=5FTEST=3Dm=0ACONFIG=5FRING=5FBUFFER=5FBENCHMARK=3Dy=0ACONFIG=5FPROVI=
DE=5FOHCI1394=5FDMA=5FINIT=3Dy=0ACONFIG=5FFIREWIRE=5FOHCI=5FREMOTE=5FDMA=3D=
y=0ACONFIG=5FBUILD=5FDOCSRC=3Dy=0ACONFIG=5FDYNAMIC=5FDEBUG=3Dy=0ACONFIG=5FD=
MA=5FAPI=5FDEBUG=3Dy=0ACONFIG=5FATOMIC64=5FSELFTEST=3Dy=0ACONFIG=5FASYNC=5F=
RAID6=5FTEST=3Dy=0ACONFIG=5FSAMPLES=3Dy=0ACONFIG=5FSAMPLE=5FTRACEPOINTS=3Dm=
=0ACONFIG=5FSAMPLE=5FTRACE=5FEVENTS=3Dm=0ACONFIG=5FSAMPLE=5FKOBJECT=3Dm=0AC=
ONFIG=5FSAMPLE=5FKPROBES=3Dm=0ACONFIG=5FSAMPLE=5FKRETPROBES=3Dm=0ACONFIG=5F=
SAMPLE=5FHW=5FBREAKPOINT=3Dm=0ACONFIG=5FSAMPLE=5FKFIFO=3Dm=0ACONFIG=5FSAMPL=
E=5FKDB=3Dm=0ACONFIG=5FHAVE=5FARCH=5FKGDB=3Dy=0ACONFIG=5FKGDB=3Dy=0ACONFIG=
=5FKGDB=5FSERIAL=5FCONSOLE=3Dy=0ACONFIG=5FKGDB=5FTESTS=3Dy=0ACONFIG=5FKGDB=
=5FTESTS=5FON=5FBOOT=3Dy=0ACONFIG=5FKGDB=5FTESTS=5FBOOT=5FSTRING=3D"V1F100"=
=0ACONFIG=5FKGDB=5FLOW=5FLEVEL=5FTRAP=3Dy=0ACONFIG=5FKGDB=5FKDB=3Dy=0ACONFI=
G=5FKDB=5FKEYBOARD=3Dy=0ACONFIG=5FHAVE=5FARCH=5FKMEMCHECK=3Dy=0ACONFIG=5FST=
RICT=5FDEVMEM=3Dy=0ACONFIG=5FX86=5FVERBOSE=5FBOOTUP=3Dy=0ACONFIG=5FEARLY=5F=
PRINTK=3Dy=0ACONFIG=5FEARLY=5FPRINTK=5FDBGP=3Dy=0ACONFIG=5FDEBUG=5FSTACKOVE=
RFLOW=3Dy=0ACONFIG=5FDEBUG=5FSTACK=5FUSAGE=3Dy=0ACONFIG=5FDEBUG=5FPER=5FCPU=
=5FMAPS=3Dy=0ACONFIG=5FX86=5FPTDUMP=3Dy=0ACONFIG=5FDEBUG=5FRODATA=3Dy=0ACON=
FIG=5FDEBUG=5FRODATA=5FTEST=3Dy=0ACONFIG=5FDEBUG=5FSET=5FMODULE=5FRONX=3Dy=
=0ACONFIG=5FDEBUG=5FNX=5FTEST=3Dm=0ACONFIG=5FIOMMU=5FDEBUG=3Dy=0ACONFIG=5FI=
OMMU=5FSTRESS=3Dy=0ACONFIG=5FIOMMU=5FLEAK=3Dy=0ACONFIG=5FHAVE=5FMMIOTRACE=
=5FSUPPORT=3Dy=0ACONFIG=5FX86=5FDECODER=5FSELFTEST=3Dy=0ACONFIG=5FIO=5FDELA=
Y=5FTYPE=5F0X80=3D0=0ACONFIG=5FIO=5FDELAY=5FTYPE=5F0XED=3D1=0ACONFIG=5FIO=
=5FDELAY=5FTYPE=5FUDELAY=3D2=0ACONFIG=5FIO=5FDELAY=5FTYPE=5FNONE=3D3=0ACONF=
IG=5FIO=5FDELAY=5F0X80=3Dy=0A# CONFIG=5FIO=5FDELAY=5F0XED is not set=0A# CO=
NFIG=5FIO=5FDELAY=5FUDELAY is not set=0A# CONFIG=5FIO=5FDELAY=5FNONE is not=
 set=0ACONFIG=5FDEFAULT=5FIO=5FDELAY=5FTYPE=3D0=0ACONFIG=5FDEBUG=5FBOOT=5FP=
ARAMS=3Dy=0ACONFIG=5FCPA=5FDEBUG=3Dy=0ACONFIG=5FOPTIMIZE=5FINLINING=3Dy=0AC=
ONFIG=5FDEBUG=5FSTRICT=5FUSER=5FCOPY=5FCHECKS=3Dy=0A=0A#=0A# Security optio=
ns=0A#=0ACONFIG=5FKEYS=3Dy=0ACONFIG=5FTRUSTED=5FKEYS=3Dy=0ACONFIG=5FENCRYPT=
ED=5FKEYS=3Dy=0ACONFIG=5FKEYS=5FDEBUG=5FPROC=5FKEYS=3Dy=0ACONFIG=5FSECURITY=
=5FDMESG=5FRESTRICT=3Dy=0ACONFIG=5FSECURITY=3Dy=0ACONFIG=5FSECURITYFS=3Dy=
=0ACONFIG=5FSECURITY=5FNETWORK=3Dy=0ACONFIG=5FSECURITY=5FNETWORK=5FXFRM=3Dy=
=0ACONFIG=5FSECURITY=5FPATH=3Dy=0ACONFIG=5FINTEL=5FTXT=3Dy=0ACONFIG=5FLSM=
=5FMMAP=5FMIN=5FADDR=3D65536=0ACONFIG=5FSECURITY=5FSELINUX=3Dy=0ACONFIG=5FS=
ECURITY=5FSELINUX=5FBOOTPARAM=3Dy=0ACONFIG=5FSECURITY=5FSELINUX=5FBOOTPARAM=
=5FVALUE=3D1=0ACONFIG=5FSECURITY=5FSELINUX=5FDISABLE=3Dy=0ACONFIG=5FSECURIT=
Y=5FSELINUX=5FDEVELOP=3Dy=0ACONFIG=5FSECURITY=5FSELINUX=5FAVC=5FSTATS=3Dy=
=0ACONFIG=5FSECURITY=5FSELINUX=5FCHECKREQPROT=5FVALUE=3D1=0ACONFIG=5FSECURI=
TY=5FSELINUX=5FPOLICYDB=5FVERSION=5FMAX=3Dy=0ACONFIG=5FSECURITY=5FSELINUX=
=5FPOLICYDB=5FVERSION=5FMAX=5FVALUE=3D19=0ACONFIG=5FSECURITY=5FSMACK=3Dy=0A=
CONFIG=5FSECURITY=5FTOMOYO=3Dy=0ACONFIG=5FSECURITY=5FAPPARMOR=3Dy=0ACONFIG=
=5FSECURITY=5FAPPARMOR=5FBOOTPARAM=5FVALUE=3D1=0ACONFIG=5FIMA=3Dy=0ACONFIG=
=5FIMA=5FMEASURE=5FPCR=5FIDX=3D10=0ACONFIG=5FIMA=5FAUDIT=3Dy=0ACONFIG=5FIMA=
=5FLSM=5FRULES=3Dy=0ACONFIG=5FDEFAULT=5FSECURITY=5FSELINUX=3Dy=0A# CONFIG=
=5FDEFAULT=5FSECURITY=5FSMACK is not set=0A# CONFIG=5FDEFAULT=5FSECURITY=5F=
TOMOYO is not set=0A# CONFIG=5FDEFAULT=5FSECURITY=5FAPPARMOR is not set=0A#=
 CONFIG=5FDEFAULT=5FSECURITY=5FDAC is not set=0ACONFIG=5FDEFAULT=5FSECURITY=
=3D"selinux"=0ACONFIG=5FXOR=5FBLOCKS=3Dy=0ACONFIG=5FASYNC=5FCORE=3Dy=0ACONF=
IG=5FASYNC=5FMEMCPY=3Dy=0ACONFIG=5FASYNC=5FXOR=3Dy=0ACONFIG=5FASYNC=5FPQ=3D=
y=0ACONFIG=5FASYNC=5FRAID6=5FRECOV=3Dy=0ACONFIG=5FASYNC=5FTX=5FDISABLE=5FPQ=
=5FVAL=5FDMA=3Dy=0ACONFIG=5FASYNC=5FTX=5FDISABLE=5FXOR=5FVAL=5FDMA=3Dy=0ACO=
NFIG=5FCRYPTO=3Dy=0A=0A#=0A# Crypto core or helper=0A#=0ACONFIG=5FCRYPTO=5F=
ALGAPI=3Dy=0ACONFIG=5FCRYPTO=5FALGAPI2=3Dy=0ACONFIG=5FCRYPTO=5FAEAD=3Dy=0AC=
ONFIG=5FCRYPTO=5FAEAD2=3Dy=0ACONFIG=5FCRYPTO=5FBLKCIPHER=3Dy=0ACONFIG=5FCRY=
PTO=5FBLKCIPHER2=3Dy=0ACONFIG=5FCRYPTO=5FHASH=3Dy=0ACONFIG=5FCRYPTO=5FHASH2=
=3Dy=0ACONFIG=5FCRYPTO=5FRNG=3Dy=0ACONFIG=5FCRYPTO=5FRNG2=3Dy=0ACONFIG=5FCR=
YPTO=5FPCOMP=3Dy=0ACONFIG=5FCRYPTO=5FPCOMP2=3Dy=0ACONFIG=5FCRYPTO=5FMANAGER=
=3Dy=0ACONFIG=5FCRYPTO=5FMANAGER2=3Dy=0ACONFIG=5FCRYPTO=5FMANAGER=5FDISABLE=
=5FTESTS=3Dy=0ACONFIG=5FCRYPTO=5FGF128MUL=3Dy=0ACONFIG=5FCRYPTO=5FNULL=3Dy=
=0ACONFIG=5FCRYPTO=5FPCRYPT=3Dy=0ACONFIG=5FCRYPTO=5FWORKQUEUE=3Dy=0ACONFIG=
=5FCRYPTO=5FCRYPTD=3Dy=0ACONFIG=5FCRYPTO=5FAUTHENC=3Dy=0ACONFIG=5FCRYPTO=5F=
TEST=3Dm=0A=0A#=0A# Authenticated Encryption with Associated Data=0A#=0ACON=
FIG=5FCRYPTO=5FCCM=3Dy=0ACONFIG=5FCRYPTO=5FGCM=3Dy=0ACONFIG=5FCRYPTO=5FSEQI=
V=3Dy=0A=0A#=0A# Block modes=0A#=0ACONFIG=5FCRYPTO=5FCBC=3Dy=0ACONFIG=5FCRY=
PTO=5FCTR=3Dy=0ACONFIG=5FCRYPTO=5FCTS=3Dy=0ACONFIG=5FCRYPTO=5FECB=3Dy=0ACON=
FIG=5FCRYPTO=5FLRW=3Dy=0ACONFIG=5FCRYPTO=5FPCBC=3Dy=0ACONFIG=5FCRYPTO=5FXTS=
=3Dy=0ACONFIG=5FCRYPTO=5FFPU=3Dy=0A=0A#=0A# Hash modes=0A#=0ACONFIG=5FCRYPT=
O=5FHMAC=3Dy=0ACONFIG=5FCRYPTO=5FXCBC=3Dy=0ACONFIG=5FCRYPTO=5FVMAC=3Dy=0A=
=0A#=0A# Digest=0A#=0ACONFIG=5FCRYPTO=5FCRC32C=3Dy=0ACONFIG=5FCRYPTO=5FCRC3=
2C=5FINTEL=3Dy=0ACONFIG=5FCRYPTO=5FGHASH=3Dy=0ACONFIG=5FCRYPTO=5FMD4=3Dy=0A=
CONFIG=5FCRYPTO=5FMD5=3Dy=0ACONFIG=5FCRYPTO=5FMICHAEL=5FMIC=3Dy=0ACONFIG=5F=
CRYPTO=5FRMD128=3Dy=0ACONFIG=5FCRYPTO=5FRMD160=3Dy=0ACONFIG=5FCRYPTO=5FRMD2=
56=3Dy=0ACONFIG=5FCRYPTO=5FRMD320=3Dy=0ACONFIG=5FCRYPTO=5FSHA1=3Dy=0ACONFIG=
=5FCRYPTO=5FSHA256=3Dy=0ACONFIG=5FCRYPTO=5FSHA512=3Dy=0ACONFIG=5FCRYPTO=5FT=
GR192=3Dy=0ACONFIG=5FCRYPTO=5FWP512=3Dy=0ACONFIG=5FCRYPTO=5FGHASH=5FCLMUL=
=5FNI=5FINTEL=3Dy=0A=0A#=0A# Ciphers=0A#=0ACONFIG=5FCRYPTO=5FAES=3Dy=0ACONF=
IG=5FCRYPTO=5FAES=5FX86=5F64=3Dy=0ACONFIG=5FCRYPTO=5FAES=5FNI=5FINTEL=3Dy=
=0ACONFIG=5FCRYPTO=5FANUBIS=3Dy=0ACONFIG=5FCRYPTO=5FARC4=3Dy=0ACONFIG=5FCRY=
PTO=5FBLOWFISH=3Dy=0ACONFIG=5FCRYPTO=5FCAMELLIA=3Dy=0ACONFIG=5FCRYPTO=5FCAS=
T5=3Dy=0ACONFIG=5FCRYPTO=5FCAST6=3Dy=0ACONFIG=5FCRYPTO=5FDES=3Dy=0ACONFIG=
=5FCRYPTO=5FFCRYPT=3Dy=0ACONFIG=5FCRYPTO=5FKHAZAD=3Dy=0ACONFIG=5FCRYPTO=5FS=
ALSA20=3Dy=0ACONFIG=5FCRYPTO=5FSALSA20=5FX86=5F64=3Dy=0ACONFIG=5FCRYPTO=5FS=
EED=3Dy=0ACONFIG=5FCRYPTO=5FSERPENT=3Dy=0ACONFIG=5FCRYPTO=5FTEA=3Dy=0ACONFI=
G=5FCRYPTO=5FTWOFISH=3Dy=0ACONFIG=5FCRYPTO=5FTWOFISH=5FCOMMON=3Dy=0ACONFIG=
=5FCRYPTO=5FTWOFISH=5FX86=5F64=3Dy=0A=0A#=0A# Compression=0A#=0ACONFIG=5FCR=
YPTO=5FDEFLATE=3Dy=0ACONFIG=5FCRYPTO=5FZLIB=3Dy=0ACONFIG=5FCRYPTO=5FLZO=3Dy=
=0A=0A#=0A# Random Number Generation=0A#=0ACONFIG=5FCRYPTO=5FANSI=5FCPRNG=
=3Dy=0ACONFIG=5FCRYPTO=5FUSER=5FAPI=3Dy=0ACONFIG=5FCRYPTO=5FUSER=5FAPI=5FHA=
SH=3Dy=0ACONFIG=5FCRYPTO=5FUSER=5FAPI=5FSKCIPHER=3Dy=0ACONFIG=5FCRYPTO=5FHW=
=3Dy=0ACONFIG=5FCRYPTO=5FDEV=5FPADLOCK=3Dy=0ACONFIG=5FCRYPTO=5FDEV=5FPADLOC=
K=5FAES=3Dy=0ACONFIG=5FCRYPTO=5FDEV=5FPADLOCK=5FSHA=3Dy=0ACONFIG=5FCRYPTO=
=5FDEV=5FHIFN=5F795X=3Dy=0ACONFIG=5FCRYPTO=5FDEV=5FHIFN=5F795X=5FRNG=3Dy=0A=
CONFIG=5FHAVE=5FKVM=3Dy=0ACONFIG=5FHAVE=5FKVM=5FIRQCHIP=3Dy=0ACONFIG=5FHAVE=
=5FKVM=5FEVENTFD=3Dy=0ACONFIG=5FKVM=5FAPIC=5FARCHITECTURE=3Dy=0ACONFIG=5FKV=
M=5FMMIO=3Dy=0ACONFIG=5FKVM=5FASYNC=5FPF=3Dy=0ACONFIG=5FVIRTUALIZATION=3Dy=
=0ACONFIG=5FKVM=3Dy=0ACONFIG=5FKVM=5FINTEL=3Dy=0ACONFIG=5FKVM=5FAMD=3Dy=0AC=
ONFIG=5FKVM=5FMMU=5FAUDIT=3Dy=0ACONFIG=5FVHOST=5FNET=3Dy=0ACONFIG=5FVIRTIO=
=3Dy=0ACONFIG=5FVIRTIO=5FRING=3Dy=0ACONFIG=5FVIRTIO=5FPCI=3Dy=0ACONFIG=5FVI=
RTIO=5FBALLOON=3Dy=0ACONFIG=5FBINARY=5FPRINTF=3Dy=0A=0A#=0A# Library routin=
es=0A#=0ACONFIG=5FRAID6=5FPQ=3Dy=0ACONFIG=5FBITREVERSE=3Dy=0ACONFIG=5FGENER=
IC=5FFIND=5FFIRST=5FBIT=3Dy=0ACONFIG=5FGENERIC=5FFIND=5FNEXT=5FBIT=3Dy=0ACO=
NFIG=5FGENERIC=5FFIND=5FLAST=5FBIT=3Dy=0ACONFIG=5FCRC=5FCCITT=3Dy=0ACONFIG=
=5FCRC16=3Dy=0ACONFIG=5FCRC=5FT10DIF=3Dy=0ACONFIG=5FCRC=5FITU=5FT=3Dy=0ACON=
FIG=5FCRC32=3Dy=0ACONFIG=5FCRC7=3Dy=0ACONFIG=5FLIBCRC32C=3Dy=0ACONFIG=5FZLI=
B=5FINFLATE=3Dy=0ACONFIG=5FZLIB=5FDEFLATE=3Dy=0ACONFIG=5FLZO=5FCOMPRESS=3Dy=
=0ACONFIG=5FLZO=5FDECOMPRESS=3Dy=0ACONFIG=5FXZ=5FDEC=3Dy=0ACONFIG=5FXZ=5FDE=
C=5FX86=3Dy=0ACONFIG=5FXZ=5FDEC=5FPOWERPC=3Dy=0ACONFIG=5FXZ=5FDEC=5FIA64=3D=
y=0ACONFIG=5FXZ=5FDEC=5FARM=3Dy=0ACONFIG=5FXZ=5FDEC=5FARMTHUMB=3Dy=0ACONFIG=
=5FXZ=5FDEC=5FSPARC=3Dy=0ACONFIG=5FXZ=5FDEC=5FBCJ=3Dy=0ACONFIG=5FXZ=5FDEC=
=5FTEST=3Dy=0ACONFIG=5FDECOMPRESS=5FGZIP=3Dy=0ACONFIG=5FDECOMPRESS=5FBZIP2=
=3Dy=0ACONFIG=5FDECOMPRESS=5FLZMA=3Dy=0ACONFIG=5FDECOMPRESS=5FXZ=3Dy=0ACONF=
IG=5FDECOMPRESS=5FLZO=3Dy=0ACONFIG=5FGENERIC=5FALLOCATOR=3Dy=0ACONFIG=5FREE=
D=5FSOLOMON=3Dy=0ACONFIG=5FREED=5FSOLOMON=5FDEC16=3Dy=0ACONFIG=5FTEXTSEARCH=
=3Dy=0ACONFIG=5FTEXTSEARCH=5FKMP=3Dy=0ACONFIG=5FTEXTSEARCH=5FBM=3Dy=0ACONFI=
G=5FTEXTSEARCH=5FFSM=3Dy=0ACONFIG=5FBTREE=3Dy=0ACONFIG=5FHAS=5FIOMEM=3Dy=0A=
CONFIG=5FHAS=5FIOPORT=3Dy=0ACONFIG=5FHAS=5FDMA=3Dy=0ACONFIG=5FCHECK=5FSIGNA=
TURE=3Dy=0ACONFIG=5FCPUMASK=5FOFFSTACK=3Dy=0ACONFIG=5FCPU=5FRMAP=3Dy=0ACONF=
IG=5FNLATTR=3Dy=0ACONFIG=5FLRU=5FCACHE=3Dy=0ACONFIG=5FAVERAGE=3Dy=0A=

--------------070607070904080106030202--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
