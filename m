From: Pavel Machek <pavel@ucw.cz>
Subject: Re: sis900 oops on resume
Date: Wed, 17 Nov 2004 21:10:08 +0100
Message-ID: <20041117201008.GA11439@elf.ucw.cz>
References: <20041117182403.GC2252@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, Daniele Venzano <webvenza@libero.it>
Content-Disposition: inline
In-Reply-To: <20041117182403.GC2252@stro.at>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

> happens since the use of guessnet,
> guessnet is based on divine and sends arp requests to network.
> network was down after the oops, but beside resume system worked.

And where do you see the oops? Irq 10 does not work, that's only
backtrace. Fix the sis900 driver...

							Pavel

> Nov 16 20:15:36 sputnik kernel: Stopping tasks: ============================|
> Nov 16 20:15:37 sputnik kernel: Freeing memory... done (37019 pages freed)
> Nov 16 20:15:37 sputnik kernel: ..........................................swsusp
> : Need to copy 10075 pages
> Nov 16 20:15:37 sputnik kernel: .<6>eth0: Abnormal interrupt,status 0x03008000.
> Nov 16 20:15:37 sputnik kernel: irq 10: nobody cared!
> Nov 16 20:15:37 sputnik kernel: [<c0130a34>] __report_bad_irq+0x24/0x90
> Nov 16 20:15:37 sputnik kernel: [<c0130b31>] note_interrupt+0x61/0x90
> Nov 16 20:15:37 sputnik kernel: [<c013059b>] __do_IRQ+0x11b/0x130
> Nov 16 20:15:37 sputnik kernel: [<c0104b4c>] do_IRQ+0x5c/0x60
> Nov 16 20:15:37 sputnik kernel: [<c01031ea>] common_interrupt+0x1a/0x20
> Nov 16 20:15:37 sputnik kernel: [<c0130440>] handle_IRQ_event+0x20/0x60
> Nov 16 20:15:37 sputnik kernel: [<c013054a>] __do_IRQ+0xca/0x130
> Nov 16 20:15:37 sputnik kernel: [<c0104b2e>] do_IRQ+0x3e/0x60
> Nov 16 20:15:37 sputnik kernel: =======================
> Nov 16 20:15:37 sputnik kernel: [<c01031ea>] common_interrupt+0x1a/0x20
> Nov 16 20:15:37 sputnik kernel: [<c020007b>] sisdrv_irq_install+0xbb/0x160
> Nov 16 20:15:37 sputnik kernel: [<c0207144>] i8042_command+0xc4/0xf0
> Nov 16 20:15:37 sputnik kernel: [<c0207571>] i8042_enable_mux_mode+0x21/0x90
> Nov 16 20:15:37 sputnik kernel: [<c0207a9c>] i8042_controller_resume+0xdc/0x120
> Nov 16 20:15:37 sputnik kernel: [<c020abad>] platform_resume+0x3d/0x40
> Nov 16 20:15:37 sputnik kernel: [<c020be46>] resume_device+0x16/0x20
> Nov 16 20:15:37 sputnik kernel: [<c020bef7>] dpm_resume+0xa7/0xb0
> Nov 16 20:15:37 sputnik kernel: [<c020bf11>] device_resume+0x11/0x20
> Nov 16 20:15:37 sputnik kernel: [<c012f6a5>] finish+0x5/0x40
> Nov 16 20:15:37 sputnik kernel: [<c012f7bc>] pm_suspend_disk+0x3c/0x70
> Nov 16 20:15:37 sputnik kernel: [<c012dee5>] enter_state+0x65/0x70
> Nov 16 20:15:37 sputnik kernel: [<c012e023>] state_store+0xa3/0xab
> Nov 16 20:15:37 sputnik kernel: [<c012df80>] state_store+0x0/0xab
> Nov 16 20:15:37 sputnik kernel: [<c017e7f6>] subsys_attr_store+0x36/0x40
> Nov 16 20:15:37 sputnik kernel: [<c017ea5e>] flush_write_buffer+0x2e/0x40
> Nov 16 20:15:37 sputnik kernel: [<c017eac1>] sysfs_write_file+0x51/0x60
> Nov 16 20:15:37 sputnik kernel: [<c014e101>] vfs_write+0xd1/0x120
> Nov 16 20:15:37 sputnik kernel: [<c014e217>] sys_write+0x47/0x80
> Nov 16 20:15:37 sputnik kernel: [<c010307b>] syscall_call+0x7/0xb
> Nov 16 20:15:37 sputnik kernel: [<e0032720>] (sis900_interrupt+0x0/0x100 [sis900])
> Nov 16 20:15:37 sputnik kernel: Disabling IRQ #10

-- 
People were complaining that M$ turns users into beta-testers...
...jr ghea gurz vagb qrirybcref, naq gurl frrz gb yvxr vg gung jnl!
