From: =?utf-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <ne-vlezay80@yandex.ru>
Subject: BUG: Bad page state in process Compositor pfn:c03e2
Date: Fri, 09 Jun 2017 23:31:18 +0300
Message-ID: <369961497040278@web18j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward6o.cmail.yandex.net ([37.9.109.52]:48502 "EHLO
        forward6o.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751536AbdFIUi1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 16:38:27 -0400
Received: from mxback8j.mail.yandex.net (mxback8j.mail.yandex.net [IPv6:2a02:6b8:0:1619::111])
        by forward6o.cmail.yandex.net (Yandex) with ESMTP id ACF1E23338
        for <netdev@vger.kernel.org>; Fri,  9 Jun 2017 23:31:18 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ 1621.875870] BUG: Bad page state in process Compositor pfn:c03e2
[ 1621.875876] page:ffffea000300f880 count:-1 mapcount:0 mapping: (null) index:0x0
[ 1621.875878] flags: 0x100000000000000()
[ 1621.875881] raw: 0100000000000000 0000000000000000 0000000000000000 ffffffffffffffff
[ 1621.875882] raw: 0000000000000000 dead000000000200 0000000000000000 0000000000000000
[ 1621.875883] page dumped because: nonzero _count
[ 1621.875884] Modules linked in: vhost_net vhost tap af_packet tun ebtable_filter ebtables x_tables dummy nbd bridge 8021q garp mrp stp llc ata_generic pata_acpi snd_hda_codec_realtek snd_hda_codec_generic snd_usb_audio snd_usbmidi_lib snd_rawmidi snd_seq_device uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 videobuf2_core videodev media snd_hda_intel snd_hda_codec snd_pcsp snd_hda_core snd_hwdep kvm_amd snd_pcm kvm snd_timer snd irqbypass e1000 soundcore pata_atiixp nouveau r8169 ttm tpm_infineon mii wmi acpi_cpufreq ohci_pci tpm_tis ohci_hcd tpm_tis_core tpm fuse ipv6 crc_ccitt unix
[ 1621.875907] CPU: 0 PID: 3674 Comm: Compositor Not tainted 4.11.3 #2
[ 1621.875907] Hardware name: MSI MS-7715/870-C45(FX) V2 (MS-7715) , BIOS V3.1 04/16/2012
[ 1621.875908] Call Trace:
[ 1621.875914] dump_stack+0x4d/0x65
[ 1621.875916] bad_page+0xc1/0x130
[ 1621.875917] check_new_page_bad+0x75/0x80
[ 1621.875918] get_page_from_freelist+0x6fd/0xab0
[ 1621.875920] ? enqueue_task_fair+0xfa5/0x1910
[ 1621.875921] ? select_task_rq_fair+0xaeb/0xed0
[ 1621.875923] __alloc_pages_nodemask+0xcb/0x200
[ 1621.875924] alloc_pages_current+0x8d/0x110
[ 1621.875926] alloc_skb_with_frags+0xcb/0x1c0
[ 1621.875928] sock_alloc_send_pskb+0x1e4/0x210
[ 1621.875931] unix_stream_sendmsg+0x26c/0x3b0 [unix]
[ 1621.875932] sock_sendmsg+0x33/0x40
[ 1621.875933] sock_write_iter+0x76/0xd0
[ 1621.875935] __do_readv_writev+0x29e/0x370
[ 1621.875936] do_readv_writev+0x78/0xa0
[ 1621.875937] vfs_writev+0x37/0x50
[ 1621.875939] ? __fdget_pos+0x12/0x50
[ 1621.875940] ? vfs_writev+0x37/0x50
[ 1621.875940] do_writev+0x4d/0xd0
[ 1621.875942] SyS_writev+0xb/0x10
[ 1621.875943] entry_SYSCALL_64_fastpath+0x13/0x94
[ 1621.875944] RIP: 0033:0x7f730f8dd2f0
[ 1621.875945] RSP: 002b:00007f72f15f55f0 EFLAGS: 00000293 ORIG_RAX: 0000000000000014
[ 1621.875946] RAX: ffffffffffffffda RBX: 00007f72cc39cf28 RCX: 00007f730f8dd2f0
[ 1621.875947] RDX: 0000000000000003 RSI: 00007f72f15f5790 RDI: 0000000000000004
[ 1621.875947] RBP: 00007f72c7ee1c00 R08: 0000000000000000 R09: 0000000000000000
[ 1621.875948] R10: 0000000000000020 R11: 0000000000000293 R12: 00007f72f15f6e01
[ 1621.875948] R13: 0000000000000000 R14: 0000000000000166 R15: 00007f72cc39d428
[ 1621.875949] Disabling lock debugging due to kernel taint
