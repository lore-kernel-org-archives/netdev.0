From: Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: iwlwifi worse than ever in current git.
Date: Tue, 10 Jan 2012 20:42:43 -0500
Message-ID: <20120111014243.GA22066@redhat.com>
References: <20120110184917.GA26973@redhat.com>
 <1326221614.5067.6.camel@dcbw.foobar.com>
 <0BA3FCBA62E2DC44AF3030971E174FB3063085@HASMSX103.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Guy, Wey-Yi W" <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Linux Wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB3063085-yLYCJVCiOGwLt2AQoY/u9bfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 10, 2012 at 08:40:32PM +0000, Grumbach, Emmanuel wrote:
 > Hi,
 > 
 > Is that series I added a debug flag that tells us what happens with the queues: please enable the 31st bit: 0x80000000
 > 
 > Just debug=0x80000000 as a module parameter.
 
>From boot to first hang..

[   24.874236] Intel(R) Wireless WiFi Link AGN driver for Linux, in-tree:d
[   24.875980] Copyright(c) 2003-2011 Intel Corporation
[   24.877877] iwlwifi 0000:04:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[   24.879733] iwlwifi 0000:04:00.0: setting latency timer to 64
[   24.879847] iwlwifi 0000:04:00.0: pci_resource_len = 0x00002000
[   24.881528] iwlwifi 0000:04:00.0: pci_resource_base = ffffc9001155c000
[   24.883276] iwlwifi 0000:04:00.0: HW Revision ID = 0x0
[   24.885297] iwlwifi 0000:04:00.0: irq 46 for MSI/MSI-X
[   24.885766] iwlwifi 0000:04:00.0: CONFIG_IWLWIFI_DEBUG enabled
[   24.887414] iwlwifi 0000:04:00.0: CONFIG_IWLWIFI_DEBUGFS enabled
[   24.889060] iwlwifi 0000:04:00.0: CONFIG_IWLWIFI_DEVICE_TRACING enabled
[   24.890740] iwlwifi 0000:04:00.0: CONFIG_IWLWIFI_DEVICE_TESTMODE enabled
[   24.892371] iwlwifi 0000:04:00.0: CONFIG_IWLWIFI_P2P disabled
[   24.893963] iwlwifi 0000:04:00.0: Detected Intel(R) Ultimate N WiFi Link 5300 AGN, REV=0x24
[   24.896234] iwlwifi 0000:04:00.0: L1 Enabled; Disabling L0S
[   24.919869] iwlwifi 0000:04:00.0: device EEPROM VER=0x120, CALIB=0x4
[   24.921403] iwlwifi 0000:04:00.0: Device SKU: 0xF0
[   24.922924] iwlwifi 0000:04:00.0: Tunable channels: 13 802.11bg, 24 802.11a channels
[   24.943679] iwlwifi 0000:04:00.0: loaded firmware version 8.83.5.1 build 33692
[   24.946313] Registered led device: phy0-led
[   24.978763] ieee80211 phy0: Selected rate control algorithm 'iwl-agn-rs'
[   25.032235] cfg80211: Calling CRDA for country: US
[   25.083063] cfg80211: Regulatory domain changed to country: US
[   25.084776] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[   25.086556] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[   25.088280] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[   25.089954] cfg80211:   (5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   25.091618] cfg80211:   (5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   25.093234] cfg80211:   (5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   25.095115] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)

