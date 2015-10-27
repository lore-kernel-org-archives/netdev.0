From: Strongly Typed <stronglytyp3d@gmail.com>
Subject: Kernel Panic: DM9601 Fast Ethernet Adapter on ARMv7
Date: Tue, 27 Oct 2015 10:50:39 +0100
Message-ID: <CAH+gtFqavohWFxn-pwW6QZLuEKV=cPzE0HEwXxNt0i_xppSWuA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:35501 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753062AbbJ0Juk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 05:50:40 -0400
Received: by igbkq10 with SMTP id kq10so78316996igb.0
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 02:50:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear list,

Peter as the maintainer from MAINTAINERS is not reachable by mail
(mail delivery failed) so I send this to the list directly.

I am experiencing a kernel oops on a regular basis with a DM9601 Fast
Ethernet Adapter on an Raspberry Pi 2 Model B.

I collected as much information as possible accordingly to
     https://www.kernel.org/pub/linux/docs/lkml/reporting-bugs.html

I already reported the bug here
    https://github.com/raspberrypi/linux/issues/1045

It was mentioned that it is known that the driver is broken.

Can and will you fix the driver? Any help is appreciated.

Best regards

Dave

[1.] One line summary of the problem: Kernel Panic: DM9601 Fast Ethernet Adapter
[2.] Full description of the problem/report:
     Kernel on Raspberry Pi 2 oopses when some significant traffic occurrs.
     Pinging sometimes works fine, but downloading a file oopses the kernel.
[3.] Keywords (i.e., modules, networking, kernel):
[4.] Kernel version (from /proc/version):
     pi@raspberrypi:~$ cat /proc/version
     Linux version 4.1.10-v7+ (dc4@dc4-XPS13-9333) (gcc version 4.8.3
20140303 (prerelease) (crosstool-NG linaro-1.13.1+bzr2650 - Linaro GCC
2014.03) ) #821 SMP PREEMPT Sat Oct 10 00:16:28 BST 2015
[5.] Output of Oops.. message (if applicable) with symbolic information
     resolved (see Documentation/oops-tracing.txt)
     See end of report.
[6.] A small shell script or example program which triggers the
     problem (if possible)
     wget http://cachefly.cachefly.net/100mb.test
     Will certainly oops.
[7.] Environment
[7.1.] Software (add the output of the ver_linux script here)
       Linux raspberrypi 4.1.10-v7+ #821 SMP PREEMPT Sat Oct 10
00:16:28 BST 2015 armv7l GNU/Linux

       Gnu C                  4.6
       Gnu make               4.0
       binutils               2.24.51.20140425
       util-linux             2.20.1
       mount                  support
       module-init-tools      9
       e2fsprogs              1.42.5
       Linux C Library        2.13
       Dynamic linker (ldd)   2.13
       Procps                 3.3.3
       Net-tools              1.60
       Kbd                    1.15.3
       Sh-utils               8.13
       wireless-tools         30
       Modules Loaded         sr9700 dm9601 cfg80211 rfkill
snd_bcm2835 snd_pcm snd_seq snd_seq_device        snd_timer snd
bcm2835_gpiomem uio_pdrv_genirq uio

[7.2.] Processor information (from /proc/cpuinfo):
       processor  : 0
       model name  : ARMv7 Processor rev 5 (v7l)
       BogoMIPS  : 38.40
       Features  : half thumb fastmult vfp edsp neon vfpv3 tls vfpv4
idiva idivt vfpd32 lpae evtstrm
       CPU implementer : 0x41
       CPU architecture: 7
       CPU variant : 0x0
       CPU part  : 0xc07
       CPU revision  : 5

       processor : 1
       model name  : ARMv7 Processor rev 5 (v7l)
       BogoMIPS  : 38.40
       Features  : half thumb fastmult vfp edsp neon vfpv3 tls vfpv4
