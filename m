From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH] iwlwifi: pcie: fix SPLC structure parsing
Date: Thu, 13 Oct 2016 14:36:34 +0200
Message-ID: <1476362194.1999.11.camel@tiscali.nl>
References: <1476349269.3880.18.camel@coelho.fi>
         <20161013102155.14547-1-luca@coelho.fi>
         <1476358075.1999.5.camel@tiscali.nl> <1476358222.3880.21.camel@coelho.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linuxwifi@intel.com, emmanuel.grumbach@intel.com,
        johannes@sipsolutions.net, kvalo@codeaurora.org,
        oren.givon@intel.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Luca Coelho <luca@coelho.fi>, linux-wireless@vger.kernel.org,
        chris@rorvick.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476358222.3880.21.camel@coelho.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-10-13 at 14:30 +0300, Luca Coelho wrote:
> I forgot to say... could you load the iwlwifi module with debug=0x01
> (module parameter), so we can see the messages the driver is printing
> when it doesn't find a proper structure?

That makes a lot of noise! Here's the first 100 lines or so, that
apparently are generated directly after modprobing iwlwifi.

After these 100 lines there's a ten second gap (I guess it took me ten
seconds to actually use the wifi). I assume you don't care about that
part of the debug messages.

Have fun!


Paul Bolle

