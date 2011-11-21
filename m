From: wwguy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: Firmware errors and warnings with Centrino Advanced-N 6205
Date: Mon, 21 Nov 2011 14:24:22 -0800
Message-ID: <1321914262.1834.1.camel@wwguy-ubuntu>
References: <20111120210012.405bd632@x220>
	 <1321889065.2258.5.camel@wwguy-ubuntu>	<20111121194824.12f4c276@x220>
	 <1321903999.2258.8.camel@wwguy-ubuntu>  <20111121222335.19493eed@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Network Mailing List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Udo Steinberg <udo-VarzJz7m+TuRpAAqCnN02g@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111121222335.19493eed@x220>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

ok, so looks like the driver not provide the correct 40MHz information
to the firmware. Are you seeing the similar issue on 20MHz?

Also what AP you are using?

Thanks
Wey

On Mon, 2011-11-21 at 13:23 -0800, Udo Steinberg wrote:
> On Mon, 21 Nov 2011 11:33:19 -0800 wwguy (W) wrote:
> 
> W> Looks like the firmware not like the rate was used with the antenna
> W> choice.
> W> 
> W> Could you please load the iwlagn module with debug flag = 0x1000
> W> 
> W> $ sudo modprobe iwlagn debug=0x1000
> W> 
> W> and let me know what you have
> W> 
> W> btw, what kernel version you are using?
> 
> Hi Wey,
> 
> I'm using Linux kernel 3.1.0. I got the following output with debug=0x1000.
> 
> Cheers,
> 
> 	- Udo
> 
> Nov 21 22:12:02 x220 kernel: Intel(R) Wireless WiFi Link AGN driver for Linux, in-tree:d
> Nov 21 22:12:02 x220 kernel: Copyright(c) 2003-2011 Intel Corporation
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: setting latency timer to 64
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: pci_resource_len = 0x00002000
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: pci_resource_base = ffffc900041a0000
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: HW Revision ID = 0x34
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: irq 49 for MSI/MSI-X
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: Detected Intel(R) Centrino(R) Advanced-N 6205 AGN, REV=0xB0
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: L1 Disabled; Enabling L0S
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: device EEPROM VER=0x715, CALIB=0x6
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: Device SKU: 0X1f0
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: Valid Tx ant: 0X3, Valid Rx ant: 0X3
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2406 active=2 idle=1
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: Tunable channels: 13 802.11bg, 24 802.11a channels
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: loaded firmware version 17.168.5.3 build 42301
> Nov 21 22:12:02 x220 kernel: Registered led device: phy1-led
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: Selected rate control algorithm 'iwl-agn-rs'
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 15: ff:ff:ff:ff:ff:ff
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 14: ff:ff:ff:ff:ff:ff
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: L1 Disabled; Enabling L0S
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: Radio type=0x1-0x2-0x0
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: L1 Disabled; Enabling L0S
> Nov 21 22:12:02 x220 kernel: iwlagn 0000:03:00.0: Radio type=0x1-0x2-0x0
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2406 active=2 idle=1
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2406 active=2 idle=1
> Nov 21 22:12:02 x220 last message repeated 2 times
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2406 active=2 idle=1
> Nov 21 22:12:02 x220 last message repeated 5 times
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:12:02 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2406 active=2 idle=1
> Nov 21 22:12:06 x220 last message repeated 11 times
> Nov 21 22:12:06 x220 kernel: wlan0: authenticate with 00:24:fe:41:8d:0e (try 1)
> Nov 21 22:12:06 x220 kernel: wlan0: authenticated
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2406 active=2 idle=1
> Nov 21 22:12:06 x220 last message repeated 5 times
> Nov 21 22:12:06 x220 kernel: wlan0: associate with 00:24:fe:41:8d:0e (try 1)
> Nov 21 22:12:06 x220 kernel: wlan0: RX ReassocResp from 00:24:fe:41:8d:0e (capab=0x431 status=0 aid=1)
> Nov 21 22:12:06 x220 kernel: wlan0: associated
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 0: 00:24:fe:41:8d:0e
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_set_ht_add_station spatial multiplexing power save mode: disabled
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2406 active=2 idle=1
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x6806 active=2 idle=2
> Nov 21 22:12:06 x220 last message repeated 2 times
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x6806 active=2 idle=2
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x6806 active=2 idle=2
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta 00:24:fe:41:8d:0e
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008025 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta 00:24:fe:41:8d:0e
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_send_rxon_timing beacon interval 100 beacon timer 102016 beacon tim 0
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_send_remove_station REPLY_REMOVE_STA PASSED
> Nov 21 22:12:06 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:12:07 x220 last message repeated 2 times
> Nov 21 22:12:08 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:12:08 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:12:33 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:12:38 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:12:38 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:12:38 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:12:38 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:12:38 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:12:44 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:12:44 x220 kernel: iwlagn 0000:03:00.0: Tx aggregation enabled on ra = 00:24:fe:41:8d:0e tid = 0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 last message repeated 2 times
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 last message repeated 2 times
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: Microcode SW error detected.  Restarting 0x2000000.
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: Loaded firmware version: 17.168.5.3 build 42301
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: Start IWL Error Log Dump:
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: Status: 0x000412E4, count: 6
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x00002078 | ADVANCED_SYSASSERT          
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x00009514 | uPc
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x00009496 | branchlink1
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x00009496 | branchlink2
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x0000D1F2 | interruptlink1
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | interruptlink2
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x00008035 | data1
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x0000C90F | data2
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x000005A7 | line
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x4E404AC5 | beacon time
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x812C753B | tsf low
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | tsf hi
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | time gp1
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x085F4F65 | time gp2
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | time gp3
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x000111A8 | uCode version
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x000000B0 | hw version
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x00480303 | board version
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: 0x093D004E | hcmd
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: CSR values:
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: (2nd byte of CSR_INT_COALESCING is CSR_INT_PERIODIC_REG)
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:        CSR_HW_IF_CONFIG_REG: 0X00480303
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:          CSR_INT_COALESCING: 0X0000ff40
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:                     CSR_INT: 0X00000000
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:                CSR_INT_MASK: 0X00000000
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:           CSR_FH_INT_STATUS: 0X00000000
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:                 CSR_GPIO_IN: 0X00000030
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:                   CSR_RESET: 0X00000000
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:                CSR_GP_CNTRL: 0X080403c5
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:                  CSR_HW_REV: 0X000000b0
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:              CSR_EEPROM_REG: 0X37d60ffd
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:               CSR_EEPROM_GP: 0X90000001
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:              CSR_OTP_GP_REG: 0X00030001
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:                 CSR_GIO_REG: 0X00080044
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:            CSR_GP_UCODE_REG: 0X00008520
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:           CSR_GP_DRIVER_REG: 0X00000000
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:           CSR_UCODE_DRV_GP1: 0X00000000
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:           CSR_UCODE_DRV_GP2: 0X00000000
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:                 CSR_LED_REG: 0X00000058
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:        CSR_DRAM_INT_TBL_REG: 0X88211eee
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:        CSR_GIO_CHICKEN_BITS: 0X27800200
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:             CSR_ANA_PLL_CFG: 0X00000000
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:           CSR_HW_REV_WA_REG: 0X0001001a
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:        CSR_DBG_HPET_MEM_REG: 0Xffff0010
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: FH register values:
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:         FH_RSCSR_CHNL0_STTS_WPTR_REG: 0X212d1300
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:        FH_RSCSR_CHNL0_RBDCB_BASE_REG: 0X0213af40
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:                  FH_RSCSR_CHNL0_WPTR: 0X000000c8
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:         FH_MEM_RCSR_CHNL0_CONFIG_REG: 0X80819104
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:          FH_MEM_RSSR_SHARED_CTRL_REG: 0X000000fc
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:            FH_MEM_RSSR_RX_STATUS_REG: 0X07030000
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:    FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:                FH_TSSR_TX_STATUS_REG: 0X07ff0001
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0:                 FH_TSSR_TX_ERROR_REG: 0X00000000
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: Start IWL Event Log Dump: display last 20 entries
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140460940:0x00000020:0208
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140460959:0x00000000:0302
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140460993:0x00000001:0203
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140460998:0x0ab7001c:0206
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140460999:0x00000040:0204
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140461002:0x2a10fb5e:0222
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140461002:0xc0100084:0223
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140461005:0x00000040:0219
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140461006:0x01000110:0211
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140461010:0x00000000:0212
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140461049:0x00000000:0215
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140461051:0x00000008:0220
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140461069:0x00000000:0302
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140461100:0x000000d4:0303
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140461104:0x00001fb8:0217
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140461104:0x0ab7001c:0217
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140461723:0x000000fa:0106
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140461725:0x00000000:0301
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140463965:0x093d004e:0401
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0140463975:0x00000000:0125
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: Hardware restart was requested
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 15: ff:ff:ff:ff:ff:ff
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 14: ff:ff:ff:ff:ff:ff
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: L1 Disabled; Enabling L0S
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: Radio type=0x1-0x2-0x0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_send_rxon_timing beacon interval 200 beacon timer 204416 beacon tim 0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 last message repeated 2 times
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 0: 00:24:fe:41:8d:0e
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_set_ht_add_station spatial multiplexing power save mode: disabled
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 last message repeated 2 times
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8015 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8015 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta 00:24:fe:41:8d:0e
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta 00:24:fe:41:8d:0e
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_send_rxon_timing beacon interval 100 beacon timer 102016 beacon tim 0
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_send_remove_station REPLY_REMOVE_STA PASSED
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: Stopping AGG while state not ON or starting
> Nov 21 22:14:23 x220 kernel: iwlagn 0000:03:00.0: queue number out of range: 0, must be 10 to 19
> Nov 21 22:14:23 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:14:23 x220 last message repeated 3 times
> Nov 21 22:14:24 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:24 x220 last message repeated 2 times
> Nov 21 22:14:24 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:14:24 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:24 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:14:24 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:24 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:14:24 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:24 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:14:24 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:24 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:14:24 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:24 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:14:24 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:14:25 x220 last message repeated 2 times
> Nov 21 22:14:40 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:14:40 x220 kernel: iwlagn 0000:03:00.0: Tx aggregation enabled on ra = 00:24:fe:41:8d:0e tid = 0
> Nov 21 22:15:05 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:16:32 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:32 x220 last message repeated 2 times
> Nov 21 22:16:32 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:16:32 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:32 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:16:32 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:32 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:16:32 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:32 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:16:32 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:32 x220 last message repeated 2 times
> Nov 21 22:16:32 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:16:32 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:32 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:16:32 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: Microcode SW error detected.  Restarting 0x2000000.
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: Loaded firmware version: 17.168.5.3 build 42301
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: Start IWL Error Log Dump:
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: Status: 0x000412E4, count: 6
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x00002078 | ADVANCED_SYSASSERT          
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x00009514 | uPc
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x00009496 | branchlink1
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x00009496 | branchlink2
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x0000D1F2 | interruptlink1
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | interruptlink2
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x00008035 | data1
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x0000E90D | data2
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x000005A7 | line
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x3BC143DF | beacon time
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x88E40C21 | tsf low
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | tsf hi
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | time gp1
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x07B77463 | time gp2
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | time gp3
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x000111A8 | uCode version
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x000000B0 | hw version
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x00480303 | board version
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: 0x091D004E | hcmd
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: CSR values:
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: (2nd byte of CSR_INT_COALESCING is CSR_INT_PERIODIC_REG)
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:        CSR_HW_IF_CONFIG_REG: 0X00480303
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:          CSR_INT_COALESCING: 0X0000ff40
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:                     CSR_INT: 0X00000000
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:                CSR_INT_MASK: 0X00000000
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:           CSR_FH_INT_STATUS: 0X00000000
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:                 CSR_GPIO_IN: 0X00000030
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:                   CSR_RESET: 0X00000000
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:                CSR_GP_CNTRL: 0X080403c5
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:                  CSR_HW_REV: 0X000000b0
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:              CSR_EEPROM_REG: 0X37d60ffd
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:               CSR_EEPROM_GP: 0X90000001
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:              CSR_OTP_GP_REG: 0X00030001
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:                 CSR_GIO_REG: 0X00080044
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:            CSR_GP_UCODE_REG: 0X00007b58
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:           CSR_GP_DRIVER_REG: 0X00000000
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:           CSR_UCODE_DRV_GP1: 0X00000000
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:           CSR_UCODE_DRV_GP2: 0X00000000
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:                 CSR_LED_REG: 0X00000078
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:        CSR_DRAM_INT_TBL_REG: 0X88211eee
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:        CSR_GIO_CHICKEN_BITS: 0X27800200
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:             CSR_ANA_PLL_CFG: 0X00000000
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:           CSR_HW_REV_WA_REG: 0X0001001a
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:        CSR_DBG_HPET_MEM_REG: 0Xffff0000
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: FH register values:
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:         FH_RSCSR_CHNL0_STTS_WPTR_REG: 0X212d1300
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:        FH_RSCSR_CHNL0_RBDCB_BASE_REG: 0X0213af40
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:                  FH_RSCSR_CHNL0_WPTR: 0X00000078
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:         FH_MEM_RCSR_CHNL0_CONFIG_REG: 0X80819104
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:          FH_MEM_RSSR_SHARED_CTRL_REG: 0X000000fc
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:            FH_MEM_RSSR_RX_STATUS_REG: 0X07030000
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:    FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:                FH_TSSR_TX_STATUS_REG: 0X07ff0001
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0:                 FH_TSSR_TX_ERROR_REG: 0X00000000
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: Start IWL Event Log Dump: display last 20 entries
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129462778:0x00000008:0220
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129462963:0x000000fa:0106
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129462964:0x00000000:0302
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463112:0x000000d4:0322
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463141:0x005a7a5f:0310
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463204:0x0a6e001c:0206
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463205:0x00000001:0204
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463209:0x00000001:0214
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463209:0x01001110:0205
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463233:0x00000020:0208
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463252:0x00000000:0302
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463286:0x00000001:0203
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463291:0x0a6e001c:0206
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463292:0x00000040:0204
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463295:0x01000110:0211
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463299:0x00000000:0212
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463344:0x00000000:0215
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463347:0x00000008:0220
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463387:0x091d004e:0401
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0129463397:0x00000000:0125
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: Hardware restart was requested
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 15: ff:ff:ff:ff:ff:ff
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 14: ff:ff:ff:ff:ff:ff
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: L1 Disabled; Enabling L0S
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: Radio type=0x1-0x2-0x0
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_send_rxon_timing beacon interval 200 beacon timer 204416 beacon tim 0
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:33 x220 last message repeated 2 times
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 0: 00:24:fe:41:8d:0e
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_set_ht_add_station spatial multiplexing power save mode: disabled
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:33 x220 last message repeated 2 times
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8015 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8015 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta 00:24:fe:41:8d:0e
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta 00:24:fe:41:8d:0e
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_send_rxon_timing beacon interval 100 beacon timer 102016 beacon tim 0
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_send_remove_station REPLY_REMOVE_STA PASSED
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: Stopping AGG while state not ON or starting
> Nov 21 22:16:33 x220 kernel: iwlagn 0000:03:00.0: queue number out of range: 0, must be 10 to 19
> Nov 21 22:16:33 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:16:33 x220 last message repeated 4 times
> Nov 21 22:16:34 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:34 x220 last message repeated 2 times
> Nov 21 22:16:34 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:16:34 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:34 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:16:34 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:34 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:16:34 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:34 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:16:34 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:34 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:16:34 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:34 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:16:34 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:16:34 x220 last message repeated 2 times
> Nov 21 22:16:52 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:16:52 x220 kernel: iwlagn 0000:03:00.0: Tx aggregation enabled on ra = 00:24:fe:41:8d:0e tid = 0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 last message repeated 2 times
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 last message repeated 2 times
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: Microcode SW error detected.  Restarting 0x2000000.
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: Loaded firmware version: 17.168.5.3 build 42301
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: Start IWL Error Log Dump:
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: Status: 0x000412E4, count: 6
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x00002078 | ADVANCED_SYSASSERT          
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x00009514 | uPc
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x00009496 | branchlink1
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x00009496 | branchlink2
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x0000D1F2 | interruptlink1
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | interruptlink2
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x00008035 | data1
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x0000C90F | data2
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x000005A7 | line
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x3980974C | beacon time
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x908DA8B4 | tsf low
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | tsf hi
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | time gp1
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x07A97A19 | time gp2
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | time gp3
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x000111A8 | uCode version
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x000000B0 | hw version
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x00480303 | board version
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: 0x09DA004E | hcmd
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: CSR values:
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: (2nd byte of CSR_INT_COALESCING is CSR_INT_PERIODIC_REG)
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:        CSR_HW_IF_CONFIG_REG: 0X00480303
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:          CSR_INT_COALESCING: 0X0000ff40
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:                     CSR_INT: 0X00000000
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:                CSR_INT_MASK: 0X00000000
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:           CSR_FH_INT_STATUS: 0X00000000
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:                 CSR_GPIO_IN: 0X00000030
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:                   CSR_RESET: 0X00000000
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:                CSR_GP_CNTRL: 0X080403c5
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:                  CSR_HW_REV: 0X000000b0
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:              CSR_EEPROM_REG: 0X37d60ffd
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:               CSR_EEPROM_GP: 0X90000001
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:              CSR_OTP_GP_REG: 0X00030001
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:                 CSR_GIO_REG: 0X00080044
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:            CSR_GP_UCODE_REG: 0X0000760f
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:           CSR_GP_DRIVER_REG: 0X00000000
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:           CSR_UCODE_DRV_GP1: 0X00000000
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:           CSR_UCODE_DRV_GP2: 0X00000000
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:                 CSR_LED_REG: 0X00000078
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:        CSR_DRAM_INT_TBL_REG: 0X88211eee
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:        CSR_GIO_CHICKEN_BITS: 0X27800200
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:             CSR_ANA_PLL_CFG: 0X00000000
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:           CSR_HW_REV_WA_REG: 0X0001001a
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:        CSR_DBG_HPET_MEM_REG: 0Xffff0000
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: FH register values:
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:         FH_RSCSR_CHNL0_STTS_WPTR_REG: 0X212d1300
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:        FH_RSCSR_CHNL0_RBDCB_BASE_REG: 0X0213af40
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:                  FH_RSCSR_CHNL0_WPTR: 0X000000a8
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:         FH_MEM_RCSR_CHNL0_CONFIG_REG: 0X80819104
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:          FH_MEM_RSSR_SHARED_CTRL_REG: 0X000000fc
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:            FH_MEM_RSSR_RX_STATUS_REG: 0X07030000
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:    FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:                FH_TSSR_TX_STATUS_REG: 0X07ff0001
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0:                 FH_TSSR_TX_ERROR_REG: 0X00000000
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: Start IWL Event Log Dump: display last 20 entries
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546673:0x00000001:0203
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546678:0x0ad5001c:0206
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546678:0x00000040:0204
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546681:0x2a10fb5e:0222
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546682:0xc0100084:0223
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546685:0x00000040:0219
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546685:0x01000110:0211
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546689:0x00000000:0212
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546728:0x00000000:0215
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546731:0x00000008:0220
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546748:0x00000000:0302
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546779:0x000000d4:0303
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546783:0x00001dd6:0217
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546784:0x0ad5001c:0217
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546920:0x000000fa:0106
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128546922:0x00000000:0302
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128547069:0x000000d4:0322
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128547099:0x005a7a5f:0310
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128547345:0x09da004e:0401
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0128547355:0x00000000:0125
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: Hardware restart was requested
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 15: ff:ff:ff:ff:ff:ff
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 14: ff:ff:ff:ff:ff:ff
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: L1 Disabled; Enabling L0S
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: Radio type=0x1-0x2-0x0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_send_rxon_timing beacon interval 200 beacon timer 204416 beacon tim 0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 last message repeated 2 times
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 0: 00:24:fe:41:8d:0e
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_set_ht_add_station spatial multiplexing power save mode: disabled
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 last message repeated 2 times
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8015 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8015 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta 00:24:fe:41:8d:0e
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta 00:24:fe:41:8d:0e
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_send_rxon_timing beacon interval 100 beacon timer 102016 beacon tim 0
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_send_remove_station REPLY_REMOVE_STA PASSED
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: Stopping AGG while state not ON or starting
> Nov 21 22:18:41 x220 kernel: iwlagn 0000:03:00.0: queue number out of range: 0, must be 10 to 19
> Nov 21 22:18:41 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:18:41 x220 last message repeated 4 times
> Nov 21 22:18:43 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:43 x220 last message repeated 2 times
> Nov 21 22:18:43 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:18:43 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:43 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:43 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:43 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:18:43 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:43 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:18:43 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:43 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:18:43 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:43 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:18:43 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:56 x220 last message repeated 5 times
> Nov 21 22:18:56 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:56 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:56 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:18:56 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:56 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:56 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:56 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:56 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:56 x220 last message repeated 2 times
> Nov 21 22:18:56 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:56 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:56 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:56 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:57 x220 last message repeated 3 times
> Nov 21 22:18:57 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:18:57 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:57 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:18:57 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:57 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:18:57 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:57 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:18:57 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:57 x220 last message repeated 2 times
> Nov 21 22:18:57 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:18:57 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:57 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:18:57 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:18:58 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:18:58 x220 kernel: iwlagn 0000:03:00.0: Tx aggregation enabled on ra = 00:24:fe:41:8d:0e tid = 0
> Nov 21 22:19:11 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:11 x220 last message repeated 2 times
> Nov 21 22:19:11 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:19:11 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:11 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:19:11 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:11 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:19:11 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:11 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:19:11 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:11 x220 last message repeated 2 times
> Nov 21 22:19:11 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:19:11 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:11 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:19:11 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: Microcode SW error detected.  Restarting 0x2000000.
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: Loaded firmware version: 17.168.5.3 build 42301
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: Start IWL Error Log Dump:
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: Status: 0x000412E4, count: 6
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x00002078 | ADVANCED_SYSASSERT          
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x00009514 | uPc
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x00009496 | branchlink1
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x00009496 | branchlink2
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x0000D1F2 | interruptlink1
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | interruptlink2
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x00008035 | data1
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x0000C90E | data2
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x000005A7 | line
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x49811381 | beacon time
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x925BAC7F | tsf low
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | tsf hi
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | time gp1
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x01CDE1AE | time gp2
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x00000000 | time gp3
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x000111A8 | uCode version
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x000000B0 | hw version
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x00480303 | board version
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: 0x09D0004E | hcmd
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: CSR values:
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: (2nd byte of CSR_INT_COALESCING is CSR_INT_PERIODIC_REG)
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:        CSR_HW_IF_CONFIG_REG: 0X00480303
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:          CSR_INT_COALESCING: 0X0000ff40
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:                     CSR_INT: 0X00000000
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:                CSR_INT_MASK: 0X00000000
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:           CSR_FH_INT_STATUS: 0X00000000
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:                 CSR_GPIO_IN: 0X00000030
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:                   CSR_RESET: 0X00000000
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:                CSR_GP_CNTRL: 0X080403c5
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:                  CSR_HW_REV: 0X000000b0
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:              CSR_EEPROM_REG: 0X37d60ffd
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:               CSR_EEPROM_GP: 0X90000001
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:              CSR_OTP_GP_REG: 0X00030001
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:                 CSR_GIO_REG: 0X00080044
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:            CSR_GP_UCODE_REG: 0X00001e9f
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:           CSR_GP_DRIVER_REG: 0X00000000
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:           CSR_UCODE_DRV_GP1: 0X00000000
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:           CSR_UCODE_DRV_GP2: 0X00000000
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:                 CSR_LED_REG: 0X00000078
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:        CSR_DRAM_INT_TBL_REG: 0X88211eee
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:        CSR_GIO_CHICKEN_BITS: 0X27800200
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:             CSR_ANA_PLL_CFG: 0X00000000
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:           CSR_HW_REV_WA_REG: 0X0001001a
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:        CSR_DBG_HPET_MEM_REG: 0Xffff0000
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: FH register values:
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:         FH_RSCSR_CHNL0_STTS_WPTR_REG: 0X212d1300
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:        FH_RSCSR_CHNL0_RBDCB_BASE_REG: 0X0213af40
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:                  FH_RSCSR_CHNL0_WPTR: 0X000000f0
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:         FH_MEM_RCSR_CHNL0_CONFIG_REG: 0X80819104
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:          FH_MEM_RSSR_SHARED_CTRL_REG: 0X000000fc
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:            FH_MEM_RSSR_RX_STATUS_REG: 0X07030000
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:    FH_MEM_RSSR_RX_ENABLE_ERR_IRQ2DRV: 0X00000000
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:                FH_TSSR_TX_STATUS_REG: 0X07ff0001
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0:                 FH_TSSR_TX_ERROR_REG: 0X00000000
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: Start IWL Event Log Dump: display last 20 entries
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030267653:0x00000040:0204
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030267656:0x01000110:0211
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030267660:0x00000000:0212
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030267703:0x00000000:0215
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030267706:0x00000008:0220
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030267723:0x00000000:0302
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030267754:0x000000d4:0303
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030267758:0x00001c06:0217
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030267759:0x0a05001c:0217
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030268632:0x000000fa:0106
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030268633:0x00000000:0302
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030268664:0x000000b4:0303
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030268839:0x000000fa:0106
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030268840:0x00000000:0302
> Nov 21 22:19:11 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030268871:0x000000b4:0303
> Nov 21 22:19:12 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030269495:0x000000fa:0106
> Nov 21 22:19:12 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030269497:0x00000000:0302
> Nov 21 22:19:12 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030269528:0x000000b4:0303
> Nov 21 22:19:12 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030269862:0x09d0004e:0401
> Nov 21 22:19:12 x220 kernel: iwlagn 0000:03:00.0: EVT_LOGT:0030269872:0x00000000:0125
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: Hardware restart was requested
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 15: ff:ff:ff:ff:ff:ff
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 14: ff:ff:ff:ff:ff:ff
> Nov 21 22:19:12 x220 kernel: iwlagn 0000:03:00.0: L1 Disabled; Enabling L0S
> Nov 21 22:19:12 x220 kernel: iwlagn 0000:03:00.0: Radio type=0x1-0x2-0x0
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_send_rxon_timing beacon interval 200 beacon timer 204416 beacon tim 0
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 last message repeated 2 times
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_prep_station Add STA to driver ID 0: 00:24:fe:41:8d:0e
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_set_ht_add_station spatial multiplexing power save mode: disabled
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 last message repeated 2 times
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8015 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8015 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta 00:24:fe:41:8d:0e
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x8035 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring all known stations ... start.
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta 00:24:fe:41:8d:0e
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_restore_stations Restoring sta ff:ff:ff:ff:ff:ff
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 0 addr 00:24:fe:41:8d:0e to uCode
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate Added STA id 15 addr ff:ff:ff:ff:ff:ff to uCode
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_send_rxon_timing beacon interval 100 beacon timer 102016 beacon tim 0
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_send_remove_station REPLY_REMOVE_STA PASSED
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:19:12 x220 kernel: iwlagn 0000:03:00.0: Stopping AGG while state not ON or starting
> Nov 21 22:19:12 x220 kernel: iwlagn 0000:03:00.0: queue number out of range: 0, must be 10 to 19
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:19:12 x220 last message repeated 3 times
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 last message repeated 2 times
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x5 operation mode :0x0 extension channel offset 0x0
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4008035 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U _iwl_set_rxon_ht rxon flags 0x4000005 operation mode :0x0 extension channel offset 0x1
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2
> Nov 21 22:19:12 x220 kernel: ieee80211 phy1: U iwl_sta_ucode_activate STA id 0 addr 00:24:fe:41:8d:0e already present in uCode (according to driver)
> Nov 21 22:19:13 x220 kernel: ieee80211 phy1: U iwlagn_set_rxon_chain rx_chain=0x2806 active=2 idle=2


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
