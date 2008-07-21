From: Alexander Beregalov <a.beregalov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: 2.6.26 Oops at tcp_data_queue
Date: Tue, 22 Jul 2008 00:12:26 +0400
Message-ID: <20080721201226.GD18891@orion>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="2B/JsCI69OhZNC5r"
To: kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--2B/JsCI69OhZNC5r
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi

It is clean 2.6.26, eth drivers are e1000 and forcedeth.


00:00.0 Host bridge [0600]: nVidia Corporation nForce2 AGP (different version?) [10de:01e0] (rev c1)
00:00.1 RAM memory [0500]: nVidia Corporation nForce2 Memory Controller 1 [10de:01eb] (rev c1)
00:00.2 RAM memory [0500]: nVidia Corporation nForce2 Memory Controller 4 [10de:01ee] (rev c1)
00:00.3 RAM memory [0500]: nVidia Corporation nForce2 Memory Controller 3 [10de:01ed] (rev c1)
00:00.4 RAM memory [0500]: nVidia Corporation nForce2 Memory Controller 2 [10de:01ec] (rev c1)
00:00.5 RAM memory [0500]: nVidia Corporation nForce2 Memory Controller 5 [10de:01ef] (rev c1)
00:01.0 ISA bridge [0601]: nVidia Corporation nForce2 ISA Bridge [10de:0060] (rev a4)
00:01.1 SMBus [0c05]: nVidia Corporation nForce2 SMBus (MCP) [10de:0064] (rev a2)
00:02.0 USB Controller [0c03]: nVidia Corporation nForce2 USB Controller [10de:0067] (rev a4)
00:02.1 USB Controller [0c03]: nVidia Corporation nForce2 USB Controller [10de:0067] (rev a4)
00:02.2 USB Controller [0c03]: nVidia Corporation nForce2 USB Controller [10de:0068] (rev a4)
00:04.0 Ethernet controller [0200]: nVidia Corporation nForce2 Ethernet Controller [10de:0066] (rev a1)
00:08.0 PCI bridge [0604]: nVidia Corporation nForce2 External PCI Bridge [10de:006c] (rev a3)
00:09.0 IDE interface [0101]: nVidia Corporation nForce2 IDE [10de:0065] (rev a2)
00:1e.0 PCI bridge [0604]: nVidia Corporation nForce2 AGP [10de:01e8] (rev c1)
01:06.0 Ethernet controller [0200]: Intel Corporation 82540EM Gigabit Ethernet Controller [8086:100e] (rev 02)
01:0a.0 RAID bus controller [0104]: Promise Technology, Inc. PDC20270 (FastTrak100 LP/TX2/TX4) [105a:6268] (rev 02)
02:00.0 VGA compatible controller [0300]: ATI Technologies Inc Radeon RV250 If [Radeon 9000] [1002:4966] (rev 01)
02:00.1 Display controller [0380]: ATI Technologies Inc Radeon RV250 [Radeon 9000] (Secondary) [1002:496e] (rev 01)


