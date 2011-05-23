From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: 2.6.38.x, 2.6.39 =?UTF-8?Q?sfq=3F=20kernel=20panic=20in=20sfq=5Fe?=  =?UTF-8?Q?nqueue?=
Date: Mon, 23 May 2011 13:01:46 +0300
Message-ID: <598fe111e91c6236b8bfdfca323b9a17@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>, <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rev-153-13.globalproof.net ([194.146.153.13]:43804 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751491Ab1EWKBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 06:01:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 It is not  mine, just helping to forward information to netdev.
 Arch Linux, x86_64, NAS for PPTP (with PPTP "acceleration" enabled)
 If any other info required, please let me know.

 Here is panic message

 [ 4461.966303] BUG: unable to handle kernel NULL pointer dereference at 
          (null)
 [ 4461.969603] IP: [<ffffffffa019fb90>] sfq_enqueue+0xe0/0x630 
 [sch_sfq]
 [ 4461.969603] PGD 1179a0067 PUD 1160fa067 PMD 0
 [ 4461.969603] Oops: 0002 [#1] PREEMPT SMP
 [ 4461.969603] last sysfs file: /sys/devices/virtual/net/ppp41/uevent
 [ 4461.969603] CPU 0
 [ 4461.969603] Modules linked in: act_police sch_ingress cls_u32 
 sch_sfq sch_htb xt_TCPMSS xt_tcpudp iptable_filter ip_tables x_tables 
 igb l2tp_ppp l2tp_netlink l2tp_core pptp pppox ppp_generic slhc gre 
 bonding i2c_i801 firewire_ohci psmouse uhci_hcd iTCO_wdt button evdev 
 firewire_core processor intel_agp intel_gtt i2c_core asus_atk0110 dca 
 iTCO_vendor_support ehci_hcd pcspkr serio_raw sg usbcore crc_itu_t ipv6 
 ext2 mbcache sd_mod ahci libahci pata_jmicron pata_acpi libata scsi_mod
 [ 4461.969603]
 [ 4461.969603] Pid: 0, comm: swapper Not tainted 2.6.39-ARCH #1 System 
 manufacturer System Product Name/P5QD TURBO
 [ 4461.969603] RIP: 0010:[<ffffffffa019fb90>]  [<ffffffffa019fb90>] 
 sfq_enqueue+0xe0/0x630 [sch_sfq]
 [ 4461.969603] RSP: 0018:ffff88011fc03940  EFLAGS: 00010206
 [ 4461.969603] RAX: ffff8801172a7d08 RBX: ffff8801172a7000 RCX: 
 ffff8801172a7100
 [ 4461.969603] RDX: 000000000000007b RSI: 0000000000000000 RDI: 
 ffff8801172a7d08
 [ 4461.969603] RBP: ffff88011fc03980 R08: ffff8801170e8ac0 R09: 
 0000000000000007
 [ 4461.969603] R10: 0000000000000001 R11: ffffc900110a1000 R12: 
 ffff8801172a7d08
 [ 4461.969603] R13: 0000000017cc394b R14: 00000000a54672c3 R15: 
 ffff880117f8109c
 [ 4461.969603] FS:  0000000000000000(0000) GS:ffff88011fc00000(0000) 
 knlGS:0000000000000000
 [ 4461.969603] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
 [ 4461.969603] CR2: 0000000000000000 CR3: 00000001171b2000 CR4: 
 00000000000406f0
 [ 4461.969603] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
 0000000000000000
 [ 4461.969603] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
 0000000000000400
 [ 4461.969603] Process swapper (pid: 0, threadinfo ffffffff81600000, 
 task ffffffff8169b020)
 [ 4461.969603] Stack:
 [ 4461.969603]  ffff88011fc039a0 ffff880117787d80 ffff88011fc03980 
 ffff880117f81000
 [ 4461.969603]  ffff880117b0f400 ffff8801172a7d08 ffff8801172a7000 
 ffff880117f8109c
 [ 4461.969603]  ffff88011fc039d0 ffffffffa0165080 ffff880114016f00 
 ffff880114016f00
 [ 4461.969603] Call Trace:
 [ 4461.969603]  <IRQ>
 [ 4461.969603]  [<ffffffffa0165080>] htb_enqueue+0xb0/0x3c0 [sch_htb]
 [ 4461.969603]  [<ffffffff8112f0d3>] ? 
 __kmalloc_node_track_caller+0x33/0x240
 [ 4461.969603]  [<ffffffff813127b3>] dev_queue_xmit+0x1d3/0x680
 [ 4461.969603]  [<ffffffff81345300>] ? ip_fragment+0x1d0/0x960
 [ 4461.969603]  [<ffffffff81344252>] ip_finish_output2+0x1e2/0x2c0
 [ 4461.969603]  [<ffffffff8134534e>] ip_fragment+0x21e/0x960
 [ 4461.969603]  [<ffffffff81344070>] ? ip_send_check+0x50/0x50
 [ 4461.969603]  [<ffffffff81345d8f>] ip_finish_output+0x27f/0x360
 [ 4461.969603]  [<ffffffff81342840>] ? ip_frag_mem+0x10/0x10
 [ 4461.969603]  [<ffffffff81346928>] ip_output+0xc8/0xe0
 [ 4461.969603]  [<ffffffff8134287f>] ip_forward_finish+0x3f/0x50
 [ 4461.969603]  [<ffffffff81342b25>] ip_forward+0x295/0x430
 [ 4461.969603]  [<ffffffff81340d61>] ip_rcv_finish+0x131/0x370
 [ 4461.969603]  [<ffffffff81303a1a>] ? __alloc_skb+0x4a/0x230
 [ 4461.969603]  [<ffffffff8134163e>] ip_rcv+0x21e/0x2f0
 [ 4461.969603]  [<ffffffff8130f80a>] __netif_receive_skb+0x30a/0x6c0
 [ 4461.969603]  [<ffffffff81011759>] ? read_tsc+0x9/0x20
 [ 4461.969603]  [<ffffffff813103bd>] netif_receive_skb+0xad/0xc0
 [ 4461.969603]  [<ffffffff8121867c>] ? is_swiotlb_buffer+0x3c/0x50
 [ 4461.969603]  [<ffffffff81310d08>] napi_skb_finish+0x48/0x60
 [ 4461.969603]  [<ffffffff81310dcd>] napi_gro_receive+0xad/0xc0
 [ 4461.969603]  [<ffffffffa01b79b7>] igb_poll+0x8c7/0xd60 [igb]
 [ 4461.969603]  [<ffffffff81310699>] net_rx_action+0x149/0x300
 [ 4461.969603]  [<ffffffff81011759>] ? read_tsc+0x9/0x20
 [ 4461.969603]  [<ffffffff8105ea78>] __do_softirq+0xa8/0x280
 [ 4461.969603]  [<ffffffff81089538>] ? 
 tick_dev_program_event+0x48/0x110
 [ 4461.969603]  [<ffffffff8108961a>] ? tick_program_event+0x1a/0x20
 [ 4461.969603]  [<ffffffff813cc51c>] call_softirq+0x1c/0x30
 [ 4461.969603]  [<ffffffff8100caf5>] do_softirq+0x65/0xa0
 [ 4461.969603]  [<ffffffff8105ef86>] irq_exit+0x96/0xb0
 [ 4461.969603]  [<ffffffff8102784b>] smp_apic_timer_interrupt+0x6b/0xa0
 [ 4461.969603]  [<ffffffff813cbcd3>] apic_timer_interrupt+0x13/0x20
 [ 4461.969603]  <EOI>
 [ 4461.969603]  [<ffffffff81012beb>] ? mwait_idle+0x9b/0x2d0
 [ 4461.969603]  [<ffffffff81009226>] cpu_idle+0xb6/0x100
 [ 4461.969603]  [<ffffffff813a903d>] rest_init+0x91/0xa4
 [ 4461.969603]  [<ffffffff81722c32>] start_kernel+0x3ed/0x3fa
 [ 4461.969603]  [<ffffffff81722347>] 
 x86_64_start_reservations+0x132/0x136
 [ 4461.969603]  [<ffffffff81722140>] ? early_idt_handlers+0x140/0x140
 [ 4461.969603]  [<ffffffff8172244d>] x86_64_start_kernel+0x102/0x111
 [ 4461.969603] Code: b6 70 10 3b b3 08 01 00 00 0f 8d df 01 00 00 41 8b 
 74 24 28 01 b3 b4 00 00 00 48 8b 70 08 49 89 04 24 49 89 74 24 08 48 8b 
 70 08 <4c> 89 26 0f b6 f2 4c 89 60 08 48 8d 3c 76 48 8d bc fb 90 01 00
 [ 4461.969603] RIP  [<ffffffffa019fb90>] sfq_enqueue+0xe0/0x630 
 [sch_sfq]
 [ 4461.969603]  RSP <ffff88011fc03940>
 [ 4461.969603] CR2: 0000000000000000
 [ 4463.351117] ---[ end trace f04e6b6edad2d731 ]---
 [ 4463.364930] Kernel panic - not syncing: Fatal exception in interrupt
 [ 4463.383963] Pid: 0, comm: swapper Tainted: G      D     2.6.39-ARCH 
 #1
 [ 4463.403515] Call Trace:
 [ 4463.410847]  <IRQ>  [<ffffffff813c16b9>] panic+0x9b/0x1a8
 [ 4463.427073]  [<ffffffff8100e322>] oops_end+0xe2/0xf0
 [ 4463.441944]  [<ffffffff813c117f>] no_context+0x204/0x213
 [ 4463.457857]  [<ffffffff81346928>] ? ip_output+0xc8/0xe0
 [ 4463.473509]  [<ffffffff813c1317>] __bad_area_nosemaphore+0x189/0x1ac
 [ 4463.492542]  [<ffffffffa01b4c4b>] ? 
 igb_xmit_frame_ring_adv+0x1fb/0xc30 [igb]
 [ 4463.513913]  [<ffffffff813c1348>] bad_area_nosemaphore+0xe/0x10
 [ 4463.531645]  [<ffffffff81036329>] do_page_fault+0x3c9/0x4b0
 [ 4463.548337]  [<ffffffff812068e4>] ? timerqueue_add+0x74/0xc0
 [ 4463.565291]  [<ffffffff8107c4d3>] ? enqueue_hrtimer+0x33/0xe0
 [ 4463.582503]  [<ffffffff8107d0fe>] ? 
 __hrtimer_start_range_ns+0x1be/0x520
 [ 4463.602576]  [<ffffffff810b95fd>] ? handle_edge_irq+0x7d/0x120
 [ 4463.620048]  [<ffffffff813cae85>] page_fault+0x25/0x30
 [ 4463.635438]  [<ffffffffa019fb90>] ? sfq_enqueue+0xe0/0x630 [sch_sfq]
 [ 4463.654471]  [<ffffffffa0165080>] htb_enqueue+0xb0/0x3c0 [sch_htb]
 [ 4463.672983]  [<ffffffff8112f0d3>] ? 
 __kmalloc_node_track_caller+0x33/0x240
 [ 4463.693576]  [<ffffffff813127b3>] dev_queue_xmit+0x1d3/0x680
 [ 4463.710528]  [<ffffffff81345300>] ? ip_fragment+0x1d0/0x960
 [ 4463.727221]  [<ffffffff81344252>] ip_finish_output2+0x1e2/0x2c0
 [ 4463.744953]  [<ffffffff8134534e>] ip_fragment+0x21e/0x960
 [ 4463.761124]  [<ffffffff81344070>] ? ip_send_check+0x50/0x50
 [ 4463.777817]  [<ffffffff81345d8f>] ip_finish_output+0x27f/0x360
 [ 4463.795289]  [<ffffffff81342840>] ? ip_frag_mem+0x10/0x10
 [ 4463.811462]  [<ffffffff81346928>] ip_output+0xc8/0xe0
 [ 4463.826592]  [<ffffffff8134287f>] ip_forward_finish+0x3f/0x50
 [ 4463.843806]  [<ffffffff81342b25>] ip_forward+0x295/0x430
 [ 4463.859719]  [<ffffffff81340d61>] ip_rcv_finish+0x131/0x370
 [ 4463.876411]  [<ffffffff81303a1a>] ? __alloc_skb+0x4a/0x230
 [ 4463.892842]  [<ffffffff8134163e>] ip_rcv+0x21e/0x2f0
 [ 4463.907714]  [<ffffffff8130f80a>] __netif_receive_skb+0x30a/0x6c0
 [ 4463.925966]  [<ffffffff81011759>] ? read_tsc+0x9/0x20
 [ 4463.941099]  [<ffffffff813103bd>] netif_receive_skb+0xad/0xc0
 [ 4463.958310]  [<ffffffff8121867c>] ? is_swiotlb_buffer+0x3c/0x50
 [ 4463.976044]  [<ffffffff81310d08>] napi_skb_finish+0x48/0x60
 [ 4463.992735]  [<ffffffff81310dcd>] napi_gro_receive+0xad/0xc0
 [ 4464.009688]  [<ffffffffa01b79b7>] igb_poll+0x8c7/0xd60 [igb]
 [ 4464.026639]  [<ffffffff81310699>] net_rx_action+0x149/0x300
 [ 4464.043333]  [<ffffffff81011759>] ? read_tsc+0x9/0x20
 [ 4464.058465]  [<ffffffff8105ea78>] __do_softirq+0xa8/0x280
 [ 4464.074636]  [<ffffffff81089538>] ? 
 tick_dev_program_event+0x48/0x110
 [ 4464.093928]  [<ffffffff8108961a>] ? tick_program_event+0x1a/0x20
 [ 4464.111920]  [<ffffffff813cc51c>] call_softirq+0x1c/0x30
 [ 4464.127833]  [<ffffffff8100caf5>] do_softirq+0x65/0xa0
 [ 4464.143225]  [<ffffffff8105ef86>] irq_exit+0x96/0xb0
 [ 4464.158098]  [<ffffffff8102784b>] smp_apic_timer_interrupt+0x6b/0xa0
 [ 4464.177130]  [<ffffffff813cbcd3>] apic_timer_interrupt+0x13/0x20
 [ 4464.195120]  <EOI>  [<ffffffff81012beb>] ? mwait_idle+0x9b/0x2d0
 [ 4464.213145]  [<ffffffff81009226>] cpu_idle+0xb6/0x100
 [ 4464.228274]  [<ffffffff813a903d>] rest_init+0x91/0xa4
 [ 4464.243404]  [<ffffffff81722c32>] start_kernel+0x3ed/0x3fa
 [ 4464.259837]  [<ffffffff81722347>] 
 x86_64_start_reservations+0x132/0x136
 [ 4464.279649]  [<ffffffff81722140>] ? early_idt_handlers+0x140/0x140
 [ 4464.298161]  [<ffffffff8172244d>] x86_64_start_kernel+0x102/0x111

 Here is shaper code

 #!/bin/sh
 #ABillS %DATE% %TIME%
 #
 # When the ppp link comes up, this script is called with the following
 # parameters
 #       $1      the interface name used by pppd (e.g. ppp3)
 #       $2      the tty device name
 #       $3      the tty device speed
 #       $4      the local IP address for the interface
 #       $5      the remote IP address
 #       $6      the parameter specified by the 'ipparam' option to pppd
 #

 AWK="/bin/awk"
 TC="/usr/sbin/tc"
 TCQA=$TC" qdisc add"
 TCCA=$TC" class add"
 TCFA=$TC" filter add"
 TCCR=$TC" class replace"
 TCFR=$TC" filter replace"
 OUTPUT=$1
 if [ "$OUTPUT" = "" ];
 then
   OUTPUT="$PPP_IFACE"
 fi

 if [ -f /var/run/radattr.$OUTPUT ]
 then
    $TC qdisc del dev $OUTPUT root >/dev/null 2>&1
    $TC qdisc del dev $OUTPUT ingress >/dev/null 2>&1
    DOWNSPEED=`$AWK  '/PPPD-Downstream-Speed-Limit/ {print $2}'  
 /var/run/radattr.$OUTPUT`
    UPSPEED=`$AWK  '/PPPD-Upstream-Speed-Limit/ {print $2}'  
 /var/run/radattr.$OUTPUT`
    [ w"$DOWNSPEED" = w ] && DOWNSPEED=0
    [ w"$UPSPEED" = w ] && UPSPEED=0
    FILTERS=`$AWK  '/Filter-Id/ {print $2}'  /var/run/radattr.$OUTPUT`
 
 ##### speed server->client
    if [ "$UPSPEED" != "0" ] ;
    then
       UBURST=$((DOWNSPEED/8))
       UBURSTS=$((DOWNSPEED*2))
       $TCQA dev $OUTPUT root handle 1: htb default 20 r2q 1
       $TCCA dev $OUTPUT parent 1: classid 1:1 htb rate 100mbit ceil 
 100mbit
       $TCCA dev $OUTPUT parent 1:1 classid 1:10 htb rate ${UPSPEED}kbit 
 ceil ${UBURSTS}kbit burst ${UBURST}k prio 1
       $TCCA dev $OUTPUT parent 1:1 classid 1:20 htb rate ${UPSPEED}kbit 
 ceil ${UBURSTS}kbit burst ${UBURST}k prio 2
       $TCCA dev $OUTPUT parent 1:1 classid 1:30 htb rate 100mbit ceil 
 100mbit prio 3
       $TCQA dev $OUTPUT parent 1:10 handle 10: sfq perturb 10 quantum 
 1400
       $TCQA dev $OUTPUT parent 1:20 handle 20: sfq perturb 10 quantum 
 1400
       $TCQA dev $OUTPUT parent 1:30 handle 30: sfq perturb 10 quantum 
 1400
       $TCFA dev $OUTPUT parent 1:0 protocol ip prio 5 u32 match ip tos 
 0x10 0xff flowid 1:30
       $TCFA dev $OUTPUT parent 1:0 protocol ip prio 10 u32 match ip tos 
 0x10 0xff flowid 1:10
       $TCFA dev $OUTPUT parent 1:0 protocol ip prio 10 u32 match ip 
 protocol 1 0xff flowid 1:10
       $TCFA dev $OUTPUT parent 1:  protocol ip prio 10 u32 match ip 
 protocol 6 0xff match u8 0x05 0x0f at 0 match u16 0x0000 0xffc0 at 2 
 match u8 0x10 0xff at 33 flowid 1:10
    fi

 ##### speed client->server
    if [ "$DOWNSPEED" != "0" ] ;
    then
       DBURST=$((UPSPEED/4))
       DBURSTS=$((UPSPEED*2))
       $TCQA dev $OUTPUT handle ffff: ingress
       $TCFA dev $OUTPUT parent ffff: protocol ip u32 match ip src 
 0.0.0.0/0 police rate ${DOWNSPEED}kbit burst ${DBURST}kb drop flowid :1
    fi

 #### Filters
 #  if [ w$FILTERS != w ] ;
 #  then
 #    echo "filters not supported"
 #  fi
 fi

