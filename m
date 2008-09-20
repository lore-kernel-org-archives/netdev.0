From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: NetDev! Please help!
Date: Sat, 20 Sep 2008 17:38:40 +0400
Message-ID: <48D4FCE0.5010301@bigtelecom.ru>
References: <48D4F85C.8090709@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:56972 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbYITNis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 09:38:48 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id DCF8AA6C82B
	for <netdev@vger.kernel.org>; Sat, 20 Sep 2008 17:38:46 +0400 (MSD)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id PWmy-IKC75G7 for <netdev@vger.kernel.org>;
	Sat, 20 Sep 2008 17:38:40 +0400 (MSD)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 3A8C5A6C827
	for <netdev@vger.kernel.org>; Sat, 20 Sep 2008 17:38:40 +0400 (MSD)
In-Reply-To: <48D4F85C.8090709@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


New crash.... netconsole log:

[  116.333349] ------------[ cut here ]------------
[  116.333516] WARNING: at net/sched/sch_generic.c:222
dev_watchdog+0xf1/0x110()
[  116.333690] Modules linked in: netconsole i2c_i801 i2c_core e1000e e1000
[  116.334199] Pid: 0, comm: swapper Not tainted 2.6.26-gentoo-r1-fw #2
[  116.334371]  [<c012506f>] warn_on_slowpath+0x5f/0x90
[  116.334597]  [<c011dd1a>] enqueue_task_fair+0x1a/0x30
[  116.334823]  [<c011b962>] enqueue_task+0x12/0x30
[  116.335046]  [<c011b9d3>] activate_task+0x23/0x40
[  116.335268]  [<c011e01a>] try_to_wake_up+0x6a/0x110
[  116.335491]  [<c0137c7b>] autoremove_wake_function+0x1b/0x50
[  116.335718]  [<c011be6b>] __wake_up_common+0x4b/0x80
[  116.335941]  [<c011cfde>] __wake_up+0x3e/0x60
[  116.336161]  [<c0134a2b>] insert_work+0x4b/0x70
[  116.336384]  [<c0134dd7>] __queue_work+0x27/0x40
[  116.336610]  [<c02d0651>] dev_watchdog+0xf1/0x110
[  116.337333]  [<c012e055>] run_timer_softirq+0x115/0x170
[  116.337557]  [<c0122c71>] scheduler_tick+0xa1/0xd0
[  116.337780]  [<c012a062>] __do_softirq+0x82/0x100
[  116.338002]  [<c012a117>] do_softirq+0x37/0x40
[  116.338222]  [<c0114027>] smp_apic_timer_interrupt+0x57/0x90
[  116.338448]  [<c0105660>] apic_timer_interrupt+0x28/0x30
[  116.338672]  [<c010a5e2>] mwait_idle+0x32/0x40
[  116.338894]  [<c010a5b0>] mwait_idle+0x0/0x40
[  116.339115]  [<c01036e8>] cpu_idle+0x48/0xc0
[  116.339336]  =======================
[  116.339499] ---[ end trace e25a40b7dc59df07 ]---
[  117.655918] CPU 1: Machine Check Exception: 0000000000000005
[  117.656103] CPU 1: Bank 0: 3200004000000800
[  117.656604] CPU 1: Bank 5: 3200220024080400
[  117.656604] Kernel panic - not syncing: CPU context corrupt
[  117.656624] Rebooting in 3 seconds..


Thanks