[ 7788.611448] Oops: 0002 [#1] PREEMPT DEBUG_PAGEALLOC
[ 7788.612565] Modules linked in: i2c_nforce2
[ 7788.612565] 
[ 7788.612565] Pid: 0, comm: swapper Not tainted (2.6.26 #12)
[ 7788.612565] EIP: 0060:[<c0342731>] EFLAGS: 00010246 CPU: 0
[ 7788.612565] EIP is at tcp_data_queue+0x35c/0xc96
[ 7788.612565] EAX: 5a5a5a5a EBX: f4c43e20 ECX: 6b7cb7ee EDX: 5a5a5a5a
[ 7788.612565] ESI: f293c600 EDI: f4c43e00 EBP: c04e2e90 ESP: c04e2e4c
[ 7788.612565]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[ 7788.612565] Process swapper (pid: 0, ti=c04e2000 task=c04833a8 task.ti=c04b4000)
[ 7788.612565] Stack: f4e80ee0 ffffffff 00000000 00000000 d7956272 00000002 00000000 f4e80ee0 
[ 7788.612565]        f293cac4 f293c6cc 5a5a5a5a f4c43e20 f4e80ee0 d7956272 00224726 f293c600 
[ 7788.612565]        f4e80ee0 c04e2ecc c0344677 00000246 00000000 d7956272 f4e80f00 c0133c22 
[ 7788.612565] Call Trace:
[ 7788.612565]  [<c0344677>] ? tcp_rcv_established+0x771/0x96a
[ 7788.612565]  [<c0133c22>] ? put_lock_stats+0xd/0x21
[ 7788.612565]  [<c03497f9>] ? tcp_v4_do_rcv+0x25/0x14e
[ 7788.612565]  [<c0384141>] ? _spin_lock_nested+0x4f/0x57
[ 7788.612565]  [<c0349c1c>] ? tcp_v4_rcv+0x2fa/0x492
[ 7788.612565]  [<c0333b0a>] ? ip_local_deliver+0x7d/0xcd
[ 7788.612565]  [<c0333a66>] ? ip_rcv+0x352/0x379
[ 7788.612565]  [<c012ccab>] ? ktime_get_real+0x13/0x30
[ 7788.612565]  [<c031fe39>] ? netif_receive_skb+0x1ec/0x21a
[ 7788.612565]  [<c032b998>] ? eth_type_trans+0x28/0xcc
[ 7788.612565]  [<c02e4af0>] ? nv_napi_poll+0x1fa/0x61a
[ 7788.612565]  [<c0134c70>] ? mark_held_locks+0x4e/0x66
[ 7788.612565]  [<c0134de4>] ? trace_hardirqs_on+0xd0/0x10d
[ 7788.612565]  [<c031ef4c>] ? net_rx_action+0x8b/0x14e
[ 7788.612565]  [<c011eb9f>] ? __do_softirq+0x54/0xa1
[ 7788.612565]  [<c0141293>] ? handle_fasteoi_irq+0x0/0xab
[ 7788.612565]  [<c010494f>] ? do_softirq+0x57/0xa6
[ 7788.612565]  [<c011e795>] ? irq_exit+0x3b/0x7c
[ 7788.612565]  [<c0104b18>] ? do_IRQ+0xca/0xe2
[ 7788.612565]  [<c0101d2a>] ? default_idle+0x0/0x4e
[ 7788.612565]  [<c0101d2a>] ? default_idle+0x0/0x4e
[ 7788.612565]  [<c0103712>] ? common_interrupt+0x2e/0x34
[ 7788.612565]  [<c0101d2a>] ? default_idle+0x0/0x4e
[ 7788.612565]  [<c0101d2a>] ? default_idle+0x0/0x4e
[ 7788.612565]  [<c0101d57>] ? default_idle+0x2d/0x4e
[ 7788.612565]  [<c0101cfd>] ? cpu_idle+0x62/0x8f
[ 7788.612565]  [<c0376bf9>] ? rest_init+0x61/0x63
[ 7788.612565]  =======================
[ 7788.612565] Code: d1 78 36 f6 c4 04 74 0b 68 2e 6d 46 c0 e8 9e 59 04 00 58 ff 8e cc 04 00 00 8b 47 04 8b 17 c7 47 04 00 00 00 00 c7 07 00 00 00 00 <89> 42 04 89 10 89 f8 e8 d2 91 fd ff eb 65 f6 c4 04 74 15 8b 45 
[ 7788.612565] EIP: [<c0342731>] tcp_data_queue+0x35c/0xc96 SS:ESP 0068:c04e2e4c
[ 7791.577851] Kernel panic - not syncing: Fatal exception in interrupt

--2B/JsCI69OhZNC5r
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="config.gz"
Content-Transfer-Encoding: base64

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

--2B/JsCI69OhZNC5r--
