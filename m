From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Machine Check Exception Was: NetDev! Please help!
Date: Sat, 20 Sep 2008 20:31:36 +0200
Message-ID: <48D54188.3080801@gmail.com>
References: <48D4F85C.8090709@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753075AbYITSbZ@vger.kernel.org>
In-Reply-To: <48D4F85C.8090709@bigtelecom.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Badalian Vyacheslav wrote, On 09/20/2008 03:19 PM:

> Hello all.


Hi Vyacheslav,


I think it might be something more than netdev. Please, read in the kernel
config the comment to Processor type and features/Machine Check Exception.

I pasted your second message below and Cc linux-kernel.

Jarek P.

> We buy 10 Intel servers and paste it to shape traffic. After 5-15 hours
> all PC is was freeze!  Kernel not see TCO watchdog at this platform and
> can't reboot it!. Soft Watchdog not reboot pc in this situation.  =(
> 
> At screen we see messages like this (when it freeze and i was near monitor):
> 
> http://www.kerneloops.org/guilty.php?guilty=dev_watchdog&version=2.6.26-release&start=1736704&end=1769471&class=warn
> 
> Also by netconsole we was get this one time:
> 
> [ 1352.245851] netconsole: network logging started
> [ 1458.400133] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
> [ 1458.400133] All bugs added by David S. Miller <davem@redhat.com>
> [ 4956.420298] CPU 1: Machine Check Exception: 0000000000000005
> [ 4956.420298] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
> [ 4956.420300]   Tx Queue             <0>
> [ 4956.420300]   TDH                  <81>
> [ 4956.420301]   TDT                  <81>
> [ 4956.420302]   next_to_use          <81>
> [ 4956.420302]   next_to_clean        <d6>
> [ 4956.420303] buffer_info[next_to_clean]
> [ 4956.420303]   time_stamp           <15498d>
> [ 4956.420304]   next_to_watch        <d6>
> [ 4956.420304]   jiffies              <15511c>
> [ 4956.420305]   next_to_watch.status <1>
> [ 4956.420537] eth1: Detected Tx Unit Hang:
> [ 4956.420538]   TDH                  <b0>
> [ 4956.420538]   TDT                  <b0>
> [ 4956.420539]   next_to_use          <b0>
> [ 4956.420539]   next_to_clean        <5>
> [ 4956.420540] buffer_info[next_to_clean]:
> [ 4956.420540]   time_stamp           <15498e>
> [ 4956.420541]   next_to_watch        <5>
> [ 4956.420542]   jiffies              <15511c>
> [ 4956.420542]   next_to_watch.status <1>
> [ 4956.423064] CPU 1: Bank 0: 3200004000000800
> [ 4956.423190] CPU 1: Bank 5: 3200220024080400
> [ 4956.423315] Kernel panic - not syncing: CPU context corrupt
> [ 4956.423933] Rebooting in 3 seconds..[  531.843998] CPU 2: Machine
> Check Exception: 0000000000000005
> [  531.843998] CPU 0: Machine Check Exception: 0000000000000004
> [  531.844000] CPU 0: Bank 0: 3200004000000800
> [  531.844001] CPU 0: Bank 5: 3200121014040400
> [  531.844002] Kernel panic - not syncing: CPU context corrupt
> [  531.844916] Rebooting in 3 seconds..
> 
> This out of lspci:
> 
> 00:00.0 Host bridge: Intel Corporation Server DRAM Controller
> 00:19.0 Ethernet controller: Intel Corporation 82566DM-2 Gigabit Network
> Connection (rev 02)
> 00:1a.0 USB Controller: Intel Corporation USB UHCI Controller #4 (rev 02)
> 00:1a.1 USB Controller: Intel Corporation USB UHCI Controller #5 (rev 02)
> 00:1a.2 USB Controller: Intel Corporation USB UHCI Controller #6 (rev 02)
> 00:1a.7 USB Controller: Intel Corporation USB2 EHCI Controller #2 (rev 02)
> 00:1c.0 PCI bridge: Intel Corporation PCI Express Port 1 (rev 02)
> 00:1c.4 PCI bridge: Intel Corporation PCI Express Port 5 (rev 02)
> 00:1d.0 USB Controller: Intel Corporation USB UHCI Controller #1 (rev 02)
> 00:1d.1 USB Controller: Intel Corporation USB UHCI Controller #2 (rev 02)
> 00:1d.2 USB Controller: Intel Corporation USB UHCI Controller #3 (rev 02)
> 00:1d.7 USB Controller: Intel Corporation USB2 EHCI Controller #1 (rev 02)
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92)
> 00:1f.0 ISA bridge: Intel Corporation LPC Interface Controller (rev 02)
> 00:1f.2 SATA controller: Intel Corporation 6 port SATA AHCI Controller
> (rev 02)
> 00:1f.3 SMBus: Intel Corporation SMBus Controller (rev 02)
> 02:00.0 VGA compatible controller: Matrox Graphics, Inc. MGA G200e
> [Pilot] ServerEngines (SEP1) (rev 02)
> 03:02.0 Ethernet controller: Intel Corporation 82541GI Gigabit Ethernet
> Controller (rev 05)
> 
> lspci -tv
> -[0000:00]-+-00.0  Intel Corporation Server DRAM Controller
>            +-19.0  Intel Corporation 82566DM-2 Gigabit Network Connection
>            +-1a.0  Intel Corporation USB UHCI Controller #4
>            +-1a.1  Intel Corporation USB UHCI Controller #5
>            +-1a.2  Intel Corporation USB UHCI Controller #6
>            +-1a.7  Intel Corporation USB2 EHCI Controller #2
>            +-1c.0-[0000:01]--
>            +-1c.4-[0000:02]----00.0  Matrox Graphics, Inc. MGA G200e
> [Pilot] ServerEngines (SEP1)
>            +-1d.0  Intel Corporation USB UHCI Controller #1
>            +-1d.1  Intel Corporation USB UHCI Controller #2
>            +-1d.2  Intel Corporation USB UHCI Controller #3
>            +-1d.7  Intel Corporation USB2 EHCI Controller #1
>            +-1e.0-[0000:03]----02.0  Intel Corporation 82541GI Gigabit
> Ethernet Controller
>            +-1f.0  Intel Corporation LPC Interface Controller
>            +-1f.2  Intel Corporation 6 port SATA AHCI Controller
>            \-1f.3  Intel Corporation SMBus Controller
> 
> All tests in 2.6.26.2 kernel... now i try compile 2.6.26.5 kernel, but
> if KernelOops is right - its not  will help.
> 
> I hope NetDev help!
> If any information or test is needed - please write!
> 
> Thanks for anyone!
> 
> Badalian Vyacheslav.

