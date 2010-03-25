From: Valdis.Kletnieks@vt.edu
Subject: mmotm 2010-03-23 - IPv6 warnings...
Date: Wed, 24 Mar 2010 21:36:41 -0400
Message-ID: <12096.1269481001@localhost>
References: <201003232301.o2NN1bms031050@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1269481001_4394P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Tue, 23 Mar 2010 15:34:59 PDT."
             <201003232301.o2NN1bms031050@imap1.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1269481001_4394P
Content-Type: text/plain; charset=us-ascii

On Tue, 23 Mar 2010 15:34:59 PDT, akpm@linux-foundation.org said:
> The mm-of-the-moment snapshot 2010-03-23-15-34 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/

Seen in my dmesg.  It may be relevant that I'm at home, and my IPv6
prefix arrives via a PPP VPN connection. This happened about 20-25 seconds
after I launched pppd.

[  175.269411] ------------[ cut here ]------------
[  175.269433] WARNING: at net/ipv6/addrconf.c:544 inet6_ifa_finish_destroy+0x40/0xbb()
[  175.269441] Hardware name: Latitude E6500                  
[  175.269447] Modules linked in: ppp_async sunrpc usb_storage [last unloaded: scsi_wait_scan]
[  175.269473] Pid: 7, comm: ksoftirqd/1 Tainted: G        W   2.6.34-rc2-mmotm0323 #1
[  175.269480] Call Trace:
[  175.269488]  <IRQ>  [<ffffffff8103728a>] warn_slowpath_common+0x80/0x98
[  175.269517]  [<ffffffff810372b7>] warn_slowpath_null+0x15/0x17
[  175.269530]  [<ffffffff814f2093>] inet6_ifa_finish_destroy+0x40/0xbb
[  175.269542]  [<ffffffff814f2122>] in6_ifa_put+0x14/0x16
[  175.269555]  [<ffffffff814f4893>] addrconf_prefix_rcv+0x583/0x786
[  175.269568]  [<ffffffff814f70b3>] ? rt6_get_dflt_router+0xab/0xbb
[  175.269581]  [<ffffffff814fd98c>] ndisc_rcv+0x90f/0xdb4
[  175.269595]  [<ffffffff810852a7>] ? __rcu_read_unlock+0x30c/0x341
[  175.269609]  [<ffffffff81502f6d>] ? debug_lockdep_rcu_enabled+0x33/0x39
[  175.269622]  [<ffffffff815040ae>] icmpv6_rcv+0x59b/0x659
[  175.269634]  [<ffffffff81504c9e>] ? ipv6_chk_mcast_addr+0xaf/0x13d
[  175.269648]  [<ffffffff81063e21>] ? trace_hardirqs_on_caller+0x16/0x13c
[  175.269661]  [<ffffffff8103d5b3>] ? _local_bh_enable_ip+0x15c/0x16e
[  175.269674]  [<ffffffff8103d5ce>] ? local_bh_enable_ip+0x9/0xb
[  175.269689]  [<ffffffff81598c44>] ? _raw_read_unlock_bh+0x39/0x3e
[  175.269702]  [<ffffffff81504d13>] ? ipv6_chk_mcast_addr+0x124/0x13d
[  175.269714]  [<ffffffff814eee7d>] ? ip6_input_finish+0x0/0x343
[  175.269726]  [<ffffffff814ef066>] ip6_input_finish+0x1e9/0x343
[  175.269737]  [<ffffffff814eee7d>] ? ip6_input_finish+0x0/0x343
[  175.269748]  [<ffffffff814ef20c>] NF_HOOK.clone.1+0x4c/0x53
[  175.269759]  [<ffffffff814ef6d6>] ip6_input+0x1c/0x1e
[  175.269769]  [<ffffffff814ef7df>] ip6_mc_input+0x107/0x11c
[  175.269780]  [<ffffffff814eee17>] ? ip6_rcv_finish+0x0/0x26
[  175.269791]  [<ffffffff814eee39>] ip6_rcv_finish+0x22/0x26
[  175.269802]  [<ffffffff814ef20c>] NF_HOOK.clone.1+0x4c/0x53
[  175.269812]  [<ffffffff814ef666>] ipv6_rcv+0x453/0x4a7
[  175.269827]  [<ffffffff8146527e>] __netif_receive_skb+0x2da/0x307
[  175.269839]  [<ffffffff81465348>] process_backlog+0x9d/0xd6
[  175.269851]  [<ffffffff81465631>] net_rx_action+0xf2/0x356
[  175.269863]  [<ffffffff8103dc41>] __do_softirq+0x14a/0x282
[  175.269876]  [<ffffffff8100360c>] call_softirq+0x1c/0x34
[  175.269882]  <EOI>  [<ffffffff81004b58>] ? do_softirq+0x44/0xf0
[  175.269901]  [<ffffffff8103d7dd>] run_ksoftirqd+0xbc/0x1fb
[  175.269912]  [<ffffffff8103d721>] ? run_ksoftirqd+0x0/0x1fb
[  175.269925]  [<ffffffff81052c6b>] kthread+0x7a/0x82
[  175.269937]  [<ffffffff81003514>] kernel_thread_helper+0x4/0x10
[  175.269949]  [<ffffffff81599900>] ? restore_args+0x0/0x30
[  175.269961]  [<ffffffff81052bf1>] ? kthread+0x0/0x82
[  175.269971]  [<ffffffff81003510>] ? kernel_thread_helper+0x0/0x10
[  175.269979] ---[ end trace a7919e7f17c0a727 ]---
[  175.269986] Freeing alive inet6 address ffff880107e1a400
[  176.472172] ------------[ cut here ]------------
[  176.472192] WARNING: at net/ipv6/addrconf.c:544 inet6_ifa_finish_destroy+0x40/0xbb()
[  176.472200] Hardware name: Latitude E6500                  
[  176.472206] Modules linked in: ppp_async sunrpc usb_storage [last unloaded: scsi_wait_scan]
[  176.472232] Pid: 4008, comm: fetchmail Tainted: G        W   2.6.34-rc2-mmotm0323 #1
[  176.472239] Call Trace:
[  176.472256]  [<ffffffff8103728a>] warn_slowpath_common+0x80/0x98
[  176.472269]  [<ffffffff810372b7>] warn_slowpath_null+0x15/0x17
[  176.472280]  [<ffffffff814f2093>] inet6_ifa_finish_destroy+0x40/0xbb
[  176.472291]  [<ffffffff814f2122>] in6_ifa_put+0x14/0x16
[  176.472303]  [<ffffffff814f2a7b>] ipv6_dev_get_saddr+0x2b3/0x2c7
[  176.472316]  [<ffffffff814f8f32>] ? fib6_rule_lookup+0x18/0x1a
[  176.472328]  [<ffffffff814ebb04>] ip6_dst_lookup_tail+0x90/0xc5
[  176.472339]  [<ffffffff814ebc37>] ip6_dst_lookup+0x10/0x12
[  176.472352]  [<ffffffff8150f712>] ip6_datagram_connect+0x334/0x4f6
[  176.472365]  [<ffffffff8103d5b3>] ? _local_bh_enable_ip+0x15c/0x16e
[  176.472378]  [<ffffffff81457d82>] ? release_sock+0xff/0x108
[  176.472390]  [<ffffffff814c0042>] inet_dgram_connect+0x56/0x5d
[  176.472402]  [<ffffffff81455907>] sys_connect+0x75/0x98
[  176.472415]  [<ffffffff810e24b4>] ? path_put+0x1d/0x22
[  176.472429]  [<ffffffff81063e21>] ? trace_hardirqs_on_caller+0x16/0x13c
[  176.472442]  [<ffffffff8107d442>] ? audit_syscall_entry+0xcb/0x19c
[  176.472455]  [<ffffffff810026eb>] system_call_fastpath+0x16/0x1b
[  176.472464] ---[ end trace a7919e7f17c0a728 ]---
[  176.472472] Freeing alive inet6 address ffff880107e1a400


--==_Exmh_1269481001_4394P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLqr4pcC3lWbTT17ARAi/lAKC8PAVZmdn6z4gz9cN6e03pG50f5QCbBsxc
TdPqr5J9JRPBR2hhsT1kXqY=
=6InZ
-----END PGP SIGNATURE-----

--==_Exmh_1269481001_4394P--
