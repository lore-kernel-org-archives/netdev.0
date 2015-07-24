From: Suman Tripathi <stripathi@apm.com>
Subject: Re: 4.2-rc3: APM xgene2: ethernet doesn't work
Date: Fri, 24 Jul 2015 08:10:43 +0530
Message-ID: <CAOHikRDw3tCsmEHxgiXV1hvxS=k0b87urqraVS=v2BsgQjO_tg@mail.gmail.com>
References: <CACVXFVPz3g7O5+HWDo5iry-zjpCW_=NhDw4eF6mPT99ooSaXQA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Cloke <andrew.cloke@canonical.com>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACVXFVPz3g7O5+HWDo5iry-zjpCW_=NhDw4eF6mPT99ooSaXQA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ming,

On Thu, Jul 23, 2015 at 2:37 PM, Ming Lei <ming.lei@canonical.com> wrote:
> Hi Guys,
>
> When booting from UEFI/ACPI, sometimes there is a crash[1]
> from rx path, sometimes there isn't any rx packets comming.
>
> Firmware version: 2.02.10
>
> Thanks,
>
> [1], crash log
> Call trace:
> skbuff: skb_over_panic: text:ffffffc00048094c len:85 put:60
> head:ffffffffffffffff data:          (null) tail:0x3c end:0x0
> dev:<NULL>
> Kernel panic - not syncing: BUG!
> CPU: 0 PID: 0 Comm: swapper/0 Tainted: G        W       4.2.0-rc3+ #76
> Hardware name: AppliedMicro Mustang/Mustang, BIOS 2.0.0 Jun  9 2015
> Call trace:
> [<ffffffc000089b94>] dump_backtrace+0x0/0x12c
> [<ffffffc000089cd0>] show_stack+0x10/0x1c
> [<ffffffc0005fbe48>] dump_stack+0x8c/0xdc
> [<ffffffc0005f8448>] panic+0xe4/0x220
> [<ffffffc0005fcfa4>] skb_panic+0x74/0x78
> [<ffffffc000526e88>] skb_put+0x88/0x8c
> [<ffffffc000480948>] xgene_enet_process_ring+0xcc/0x394
> [<ffffffc000480edc>] xgene_enet_napi+0x1c/0x54
> [<ffffffc000537fbc>] net_rx_action+0x124/0x2c0
> [<ffffffc0000b0070>] __do_softirq+0x110/0x238
> [<ffffffc0000b0400>] irq_exit+0x88/0xf0
> [<ffffffc0000e98b8>] __handle_domain_irq+0x68/0xb4
> [<ffffffc0000824a0>] gic_handle_irq+0x30/0x7c
> Exception stack(0xffffffc000877dc0 to 0xffffffc000877ee0)
> 7dc0: 00874000 ffffffc0 0087a648 ffffffc0 00877f00 ffffffc0 000869e0 ffffffc0
> 7de0: 00000000 00000000 00877f10 ffffffc0 fffbcb38 ffffffc7 fffbcb44 ffffffc7
> 7e00: 00000000 01000000 da24b9c8 ffffffc7 fffbe0d9 ffffffc7 fffbe0d8 ffffffc7
> 7e20: 008813a0 ffffffc0 ffff9429 00000000 00000750 00000000 008c93a9 ffffffc0
> 7e40: 007a1b38 ffffffc0 007a1b20 ffffffc0 df5d7500 ffffffbe 00000000 00000000
> 7e60: 98ab6000 0000007f 98a9d440 0000007f 00000000 00000000 00874000 ffffffc0
> 7e80: 0087a648 ffffffc0 00867b00 ffffffc0 00000001 00000000 00877f20 ffffffc0
> 7ea0: 00614500 ffffffc0 00785000 ffffffc0 008c9000 ffffffc0 0087a6cc ffffffc0
> 7ec0: ffa01348 00000047 00877f00 ffffffc0 000869dc ffffffc0 00877f00 ffffffc0
> [<ffffffc0000855a4>] el1_irq+0x64/0xd8
> [<ffffffc0000e03fc>] default_idle_call+0x18/0x2c
> [<ffffffc0000e050c>] cpu_startup_entry+0xfc/0x180
> [<ffffffc0005f5f64>] rest_init+0x80/0x8c
> [<ffffffc0008269b8>] start_kernel+0x3c0/0x3d8
> Rebooting in 1 seconds..[DRAM: PHY calibrating ...ignored]
>  ECC init *********ignored]

It will be fixed in next release as it is a fix in firmware.

-- 
Thanks,
with regards,
Suman Tripathi
