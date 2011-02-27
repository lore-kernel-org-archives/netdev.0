From: Stephen Hemminger <shemminger@vyatta.com>
Subject: net-next: warnings from sysctl_net_exit
Date: Sat, 26 Feb 2011 16:56:01 -0800
Message-ID: <20110226165601.48858003@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33325 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750915Ab1B0A4E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Feb 2011 19:56:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seeing lots of these messages in dmesg. Something is broken
recently in net-next.


[26207.669668] ------------[ cut here ]------------
[26207.669673] WARNING: at net/sysctl_net.c:84 sysctl_net_exit+0x2a/0x2c()
[26207.669675] Hardware name: System Product Name
[26207.669676] Modules linked in: ip6table_filter ip6_tables nfs lockd fscache nfs_acl auth_rpcgss sunrpc binfmt_misc ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc kvm_intel kvm snd_hda_codec_analog lm63 snd_hda_intel snd_hda_codec snd_hwdep radeon pl2303 snd_pcm snd_seq_midi snd_rawmidi snd_seq_midi_event ttm drm_kms_helper snd_seq drm usbserial i7core_edac snd_timer snd_seq_device snd sky2 e1000e edac_core psmouse igb serio_raw soundcore snd_page_alloc i2c_algo_bit asus_atk0110 hid_belkin usbhid hid pata_marvell ahci libahci dca floppy btrfs lzo_compress zlib_deflate crc32c libcrc32c
[26207.669725] Pid: 67, comm: kworker/u:5 Tainted: G        W   2.6.38-rc5-net-next+ #38
[26207.669726] Call Trace:
[26207.669731]  [<ffffffff81040dd2>] ? warn_slowpath_common+0x85/0x9d
[26207.669735]  [<ffffffff813617f6>] ? cleanup_net+0x0/0x19a
[26207.669738]  [<ffffffff81040e04>] ? warn_slowpath_null+0x1a/0x1c
[26207.669740]  [<ffffffff814154ad>] ? sysctl_net_exit+0x2a/0x2c
[26207.669742]  [<ffffffff8136144e>] ? ops_exit_list+0x2a/0x5b
[26207.669745]  [<ffffffff813618f0>] ? cleanup_net+0xfa/0x19a
[26207.669749]  [<ffffffff810575c1>] ? process_one_work+0x233/0x3aa
[26207.669752]  [<ffffffff81057528>] ? process_one_work+0x19a/0x3aa
[26207.669755]  [<ffffffff810599c2>] ? worker_thread+0x13b/0x25a
[26207.669757]  [<ffffffff81059887>] ? worker_thread+0x0/0x25a
[26207.669760]  [<ffffffff8105d0f5>] ? kthread+0x9d/0xa5
[26207.669763]  [<ffffffff8106d618>] ? trace_hardirqs_on_caller+0x10c/0x130
[26207.669766]  [<ffffffff810030d4>] ? kernel_thread_helper+0x4/0x10
[26207.669770]  [<ffffffff8142f300>] ? restore_args+0x0/0x30
[26207.669772]  [<ffffffff8105d058>] ? kthread+0x0/0xa5
[26207.669774]  [<ffffffff810030d0>] ? kernel_thread_helper+0x0/0x10
[26207.669776] ---[ end trace 0cd6e119ada0eab1 ]---
