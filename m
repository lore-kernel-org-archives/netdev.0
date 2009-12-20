From: Michael Guntsche <mike@it-loops.com>
Subject: [BUG] 2.6.33-rc1 gianfar error message
Date: Sun, 20 Dec 2009 22:44:47 +0100
Message-ID: <20091220214447.GA10233@trillian.comsick.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:49808
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754654AbZLTVve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2009 16:51:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I recently installed 2.6.33-rc1 on my Routerboard RB600a to give it a
quick test. After rebooting with 2.6.33-rc1 I got an almost immediate error 
message in my logs.

Sorry for not being able to get more debug info. But with this board I have a
limit on the kernel size.

wan selects TX queue 66, but real number of TX queues is 1
------------[ cut here ]------------
Badness at c01d846c [verbose debug info unavailable]
NIP: c01d846c LR: c01d846c CTR: c0159344
REGS: c0391b70 TRAP: 0700   Not tainted  (2.6.33-rc1)
MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 24002024  XER: 20000000
TASK = c03733e8[0] 'swapper' THREAD: c0390000
GPR00: c01d846c c0391c20 c03733e8 0000004d 00003112 ffffffff c0159ebc c03756f0
GPR08: c039e7fc c0370000 00007fff 00003112 84002024 1001afc0 c78eb200 c031b38c
GPR16: 00000001 c031b3b8 00000000 c7967800 00000000 00000001 c780abec c780a800
GPR24: c780b000 c780b000 c581b300 c780b000 c79d96c0 c79d96c0 00000000 00000042
NIP [c01d846c] dev_queue_xmit+0x534/0x550
LR [c01d846c] dev_queue_xmit+0x534/0x550
Call Trace:
[c0391c20] [c01d846c] dev_queue_xmit+0x534/0x550 (unreliable)
[c0391c50] [c01e02bc] neigh_resolve_output+0xfc/0x26c
[c0391c80] [c0217354] ip_finish_output+0x2c0/0x300
[c0391ca0] [c0213e0c] ip_forward_finish+0x48/0x64
[c0391cb0] [c021263c] ip_rcv_finish+0x1a8/0x3b0
[c0391ce0] [c01d6a98] netif_receive_skb+0x2a4/0x530
[c0391d20] [c01a0998] gfar_clean_rx_ring+0xe0/0x43c
[c0391d70] [c01a1178] gfar_poll+0x484/0x598
[c0391e10] [c01d7688] net_rx_action+0xf0/0x1b4
[c0391e50] [c002651c] __do_softirq+0xb0/0x130
[c0391e90] [c0006294] do_softirq+0x58/0x5c
[c0391ea0] [c0026310] irq_exit+0x7c/0x9c
[c0391eb0] [c0006334] do_IRQ+0x9c/0xb4
[c0391ed0] [c0011dd8] ret_from_except+0x0/0x14
--- Exception: 501 at cpu_idle+0xdc/0xec
    LR = cpu_idle+0xdc/0xec