idiva idivt vfpd32 lpae evtstrm
       CPU implementer : 0x41
       CPU architecture: 7
       CPU variant : 0x0
       CPU part  : 0xc07
       CPU revision  : 5

       processor : 2
       model name  : ARMv7 Processor rev 5 (v7l)
       BogoMIPS  : 38.40
       Features  : half thumb fastmult vfp edsp neon vfpv3 tls vfpv4
idiva idivt vfpd32 lpae evtstrm
       CPU implementer : 0x41
       CPU architecture: 7
       CPU variant : 0x0
       CPU part  : 0xc07
       CPU revision  : 5

       processor : 3
       model name  : ARMv7 Processor rev 5 (v7l)
       BogoMIPS  : 38.40
       Features  : half thumb fastmult vfp edsp neon vfpv3 tls vfpv4
idiva idivt vfpd32 lpae evtstrm
       CPU implementer : 0x41
       CPU architecture: 7
       CPU variant : 0x0
       CPU part  : 0xc07
       CPU revision  : 5

       Hardware  : BCM2709
       Revision  : a01041
       Serial    : 00000000xxxxxxxx
[7.3.] Module information (from /proc/modules):
       sr9700 5449 0 - Live 0x7f130000
       dm9601 6357 0 - Live 0x7f12a000
       cfg80211 420690 0 - Live 0x7f093000
       rfkill 16659 1 cfg80211, Live 0x7f089000
       snd_bcm2835 19769 0 - Live 0x7f07f000
       snd_pcm 74825 1 snd_bcm2835, Live 0x7f061000
       snd_seq 53561 0 - Live 0x7f04b000
       snd_seq_device 3650 1 snd_seq, Live 0x7f046000
       snd_timer 18157 2 snd_pcm,snd_seq, Live 0x7f03c000
       snd 52116 5
snd_bcm2835,snd_pcm,snd_seq,snd_seq_device,snd_timer, Live 0x7f025000
       bcm2835_gpiomem 3023 0 - Live 0x7f021000
       uio_pdrv_genirq 2966 0 - Live 0x7f017000
       uio 8235 1 uio_pdrv_genirq, Live 0x7f004000