Badalian Vyacheslav wrote, On 09/20/2008 03:38 PM:

> New crash.... netconsole log:
> 
> [  116.333349] ------------[ cut here ]------------
> [  116.333516] WARNING: at net/sched/sch_generic.c:222
> dev_watchdog+0xf1/0x110()
> [  116.333690] Modules linked in: netconsole i2c_i801 i2c_core e1000e e1000
> [  116.334199] Pid: 0, comm: swapper Not tainted 2.6.26-gentoo-r1-fw #2
> [  116.334371]  [<c012506f>] warn_on_slowpath+0x5f/0x90
> [  116.334597]  [<c011dd1a>] enqueue_task_fair+0x1a/0x30
> [  116.334823]  [<c011b962>] enqueue_task+0x12/0x30
> [  116.335046]  [<c011b9d3>] activate_task+0x23/0x40
> [  116.335268]  [<c011e01a>] try_to_wake_up+0x6a/0x110
> [  116.335491]  [<c0137c7b>] autoremove_wake_function+0x1b/0x50
> [  116.335718]  [<c011be6b>] __wake_up_common+0x4b/0x80
> [  116.335941]  [<c011cfde>] __wake_up+0x3e/0x60
> [  116.336161]  [<c0134a2b>] insert_work+0x4b/0x70
> [  116.336384]  [<c0134dd7>] __queue_work+0x27/0x40
> [  116.336610]  [<c02d0651>] dev_watchdog+0xf1/0x110
> [  116.337333]  [<c012e055>] run_timer_softirq+0x115/0x170
> [  116.337557]  [<c0122c71>] scheduler_tick+0xa1/0xd0
> [  116.337780]  [<c012a062>] __do_softirq+0x82/0x100
> [  116.338002]  [<c012a117>] do_softirq+0x37/0x40
> [  116.338222]  [<c0114027>] smp_apic_timer_interrupt+0x57/0x90
> [  116.338448]  [<c0105660>] apic_timer_interrupt+0x28/0x30
> [  116.338672]  [<c010a5e2>] mwait_idle+0x32/0x40
> [  116.338894]  [<c010a5b0>] mwait_idle+0x0/0x40
> [  116.339115]  [<c01036e8>] cpu_idle+0x48/0xc0
> [  116.339336]  =======================
> [  116.339499] ---[ end trace e25a40b7dc59df07 ]---
> [  117.655918] CPU 1: Machine Check Exception: 0000000000000005
> [  117.656103] CPU 1: Bank 0: 3200004000000800
> [  117.656604] CPU 1: Bank 5: 3200220024080400
> [  117.656604] Kernel panic - not syncing: CPU context corrupt
> [  117.656624] Rebooting in 3 seconds..
> 
> 
> Thanks
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