[c0391f90] [c0009378] cpu_idle+0x58/0xec (unreliable)
[c0391fb0] [c0003ea8] rest_init+0x5c/0x74
[c0391fc0] [c0346760] start_kernel+0x234/0x27c
[c0391ff0] [00003438] 0x3438
Instruction dump:
480d6491 4bfffdc0 7fe3fb78 3bc00000 480122c1 4bfffc00 80db019c 3c60c032
7fe5fb78 7f64db78 3863f000 480d6465 <0fe00000> 4bfffeec 3c60c032 7f64db78
lan selects TX queue 66, but real number of TX queues is 1
------------[ cut here ]------------
Badness at c01d846c [verbose debug info unavailable]
NIP: c01d846c LR: c01d846c CTR: c0159344
REGS: c5857690 TRAP: 0700   Tainted: G        W   (2.6.33-rc1)
MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 24242422  XER: 20000000
TASK = c7b7d200[596] 'dnsmasq' THREAD: c5856000
GPR00: c01d846c c5857740 c7b7d200 0000004d 00003ae4 ffffffff c0159ebc c03756f0
GPR08: c039e7fc c038ecf4 00007fff 00003ae4 84242424 1004335c c78eb380 c031b38c
GPR16: 00000001 c031b3b8 00000000 c797c800 00000000 00000001 c780b3ec c780b000
GPR24: c780a800 c780a800 c7b90f00 c780a800 c5882180 c5882180 00000000 00000042
NIP [c01d846c] dev_queue_xmit+0x534/0x550
LR [c01d846c] dev_queue_xmit+0x534/0x550
Call Trace:
[c5857740] [c01d846c] dev_queue_xmit+0x534/0x550 (unreliable)
[c5857770] [c01e02bc] neigh_resolve_output+0xfc/0x26c
[c58577a0] [c0217354] ip_finish_output+0x2c0/0x300
[c58577c0] [c0213e0c] ip_forward_finish+0x48/0x64
[c58577d0] [c021263c] ip_rcv_finish+0x1a8/0x3b0
[c5857800] [c01d6a98] netif_receive_skb+0x2a4/0x530
[c5857840] [c01a0998] gfar_clean_rx_ring+0xe0/0x43c
[c5857890] [c01a1178] gfar_poll+0x484/0x598
[c5857930] [c01d7688] net_rx_action+0xf0/0x1b4
[c5857970] [c002651c] __do_softirq+0xb0/0x130
[c58579b0] [c0006294] do_softirq+0x58/0x5c
[c58579c0] [c0026310] irq_exit+0x7c/0x9c
[c58579d0] [c0006334] do_IRQ+0x9c/0xb4
[c58579f0] [c0011dd8] ret_from_except+0x0/0x14
--- Exception: 501 at sock_poll+0x20/0x38
    LR = do_select+0x2a8/0x4f0
[c5857ab0] [c009954c] poll_schedule_timeout+0x3c/0x60 (unreliable)
[c5857ac0] [c009a0bc] do_select+0x2a8/0x4f0
[c5857dc0] [c009a598] core_sys_select+0x294/0x388
[c5857f10] [c009a970] sys_select+0x40/0x138
[c5857f40] [c0011740] ret_from_syscall+0x0/0x38
--- Exception: c01 at 0xfe3864c
    LR = 0x10015860
Instruction dump:
480d6491 4bfffdc0 7fe3fb78 3bc00000 480122c1 4bfffc00 80db019c 3c60c032
7fe5fb78 7f64db78 3863f000 480d6465 <0fe00000> 4bfffeec 3c60c032 7f64db78

Both NICs continue to work but the messages continue to appear in the log
with the number (66) varying a little bit every now and then.

I had a look at the recent changes and started testing the different commits. I
found out that I start getting the errors with commmit

fba4ed030cfae7efdb6b79a57b0c5a9d72c9de83
gianfar: Add Multiple Queue Support

Relevant dmesg output:
eth0: Gianfar Ethernet Controller Version 1.2, 00:0c:42:28:de:4e
eth0: Running with NAPI enabled
eth0: :RX BD ring size for Q[0]: 256
eth0:TX BD ring size for Q[0]: 256
  alloc irq_desc for 32 on node 0
  alloc kstat_irqs on node 0
irq: irq 32 on host /soc8343@e0000000/pic@700 mapped to virtual irq 32
  alloc irq_desc for 33 on node 0
  alloc kstat_irqs on node 0
irq: irq 33 on host /soc8343@e0000000/pic@700 mapped to virtual irq 33
  alloc irq_desc for 34 on node 0[    0.546127]   alloc kstat_irqs on node 0
irq: irq 34 on host /soc8343@e0000000/pic@700 mapped to virtual irq 34
eth1: Gianfar Ethernet Controller Version 1.2, 00:0c:42:28:de:4f
eth1: Running with NAPI enabled
eth1: :RX BD ring size for Q[0]: 256
eth1:TX BD ring size for Q[0]: 256
Freescale PowerQUICC MII Bus: probed
Freescale PowerQUICC MII Bus: probed

If you need any more information please tell me.

Kind regards,
Michael
