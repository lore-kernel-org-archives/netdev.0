From: Pekka Enberg <penberg@kernel.org>
Subject: [PROBLEM] ipw2200: WARNING: at kernel/softirq.c:143 local_bh_enable+0x58/0x80()
Date: Sun, 5 Sep 2010 18:11:41 +0300
Message-ID: <AANLkTi=BBQL5cS6Ox8MGiy+Pun56xtEhakJxeLwx9UnW@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux Netdev List <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This showed up in dmesg:

[  143.695527] ------------[ cut here ]------------
[  143.695550] WARNING: at kernel/softirq.c:143 local_bh_enable+0x58/0x80()
[  143.695557] Hardware name: 2373KYG
[  143.695562] Modules linked in: ipw2200 libipw
[  143.695577] Pid: 4112, comm: NetworkManager Not tainted 2.6.36-rc2+ #182
[  143.695584] Call Trace:
[  143.695596]  [<c15b8ddc>] ? printk+0x18/0x1a
[  143.695610]  [<c1033fbd>] warn_slowpath_common+0x6d/0xa0
[  143.695620]  [<c1039568>] ? local_bh_enable+0x58/0x80
[  143.695630]  [<c1039568>] ? local_bh_enable+0x58/0x80
[  143.695640]  [<c103400b>] warn_slowpath_null+0x1b/0x20
[  143.695650]  [<c1039568>] local_bh_enable+0x58/0x80
[  143.695662]  [<c1482d25>] netif_rx+0x155/0x180
[  143.695677]  [<f807519c>] libipw_rx+0x55c/0xad0 [libipw]
[  143.695703]  [<f816f86a>] ipw_handle_data_packet+0x12a/0x260 [ipw2200]
[  143.695724]  [<f81702da>] ipw_irq_tasklet+0x82a/0xd80 [ipw2200]
[  143.695736]  [<c1038942>] tasklet_action+0x62/0x70
[  143.695746]  [<c103929d>] __do_softirq+0x7d/0x190
[  143.695756]  [<c106d2f5>] ? handle_IRQ_event+0x45/0x150
[  143.695766]  [<c10393dd>] do_softirq+0x2d/0x40
[  143.695775]  [<c10394fd>] irq_exit+0x5d/0x70
[  143.695785]  [<c10045b3>] do_IRQ+0x43/0xb0
[  143.695796]  [<c10d0c74>] ? sys_poll+0x54/0xc0
[  143.695806]  [<c1003269>] common_interrupt+0x29/0x30
[  143.695814] ---[ end trace a6c4b2362817c5f7 ]---

I have IPW2200 wireless card on this laptop:

02:02.0 Network controller: Intel Corporation PRO/Wireless 2200BG
[Calexico2] Network Connection (rev 05)

                        Pekka
