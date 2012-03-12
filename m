From: Dave Jones <davej@redhat.com>
Subject: WARNING: at net/ipv4/tcp_input.c:1951
 tcp_sacktag_write_queue+0xbe4/0xbf0()
Date: Mon, 12 Mar 2012 14:50:00 -0400
Message-ID: <20120312185000.GC1946@redhat.com>
References: <20120312184733.GB1946@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fedora Kernel Team <kernel-team@fedoraproject.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4075 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754105Ab2CLSuC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 14:50:02 -0400
Content-Disposition: inline
In-Reply-To: <20120312184733.GB1946@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A related problem ? (same WARN condition, different location)

	Dave

 > :WARNING: at net/ipv4/tcp_input.c:1951 tcp_sacktag_write_queue+0xbe4/0xbf0()
 > :Hardware name: System Product Name
 > :Modules linked in: tcp_lp fuse lockd ip6t_REJECT nf_conntrack_ipv6
 > nf_defrag_ipv6 ip6table_filter ip6_tables xt_physdev xt_state ipt_MASQUERADE
 > iptable_nat nf_nat nf_conntrack_ipv4 nf_conntrack nf_defrag_ipv4
 > snd_hda_codec_hdmi snd_hda_codec_realtek snd_hda_intel snd_hda_codec
 > hid_logitech_dj arc4 joydev snd_hwdep snd_seq snd_seq_device snd_pcm snd_timer
 > rt2800pci rt2800lib crc_ccitt rt2x00pci rt2x00lib ath5k sp5100_tco ath snd
 > edac_core edac_mce_amd serio_raw sky2 mac80211 i2c_piix4 cfg80211 k10temp
 > asus_atk0110 uinput soundcore eeprom_93cx6 rfkill microcode snd_page_alloc
 > binfmt_misc sunrpc btrfs zlib_deflate libcrc32c firewire_ohci firewire_core
 > pata_acpi ata_generic crc_itu_t pata_atiixp wmi radeon ttm drm_kms_helper drm
 > i2c_algo_bit i2c_core [last unloaded: scsi_wait_scan]
 > :Pid: 9871, comm: vlc Tainted: G        W    3.2.9-1.fc16.x86_64 #1
 > :Call Trace:
 > : <IRQ>  [<ffffffff8106e53f>] warn_slowpath_common+0x7f/0xc0
 > : [<ffffffff8106e59a>] warn_slowpath_null+0x1a/0x20
 > : [<ffffffff8151d824>] tcp_sacktag_write_queue+0xbe4/0xbf0
 > : [<ffffffff815e2b05>] ? _raw_spin_unlock_bh+0x15/0x20
 > : [<ffffffffa0466487>] ? tcp_packet+0x4a7/0x14e0 [nf_conntrack]
 > : [<ffffffff8152113e>] tcp_ack+0xc8e/0x2260
 > : [<ffffffff8155444a>] ? ipt_do_table+0x21a/0x680
 > : [<ffffffff8151e2b0>] ? tcp_validate_incoming+0x110/0x370
 > : [<ffffffff815234ea>] tcp_rcv_established+0x1ca/0x8b0
 > : [<ffffffff8152b6bf>] tcp_v4_do_rcv+0x27f/0x430
 > : [<ffffffff8152d490>] tcp_v4_rcv+0x610/0x8e0
 > : [<ffffffff81509310>] ? ip_rcv_finish+0x380/0x380
 > : [<ffffffff81509310>] ? ip_rcv_finish+0x380/0x380
 > : [<ffffffff815093ed>] ip_local_deliver_finish+0xdd/0x280
 > : [<ffffffff81509758>] ip_local_deliver+0x88/0x90
 > : [<ffffffff815090c1>] ip_rcv_finish+0x131/0x380
 > : [<ffffffff81509995>] ip_rcv+0x235/0x300
 > : [<ffffffff814d3463>] __netif_receive_skb+0x523/0x5c0
 > : [<ffffffff814d4060>] netif_receive_skb+0x80/0x90
 > : [<ffffffff814d4429>] ? dev_gro_receive+0x1b9/0x2c0
 > : [<ffffffff814d4170>] napi_skb_finish+0x50/0x70
 > : [<ffffffff814d4775>] napi_gro_receive+0xf5/0x140
 > : [<ffffffffa02e1833>] sky2_poll+0x6a3/0xd20 [sky2]
 > : [<ffffffff81065c35>] ? wake_up_process+0x15/0x20
 > : [<ffffffff814d49bb>] net_rx_action+0x12b/0x270
 > : [<ffffffff81096cc8>] ? sched_clock_cpu+0xa8/0x110
 > : [<ffffffff81075b68>] __do_softirq+0xb8/0x230
 > : [<ffffffff8101b953>] ? native_sched_clock+0x13/0x80
 > : [<ffffffff8101b9c9>] ? sched_clock+0x9/0x10
 > : [<ffffffff81096b35>] ? sched_clock_local+0x25/0x90
 > : [<ffffffff815ecd2c>] call_softirq+0x1c/0x30
 > : [<ffffffff810162f5>] do_softirq+0x65/0xa0
 > : [<ffffffff81075f7e>] irq_exit+0x9e/0xc0
 > : [<ffffffff815ed5e3>] do_IRQ+0x63/0xe0
 > : [<ffffffff815e2f2e>] common_interrupt+0x6e/0x6e
 > : <EOI>
