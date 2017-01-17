From: Greg <gvrose8192@gmail.com>
Subject: Re: 52bd2d62ce6758d811edcbd2256eb9ea7f6a56cb fixing crashes? -> 4.4
 stable?
Date: Tue, 17 Jan 2017 15:09:57 -0800
Message-ID: <1484694597.29083.0.camel@gmail.com>
References: <20170117214832.GA17323@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, nik@linuxbox.cz
To: Nikola Ciprich <nikola.ciprich@linuxbox.cz>,
        Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35783 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750929AbdAQXSO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 18:18:14 -0500
Received: by mail-pg0-f66.google.com with SMTP id 204so9074010pge.2
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 15:18:13 -0800 (PST)
In-Reply-To: <20170117214832.GA17323@pcnci.linuxbox.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-01-17 at 22:48 +0100, Nikola Ciprich wrote:
> Dear netdev developers,
> 
> I'd like to ask for a consultation regarding 4.4 kernel crashes.
> we're using intel X540-AT2 10g controllers (onboard ones, on supermicro
> boards) and we've noticed, then when using openvswitch, system very quickly
> crashes on 4.4.x kernels we're usign. 4.5 is fine though.
> 
> here's backtrace gathered from system pstore:

Adding the openvswitch maintainer, Pravin. Hopefully you'll get a
quicker response.

- Greg

