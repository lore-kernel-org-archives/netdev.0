From: Gabriel C <nix.or.die@googlemail.com>
Subject: Re: forcedeth ?
Date: Tue, 31 Jul 2007 00:00:55 +0200
Message-ID: <46AE5F97.4050501@googlemail.com>
References: <dcf706c60707301301j21d3cf60n59a686c9abb5e5b3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Sasa Ostrouska <casaxa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:19986 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937041AbXG3WFe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2007 18:05:34 -0400
Received: by mu-out-0910.google.com with SMTP id i10so2466724mue
        for <netdev@vger.kernel.org>; Mon, 30 Jul 2007 15:05:33 -0700 (PDT)
In-Reply-To: <dcf706c60707301301j21d3cf60n59a686c9abb5e5b3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sasa Ostrouska wrote:
[ added netdev to CC ]
> Hi people,
> 
> I'm using this on a x86-64 amd machine. During boot of the last
> 2.6.22.1 kernel I get this error:
> 
> fb0: VESA VGA frame buffer device
> Linux agpgart interface v0.102 (c) Dave Jones
> Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
> 00:0c: ttyS0 at I/O 0x3f8 (irq = 4) is a 16550A
> Marvell 88E1101: Registered new driver
> Marvell 88E1111: Registered new driver
> Marvell 88E1145: Registered new driver
> Fixed PHY: Registered new driver
> Device 'fixed@100:1' does not have a release() function, it is broken
> and must be fixed.
> WARNING: at drivers/base/core.c:107 device_release()
> 
> Call Trace:
>  [<ffffffff802f16c8>] kobject_cleanup+0x52/0x70
>  [<ffffffff802f16e6>] kobject_release+0x0/0x9
>  [<ffffffff802f237a>] kref_put+0x74/0x82
>  [<ffffffff8035c0be>] fixed_mdio_register_device+0x1f3/0x229
>  [<ffffffff805884f6>] fixed_init+0x1f/0x35
>  [<ffffffff80216e2d>] flat_send_IPI_mask+0x0/0x4c
>  [<ffffffff80570910>] kernel_init+0x16f/0x2d5
>  [<ffffffff8020a458>] child_rip+0xa/0x12
>  [<ffffffff8031763c>] acpi_ds_init_one_object+0x0/0x7f
>  [<ffffffff805707a1>] kernel_init+0x0/0x2d5
>  [<ffffffff8020a44e>] child_rip+0x0/0x12
> 
> Device 'fixed@10:1' does not have a release() function, it is broken
> and must be fixed.
> WARNING: at drivers/base/core.c:107 device_release()
> 
> Call Trace:
>  [<ffffffff802f16c8>] kobject_cleanup+0x52/0x70
>  [<ffffffff802f16e6>] kobject_release+0x0/0x9
>  [<ffffffff802f237a>] kref_put+0x74/0x82
>  [<ffffffff8035c0be>] fixed_mdio_register_device+0x1f3/0x229
>  [<ffffffff80588507>] fixed_init+0x30/0x35
>  [<ffffffff80216e2d>] flat_send_IPI_mask+0x0/0x4c
>  [<ffffffff80570910>] kernel_init+0x16f/0x2d5
>  [<ffffffff8020a458>] child_rip+0xa/0x12
>  [<ffffffff8031763c>] acpi_ds_init_one_object+0x0/0x7f
>  [<ffffffff805707a1>] kernel_init+0x0/0x2d5
>  [<ffffffff8020a44e>] child_rip+0x0/0x12
> 
> forcedeth.c: Reverse Engineered nForce ethernet driver. Version 0.60.
> ACPI: PCI Interrupt Link [LMAC] enabled at IRQ 23
> ACPI: PCI Interrupt 0000:00:07.0[A] -> Link [LMAC] -> GSI 23 (level,
> low) -> IRQ 23
> PCI: Setting latency timer of device 0000:00:07.0 to 64
> forcedeth: using HIGHDMA
> eth0: forcedeth.c: subsystem: 01849:03ef bound to 0000:00:07.0
> netconsole: not configured, aborting
> Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
> ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
> NFORCE-MCP61: IDE controller at PCI slot 0000:00:06.0
> 
> If somebody needs some additional info please cc me.

I got an Oops in 22-git++ with the fixed one but I don't have forcedeth.
There is a patch for it http://lkml.org/lkml/2007/7/18/506.


> 
> Best Regards
> Sasa Ostrouska


Regards,

Gabriel C