[   36.649871] iwlwifi 0000:04:00.0: L1 Enabled; Disabling L0S
[   36.662470] iwlwifi 0000:04:00.0: Radio type=0x0-0x2-0x0
[   36.825012] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 4  WrPtr: 0
[   36.825012] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 0 on FIFO 3
[   36.830829] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 1 on FIFO 2
[   36.830829] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 2 on FIFO 1
[   36.830829] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 3 on FIFO 0
[   36.830829] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 4 on FIFO 7
[   37.023008] iwlwifi 0000:04:00.0: L1 Enabled; Disabling L0S
[   37.033727] iwlwifi 0000:04:00.0: Radio type=0x0-0x2-0x0
[   37.215009] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 4  WrPtr: 0
[   37.215009] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 0 on FIFO 3
[   37.215009] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 1 on FIFO 2
[   37.215009] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 2 on FIFO 1
[   37.222439] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 3 on FIFO 0
[   37.222439] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 4 on FIFO 7
[   37.321187] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[   44.614100] wlan0: authenticate with b8:c7:5d:0c:39:88 (try 1)
[   44.815110] wlan0: authenticate with b8:c7:5d:0c:39:88 (try 2)
[   44.817695] wlan0: authenticated
[   44.839289] wlan0: associate with b8:c7:5d:0c:39:88 (try 1)
[   44.842270] wlan0: RX AssocResp from b8:c7:5d:0c:39:88 (capab=0x511 status=0 aid=3)
[   44.842270] wlan0: associated
[   44.842270] wlan0: moving STA b8:c7:5d:0c:39:88 to state 1
[   44.842270] wlan0: moving STA b8:c7:5d:0c:39:88 to state 2
[   44.862870] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[   44.866222] cfg80211: Calling CRDA for country: US
[   44.869918] iwlwifi 0000:04:00.0: I iwl_stop_queue Stop hwq 0 ac 0 stop count 1. Tx on passive channel
[   44.904744] cfg80211: Regulatory domain changed to country: US
[   44.905049] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[   44.905435] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[   44.905788] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[   44.906167] cfg80211:   (5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   44.906524] cfg80211:   (5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   44.906879] cfg80211:   (5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[   44.907312] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[   44.937401] iwlwifi 0000:04:00.0: I iwl_trans_pcie_wake_any_queue Queue Status: Q[0] stopped
[   44.937789] iwlwifi 0000:04:00.0: I iwl_wake_queue Wake hwq 0 ac 0. channel got active
[   44.938089] iwlwifi 0000:04:00.0: I iwl_trans_pcie_wake_any_queue Queue Status: Q[1] awake
[   44.938089] iwlwifi 0000:04:00.0: I iwl_trans_pcie_wake_any_queue Queue Status: Q[2] awake
[   44.938089] iwlwifi 0000:04:00.0: I iwl_trans_pcie_wake_any_queue Queue Status: Q[3] awake
[   45.891438] wlan0: moving STA b8:c7:5d:0c:39:88 to state 3
[   56.018088] wlan0: no IPv6 routers present
[   97.157673] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_start Can proceed: ssn = next_recl = 137
[   97.159663] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11  WrPtr: 137
[   97.159932] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate BA Queue 11 on FIFO 1
[   97.160516] iwlwifi 0000:04:00.0: Tx aggregation enabled on ra = b8:c7:5d:0c:39:88 tid = 0
[  111.136741] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_stop Can proceed: ssn = next_recl = 194
[  111.137162] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11  WrPtr: 0
[  111.137531] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Deactivate AC/CMD Queue 11 on FIFO 0

[  147.455293] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_start Can proceed: ssn = next_recl = 264
[  147.456993] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11  WrPtr: 8
[  147.457027] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate BA Queue 11 on FIFO 1
[  147.457830] iwlwifi 0000:04:00.0: Tx aggregation enabled on ra = b8:c7:5d:0c:39:88 tid = 0
[  164.513842] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_stop Can proceed: ssn = next_recl = 816
[  164.514282] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11  WrPtr: 0
[  164.514664] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Deactivate AC/CMD Queue 11 on FIFO 0
[  173.145695] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_start Can proceed: ssn = next_recl = 869
[  173.147133] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11  WrPtr: 101
[  173.147545] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate BA Queue 11 on FIFO 1
[  173.148050] iwlwifi 0000:04:00.0: Tx aggregation enabled on ra = b8:c7:5d:0c:39:88 tid = 0
[  192.805102] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 1)
[  192.807392] wlan0: authenticated
[  192.814840] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_stop Can't proceed: ssn 1633, next_recl = 139
[  192.818669] wlan0: moving STA b8:c7:5d:0c:39:88 to state 2
[  192.818939] wlan0: moving STA b8:c7:5d:0c:39:88 to state 1
[  192.819206] wlan0: moving STA b8:c7:5d:0c:39:88 to state 0
[  192.824157] wlan0: associate with b8:c7:5d:0c:39:87 (try 1)
[  192.828014] wlan0: RX ReassocResp from b8:c7:5d:0c:39:87 (capab=0x431 status=0 aid=3)
[  192.828372] wlan0: associated
[  192.828515] wlan0: moving STA b8:c7:5d:0c:39:87 to state 1
[  192.828713] wlan0: moving STA b8:c7:5d:0c:39:87 to state 2
[  193.853664] wlan0: moving STA b8:c7:5d:0c:39:87 to state 3
[  278.421399] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_start Can proceed: ssn = next_recl = 165
[  278.423946] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 12  WrPtr: 165
[  278.424007] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate BA Queue 12 on FIFO 1
[  278.424835] iwlwifi 0000:04:00.0: Tx aggregation enabled on ra = b8:c7:5d:0c:39:87 tid = 0
[  285.176431] iwlwifi 0000:04:00.0: I iwl_stop_queue Stop hwq 12 ac 2 stop count 1. Queue is full
[  290.304163] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_stop Can't proceed: ssn 397, next_recl = 174


