From: Dave Jones <davej@redhat.com>
Subject: Re: iwlwifi worse than ever in current git.
Date: Wed, 11 Jan 2012 14:50:55 -0500
Message-ID: <20120111195055.GA5140@redhat.com>
References: <20120110184917.GA26973@redhat.com>
 <1326221614.5067.6.camel@dcbw.foobar.com>
 <0BA3FCBA62E2DC44AF3030971E174FB3063085@HASMSX103.ger.corp.intel.com>
 <20120111014243.GA22066@redhat.com>
 <0BA3FCBA62E2DC44AF3030971E174FB306429E@HASMSX103.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Guy, Wey-Yi W" <wey-yi.w.guy@intel.com>,
	Linux Wireless <linux-wireless@vger.kernel.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:24696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757871Ab2AKTu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jan 2012 14:50:59 -0500
Content-Disposition: inline
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB306429E@HASMSX103.ger.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2012 at 12:38:43PM +0000, Grumbach, Emmanuel wrote:

 > I am missing logs here... You seem to reauthenticate but I can't see disconnection... weird

Ok, here's a fresh log.

wireless was working, (with 11n_disable=1)

unload, and reload without the 11n_disable=1 ..

[16421.730025] wlan0: deauthenticating from b8:c7:5d:0c:39:87 by local choice (reason=3)
[16421.735002] ieee80211 phy0: failed to remove key (1, ff:ff:ff:ff:ff:ff) from hardware (-16)
[16421.736095] ieee80211 phy0: failed to remove key (2, ff:ff:ff:ff:ff:ff) from hardware (-16)
[16421.737548] ieee80211 phy0: failed to remove key (0, b8:c7:5d:0c:39:87) from hardware (-16)
[16421.738400] wlan0: moving STA b8:c7:5d:0c:39:87 to state 2
[16421.738646] wlan0: moving STA b8:c7:5d:0c:39:87 to state 1
[16421.738878] wlan0: moving STA b8:c7:5d:0c:39:87 to state 0
[16421.741175] cfg80211: Calling CRDA to update world regulatory domain
[16421.777981] iwlwifi 0000:04:00.0: PCI INT A disabled
[16421.803665] cfg80211: World regulatory domain updated:
[16421.803924] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[16421.808846] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[16421.811357] cfg80211:   (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[16421.811739] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[16421.812193] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[16421.812566] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[16421.820504] cfg80211: Calling CRDA for country: US
[16421.918341] cfg80211: Calling CRDA to update world regulatory domain
[16421.949295] cfg80211: World regulatory domain updated:
[16421.949559] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[16421.949966] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[16421.950851] cfg80211:   (2457000 KHz - 2482000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[16421.951528] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz), (300 mBi, 2000 mBm)
[16421.951911] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[16421.952651] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[16422.035828] Intel(R) Wireless WiFi Link AGN driver for Linux, in-tree:d
[16422.036165] Copyright(c) 2003-2011 Intel Corporation
[16422.036582] iwlwifi 0000:04:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[16422.036957] iwlwifi 0000:04:00.0: setting latency timer to 64
[16422.037338] iwlwifi 0000:04:00.0: pci_resource_len = 0x00002000
[16422.037620] iwlwifi 0000:04:00.0: pci_resource_base = ffffc90011560000
[16422.037930] iwlwifi 0000:04:00.0: HW Revision ID = 0x0
[16422.038381] iwlwifi 0000:04:00.0: irq 46 for MSI/MSI-X
[16422.038915] iwlwifi 0000:04:00.0: CONFIG_IWLWIFI_DEBUG enabled
[16422.041287] iwlwifi 0000:04:00.0: CONFIG_IWLWIFI_DEBUGFS enabled
[16422.041569] iwlwifi 0000:04:00.0: CONFIG_IWLWIFI_DEVICE_TRACING enabled
[16422.041881] iwlwifi 0000:04:00.0: CONFIG_IWLWIFI_DEVICE_TESTMODE enabled
[16422.042213] iwlwifi 0000:04:00.0: CONFIG_IWLWIFI_P2P disabled
[16422.042517] iwlwifi 0000:04:00.0: Detected Intel(R) Ultimate N WiFi Link 5300 AGN, REV=0x24
[16422.043276] iwlwifi 0000:04:00.0: L1 Enabled; Disabling L0S
[16422.075500] iwlwifi 0000:04:00.0: device EEPROM VER=0x120, CALIB=0x4
[16422.075809] iwlwifi 0000:04:00.0: Device SKU: 0xF0
[16422.076390] iwlwifi 0000:04:00.0: Tunable channels: 13 802.11bg, 24 802.11a channels
[16422.121284] iwlwifi 0000:04:00.0: loaded firmware version 8.83.5.1 build 33692
[16422.122291] Registered led device: phy0-led
[16422.124681] ieee80211 phy0: Selected rate control algorithm 'iwl-agn-rs'
[16422.155786] iwlwifi 0000:04:00.0: L1 Enabled; Disabling L0S
[16422.159119] iwlwifi 0000:04:00.0: Radio type=0x0-0x2-0x0
[16422.201065] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 4  WrPtr: 0
[16422.201065] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 0 on FIFO 3
[16422.201065] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 1 on FIFO 2
[16422.201065] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 2 on FIFO 1
[16422.201065] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 3 on FIFO 0
[16422.201065] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 4 on FIFO 7
[16422.263369] cfg80211: Calling CRDA for country: US
[16422.287176] cfg80211: Regulatory domain changed to country: US
[16422.287457] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[16422.287849] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[16422.288337] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[16422.288703] cfg80211:   (5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[16422.289090] cfg80211:   (5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[16422.289455] cfg80211:   (5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[16422.289824] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[16422.318523] iwlwifi 0000:04:00.0: L1 Enabled; Disabling L0S
[16422.321880] iwlwifi 0000:04:00.0: Radio type=0x0-0x2-0x0
[16422.360115] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 4  WrPtr: 0
[16422.360115] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 0 on FIFO 3
[16422.360115] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 1 on FIFO 2
[16422.360115] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 2 on FIFO 1
[16422.360115] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 3 on FIFO 0
[16422.360115] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate AC/CMD Queue 4 on FIFO 7
[16422.376787] ADDRCONF(NETDEV_UP): wlan0: link is not ready
[16427.671916] wlan0: authenticate with b8:c7:5d:0c:39:87 (try 1)
[16427.674716] wlan0: authenticated
[16427.678205] wlan0: associate with b8:c7:5d:0c:39:87 (try 1)
[16427.681953] wlan0: RX AssocResp from b8:c7:5d:0c:39:87 (capab=0x431 status=0 aid=3)
[16427.682325] wlan0: associated
[16427.682473] wlan0: moving STA b8:c7:5d:0c:39:87 to state 1
[16427.682731] wlan0: moving STA b8:c7:5d:0c:39:87 to state 2
[16427.700757] ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
[16427.701667] cfg80211: Calling CRDA for country: US
[16427.721184] cfg80211: Regulatory domain changed to country: US
[16427.721455] cfg80211:   (start_freq - end_freq @ bandwidth), (max_antenna_gain, max_eirp)
[16427.721829] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz), (300 mBi, 2700 mBm)
[16427.722199] cfg80211:   (5170000 KHz - 5250000 KHz @ 40000 KHz), (300 mBi, 1700 mBm)
[16427.722566] cfg80211:   (5250000 KHz - 5330000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[16427.722924] cfg80211:   (5490000 KHz - 5600000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[16427.723289] cfg80211:   (5650000 KHz - 5710000 KHz @ 40000 KHz), (300 mBi, 2000 mBm)
[16427.723651] cfg80211:   (5735000 KHz - 5835000 KHz @ 40000 KHz), (300 mBi, 3000 mBm)
[16428.706438] wlan0: moving STA b8:c7:5d:0c:39:87 to state 3
[16438.802048] wlan0: no IPv6 routers present

wifi is back up.

Shortly afterwards ..


[16520.224964] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_start Can proceed: ssn = next_recl = 124
[16520.228038] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11  WrPtr: 124
[16520.228358] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate BA Queue 11 on FIFO 1
[16520.229059] iwlwifi 0000:04:00.0: Tx aggregation enabled on ra = b8:c7:5d:0c:39:87 tid = 0
[16531.888296] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_stop Can proceed: ssn = next_recl = 631
[16531.888793] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11  WrPtr: 0
[16531.889247] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Deactivate AC/CMD Queue 11 on FIFO 0
[16552.504609] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_start Can proceed: ssn = next_recl = 697
[16552.508182] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11  WrPtr: 185
[16552.508609] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate BA Queue 11 on FIFO 1
[16552.509077] iwlwifi 0000:04:00.0: Tx aggregation enabled on ra = b8:c7:5d:0c:39:87 tid = 0
[16564.084058] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_stop Can proceed: ssn = next_recl = 1241
[16564.084506] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11  WrPtr: 0
[16564.084903] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Deactivate AC/CMD Queue 11 on FIFO 0
[16568.975872] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_start Can proceed: ssn = next_recl = 1298
[16568.978796] iwlwifi 0000:04:00.0: U iwl_trans_set_wr_ptrs Q 11  WrPtr: 18
[16568.979007] iwlwifi 0000:04:00.0: U iwl_trans_tx_queue_set_status Activate BA Queue 11 on FIFO 1
[16568.979734] iwlwifi 0000:04:00.0: Tx aggregation enabled on ra = b8:c7:5d:0c:39:87 tid = 0
[16580.004052] iwlwifi 0000:04:00.0: U iwlagn_tx_agg_stop Can't proceed: ssn 1491, next_recl = 150


A possibly interesting datapoint, is that it seems I can make this happen faster
if there's disk IO going on (I ran a make clean on a kernel tree in this case).
Might be entirely coincidental, but thought I'd mention it..

	Dave
