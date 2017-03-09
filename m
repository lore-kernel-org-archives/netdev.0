From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: xgbe unbalanced enable for IRQ XX in 4.11-rc1
Date: Thu, 9 Mar 2017 16:17:38 -0600
Message-ID: <25762623-5aae-bfb1-64fd-dd431630c6c9@arm.com>
References: <41df0f3a-5867-b0d5-a7f9-14b66eaff7a2@arm.com>
 <e6f6df1d-18fa-070f-f28c-75cd3aae4582@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Tom Lendacky <thomas.lendacky@amd.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:49160 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751908AbdCIWSK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 17:18:10 -0500
In-Reply-To: <e6f6df1d-18fa-070f-f28c-75cd3aae4582@amd.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 03/09/2017 03:39 PM, Tom Lendacky wrote:
> On 3/9/2017 3:26 PM, Jeremy Linton wrote:
>> Hi,
>
> Hi Jeremy,
>
> I'll have a look at it.  Can you send me your kernel config just in
> case?

Sure, i will send it to you off list to avoid spamming everyone with a 
43k gziped file.

Thanks,

>
> Thanks,
> Tom
>
>>
>> I have a softiron 3k and under network load (nfs copies, vnc with gnome,
>> etc) it is now throwing these messages as fast as the console will
>> accept them. This is booted DT mode.
>>
>>
>> [  430.111324] Unbalanced enable for IRQ 33
>> [  430.115239] ------------[ cut here ]------------
>> [  430.119849] WARNING: CPU: 0 PID: 6 at kernel/irq/manage.c:529
>> __enable_irq+0x7c/0x88
>> [  430.127583] Modules linked in: fuse xt_CHECKSUM ipt_MASQUERADE
>> nf_nat_masquerade_ipv4 tun ip6t_rpfilter ip6t_REJECT nf_reject_ipv6
>> xt_conntrack ip_set nfnetlink ebtable_nat ebtable_broute bridge stp llc
>> ip6table_nat nf_conntrack_ipv6 nf_defrag_ipv6 nf_nat_ipv6
>> ip6table_mangle ip6table_raw ip6table_security iptable_nat
>> nf_conntrack_ipv4 nf_defrag_ipv4 nf_nat_ipv4 nf_nat nf_conntrack
>> iptable_mangle iptable_raw iptable_security ebtable_filter ebtables
>> ip6table_filter ip6_tables vfat fat crc32_ce crct10dif_ce amd_xgbe
>> ghash_ce ptp pps_core spi_pl022 ipmi_si i2c_designware_platform
>> ipmi_devintf i2c_designware_core ccp ipmi_msghandler nfsd auth_rpcgss
>> nfs_acl lockd grace sunrpc xfs libcrc32c
>> [  430.188350]
>> [  430.189833] CPU: 0 PID: 6 Comm: ksoftirqd/0 Tainted: G        W I
>> 4.11.0-0.rc1.git0.1.fc27.aarch64 #1
>> [  430.199391] Hardware name: AMD Overdrive/Supercharger/Default string,
>> BIOS ROD1002C 04/08/2016
>> [  430.207994] task: ffff8003e4057900 task.stack: ffff8003f4590000
>> [  430.213904] PC is at __enable_irq+0x7c/0x88
>> [  430.218078] LR is at __enable_irq+0x7c/0x88
>> [  430.222252] pc : [<ffff000008137b14>] lr : [<ffff000008137b14>]
>> pstate: 000001c5
>> [  430.229639] sp : ffff8003f4593c50
>> [  430.232944] x29: ffff8003f4593c50 x28: ffff8003dfeddce0
>> [  430.238248] x27: 0000000000000002 x26: 0000000000000001
>> [  430.243551] x25: 0000000000000040 x24: 00008003f60a0000
>> [  430.248855] x23: ffff8003d5d0a900 x22: 0000000000000040
>> [  430.254158] x21: 0000000000000001 x20: 0000000000000021
>> [  430.259462] x19: ffff8003dc507200 x18: 0000000000000000
>> [  430.264765] x17: 0000000000000000 x16: 0000000000000000
>> [  430.270069] x15: 0000000000000010 x14: ffff000089005e7f
>> [  430.275372] x13: ffff000009005e8d x12: ffff000008e8d000
>> [  430.280676] x11: ffff000008e65458 x10: ffff0000085adce8
>> [  430.285979] x9 : 00000000ffffffd0 x8 : 0000000000000005
>> [  430.291283] x7 : 636e616c61626e55 x6 : ffff8003fee74d98
>> [  430.296586] x5 : ffff8003fee74d98 x4 : 0000000000000000
>> [  430.301890] x3 : ffff8003fee88730 x2 : ffff8003fee74d98
>> [  430.307193] x1 : 00008003f60a0000 x0 : 000000000000001c
>> [  430.312496]
>> [  430.313978] ---[ end trace 5664787410723389 ]---
>> [  430.318586] Call trace:
>> [  430.321023] Exception stack(0xffff8003f4593a80 to 0xffff8003f4593bb0)
>> [  430.327454] 3a80: ffff8003dc507200 0001000000000000 ffff8003f4593c50
>> ffff000008137b14
>> [  430.335277] 3aa0: ffff8003f4593c50 ffff8003f4593c50 ffff8003f4593c10
>> 00000000ffffffc8
>> [  430.343099] 3ac0: ffff8003f4593b00 ffff000008134838 ffff000008b7a570
>> ffff8003f4593bd0
>> [  430.350921] 3ae0: ffff8003f4593c50 ffff8003f4593c50 ffff8003f4593c10
>> 00000000ffffffc8
>> [  430.358743] 3b00: ffff8003f4593bb0 ffff0000081f8130 0000000000000001
>> 0000000000000021
>> [  430.366566] 3b20: 000000000000001c 00008003f60a0000 ffff8003fee74d98
>> ffff8003fee88730
>> [  430.374388] 3b40: 0000000000000000 ffff8003fee74d98 ffff8003fee74d98
>> 636e616c61626e55
>> [  430.382210] 3b60: 0000000000000005 00000000ffffffd0 ffff0000085adce8
>> ffff000008e65458
>> [  430.390033] 3b80: ffff000008e8d000 ffff000009005e8d ffff000089005e7f
>> 0000000000000010
>> [  430.397854] 3ba0: 0000000000000000 0000000000000000
>> [  430.402723] [<ffff000008137b14>] __enable_irq+0x7c/0x88
>> [  430.407939] [<ffff000008137b60>] enable_irq+0x40/0x78
>> [  430.412999] [<ffff0000019a40c8>] xgbe_one_poll+0xc0/0xe8 [amd_xgbe]
>> [  430.419257] [<ffff0000087c1840>] net_rx_action+0x150/0x3c8
>> [  430.424734] [<ffff0000080d2530>] __do_softirq+0x138/0x358
>> [  430.430123] [<ffff0000080d279c>] run_ksoftirqd+0x4c/0x78
>> [  430.435426] [<ffff0000080f2a7c>] smpboot_thread_fn+0x184/0x1b8
>> [  430.441249] [<ffff0000080edf1c>] kthread+0x12c/0x130
>> [  430.446205] [<ffff000008082b70>] ret_from_fork+0x10/0x20
>> [  430.451600] Unbalanced enable for IRQ 33
>> [  430.455516] ------------[ cut here ]------------