At this point I unloaded, and reloaded the module.
I had to do this several times until it finally came back up.

Shortly afterwards..

[  599.752969] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 1)
[  599.755359] wlan0: authenticated
[  599.762131] iwlwifi 0000:04:00.0: I iwl_stop_queue Stop hwq 0 ac 0 stop count 1. Tx on passive channel
[  599.774132] iwlwifi 0000:04:00.0: U iwl_trans_pcie_wake_any_queue Queue Status: Q[0] stopped
[  599.774551] iwlwifi 0000:04:00.0: U iwl_wake_queue Wake hwq 0 ac 0. Disassoc: flush queue
[  599.774921] iwlwifi 0000:04:00.0: U iwl_trans_pcie_wake_any_queue Queue Status: Q[1] awake
[  599.775779] iwlwifi 0000:04:00.0: U iwl_trans_pcie_wake_any_queue Queue Status: Q[2] awake
[  599.776515] iwlwifi 0000:04:00.0: U iwl_trans_pcie_wake_any_queue Queue Status: Q[3] awake
[  599.777198] iwlwifi 0000:04:00.0: I iwl_stop_queue Stop hwq 0 ac 0 stop count 1. Tx on passive channel
[  599.782692] wlan0: moving STA b8:c7:5d:0c:39:88 to state 2
[  599.782964] wlan0: moving STA b8:c7:5d:0c:39:88 to state 1
[  599.783538] wlan0: moving STA b8:c7:5d:0c:39:88 to state 0
[  599.790449] wlan0: associate with b8:c7:5d:0c:39:87 (try 1)
[  599.990029] wlan0: associate with b8:c7:5d:0c:39:87 (try 2)
[  600.190028] wlan0: associate with b8:c7:5d:0c:39:87 (try 3)
[  600.390029] wlan0: association with b8:c7:5d:0c:39:87 timed out
[  608.005916] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 1)
[  608.206036] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 2)
[  608.406036] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 3)
[  608.607032] wlan0: authentication with b8:c7:5d:0c:39:87 timed out
[  616.193769] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 1)
[  616.394070] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 2)
[  616.594039] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 3)
[  616.794053] wlan0: authentication with b8:c7:5d:0c:39:87 timed out
[  619.373114] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 1)
[  619.573124] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 2)
[  619.773146] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 3)
[  619.973146] wlan0: authentication with b8:c7:5d:0c:39:87 timed out
[  627.666387] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 1)
[  627.866077] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 2)
[  628.066146] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 3)
[  628.266121] wlan0: authentication with b8:c7:5d:0c:39:87 timed out
[  635.854105] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 1)
[  636.054043] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 2)
[  636.254134] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 3)
[  636.454125] wlan0: authentication with b8:c7:5d:0c:39:87 timed out

and dead again.

	Dave

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
