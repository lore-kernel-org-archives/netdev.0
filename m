From: Bart Van Assche <bvanassche@acm.org>
Subject: iwlwifi 4.0.0-rc3 kernel warning
Date: Sun, 15 Mar 2015 16:47:34 -0700
Message-ID: <55061A16.2080408@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.bxl.stone.is ([87.238.167.36]:50946 "EHLO sf1.bxl.stone.is"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751793AbbCPCIB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Mar 2015 22:08:01 -0400
Received: from smtprelay.1eurohost.com ([87.238.167.34])
	by sf1.bxl.stone.is with esmtp (Exim 4.85)
	(envelope-from <bvanassche@acm.org>)
	id 1YXIFt-0005Gt-UA
	for netdev@vger.kernel.org; Mon, 16 Mar 2015 00:47:40 +0100
Received: from vz19.stone-is.net (vz19.stone-is.net [87.238.162.57])
	by smtprelay.1eurohost.com (Postfix) with ESMTP id 853CD220A3C
	for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 00:47:37 +0100 (CET)
Received: from exp-402881.sandisk.com (unknown [12.236.17.3])
	by vz19.stone-is.net (Postfix) with ESMTPSA id 6C83E88A6E
	for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 00:47:38 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Has anyone else already seen the kernel warning below ? That warning
was triggered while I was connected to a low-quality wifi network.

Thanks,

Bart.

------------[ cut here ]------------
WARNING: CPU: 0 PID: 72 at drivers/net/wireless/iwlwifi/pcie/tx.c:1259 iwl_trans_pcie_txq_disable+0x139/0x170 [iwlwifi]()
queue 16 not used
Modules linked in:
 fuse dm_crypt algif_skcipher af_alg loop xt_CHECKSUM iptable_mangle ipt_MASQUERADE nf_nat_masquerade_ipv4 iptable_nat nf_nat_ipv4 nf_nat bridge stp llc af_packet nf_log_ipv6 xt_pkttype nf_log_ipv4 nf_log_common xt_LOG xt_limit arc4 iwlmvm ip6t_REJECT nf_reject_ipv6 xt_tcpudp nf_conntrack_ipv6 uvcvideo nf_defrag_ipv6 videobuf2_vmalloc videobuf2_memops videobuf2_core ip6table_raw mac80211 ipt_REJECT nf_reject_ipv4 iptable_raw snd_hda_codec_hdmi xt_CT iptable_filter snd_hda_codec_realtek snd_hda_codec_generic ip6table_mangle nf_conntrack_netbios_ns nf_conntrack_broadcast nf_conntrack_ipv4 nf_defrag_ipv4 ip_tables xt_conntrack nf_conntrack ip6table_filter ip6_tables bnep x_tables iwlwifi x86_pkg_temp_thermal intel_powerclamp coretemp kvm_intel snd_hda_intel snd_hda_controller kvm snd_hda_code
 c
 snd_hwdep cfg80211 snd_pcm btusb e1000e crct10dif_pclmul bluetooth dell_wmi sparse_keymap crc32_pclmul crc32c_intel ghash_clmulni_intel snd_timer aesni_intel dell_laptop aes_x86_64 snd glue_helper dcdbas lrw gf128mul sdhci_pci xhci_pci ablk_helper joydev ptp cryptd xhci_hcd lpc_ich rfkill serio_raw pcspkr pps_core shpchp mfd_core i2c_i801 soundcore thermal wmi battery i2c_hid i2c_designware_platform dell_smo8800 8250_dw processor i2c_designware_core ac dm_mod i915 i2c_algo_bit drm_kms_helper drm video sdhci_acpi sdhci mmc_core button sg
CPU: 0 PID: 72 Comm: kworker/u8:3 Not tainted 4.0.0-rc3+ #1
Hardware name: Dell Inc. Latitude E7440/03HFCG, BIOS A10 06/26/2014
Workqueue: phy0 ieee80211_iface_work [mac80211]
 ffffffffa0580160 ffff8800daa67868 ffffffff8162990e 0000000000000000
 ffff8800daa678b8 ffff8800daa678a8 ffffffff81054bca ffff8800daa67888
 ffff8800d1f1c000 0000000000000010 0000000000000010 000000000080a980
Call Trace:
 [<ffffffff8162990e>] dump_stack+0x4c/0x6e
 [<ffffffff81054bca>] warn_slowpath_common+0x8a/0xc0
 [<ffffffff81054c46>] warn_slowpath_fmt+0x46/0x50
 [<ffffffffa0729cbd>] ? iwl_mvm_send_cmd_pdu_status+0x3d/0x50 [iwlmvm]
 [<ffffffffa0571679>] iwl_trans_pcie_txq_disable+0x139/0x170 [iwlwifi]
 [<ffffffffa072a5af>] iwl_mvm_disable_txq+0x7f/0xc0 [iwlmvm]
 [<ffffffffa072faab>] iwl_mvm_sta_tx_agg_flush+0xfb/0x140 [iwlmvm]
 [<ffffffff810add00>] ? rcu_barrier+0x20/0x20
 [<ffffffffa0723342>] iwl_mvm_mac_ampdu_action+0xd2/0x220 [iwlmvm]
 [<ffffffffa066133a>] ___ieee80211_stop_tx_ba_session+0x14a/0x520 [mac80211]
 [<ffffffffa0661d77>] __ieee80211_stop_tx_ba_session+0x37/0x50 [mac80211]
 [<ffffffffa065fff5>] ieee80211_sta_tear_down_BA_sessions+0x45/0x70 [mac80211]
 [<ffffffffa065696c>] __sta_info_destroy_part1+0x3c/0x3a0 [mac80211]
 [<ffffffff810add00>] ? rcu_barrier+0x20/0x20
 [<ffffffffa0659a90>] __sta_info_flush+0x140/0x1b0 [mac80211]
 [<ffffffffa069e036>] ieee80211_set_disassoc+0xb6/0x3a0 [mac80211]
 [<ffffffffa069e355>] ieee80211_sta_connection_lost.isra.29+0x35/0x70 [mac80211]
 [<ffffffffa06a0cd3>] ieee80211_sta_work+0x1d3/0x1120 [mac80211]
 [<ffffffff8108806a>] ? dequeue_entity+0x11a/0x550
 [<ffffffff810b617f>] ? mod_timer+0xef/0x1f0
 [<ffffffffa0668228>] ieee80211_iface_work+0x3b8/0x440 [mac80211]
 [<ffffffff8107712d>] ? finish_task_switch+0x5d/0x100
 [<ffffffff8106c535>] process_one_work+0x145/0x440
 [<ffffffff8106c951>] worker_thread+0x121/0x450
 [<ffffffff8106c830>] ? process_one_work+0x440/0x440
 [<ffffffff810719e9>] kthread+0xc9/0xe0
 [<ffffffff81071920>] ? kthread_create_on_node+0x180/0x180
 [<ffffffff81630108>] ret_from_fork+0x58/0x90
 [<ffffffff81071920>] ? kthread_create_on_node+0x180/0x180
---[ end trace 5bf7a4c8f7ead96b ]---