<7>[  767.691342] iwlwifi 0000:3a:00.0: U iwl_pcie_prepare_card_hw iwl_trans_prepare_card_hw enter
<7>[  767.691362] iwlwifi 0000:3a:00.0: U iwl_pcie_set_hw_ready hardware ready
<7>[  767.692127] iwlwifi 0000:3a:00.0: U iwl_request_firmware attempting to load firmware 'iwlwifi-8000C-24.ucode'
<7>[  767.692322] iwlwifi 0000:3a:00.0: U splc_get_pwr_limit No element for the WiFi domain returned by the SPLC method.
<7>[  767.692324] iwlwifi 0000:3a:00.0: U set_dflt_pwr_limit Default power limit set to 0
<4>[  767.692672] iwlwifi 0000:3a:00.0: Direct firmware load for iwlwifi-8000C-24.ucode failed with error -2
<7>[  767.692674] iwlwifi 0000:3a:00.0: U iwl_request_firmware attempting to load firmware 'iwlwifi-8000C-23.ucode'
<4>[  767.692683] iwlwifi 0000:3a:00.0: Direct firmware load for iwlwifi-8000C-23.ucode failed with error -2
<7>[  767.692684] iwlwifi 0000:3a:00.0: U iwl_request_firmware attempting to load firmware 'iwlwifi-8000C-22.ucode'
<7>[  767.693267] iwlwifi 0000:3a:00.0: U iwl_req_fw_callback Loaded firmware file 'iwlwifi-8000C-22.ucode' (2120860 bytes).
<7>[  767.693271] iwlwifi 0000:3a:00.0: U iwl_parse_tlv_firmware Found debug memory segment: 0
<7>[  767.693272] iwlwifi 0000:3a:00.0: U iwl_parse_tlv_firmware Found debug memory segment: 1
<7>[  767.693274] iwlwifi 0000:3a:00.0: U iwl_parse_tlv_firmware Found debug memory segment: 2
<7>[  767.693276] iwlwifi 0000:3a:00.0: U iwl_parse_tlv_firmware unknown TLV: 48
<7>[  767.693278] iwlwifi 0000:3a:00.0: U iwl_parse_tlv_firmware GSCAN is supported but capabilities TLV is unavailable
<6>[  767.693829] iwlwifi 0000:3a:00.0: loaded firmware version 22.361476.0 op_mode iwlmvm
<6>[  767.747133] iwlwifi 0000:3a:00.0: Detected Intel(R) Dual Band Wireless AC 8260, REV=0x208
<7>[  767.747141] iwlwifi 0000:3a:00.0: U iwl_pcie_prepare_card_hw iwl_trans_prepare_card_hw enter
<7>[  767.747168] iwlwifi 0000:3a:00.0: U iwl_pcie_set_hw_ready hardware ready
<7>[  767.749221] iwlwifi 0000:3a:00.0: U iwl_pcie_apm_init Init card's basic functions
<6>[  767.749257] iwlwifi 0000:3a:00.0: L1 Enabled - LTR Disabled
<7>[  767.749855] iwlwifi 0000:3a:00.0: U iwl_pcie_prepare_card_hw iwl_trans_prepare_card_hw enter
<7>[  767.749870] iwlwifi 0000:3a:00.0: U iwl_pcie_set_hw_ready hardware ready
<7>[  767.749878] iwlwifi 0000:3a:00.0: U iwl_pcie_apm_init Init card's basic functions
<6>[  767.749896] iwlwifi 0000:3a:00.0: L1 Enabled - LTR Disabled
<7>[  767.749906] iwlwifi 0000:3a:00.0: U iwl_mvm_nic_config Radio type=0x0-0x2-0x1
<7>[  767.750608] iwlwifi 0000:3a:00.0: U iwl_pcie_nic_init Enabling shadow registers in device
<7>[  767.750624] iwlwifi 0000:3a:00.0: U iwl_pcie_rsa_race_bug_wa can't access the RSA semaphore it is write protected
<7>[  767.810446] iwlwifi 0000:3a:00.0: I iwl_mvm_rx_mfuart_notif MFUART: installed ver: 0x12000415, external ver: 0x12000415, status: 0x00010080, duration: 0x00000006
<7>[  767.810861] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command BT_CONFIG
<7>[  767.810862] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command BT_CONFIG
<7>[  767.810984] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command BT_CONFIG
<7>[  767.811023] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.811025] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811098] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811102] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.811103] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811212] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811222] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.811223] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811318] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811326] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.811327] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811451] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811459] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.811460] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811555] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811564] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.811565] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811672] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811681] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.811682] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811742] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811746] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.811747] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811837] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811842] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.811843] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811944] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.811952] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.811953] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.812011] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.812016] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.812017] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.812073] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.812077] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.812077] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.812142] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.812146] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.812147] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.812201] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.812204] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.812205] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.812276] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.812281] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command NVM_ACCESS_CMD
<7>[  767.812281] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.812344] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command NVM_ACCESS_CMD
<7>[  767.812366] iwlwifi 0000:3a:00.0: U iwl_nvm_check_version device EEPROM VER=0xe56, CALIB=0xff
<7>[  767.812368] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command TX_ANT_CONFIGURATION_CMD
<7>[  767.812369] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command TX_ANT_CONFIGURATION_CMD
<7>[  767.812422] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command TX_ANT_CONFIGURATION_CMD
<7>[  767.812425] iwlwifi 0000:3a:00.0: U iwl_send_phy_cfg_cmd Sending Phy CFG command: 0x330018
<7>[  767.812426] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Attempting to send sync command PHY_CONFIGURATION_CMD
<7>[  767.812427] iwlwifi 0000:3a:00.0: U iwl_pcie_send_hcmd_sync Setting HCMD_ACTIVE for command PHY_CONFIGURATION_CMD
<7>[  767.812480] iwlwifi 0000:3a:00.0: I iwl_pcie_hcmd_complete Clearing HCMD_ACTIVE for command PHY_CONFIGURATION_CMD
<7>[  767.871057] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 1 , Size: 3684
<7>[  767.871065] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 2 , Size: 4
<7>[  767.871071] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 5 , Size: 2056
<7>[  767.871108] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 5 , Size: 2056
<7>[  767.871263] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 5 , Size: 2056
<7>[  767.871441] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 5 , Size: 2056
<7>[  767.871607] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 5 , Size: 2056
<7>[  767.871782] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 5 , Size: 2056
<7>[  767.871814] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 5 , Size: 2056
<7>[  767.871955] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 4 , Size: 1552
<7>[  767.872084] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 4 , Size: 1552
<7>[  767.872216] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 4 , Size: 1552
<7>[  767.872346] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 4 , Size: 1552
<7>[  767.872478] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 4 , Size: 1552
<7>[  767.872622] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 4 , Size: 1552
<7>[  767.872764] iwlwifi 0000:3a:00.0: I iwl_phy_db_set_section iwl_phy_db_set_section(282): [PHYDB]SET: Type 4 , Size: 1552
<7>[  767.872871] iwlwifi 0000:3a:00.0: U _iwl_trans_pcie_stop_device DEVICE_ENABLED bit was set and is now cleared
<7>[  767.872961] iwlwifi 0000:3a:00.0: U iwl_pcie_apm_stop Stop card, put in low power state
<7>[  767.872980] iwlwifi 0000:3a:00.0: U iwl_pcie_apm_stop_master stop master
<7>[  767.877089] iwlwifi 0000:3a:00.0: U iwl_pcie_prepare_card_hw iwl_trans_prepare_card_hw enter
<7>[  767.877119] iwlwifi 0000:3a:00.0: U iwl_pcie_set_hw_ready hardware ready
<6>[  767.905185] iwlwifi 0000:3a:00.0 wlp58s0: renamed from wlan0
