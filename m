From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 91491] New: trie_leaf_remove
Date: Mon, 26 Jan 2015 13:32:55 +0000
Message-ID: <20150126133255.7b2de6c5@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:37908 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbbAZNdH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 08:33:07 -0500
Received: by mail-pa0-f44.google.com with SMTP id rd3so11754940pab.3
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 05:33:06 -0800 (PST)
Received: from uryu.home.lan ([144.49.132.22])
        by mx.google.com with ESMTPSA id ni10sm9776298pbc.51.2015.01.26.05.33.05
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 05:33:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sat, 17 Jan 2015 13:30:29 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 91491] New: trie_leaf_remove


https://bugzilla.kernel.org/show_bug.cgi?id=91491

            Bug ID: 91491
           Summary: trie_leaf_remove
           Product: Networking
           Version: 2.5
    Kernel Version: 3.14-2-amd64 #1 Debian 3.14.15-2.1khz
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: blocking
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: komur@bilkent.edu.tr
        Regression: No

[690122.777855] BUG: unable to handle kernel paging request at ffff88b40504020c
[690122.777870] IP: [<ffffffff81454e7f>] trie_leaf_remove+0x1f/0xa0
[690122.777881] PGD 0 
[690122.777886] Oops: 0000 [#1] SMP 
[690122.777893] Modules linked in: bonding loop xt_CLASSIFY xt_TCPMSS
iptable_mangle xt_u32 ipt_REJECT xt_tcpudp xt_recent iptable_filter ip_tables
x_tables x86_pkg_temp_thermal intel_powerclamp intel_rapl coretemp kvm_intel
snd_hda_codec_hdmi kvm crc32_pclmul crc32c_intel snd_hda_intel snd_hda_codec
snd_hwdep ghash_clmulni_intel snd_pcm snd_timer aesni_intel snd aes_x86_64
soundcore lrw joydev gf128mul iTCO_wdt glue_helper iTCO_vendor_support
ablk_helper cryptd evdev mxm_wmi psmouse sb_edac pcspkr serio_raw edac_core
tpm_tis i2c_i801 tpm nuvoton_cir rc_core wmi button mei_me lpc_ich mei shpchp
mfd_core processor thermal_sys hid_generic usbhid hid ext4 crc16 mbcache jbd2
sg sd_mod crc_t10dif crct10dif_generic crct10dif_pclmul crct10dif_common ahci
libahci libata ehci_pci igb xhci_hcd scsi_mod i2c_algo_bit
[690122.778005]  ehci_hcd i2c_core dca usbcore ptp pps_core usb_common
[690122.778005] CPU: 6 PID: 1557 Comm: zebra Not tainted 3.14-2-amd64 #1 Debian
3.14.15-2.1khz
[690122.778005] Hardware name:                  /DX79SI, BIOS
SIX7910J.86A.0525.2012.0709.1221 07/09/2012
[690122.778005] task: ffff880224960390 ti: ffff880225464000 task.ti:
ffff880225464000
[690122.778005] RIP: 0010:[<ffffffff81454e7f>]  [<ffffffff81454e7f>]
trie_leaf_remove+0x1f/0xa0
[690122.778005] RSP: 0018:ffff880225465a58  EFLAGS: 00010286
[690122.778005] RAX: 0000000000000000 RBX: ffff88b405040200 RCX:
ffff8800baa153e8
[690122.778005] RDX: ffffffff818412c0 RSI: ffff8800baa153e8 RDI:
ffff88022505ab60
[690122.778005] RBP: ffff8800baa153e8 R08: 0000000000000000 R09:
0000000000000001
[690122.778005] R10: 0000000000000400 R11: ffff8800c9ebbc80 R12:
ffff88022505ab60
[690122.778005] R13: ffff88022505ab40 R14: ffff8800c9607998 R15:
ffff8800c2c39cd8
[690122.778005] FS:  00007fd6e82c8700(0000) GS:ffff88022fcc0000(0000)
knlGS:0000000000000000
[690122.778005] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[690122.778005] CR2: ffff88b40504020c CR3: 00000002228c1000 CR4:
00000000000407e0
[690122.778005] Stack:
[690122.778005]  ffff8800c9607980 ffff880225465ad8 0000000000000018
ffffffff81455a70
[690122.778005]  ffffffff00000000 ffff8800baa153e8 0000000000000000
ffff88022505ab60
[690122.778005]  ffff8800c9607980 ffffffff81889180 ffff8800ca0b5bc0
0000000000000009
[690122.778005] Call Trace:
[690122.778005]  [<ffffffff81455a70>] ? fib_table_delete+0x280/0x2d0
[690122.778005]  [<ffffffff8144f75e>] ? inet_rtm_delroute+0x3e/0x50
[690122.778005]  [<ffffffff813ed7ba>] ? rtnetlink_rcv_msg+0x8a/0x250
[690122.778005]  [<ffffffff813d01e3>] ? __alloc_skb+0x43/0x2a0
[690122.778005]  [<ffffffff813ed730>] ? rtnetlink_rcv+0x30/0x30
[690122.778005]  [<ffffffff8140b5c9>] ? netlink_rcv_skb+0xa9/0xc0
[690122.778005]  [<ffffffff813ed71f>] ? rtnetlink_rcv+0x1f/0x30
[690122.778005]  [<ffffffff8140abc8>] ? netlink_unicast+0xe8/0x1f0
[690122.778005]  [<ffffffff8140afec>] ? netlink_sendmsg+0x31c/0x740
[690122.778005]  [<ffffffff813c7c96>] ? sock_sendmsg+0x86/0xc0
[690122.778005]  [<ffffffff8119ab20>] ? poll_select_copy_remaining+0x130/0x130
[690122.778005]  [<ffffffff813c7a24>] ? move_addr_to_kernel.part.18+0x14/0x60
[690122.778005]  [<ffffffff813c83e3>] ? ___sys_sendmsg+0x373/0x380
[690122.778005]  [<ffffffff8108871f>] ? update_rq_clock.part.85+0xf/0x30
[690122.778005]  [<ffffffff8108e294>] ? task_sched_runtime+0x54/0xa0
[690122.778005]  [<ffffffff8109273d>] ? cputime_adjust+0x1d/0x120
[690122.778005]  [<ffffffff81092da5>] ? thread_group_cputime_adjusted+0x35/0x40
[690122.778005]  [<ffffffff8105d329>] ? mmput+0x9/0x120
[690122.778005]  [<ffffffff813c8a59>] ? __sys_sendmsg+0x39/0x70
[690122.778005]  [<ffffffff814d30bd>] ? system_call_fast_compare_end+0x10/0x15
[690122.778005] Code: 00 45 31 ff eb c2 0f 0b 0f 1f 40 00 41 54 49 89 fc 55 48
89 f5 53 48 8b 1e 48 83 e3 fe f6 05 02 93 45 00 04 75 60 48 85 db 74 51 <0f> b6
4b 0c 31 f6 0f b6 43 0d 8b 55 08 80 f9 1f 77 0d d3 e2 b9 
[690122.778005] RIP  [<ffffffff81454e7f>] trie_leaf_remove+0x1f/0xa0
[690122.778005]  RSP <ffff880225465a58>
[690122.778005] CR2: ffff88b40504020c
[690122.778005] ---[ end trace 5b32f2333bf1a5eb ]---

-- 
You are receiving this mail because:
You are the assignee for the bug.