> 
> <1>[ 1084.114586] BUG: unable to handle kernel paging request at ffff8840c365b5c4
> <1>[ 1084.114918] IP: [<ffffffff81589802>] __netdev_pick_tx+0x92/0x140
> <4>[ 1084.115101] PGD 2018067 PUD 0
> <4>[ 1084.115270] Oops: 0000 [#1] SMP
> <4>[ 1084.115439] Modules linked in: bonding(E) openvswitch(E) nf_defrag_ipv6(E) nf_conntrack(E) crc32_pclmul(E) aesni_intel(E) lrw(E) gf128mul(E) glue_helper(E) ablk_helper(E) cryptd(E) kvm
> _intel(E) kvm(E) irqbypass(E) coretemp(E) crct10dif_pclmul(E) intel_powerclamp(E) x86_pkg_temp_thermal(E) ses(E) enclosure(E) iTCO_wdt(E) iTCO_vendor_support(E) mxm_wmi(E) i2c_i801(E) lpc_ic
> h(E) mei_me(E) mfd_core(E) i2c_core(E) sb_edac(E) sg(E) mei(E) pcspkr(E) edac_core(E) ipmi_devintf(E) ioatdma(E) shpchp(E) wmi(E) ipmi_si(E) ipmi_msghandler(E) 8250_fintek(E) acpi_power_mete
> r(E) acpi_pad(E) nfsd(E) auth_rpcgss(E) nfs_acl(E) lockd(E) grace(E) sunrpc(E) ip_tables(E) ext4(E) jbd2(E) mbcache(E) raid1(E) sd_mod(E) ahci(E) libahci(E) bnx2x(E) libcrc32c(E) ixgbe(E) cr
> c32c_intel(E) libata(E) mdio(E) ptp(E) dca(E) megaraid_sas(E) pps_core(E) dm_mirror(E) dm_region_hash(E) dm_log(E) dm_mod(E)
> <4>[ 1084.117683] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G            E   4.4.33lb7.01 #1
> <4>[ 1084.118012] Hardware name: Supermicro X10DRi/X10DRI-T, BIOS 2.1 09/13/2016
> <4>[ 1084.118181] task: ffffffff819f14c0 ti: ffffffff819e0000 task.ti: ffffffff819e0000
> <4>[ 1084.118501] RIP: 0010:[<ffffffff81589802>]  [<ffffffff81589802>] __netdev_pick_tx+0x92/0x140
> <4>[ 1084.118828] RSP: 0018:ffff883f7f003638  EFLAGS: 00010a02
> <4>[ 1084.118994] RAX: 00000000aef55a76 RBX: 0000000000000000 RCX: 000000009d6e7dcd
> <4>[ 1084.119164] RDX: 00000000ba9f4f5f RSI: ffff883f63f14d00 RDI: ffff883f7f0035ec
> <4>[ 1084.119333] RBP: ffff883f7f003668 R08: 0000000000000003 R09: 00000000c8cfdbe1
> <4>[ 1084.119506] R10: ffff883f61206042 R11: ffff883f7f0035c0 R12: 00000000ffffffff
> <4>[ 1084.119679] R13: ffff883f657b00c0 R14: ffff883f5d920000 R15: 00000000f0000012
> <4>[ 1084.119850] FS:  0000000000000000(0000) GS:ffff883f7f000000(0000) knlGS:0000000000000000
> <4>[ 1084.120171] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> <4>[ 1084.120338] CR2: ffff8840c365b5c4 CR3: 00000000019ea000 CR4: 00000000003406f0
> <4>[ 1084.120509] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> <4>[ 1084.120678] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> <4>[ 1084.120847] Stack:
> <4>[ 1084.121006]  ffff883f63f14d00 ffff883f63f14d00 000000000000000e 0000000000000000
> <4>[ 1084.121339]  ffff883f5d920000 ffff883f60a7f840 ffff883f7f0036a0 ffffffffa00fbed4
> <4>[ 1084.121672]  ffff883f603612ac ffff883f5d920000 ffff883f63f14d00 0000000000000000
> <4>[ 1084.122006] Call Trace:
> <4>[ 1084.122168]  <IRQ>
> <4>[ 1084.122193]  [<ffffffffa00fbed4>] ixgbe_select_queue+0xc4/0x150 [ixgbe]
> <4>[ 1084.122519]  [<ffffffff8159111e>] netdev_pick_tx+0x5e/0xf0
> <4>[ 1084.122687]  [<ffffffff81591252>] __dev_queue_xmit+0xa2/0x560
> <4>[ 1084.122856]  [<ffffffff81591720>] dev_queue_xmit+0x10/0x20
> <4>[ 1084.123034]  [<ffffffffa05e93a2>] bond_dev_queue_xmit+0x32/0x80 [bonding]
> <4>[ 1084.123207]  [<ffffffffa05eb0d6>] bond_start_xmit+0x1a6/0x3f0 [bonding]
> <4>[ 1084.123382]  [<ffffffff8124faa5>] ? ep_poll_callback+0xb5/0x160
> <4>[ 1084.123551]  [<ffffffff81590f08>] dev_hard_start_xmit+0x238/0x3f0
> <4>[ 1084.123721]  [<ffffffff815908cf>] ? netif_skb_features+0xff/0x200
> <4>[ 1084.123890]  [<ffffffff815915f2>] __dev_queue_xmit+0x442/0x560
> <4>[ 1084.124059]  [<ffffffff81591720>] dev_queue_xmit+0x10/0x20
> <4>[ 1084.124232]  [<ffffffffa04fe70a>] ovs_vport_send+0x4a/0xc0 [openvswitch]
> <4>[ 1084.124404]  [<ffffffffa04f1263>] do_output.isra.30+0x43/0x160 [openvswitch]
> <4>[ 1084.124575]  [<ffffffff81579c5e>] ? __skb_clone+0x2e/0x140
> <4>[ 1084.124744]  [<ffffffffa04f25c4>] do_execute_actions+0x684/0x7e0 [openvswitch]
> <4>[ 1084.125067]  [<ffffffffa04f2752>] ovs_execute_actions+0x32/0xd0 [openvswitch]
> <4>[ 1084.125240]  [<ffffffffa04f5ed4>] ovs_dp_process_packet+0x84/0x110 [openvswitch]
> <4>[ 1084.125565]  [<ffffffffa04fdfec>] ovs_vport_receive+0x6c/0xd0 [openvswitch]
> <4>[ 1084.125740]  [<ffffffff810b1645>] ? check_preempt_curr+0x75/0x90
> <4>[ 1084.125912]  [<ffffffff810b1679>] ? ttwu_do_wakeup+0x19/0xe0
> <4>[ 1084.126081]  [<ffffffff810b195d>] ? ttwu_do_activate.constprop.95+0x5d/0x70
> <4>[ 1084.126252]  [<ffffffff810b23c7>] ? try_to_wake_up+0x47/0x340
> <4>[ 1084.126427]  [<ffffffff810b2772>] ? default_wake_function+0x12/0x20
> <4>[ 1084.126600]  [<ffffffff810ca51b>] ? autoremove_wake_function+0x2b/0x40
> <4>[ 1084.126773]  [<ffffffffa04ff127>] netdev_frame_hook+0xe7/0x150 [openvswitch]
> <4>[ 1084.126945]  [<ffffffff8158e840>] __netif_receive_skb_core+0x1e0/0x9e0
> <4>[ 1084.127115]  [<ffffffff8167d4e6>] ? ipv6_gro_receive+0x246/0x360
> <4>[ 1084.127284]  [<ffffffff8158f058>] __netif_receive_skb+0x18/0x60
> <4>[ 1084.127453]  [<ffffffff8158f0e0>] netif_receive_skb_internal+0x40/0xb0
> <4>[ 1084.127623]  [<ffffffff8158fd23>] napi_gro_receive+0xc3/0x110
> <4>[ 1084.127813]  [<ffffffffa01e41fc>] bnx2x_rx_int+0x101c/0x19d0 [bnx2x]
> <4>[ 1084.127984]  [<ffffffff810c37e3>] ? load_balance+0x163/0x8d0
> <4>[ 1084.128166]  [<ffffffffa01e6a64>] bnx2x_poll+0x284/0x340 [bnx2x]
> <4>[ 1084.128334]  [<ffffffff8158f4eb>] net_rx_action+0x16b/0x370
> <4>[ 1084.128503]  [<ffffffff8108c032>] __do_softirq+0xe2/0x2e0
> <4>[ 1084.128671]  [<ffffffff8108c4d5>] irq_exit+0xf5/0x100
> <4>[ 1084.128843]  [<ffffffff816a0b06>] do_IRQ+0x56/0xd0
> <4>[ 1084.129010]  [<ffffffff8169eb47>] common_interrupt+0x87/0x87
> <4>[ 1084.129176]  <EOI>
> <4>[ 1084.129188]  [<ffffffff8153e168>] ? cpuidle_enter_state+0xd8/0x250
> <4>[ 1084.129510]  [<ffffffff8153e144>] ? cpuidle_enter_state+0xb4/0x250
> <4>[ 1084.129681]  [<ffffffff8153e317>] cpuidle_enter+0x17/0x20
> <4>[ 1084.129849]  [<ffffffff810ca832>] call_cpuidle+0x32/0x60
> <4>[ 1084.130016]  [<ffffffff8153e2f3>] ? cpuidle_select+0x13/0x20
> <4>[ 1084.130184]  [<ffffffff810caaf9>] cpu_startup_entry+0x299/0x360
> <4>[ 1084.130354]  [<ffffffff8169201c>] rest_init+0x7c/0x80
> <4>[ 1084.130521]  [<ffffffff81b5716a>] start_kernel+0x4cf/0x4f0
> <4>[ 1084.134763]  [<ffffffff81b56a86>] ? set_init_arg+0x55/0x55
> <4>[ 1084.134931]  [<ffffffff81b56120>] ? early_idt_handler_array+0x120/0x120
> <4>[ 1084.135101]  [<ffffffff81b565ee>] x86_64_start_reservations+0x2a/0x2c
> <4>[ 1084.135269]  [<ffffffff81b5673c>] x86_64_start_kernel+0x14c/0x16f
> <4>[ 1084.135437] Code: 8b 7d 00 41 83 ff 01 0f 84 8b 00 00 00 f6 86 91 00 00 00 30 0f 84 85 00 00 00 8b 96 a4 00 00 00 44 89 f8 48 0f af c2 48 c1 e8 20 <41> 0f b7 44 45 18 41 3b 86 cc 03 00
>  00 0f 83 81 00 00 00 44 39
> <1>[ 1084.136184] RIP  [<ffffffff81589802>] __netdev_pick_tx+0x92/0x140
> <4>[ 1084.136357]  RSP <ffff883f7f003638>
> <4>[ 1084.136518] CR2: ffff8840c365b5c4
> <4>[ 1084.137174] ---[ end trace 17b59260de82e18d ]---
> <0>[ 1084.212189] Kernel panic - not syncing: Fatal exception in interrupt
> <0>[ 1084.212482] Kernel Offset: disabled
> 
> 
> I've bisected this to following commit:
> 
> commit 52bd2d62ce6758d811edcbd2256eb9ea7f6a56cb
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Wed Nov 18 06:30:50 2015 -0800
> 
>     net: better skb->sender_cpu and skb->napi_id cohabitation
>     
>     skb->sender_cpu and skb->napi_id share a common storage,
>     and we had various bugs about this.
>     
>     We had to call skb_sender_cpu_clear() in some places to
>     not leave a prior skb->napi_id and fool netdev_pick_tx()
>     
>     As suggested by Alexei, we could split the space so that
>     these errors can not happen.
>     
>     0 value being reserved as the common (not initialized) value,
>     let's reserve [1 .. NR_CPUS] range for valid sender_cpu,
>     and [NR_CPUS+1 .. ~0U] for valid napi_id.
>     
>     This will allow proper busy polling support over tunnels.
> 
> 
> I'm by no means kernel developer and it doesn't make any sense
> to me why this patch should be fixing it, but it is.. I've confirmed
> it multiple times, that 4.4.32 without the patch crashes within
> minutes, with it applied (it applies cleanly), it's rock solid.
> 
> therefore I'd probably like to propose this patch to -stable,
> but I'd like to hear you, -netdev people opinion, especially
> Erics..
> 
> what do you think about it?
> 
> thanks a lot in advance for reply
> 
> BR
> 
> nik
> 
> 
> 
> 
> 
> 
> 