[7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
       pi@raspberrypi:~$ cat /proc/ioports
       [empty]
       pi@raspberrypi:~$ cat /proc/iomem
       00000000-3affffff : System RAM
         00008000-00775d0b : Kernel code
         007de000-0092378b : Kernel data
       3f006000-3f006fff : dwc_otg
       3f007000-3f007eff : /soc/dma@7e007000
       3f00b840-3f00b84e : /soc/vchiq
       3f00b880-3f00b8bf : /soc/mailbox@7e00b800
       3f200000-3f2000b3 : /soc/gpio@7e200000
       3f201000-3f201fff : /soc/uart@7e201000
         3f201000-3f201fff : uart-pl011
       3f300000-3f3000ff : /soc/mmc@7e300000
       3f980000-3f98ffff : dwc_otg
[7.5.] PCI information ('lspci -vvv' as root)
       RPi has no PCI
[7.6.] SCSI information (from /proc/scsi/scsi)
       RPI has no SCSI
[7.7.] Other information that might be relevant to the problem
       (please look in /proc and include all information that you
       think to be relevant):
       pi@raspberrypi:~$ lsusb
       Bus 001 Device 002: ID 0424:9514 Standard Microsystems Corp.
       Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
       Bus 001 Device 003: ID 0424:ec00 Standard Microsystems Corp.
       Bus 001 Device 004: ID 0fe6:9700 Kontron (Industrial Computer
Source / ICS Advent) DM9601 Fast Ethernet Adapter
[X.] Other notes, patches, fixes, workarounds:


[  240.940437] skbuff: skb_over_panic: text:803c5ec8 len:1536 put:1536
head:b2c11700 data:b2c11742 tail:0xb2c11d42 end:0xb2c11d40 dev:eth1
[  240.955434] ------------[ cut here ]------------
[  240.961501] kernel BUG at net/core/skbuff.c:102!
[  240.967571] Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
[  240.974894] Modules linked in: sr9700 dm9601 cfg80211 rfkill
snd_bcm2835 snd_pcm snd_seq snd_seq_device snd_timer snd
bcm2835_gpiomem uio_pdrv_genirq uio
[  240.992033] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.1.10-v7+ #821
[  241.000090] Hardware name: BCM2709
[  241.005094] task: 80800728 ti: 807de000 task.ti: 807de000
[  241.012141] PC is at skb_panic+0x64/0x70
[  241.017691] LR is at bcm2835_send_doorbell+0x5c/0x74
[  241.023753] pc : [<8055978c>]    lr : [<80022550>]    psr: 20000193
[  241.023753] sp : 807dfd68  ip : 00000001  fp : 807dfd9c
[  241.037477] r10: 00000000  r9 : 00000101  r8 : 00000000
[  241.043835] r7 : 806b7e98  r6 : b2c11700  r5 : 00000600  r4 : b2c11742
[  241.051511] r3 : 807de000  r2 : 00000101  r1 : 00000004  r0 : 0000007b
[  241.059183] Flags: nzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM
Segment kernel
[  241.068910] Control: 10c5387d  Table: 3858406a  DAC: 00000015
[  241.075882] Process swapper/0 (pid: 0, stack limit = 0x807de210)
[  241.083097] Stack: (0x807dfd68 to 0x807e0000)
[  241.088629] fd60:                   00000600 b2c11700 b2c11742
b2c11d42 b2c11d40 b8719000
[  241.099161] fd80: 00000600 b2c11d42 b2c11d40 00000000 807dfdbc
807dfda0 8046eed8 80559734
[  241.109772] fda0: b8719440 b9243d00 b91090c0 00000000 807dfde4
807dfdc0 803c5ec8 8046ee88
[  241.120405] fdc0: b9243d00 60000113 b9243d00 60000113 00000000
00000000 807dfe04 807dfde8
[  241.131104] fde0: 803ce060 803c5ea0 b9243d00 b9b8bc00 b9243d00
807d8254 807dfe24 807dfe08
[  241.141922] fe00: 803ce184 803cdfec b9a370c8 b8479500 b9a37000
b9243d00 807dfe4c 807dfe28
[  241.152843] fe20: 803f4838 803ce140 807dac74 20000113 807dfe6c
b9bbfc80 b9bbfc84 00000000
[  241.163897] fe40: 807dfe5c 807dfe50 80402d34 803f47d8 807dfe84
807dfe60 8002ad9c 80402d20
[  241.175057] fe60: 8002ad20 8002a90c 807e0080 00000001 00000000
00000001 807dfecc 807dfe88
[  241.186252] fe80: 8002a2a4 8002ad2c 807e195c b9bbf780 00000001
00200000 ffffe8d8 0000000a
[  241.197531] fea0: 8006ebb8 00000000 807dac74 00000000 00000000
00000000 807d8304 807fcd7c
[  241.208864] fec0: 807dfee4 807dfed0 8002a90c 8002a18c 807de000
00000000 807dff0c 807dfee8
[  241.220212] fee0: 8006b660 8002a84c 807dff20 80010a00 60000013
f300b200 807dff54 8085e73c
[  241.231559] ff00: 807dff1c 807dff10 8000933c 8006b5e0 807dff74
807dff20 8055e8b4 8000931c
[  241.242906] ff20: 807fdcdc 00000000 00000000 00000000 807de000
807fcddc 00000001 ffffffff
[  241.254252] ff40: 8085e73c 807d8304 807fcd7c 807dff74 807dff68
807dff68 800109fc 80010a00
[  241.265599] ff60: 60000013 ffffffff 807dff94 807dff78 8005fb04
800109dc 807dff94 807dff78
[  241.276945] ff80: 8055a798 ffffffff 807dffac 807dff98 8055421c
8005f904 807de000 80866050
[  241.288293] ffa0: 807dfff4 807dffb0 80776ccc 805541a4 ffffffff
ffffffff 807766cc 00000000
[  241.299639] ffc0: 00000000 807bb110 00000000 80866294 807fcd60
807bb10c 80801afc 0000406a
[  241.310984] ffe0: 410fc075 00000000 00000000 807dfff8 00008078
80776950 00000000 00000000
[  241.322343] [<8055978c>] (skb_panic) from [<8046eed8>] (skb_put+0x5c/0x60)
[  241.330837] [<8046eed8>] (skb_put) from [<803c5ec8>] (rx_complete+0x34/0x1fc)
[  241.339572] [<803c5ec8>] (rx_complete) from [<803ce060>]
(__usb_hcd_giveback_urb+0x80/0x154)
[  241.351104] [<803ce060>] (__usb_hcd_giveback_urb) from [<803ce184>]
(usb_hcd_giveback_urb+0x50/0x118)
[  241.363424] [<803ce184>] (usb_hcd_giveback_urb) from [<803f4838>]
(completion_tasklet_func+0x6c/0x98)
[  241.375735] [<803f4838>] (completion_tasklet_func) from
[<80402d34>] (tasklet_callback+0x20/0x24)
[  241.387690] [<80402d34>] (tasklet_callback) from [<8002ad9c>]
(tasklet_hi_action+0x7c/0x114)
[  241.399200] [<8002ad9c>] (tasklet_hi_action) from [<8002a2a4>]
(__do_softirq+0x124/0x3d4)
[  241.410441] [<8002a2a4>] (__do_softirq) from [<8002a90c>]
(irq_exit+0xcc/0x13c)
[  241.419319] [<8002a90c>] (irq_exit) from [<8006b660>]
(__handle_domain_irq+0x8c/0xec)
[  241.430171] [<8006b660>] (__handle_domain_irq) from [<8000933c>]
(asm_do_IRQ+0x2c/0x30)
[  241.441195] [<8000933c>] (asm_do_IRQ) from [<8055e8b4>]
(__irq_svc+0x34/0x14c)
[  241.449954] Exception stack(0x807dff20 to 0x807dff68)
[  241.456518] ff20: 807fdcdc 00000000 00000000 00000000 807de000
807fcddc 00000001 ffffffff
[  241.467740] ff40: 8085e73c 807d8304 807fcd7c 807dff74 807dff68
807dff68 800109fc 80010a00
[  241.478974] ff60: 60000013 ffffffff
[  241.483960] [<8055e8b4>] (__irq_svc) from [<80010a00>]
(arch_cpu_idle+0x30/0x4c)
[  241.494330] [<80010a00>] (arch_cpu_idle) from [<8005fb04>]
(cpu_startup_entry+0x20c/0x2c8)
[  241.505579] [<8005fb04>] (cpu_startup_entry) from [<8055421c>]
(rest_init+0x84/0x9c)
[  241.516302] [<8055421c>] (rest_init) from [<80776ccc>]
(start_kernel+0x388/0x3f4)
[  241.526756] Code: e58de00c e58d0010 e59f0008 ebffefdb (e7f001f2)
[  241.534349] ---[ end trace 1492d49372743884 ]---
[  241.540446] Kernel panic - not syncing: Fatal exception in interrupt
[  241.548285] CPU3: stopping
[  241.552435] CPU: 3 PID: 0 Comm: swapper/3 Tainted: G      D
4.1.10-v7+ #821
[  241.562906] Hardware name: BCM2709
[  241.567697] [<80018440>] (unwind_backtrace) from [<80013e0c>]
(show_stack+0x20/0x24)
[  241.578198] [<80013e0c>] (show_stack) from [<80558c30>]
(dump_stack+0x98/0xe0)
[  241.586832] [<80558c30>] (dump_stack) from [<80015ebc>]
(handle_IPI+0x264/0x298)
[  241.596945] [<80015ebc>] (handle_IPI) from [<80009408>] (do_IPI+0x18/0x1c)
[  241.605235] [<80009408>] (do_IPI) from [<8055e8b4>] (__irq_svc+0x34/0x14c)
[  241.613498] Exception stack(0xb9937f68 to 0xb9937fb0)
[  241.619912] 7f60:                   807fdcdc 00000000 00000000
00000000 b9936000 807fcddc
[  241.630759] 7f80: 10c0387d 80866348 8085e73c 807d8304 807fcd7c
b9937fbc b9937fb0 b9937fb0
[  241.641590] 7fa0: 800109fc 80010a00 60000013 ffffffff
[  241.647966] [<8055e8b4>] (__irq_svc) from [<80010a00>]
(arch_cpu_idle+0x30/0x4c)
[  241.658001] [<80010a00>] (arch_cpu_idle) from [<8005fb04>]
(cpu_startup_entry+0x20c/0x2c8)
[  241.668982] [<8005fb04>] (cpu_startup_entry) from [<800159e0>]
(secondary_start_kernel+0x144/0x160)
[  241.680825] [<800159e0>] (secondary_start_kernel) from [<000094ac>] (0x94ac)
[  241.689334] CPU2: stopping
[  241.693469] CPU: 2 PID: 0 Comm: swapper/2 Tainted: G      D
4.1.10-v7+ #821
[  241.703923] Hardware name: BCM2709
[  241.708721] [<80018440>] (unwind_backtrace) from [<80013e0c>]
(show_stack+0x20/0x24)
[  241.719237] [<80013e0c>] (show_stack) from [<80558c30>]
(dump_stack+0x98/0xe0)
[  241.727904] [<80558c30>] (dump_stack) from [<80015ebc>]
(handle_IPI+0x264/0x298)
[  241.738080] [<80015ebc>] (handle_IPI) from [<80009408>] (do_IPI+0x18/0x1c)
[  241.746396] [<80009408>] (do_IPI) from [<8055e8b4>] (__irq_svc+0x34/0x14c)
[  241.754683] Exception stack(0xb9935f68 to 0xb9935fb0)
[  241.761119] 5f60:                   807fdcdc 00000000 00000000
00000000 b9934000 807fcddc
[  241.772064] 5f80: 10c0387d 80866348 8085e73c 807d8304 807fcd7c
b9935fbc b9935fb0 b9935fb0
[  241.783004] 5fa0: 800109fc 80010a00 60000013 ffffffff
[  241.789435] [<8055e8b4>] (__irq_svc) from [<80010a00>]
(arch_cpu_idle+0x30/0x4c)
[  241.799532] [<80010a00>] (arch_cpu_idle) from [<8005fb04>]
(cpu_startup_entry+0x20c/0x2c8)
[  241.810521] [<8005fb04>] (cpu_startup_entry) from [<800159e0>]
(secondary_start_kernel+0x144/0x160)
[  241.822358] [<800159e0>] (secondary_start_kernel) from [<000094ac>] (0x94ac)
[  241.830868] CPU1: stopping
[  241.835016] CPU: 1 PID: 0 Comm: swapper/1 Tainted: G      D
4.1.10-v7+ #821
[  241.845493] Hardware name: BCM2709
[  241.850302] [<80018440>] (unwind_backtrace) from [<80013e0c>]
(show_stack+0x20/0x24)
[  241.860841] [<80013e0c>] (show_stack) from [<80558c30>]
(dump_stack+0x98/0xe0)
[  241.869522] [<80558c30>] (dump_stack) from [<80015ebc>]
(handle_IPI+0x264/0x298)
[  241.879720] [<80015ebc>] (handle_IPI) from [<80009408>] (do_IPI+0x18/0x1c)
[  241.888048] [<80009408>] (do_IPI) from [<8055e8b4>] (__irq_svc+0x34/0x14c)
[  241.896345] Exception stack(0xb9933f68 to 0xb9933fb0)
[  241.902794] 3f60:                   807fdcdc 00000000 00000000
00000000 b9932000 807fcddc
[  241.913764] 3f80: 10c0387d 80866348 8085e73c 807d8304 807fcd7c
b9933fbc b9933fb0 b9933fb0
[  241.924728] 3fa0: 800109fc 80010a00 60000013 ffffffff
[  241.931172] [<8055e8b4>] (__irq_svc) from [<80010a00>]
(arch_cpu_idle+0x30/0x4c)
[  241.941295] [<80010a00>] (arch_cpu_idle) from [<8005fb04>]
(cpu_startup_entry+0x20c/0x2c8)
[  241.952310] [<8005fb04>] (cpu_startup_entry) from [<800159e0>]
(secondary_start_kernel+0x144/0x160)
[  241.964177] [<800159e0>] (secondary_start_kernel) from [<000094ac>] (0x94ac)
[  241.972709] ---[ end Kernel panic - not syncing: Fatal exception in interrupt
[  241.981339] ------------[ cut here ]------------
[  241.987393] WARNING: CPU: 0 PID: 0 at kernel/workqueue.c:818
wq_worker_waking_up+0x78/0x90()
[  241.998684] Modules linked in: sr9700 dm9601 cfg80211 rfkill
snd_bcm2835 snd_pcm snd_seq snd_seq_device snd_timer snd
bcm2835_gpiomem uio_pdrv_genirq uio
[  242.015561] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G      D
4.1.10-v7+ #821
[  242.026147] Hardware name: BCM2709
[  242.030990] [<80018440>] (unwind_backtrace) from [<80013e0c>]
(show_stack+0x20/0x24)
[  242.041624] [<80013e0c>] (show_stack) from [<80558c30>]
(dump_stack+0x98/0xe0)
[  242.050330] [<80558c30>] (dump_stack) from [<80026a90>]
(warn_slowpath_common+0x8c/0xc8)
[  242.061302] [<80026a90>] (warn_slowpath_common) from [<80026b88>]
(warn_slowpath_null+0x2c/0x34)
[  242.072985] [<80026b88>] (warn_slowpath_null) from [<8003dc78>]
(wq_worker_waking_up+0x78/0x90)
[  242.084583] [<8003dc78>] (wq_worker_waking_up) from [<8004bfc8>]
(ttwu_do_activate.constprop.97+0x58/0x6c)
[  242.097145] [<8004bfc8>] (ttwu_do_activate.constprop.97) from
[<8004e9e4>] (try_to_wake_up+0x190/0x2e0)
[  242.109475] [<8004e9e4>] (try_to_wake_up) from [<8004eb9c>]
(default_wake_function+0x1c/0x20)
[  242.120957] [<8004eb9c>] (default_wake_function) from [<8005ede0>]
(__wake_up_common+0x5c/0x94)
[  242.132613] [<8005ede0>] (__wake_up_common) from [<8005ee3c>]
(__wake_up_locked+0x24/0x2c)
[  242.143841] [<8005ee3c>] (__wake_up_locked) from [<8005f6e0>]
(complete+0x44/0x54)
[  242.154462] [<8005f6e0>] (complete) from [<80441f00>]
(response_callback+0x1c/0x20)
[  242.165178] [<80441f00>] (response_callback) from [<80461990>]
(mbox_chan_received_data+0x28/0x2c)
[  242.177272] [<80461990>] (mbox_chan_received_data) from
[<80462384>] (bcm2835_mbox_irq+0x40/0x60)
[  242.189276] [<80462384>] (bcm2835_mbox_irq) from [<8006bd14>]
(handle_irq_event_percpu+0x44/0x254)
[  242.201366] [<8006bd14>] (handle_irq_event_percpu) from
[<8006bf70>] (handle_irq_event+0x4c/0x6c)
[  242.213371] [<8006bf70>] (handle_irq_event) from [<8006f168>]
(handle_level_irq+0xa4/0x13c)
[  242.224849] [<8006f168>] (handle_level_irq) from [<8006b658>]
(__handle_domain_irq+0x84/0xec)
[  242.236500] [<8006b658>] (__handle_domain_irq) from [<8000933c>]
(asm_do_IRQ+0x2c/0x30)
[  242.247625] [<8000933c>] (asm_do_IRQ) from [<8055e8b4>]
(__irq_svc+0x34/0x14c)
[  242.256436] Exception stack(0x807dfb08 to 0x807dfb50)
[  242.263052] fb00:                   807fdcdc 00000000 00000102
00000000 808664e8 80801aec
[  242.274305] fb20: 60000193 00000000 00000000 808664e8 80559790
807dfb8c 807dfb50 807dfb50
[  242.285543] fb40: 80554f08 80554f0c 60000113 ffffffff
[  242.292123] [<8055e8b4>] (__irq_svc) from [<80554f0c>] (panic+0x18c/0x204)
[  242.300533] [<80554f0c>] (panic) from [<800141d4>] (die+0x3c4/0x410)
[  242.308397] [<800141d4>] (die) from [<8001424c>] (arm_notify_die+0x2c/0x64)
[  242.316855] [<8001424c>] (arm_notify_die) from [<80009144>]
(do_undefinstr+0x144/0x1a0)
[  242.327750] [<80009144>] (do_undefinstr) from [<8055ea50>]
(__und_svc_finish+0x0/0x30)
[  242.338550] Exception stack(0x807dfce0 to 0x807dfd28)
[  242.345039] fce0: 0000007b 00000004 00000101 807de000 b2c11742
00000600 b2c11700 806b7e98
[  242.356052] fd00: 00000000 00000101 00000000 807dfd9c 00000001
807dfd68 80022550 8055978c
[  242.367064] fd20: 20000193 ffffffff
[  242.371935] [<8055ea50>] (__und_svc_finish) from [<8055978c>]
(skb_panic+0x64/0x70)
[  242.382350] [<8055978c>] (skb_panic) from [<8046eed8>] (skb_put+0x5c/0x60)
[  242.390648] [<8046eed8>] (skb_put) from [<803c5ec8>] (rx_complete+0x34/0x1fc)
[  242.399205] [<803c5ec8>] (rx_complete) from [<803ce060>]
(__usb_hcd_giveback_urb+0x80/0x154)
[  242.410383] [<803ce060>] (__usb_hcd_giveback_urb) from [<803ce184>]
(usb_hcd_giveback_urb+0x50/0x118)
[  242.422404] [<803ce184>] (usb_hcd_giveback_urb) from [<803f4838>]
(completion_tasklet_func+0x6c/0x98)
[  242.434494] [<803f4838>] (completion_tasklet_func) from
[<80402d34>] (tasklet_callback+0x20/0x24)
[  242.446281] [<80402d34>] (tasklet_callback) from [<8002ad9c>]
(tasklet_hi_action+0x7c/0x114)
[  242.457631] [<8002ad9c>] (tasklet_hi_action) from [<8002a2a4>]
(__do_softirq+0x124/0x3d4)
[  242.468767] [<8002a2a4>] (__do_softirq) from [<8002a90c>]
(irq_exit+0xcc/0x13c)
[  242.477595] [<8002a90c>] (irq_exit) from [<8006b660>]
(__handle_domain_irq+0x8c/0xec)
[  242.488351] [<8006b660>] (__handle_domain_irq) from [<8000933c>]
(asm_do_IRQ+0x2c/0x30)
[  242.499361] [<8000933c>] (asm_do_IRQ) from [<8055e8b4>]
(__irq_svc+0x34/0x14c)
[  242.508118] Exception stack(0x807dff20 to 0x807dff68)
[  242.514685] ff20: 807fdcdc 00000000 00000000 00000000 807de000
807fcddc 00000001 ffffffff
[  242.525911] ff40: 8085e73c 807d8304 807fcd7c 807dff74 807dff68
807dff68 800109fc 80010a00
[  242.537150] ff60: 60000013 ffffffff
[  242.542136] [<8055e8b4>] (__irq_svc) from [<80010a00>]
(arch_cpu_idle+0x30/0x4c)
[  242.552507] [<80010a00>] (arch_cpu_idle) from [<8005fb04>]
(cpu_startup_entry+0x20c/0x2c8)
[  242.563756] [<8005fb04>] (cpu_startup_entry) from [<8055421c>]
(rest_init+0x84/0x9c)
[  242.574479] [<8055421c>] (rest_init) from [<80776ccc>]
(start_kernel+0x388/0x3f4)
[  242.584929] ---[ end trace 1492d49372743885 ]---
