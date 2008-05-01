From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: WARNING: at net/ipv4/tcp_input.c
Date: Thu, 01 May 2008 10:01:49 +0100
Message-ID: <481986FD.8070108@andyfurniss.entadsl.com>
References: <4815BCDF.6070704@andyfurniss.entadsl.com> <Pine.LNX.4.64.0804281714090.1888@wrl-59.cs.helsinki.fi> <48162070.4030405@andyfurniss.entadsl.com> <Pine.LNX.4.64.0804282210390.16635@wrl-59.cs.helsinki.fi>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:47846 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753078AbYEAJB6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 May 2008 05:01:58 -0400
In-Reply-To: <Pine.LNX.4.64.0804282210390.16635@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Caught one -


May  1 03:35:45 noki kernel: 4l2_common ir_kbd_i2c ir_common tveeprom 
videobuf_dvb dvb_core videobuf_dma_sg videobuf_core nxt200x isl6421 
tda1004x firmware_class tda827x cls_flow sch_ingress xt_mark xt_length 
xt_MARK cls_u32 sch_sfq cls_fw sch_htb ipt_REJECT xt_state 
iptable_filter xt_TCPMSS xt_tcpmss xt_tcpudp iptable_mangle nf_nat_ftp 
nf_conntrack_ftp iptable_nat ip_tables nf_nat x_tables nf_conntrack_ipv4 
nf_conntrack bridge llc container fan thermal processor button tulip
May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #2
May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144] 
warn_on_slowpath+0x5f/0x90
May  1 03:35:45 noki kernel:  [tcp_transmit_skb+1149/1840] 
tcp_transmit_skb+0x47d/0x730
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [tcp_xmit_retransmit_queue+346/976] 
tcp_xmit_retransmit_queue+0x15a/0x3d0
May  1 03:35:45 noki kernel:  [tcp_ack+4069/7232] tcp_ack+0xfe5/0x1c40
May  1 03:35:45 noki kernel:  [tcp_rcv_established+990/1840] 
tcp_rcv_established+0x3de/0x730
May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] 
tcp_v4_do_rcv+0xb3/0x1d0
May  1 03:35:45 noki kernel:  [nf_iterate+96/144] nf_iterate+0x60/0x90
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [tcp_v4_rcv+1577/1776] tcp_v4_rcv+0x629/0x6f0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+148/416] 
ip_local_deliver_finish+0x94/0x1a0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [ip_rcv_finish+259/800] 
ip_rcv_finish+0x103/0x320
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [ip_rcv+410/608] ip_rcv+0x19a/0x260
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [netif_receive_skb+672/1104] 
netif_receive_skb+0x2a0/0x450
May  1 03:35:45 noki kernel:  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
May  1 03:35:45 noki kernel:  [<d4825ca8>] tulip_interrupt+0x568/0x840 
[tulip]
May  1 03:35:45 noki kernel:  [tick_program_event+54/112] 
tick_program_event+0x36/0x70
May  1 03:35:45 noki kernel:  [net_rx_action+147/336] 
net_rx_action+0x93/0x150
May  1 03:35:45 noki kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
May  1 03:35:45 noki kernel:  [do_softirq+38/48] do_softirq+0x26/0x30
May  1 03:35:45 noki kernel:  [do_IRQ+74/128] do_IRQ+0x4a/0x80
May  1 03:35:45 noki kernel:  [tick_notify+427/624] tick_notify+0x1ab/0x270
May  1 03:35:45 noki kernel:  [common_interrupt+35/40] 
common_interrupt+0x23/0x28
May  1 03:35:45 noki kernel:  [<d483cd05>] 
acpi_idle_enter_simple+0x153/0x1c6 [processor]
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+107/160] 
cpuidle_idle_call+0x6b/0xa0
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+0/160] 
cpuidle_idle_call+0x0/0xa0
May  1 03:35:45 noki kernel:  [cpu_idle+38/112] cpu_idle+0x26/0x70
May  1 03:35:45 noki kernel:  =======================
May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
May  1 03:35:45 noki kernel: P: 4 L: 1 vs 1 S: 3 vs 3 F: 4 vs 6 w: 
2200787703-2200792303 (7)
May  1 03:35:45 noki kernel: skb 0 cd7c8900
May  1 03:35:45 noki kernel: skb 1 d1b90760
May  1 03:35:45 noki kernel: skb 2 d1b69e60
May  1 03:35:45 noki kernel: skb 3 d1997080
May  1 03:35:45 noki kernel: head 4 d2dc91c0
May  1 03:35:45 noki kernel: skb 5 d2fb07a0
May  1 03:35:45 noki kernel: skb 6 d3b8cb60
May  1 03:35:45 noki kernel: skb 7 d1baca60
May  1 03:35:45 noki kernel: skb 8 d19ae380
May  1 03:35:45 noki kernel: skb 9 d1997ce0
May  1 03:35:45 noki kernel: skb 10 d2e084a0
May  1 03:35:45 noki kernel: skb 11 d19978c0
May  1 03:35:45 noki kernel: TCP wq(s) LSSS<
May  1 03:35:45 noki kernel: TCP wq(h) ++++<
May  1 03:35:45 noki kernel: l1 s3 f6 p4 seq: su2200787703 hs2200792303 
sn2200792303
May  1 03:35:45 noki kernel: ------------[ cut here ]------------
May  1 03:35:45 noki kernel: WARNING: at net/ipv4/tcp_ipv4.c:239 
tcp_verify_wq+0x35f/0x3b0()
May  1 03:35:45 noki kernel: Modules linked in: saa7134_dvb tda826x 
mt352 tda10086 dvb_pll tuner tea5767 tda8290 tuner_xc2028 tda9887 
tuner_simple mt20xx tea5761 saa7134 videodev v4l1_compat compat_ioctl32 
v4l2_common ir_kbd_i2c ir_common tveeprom videobuf_dvb dvb_core 
videobuf_dma_sg videobuf_core nxt200x isl6421 tda1004x firmware_class 
tda827x cls_flow sch_ingress xt_mark xt_length xt_MARK cls_u32 sch_sfq 
cls_fw sch_htb ipt_REJECT xt_state iptable_filter xt_TCPMSS xt_tcpmss 
xt_tcpudp iptable_mangle nf_nat_ftp nf_conntrack_ftp iptable_nat 
ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack bridge llc 
container fan thermal processor button tulip
May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #2
May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144] 
warn_on_slowpath+0x5f/0x90
May  1 03:35:45 noki kernel:  [atomic_notifier_call_chain+23/32] 
atomic_notifier_call_chain+0x17/0x20
May  1 03:35:45 noki kernel:  [printk+27/32] printk+0x1b/0x20
May  1 03:35:45 noki kernel:  [tcp_print_queue+535/592] 
tcp_print_queue+0x217/0x250
May  1 03:35:45 noki kernel:  [tcp_transmit_skb+1149/1840] 
tcp_transmit_skb+0x47d/0x730
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [tcp_xmit_retransmit_queue+467/976] 
tcp_xmit_retransmit_queue+0x1d3/0x3d0
May  1 03:35:45 noki kernel:  [tcp_ack+4069/7232] tcp_ack+0xfe5/0x1c40
May  1 03:35:45 noki kernel:  [tcp_rcv_established+990/1840] 
tcp_rcv_established+0x3de/0x730
May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] 
tcp_v4_do_rcv+0xb3/0x1d0
May  1 03:35:45 noki kernel:  [nf_iterate+96/144] nf_iterate+0x60/0x90
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [tcp_v4_rcv+1577/1776] tcp_v4_rcv+0x629/0x6f0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+148/416] 
ip_local_deliver_finish+0x94/0x1a0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [ip_rcv_finish+259/800] 
ip_rcv_finish+0x103/0x320
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [ip_rcv+410/608] ip_rcv+0x19a/0x260
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [netif_receive_skb+672/1104] 
netif_receive_skb+0x2a0/0x450
May  1 03:35:45 noki kernel:  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
May  1 03:35:45 noki kernel:  [<d4825ca8>] tulip_interrupt+0x568/0x840 
[tulip]
May  1 03:35:45 noki kernel:  [tick_program_event+54/112] 
tick_program_event+0x36/0x70
May  1 03:35:45 noki kernel:  [net_rx_action+147/336] 
net_rx_action+0x93/0x150
May  1 03:35:45 noki kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
May  1 03:35:45 noki kernel:  [do_softirq+38/48] do_softirq+0x26/0x30
May  1 03:35:45 noki kernel:  [do_IRQ+74/128] do_IRQ+0x4a/0x80
May  1 03:35:45 noki kernel:  [tick_notify+427/624] tick_notify+0x1ab/0x270
May  1 03:35:45 noki kernel:  [common_interrupt+35/40] 
common_interrupt+0x23/0x28
May  1 03:35:45 noki kernel:  [<d483cd05>] 
acpi_idle_enter_simple+0x153/0x1c6 [processor]
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+107/160] 
cpuidle_idle_call+0x6b/0xa0
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+0/160] 
cpuidle_idle_call+0x0/0xa0
May  1 03:35:45 noki kernel:  [cpu_idle+38/112] cpu_idle+0x26/0x70
May  1 03:35:45 noki kernel:  =======================
May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
May  1 03:35:45 noki kernel: ------------[ cut here ]------------
May  1 03:35:45 noki kernel: WARNING: at net/ipv4/tcp_output.c:2079 
tcp_ack+0xfe5/0x1c40()
May  1 03:35:45 noki kernel: Modules linked in: saa7134_dvb tda826x 
mt352 tda10086 dvb_pll tuner tea5767 tda8290 tuner_xc2028 tda9887 
tuner_simple mt20xx tea5761 saa7134 videodev v4l1_compat compat_ioctl32 
v4l2_common ir_kbd_i2c ir_common tveeprom videobuf_dvb dvb_core 
videobuf_dma_sg videobuf_core nxt200x isl6421 tda1004x firmware_class 
tda827x cls_flow sch_ingress xt_mark xt_length xt_MARK cls_u32 sch_sfq 
cls_fw sch_htb ipt_REJECT xt_state iptable_filter xt_TCPMSS xt_tcpmss 
xt_tcpudp iptable_mangle nf_nat_ftp nf_conntrack_ftp iptable_nat 
ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack bridge llc 
container fan thermal processor button tulip
May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #2
May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144] 
warn_on_slowpath+0x5f/0x90
May  1 03:35:45 noki kernel:  [tcp_transmit_skb+1149/1840] 
tcp_transmit_skb+0x47d/0x730
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [tcp_xmit_retransmit_queue+467/976] 
tcp_xmit_retransmit_queue+0x1d3/0x3d0
May  1 03:35:45 noki kernel:  [tcp_ack+4069/7232] tcp_ack+0xfe5/0x1c40
May  1 03:35:45 noki kernel:  [tcp_rcv_established+990/1840] 
tcp_rcv_established+0x3de/0x730
May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] 
tcp_v4_do_rcv+0xb3/0x1d0
May  1 03:35:45 noki kernel:  [nf_iterate+96/144] nf_iterate+0x60/0x90
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [tcp_v4_rcv+1577/1776] tcp_v4_rcv+0x629/0x6f0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+148/416] 
ip_local_deliver_finish+0x94/0x1a0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [ip_rcv_finish+259/800] 
ip_rcv_finish+0x103/0x320
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [ip_rcv+410/608] ip_rcv+0x19a/0x260
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [netif_receive_skb+672/1104] 
netif_receive_skb+0x2a0/0x450
May  1 03:35:45 noki kernel:  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
May  1 03:35:45 noki kernel:  [<d4825ca8>] tulip_interrupt+0x568/0x840 
[tulip]
May  1 03:35:45 noki kernel:  [tick_program_event+54/112] 
tick_program_event+0x36/0x70
May  1 03:35:45 noki kernel:  [net_rx_action+147/336] 
net_rx_action+0x93/0x150
May  1 03:35:45 noki kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
May  1 03:35:45 noki kernel:  [do_softirq+38/48] do_softirq+0x26/0x30
May  1 03:35:45 noki kernel:  [do_IRQ+74/128] do_IRQ+0x4a/0x80
May  1 03:35:45 noki kernel:  [tick_notify+427/624] tick_notify+0x1ab/0x270
May  1 03:35:45 noki kernel:  [common_interrupt+35/40] 
common_interrupt+0x23/0x28
May  1 03:35:45 noki kernel:  [<d483cd05>] 
acpi_idle_enter_simple+0x153/0x1c6 [processor]
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+107/160] 
cpuidle_idle_call+0x6b/0xa0
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+0/160] 
cpuidle_idle_call+0x0/0xa0
May  1 03:35:45 noki kernel:  [cpu_idle+38/112] cpu_idle+0x26/0x70
May  1 03:35:45 noki kernel:  =======================
May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
May  1 03:35:45 noki kernel: P: 4 L: 1 vs 1 S: 3 vs 3 F: 4 vs 6 w: 
2200787703-2200792303 (7)
May  1 03:35:45 noki kernel: skb 0 cd7c8900
May  1 03:35:45 noki kernel: skb 1 d1b90760
May  1 03:35:45 noki kernel: skb 2 d1b69e60
May  1 03:35:45 noki kernel: skb 3 d1997080
May  1 03:35:45 noki kernel: head 4 d2dc91c0
May  1 03:35:45 noki kernel: skb 5 d2fb07a0
May  1 03:35:45 noki kernel: skb 6 d3b8cb60
May  1 03:35:45 noki kernel: skb 7 d1baca60
May  1 03:35:45 noki kernel: skb 8 d19ae380
May  1 03:35:45 noki kernel: skb 9 d1997ce0
May  1 03:35:45 noki kernel: skb 10 d2e084a0
May  1 03:35:45 noki kernel: skb 11 d19978c0
May  1 03:35:45 noki kernel: TCP wq(s) LSSS<
May  1 03:35:45 noki kernel: TCP wq(h) ++++<
May  1 03:35:45 noki kernel: l1 s3 f6 p4 seq: su2200787703 hs2200792303 
sn2200792303
May  1 03:35:45 noki kernel: ------------[ cut here ]------------
May  1 03:35:45 noki kernel: WARNING: at net/ipv4/tcp_ipv4.c:239 
tcp_verify_wq+0x35f/0x3b0()
May  1 03:35:45 noki kernel: Modules linked in: saa7134_dvb tda826x 
mt352 tda10086 dvb_pll tuner tea5767 tda8290 tuner_xc2028 tda9887 
tuner_simple mt20xx tea5761 saa7134 videodev v4l1_compat compat_ioctl32 
v4l2_common ir_kbd_i2c ir_common tveeprom videobuf_dvb dvb_core 
videobuf_dma_sg videobuf_core nxt200x isl6421 tda1004x firmware_class 
tda827x cls_flow sch_ingress xt_mark xt_length xt_MARK cls_u32 sch_sfq 
cls_fw sch_htb ipt_REJECT xt_state iptable_filter xt_TCPMSS xt_tcpmss 
xt_tcpudp iptable_mangle nf_nat_ftp nf_conntrack_ftp iptable_nat 
ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack bridge llc 
container fan thermal processor button tulip
May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #2
May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144] 
warn_on_slowpath+0x5f/0x90
May  1 03:35:45 noki kernel:  [atomic_notifier_call_chain+23/32] 
atomic_notifier_call_chain+0x17/0x20
May  1 03:35:45 noki kernel:  [printk+27/32] printk+0x1b/0x20
May  1 03:35:45 noki kernel:  [tcp_print_queue+535/592] 
tcp_print_queue+0x217/0x250
May  1 03:35:45 noki kernel:  [tcp_transmit_skb+1149/1840] 
tcp_transmit_skb+0x47d/0x730
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [tcp_ack+3266/7232] tcp_ack+0xcc2/0x1c40
May  1 03:35:45 noki kernel:  [tcp_rcv_established+990/1840] 
tcp_rcv_established+0x3de/0x730
May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] 
tcp_v4_do_rcv+0xb3/0x1d0
May  1 03:35:45 noki kernel:  [nf_iterate+96/144] nf_iterate+0x60/0x90
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [tcp_v4_rcv+1577/1776] tcp_v4_rcv+0x629/0x6f0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+148/416] 
ip_local_deliver_finish+0x94/0x1a0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [ip_rcv_finish+259/800] 
ip_rcv_finish+0x103/0x320
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [ip_rcv+410/608] ip_rcv+0x19a/0x260
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [netif_receive_skb+672/1104] 
netif_receive_skb+0x2a0/0x450
May  1 03:35:45 noki kernel:  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
May  1 03:35:45 noki kernel:  [<d4825ca8>] tulip_interrupt+0x568/0x840 
[tulip]
May  1 03:35:45 noki kernel:  [tick_program_event+54/112] 
tick_program_event+0x36/0x70
May  1 03:35:45 noki kernel:  [net_rx_action+147/336] 
net_rx_action+0x93/0x150
May  1 03:35:45 noki kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
May  1 03:35:45 noki kernel:  [do_softirq+38/48] do_softirq+0x26/0x30
May  1 03:35:45 noki kernel:  [do_IRQ+74/128] do_IRQ+0x4a/0x80
May  1 03:35:45 noki kernel:  [tick_notify+427/624] tick_notify+0x1ab/0x270
May  1 03:35:45 noki kernel:  [common_interrupt+35/40] 
common_interrupt+0x23/0x28
May  1 03:35:45 noki kernel:  [<d483cd05>] 
acpi_idle_enter_simple+0x153/0x1c6 [processor]
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+107/160] 
cpuidle_idle_call+0x6b/0xa0
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+0/160] 
cpuidle_idle_call+0x0/0xa0
May  1 03:35:45 noki kernel:  [cpu_idle+38/112] cpu_idle+0x26/0x70
May  1 03:35:45 noki kernel:  =======================
May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
May  1 03:35:45 noki kernel: ------------[ cut here ]------------
May  1 03:35:45 noki kernel: WARNING: at net/ipv4/tcp_input.c:3303 
tcp_ack+0xcef/0x1c40()
May  1 03:35:45 noki kernel: Modules linked in: saa7134_dvb tda826x 
mt352 tda10086 dvb_pll tuner tea5767 tda8290 tuner_xc2028 tda9887 
tuner_simple mt20xx tea5761 saa7134 videodev v4l1_compat compat_ioctl32 
v4l2_common ir_kbd_i2c ir_common tveeprom videobuf_dvb dvb_core 
videobuf_dma_sg videobuf_core nxt200x isl6421 tda1004x firmware_class 
tda827x cls_flow sch_ingress xt_mark xt_length xt_MARK cls_u32 sch_sfq 
cls_fw sch_htb ipt_REJECT xt_state iptable_filter xt_TCPMSS xt_tcpmss 
xt_tcpudp iptable_mangle nf_nat_ftp nf_conntrack_ftp iptable_nat 
ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack bridge llc 
container fan thermal processor button tulip
May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #2
May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144] 
warn_on_slowpath+0x5f/0x90
May  1 03:35:45 noki kernel:  [tcp_transmit_skb+1149/1840] 
tcp_transmit_skb+0x47d/0x730
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [tcp_ack+3311/7232] tcp_ack+0xcef/0x1c40
May  1 03:35:45 noki kernel:  [tcp_rcv_established+990/1840] 
tcp_rcv_established+0x3de/0x730
May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] 
tcp_v4_do_rcv+0xb3/0x1d0
May  1 03:35:45 noki kernel:  [nf_iterate+96/144] nf_iterate+0x60/0x90
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [tcp_v4_rcv+1577/1776] tcp_v4_rcv+0x629/0x6f0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+148/416] 
ip_local_deliver_finish+0x94/0x1a0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [ip_rcv_finish+259/800] 
ip_rcv_finish+0x103/0x320
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [ip_rcv+410/608] ip_rcv+0x19a/0x260
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [netif_receive_skb+672/1104] 
netif_receive_skb+0x2a0/0x450
May  1 03:35:45 noki kernel:  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
May  1 03:35:45 noki kernel:  [<d4825ca8>] tulip_interrupt+0x568/0x840 
[tulip]
May  1 03:35:45 noki kernel:  [tick_program_event+54/112] 
tick_program_event+0x36/0x70
May  1 03:35:45 noki kernel:  [net_rx_action+147/336] 
net_rx_action+0x93/0x150
May  1 03:35:45 noki kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
May  1 03:35:45 noki kernel:  [do_softirq+38/48] do_softirq+0x26/0x30
May  1 03:35:45 noki kernel:  [do_IRQ+74/128] do_IRQ+0x4a/0x80
May  1 03:35:45 noki kernel:  [tick_notify+427/624] tick_notify+0x1ab/0x270
May  1 03:35:45 noki kernel:  [common_interrupt+35/40] 
common_interrupt+0x23/0x28
May  1 03:35:45 noki kernel:  [<d483cd05>] 
acpi_idle_enter_simple+0x153/0x1c6 [processor]
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+107/160] 
cpuidle_idle_call+0x6b/0xa0
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+0/160] 
cpuidle_idle_call+0x0/0xa0
May  1 03:35:45 noki kernel:  [cpu_idle+38/112] cpu_idle+0x26/0x70
May  1 03:35:45 noki kernel:  =======================
May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
May  1 03:35:45 noki kernel: P: 4 L: 1 vs 1 S: 3 vs 3 F: 4 vs 6 w: 
2200787703-2200792303 (7)
May  1 03:35:45 noki kernel: skb 0 cd7c8900
May  1 03:35:45 noki kernel: skb 1 d1b90760
May  1 03:35:45 noki kernel: skb 2 d1b69e60
May  1 03:35:45 noki kernel: skb 3 d1997080
May  1 03:35:45 noki kernel: head 4 d2dc91c0
May  1 03:35:45 noki kernel: skb 5 d2fb07a0
May  1 03:35:45 noki kernel: skb 6 d3b8cb60
May  1 03:35:45 noki kernel: skb 7 d1baca60
May  1 03:35:45 noki kernel: skb 8 d19ae380
May  1 03:35:45 noki kernel: skb 9 d1997ce0
May  1 03:35:45 noki kernel: skb 10 d2e084a0
May  1 03:35:45 noki kernel: skb 11 d19978c0
May  1 03:35:45 noki kernel: TCP wq(s) LSSS<
May  1 03:35:45 noki kernel: TCP wq(h) ++++<
May  1 03:35:45 noki kernel: l1 s3 f6 p4 seq: su2200787703 hs2200792303 
sn2200792303
May  1 03:35:45 noki kernel: ------------[ cut here ]------------
May  1 03:35:45 noki kernel: WARNING: at net/ipv4/tcp_ipv4.c:239 
tcp_verify_wq+0x35f/0x3b0()
May  1 03:35:45 noki kernel: Modules linked in: saa7134_dvb tda826x 
mt352 tda10086 dvb_pll tuner tea5767 tda8290 tuner_xc2028 tda9887 
tuner_simple mt20xx tea5761 saa7134 videodev v4l1_compat compat_ioctl32 
v4l2_common ir_kbd_i2c ir_common tveeprom videobuf_dvb dvb_core 
videobuf_dma_sg videobuf_core nxt200x isl6421 tda1004x firmware_class 
tda827x cls_flow sch_ingress xt_mark xt_length xt_MARK cls_u32 sch_sfq 
cls_fw sch_htb ipt_REJECT xt_state iptable_filter xt_TCPMSS xt_tcpmss 
xt_tcpudp iptable_mangle nf_nat_ftp nf_conntrack_ftp iptable_nat 
ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack bridge llc 
container fan thermal processor button tulip
May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #2
May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144] 
warn_on_slowpath+0x5f/0x90
May  1 03:35:45 noki kernel:  [atomic_notifier_call_chain+23/32] 
atomic_notifier_call_chain+0x17/0x20
May  1 03:35:45 noki kernel:  [printk+27/32] printk+0x1b/0x20
May  1 03:35:45 noki kernel:  [tcp_print_queue+535/592] 
tcp_print_queue+0x217/0x250
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [__tcp_push_pending_frames+80/2048] 
__tcp_push_pending_frames+0x50/0x800
May  1 03:35:45 noki kernel:  [tcp_rcv_established+646/1840] 
tcp_rcv_established+0x286/0x730
May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] 
tcp_v4_do_rcv+0xb3/0x1d0
May  1 03:35:45 noki kernel:  [nf_iterate+96/144] nf_iterate+0x60/0x90
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [tcp_v4_rcv+1577/1776] tcp_v4_rcv+0x629/0x6f0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+148/416] 
ip_local_deliver_finish+0x94/0x1a0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [ip_rcv_finish+259/800] 
ip_rcv_finish+0x103/0x320
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [ip_rcv+410/608] ip_rcv+0x19a/0x260
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [netif_receive_skb+672/1104] 
netif_receive_skb+0x2a0/0x450
May  1 03:35:45 noki kernel:  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
May  1 03:35:45 noki kernel:  [<d4825ca8>] tulip_interrupt+0x568/0x840 
[tulip]
May  1 03:35:45 noki kernel:  [tick_program_event+54/112] 
tick_program_event+0x36/0x70
May  1 03:35:45 noki kernel:  [net_rx_action+147/336] 
net_rx_action+0x93/0x150
May  1 03:35:45 noki kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
May  1 03:35:45 noki kernel:  [do_softirq+38/48] do_softirq+0x26/0x30
May  1 03:35:45 noki kernel:  [do_IRQ+74/128] do_IRQ+0x4a/0x80
May  1 03:35:45 noki kernel:  [tick_notify+427/624] tick_notify+0x1ab/0x270
May  1 03:35:45 noki kernel:  [common_interrupt+35/40] 
common_interrupt+0x23/0x28
May  1 03:35:45 noki kernel:  [<d483cd05>] 
acpi_idle_enter_simple+0x153/0x1c6 [processor]
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+107/160] 
cpuidle_idle_call+0x6b/0xa0
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+0/160] 
cpuidle_idle_call+0x0/0xa0
May  1 03:35:45 noki kernel:  [cpu_idle+38/112] cpu_idle+0x26/0x70
May  1 03:35:45 noki kernel:  =======================
May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
May  1 03:35:45 noki kernel: ------------[ cut here ]------------
May  1 03:35:45 noki kernel: WARNING: at net/ipv4/tcp_output.c:1475 
__tcp_push_pending_frames+0x67/0x800()
May  1 03:35:45 noki kernel: Modules linked in: saa7134_dvb tda826x 
mt352 tda10086 dvb_pll tuner tea5767 tda8290 tuner_xc2028 tda9887 
tuner_simple mt20xx tea5761 saa7134 videodev v4l1_compat compat_ioctl32 
v4l2_common ir_kbd_i2c ir_common tveeprom videobuf_dvb dvb_core 
videobuf_dma_sg videobuf_core nxt200x isl6421 tda1004x firmware_class 
tda827x cls_flow sch_ingress xt_mark xt_length xt_MARK cls_u32 sch_sfq 
cls_fw sch_htb ipt_REJECT xt_state iptable_filter xt_TCPMSS xt_tcpmss 
xt_tcpudp iptable_mangle nf_nat_ftp nf_conntrack_ftp iptable_nat 
ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack bridge llc 
container fan thermal processor button tulip
May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #2
May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144] 
warn_on_slowpath+0x5f/0x90
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [__tcp_push_pending_frames+103/2048] 
__tcp_push_pending_frames+0x67/0x800
May  1 03:35:45 noki kernel:  [tcp_rcv_established+646/1840] 
tcp_rcv_established+0x286/0x730
May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] 
tcp_v4_do_rcv+0xb3/0x1d0
May  1 03:35:45 noki kernel:  [nf_iterate+96/144] nf_iterate+0x60/0x90
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [tcp_v4_rcv+1577/1776] tcp_v4_rcv+0x629/0x6f0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+148/416] 
ip_local_deliver_finish+0x94/0x1a0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [ip_rcv_finish+259/800] 
ip_rcv_finish+0x103/0x320
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [ip_rcv+410/608] ip_rcv+0x19a/0x260
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [netif_receive_skb+672/1104] 
netif_receive_skb+0x2a0/0x450
May  1 03:35:45 noki kernel:  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
May  1 03:35:45 noki kernel:  [<d4825ca8>] tulip_interrupt+0x568/0x840 
[tulip]
May  1 03:35:45 noki kernel:  [tick_program_event+54/112] 
tick_program_event+0x36/0x70
May  1 03:35:45 noki kernel:  [net_rx_action+147/336] 
net_rx_action+0x93/0x150
May  1 03:35:45 noki kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
May  1 03:35:45 noki kernel:  [do_softirq+38/48] do_softirq+0x26/0x30
May  1 03:35:45 noki kernel:  [do_IRQ+74/128] do_IRQ+0x4a/0x80
May  1 03:35:45 noki kernel:  [tick_notify+427/624] tick_notify+0x1ab/0x270
May  1 03:35:45 noki kernel:  [common_interrupt+35/40] 
common_interrupt+0x23/0x28
May  1 03:35:45 noki kernel:  [<d483cd05>] 
acpi_idle_enter_simple+0x153/0x1c6 [processor]
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+107/160] 
cpuidle_idle_call+0x6b/0xa0
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+0/160] 
cpuidle_idle_call+0x0/0xa0
May  1 03:35:45 noki kernel:  [cpu_idle+38/112] cpu_idle+0x26/0x70
May  1 03:35:45 noki kernel:  =======================
May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
May  1 03:35:45 noki kernel: 4> [ip_finish_output+316/688] 
ip_finish_output+0x13c/0x2b0
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [tcp_ack+179/7232] tcp_ack+0xb3/0x1c40
May  1 03:35:45 noki kernel:  [<d48876c5>] tcp_error+0x95/0x1d0 
[nf_conntrack]
May  1 03:35:45 noki kernel:  [tcp_init_tso_segs+50/80] 
tcp_init_tso_segs+0x32/0x50
May  1 03:35:45 noki kernel:  [ip_route_input+67/3344] 
ip_route_input+0x43/0xd10
May  1 03:35:45 noki kernel:  [<d481d566>] ipt_do_table+0x226/0x4a0 
[ip_tables]
May  1 03:35:45 noki kernel:  [tcp_rcv_established+899/1840] 
tcp_rcv_established+0x383/0x730
May  1 03:35:45 noki kernel:  [atomic_notifier_call_chain+23/32] 
atomic_notifier_call_chain+0x17/0x20
May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] 
tcp_v4_do_rcv+0xb3/0x1d0
May  1 03:35:45 noki kernel:  [nf_iterate+96/144] nf_iterate+0x60/0x90
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [tcp_v4_rcv+1577/1776] tcp_v4_rcv+0x629/0x6f0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+148/416] 
ip_local_deliver_finish+0x94/0x1a0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [ip_rcv_finish+259/800] 
ip_rcv_finish+0x103/0x320
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [ip_rcv+410/608] ip_rcv+0x19a/0x260
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [netif_receive_skb+672/1104] 
netif_receive_skb+0x2a0/0x450
May  1 03:35:45 noki kernel:  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
May  1 03:35:45 noki kernel:  [<d4825ca8>] tulip_interrupt+0x568/0x840 
[tulip]
May  1 03:35:45 noki kernel:  [tick_program_event+54/112] 
tick_program_event+0x36/0x70
May  1 03:35:45 noki kernel:  [net_rx_action+147/336] 
net_rx_action+0x93/0x150
May  1 03:35:45 noki kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
May  1 03:35:45 noki kernel:  [do_softirq+38/48] do_softirq+0x26/0x30
May  1 03:35:45 noki kernel:  [do_IRQ+74/128] do_IRQ+0x4a/0x80
May  1 03:35:45 noki kernel:  [tick_notify+427/624] tick_notify+0x1ab/0x270
May  1 03:35:45 noki kernel:  [common_interrupt+35/40] 
common_interrupt+0x23/0x28
May  1 03:35:45 noki kernel:  [<d483cd05>] 
acpi_idle_enter_simple+0x153/0x1c6 [processor]
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+107/160] 
cpuidle_idle_call+0x6b/0xa0
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+0/160] 
cpuidle_idle_call+0x0/0xa0
May  1 03:35:45 noki kernel:  [cpu_idle+38/112] cpu_idle+0x26/0x70
May  1 03:35:45 noki kernel:  =======================
May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
May  1 03:35:45 noki kernel: ------------[ cut here ]------------
May  1 03:35:45 noki kernel: WARNING: at net/ipv4/tcp_input.c:3236 
tcp_ack+0xca/0x1c40()
May  1 03:35:45 noki kernel: Modules linked in: saa7134_dvb tda826x 
mt352 tda10086 dvb_pll tuner tea5767 tda8290 tuner_xc2028 tda9887 
tuner_simple mt20xx tea5761 saa7134 videodev v4l1_compat compat_ioctl32 
v4l2_common ir_kbd_i2c ir_common tveeprom videobuf_dvb dvb_core 
videobuf_dma_sg videobuf_core nxt200x isl6421 tda1004x firmware_class 
tda827x cls_flow sch_ingress xt_mark xt_length xt_MARK cls_u32 sch_sfq 
cls_fw sch_htb ipt_REJECT xt_state iptable_filter xt_TCPMSS xt_tcpmss 
xt_tcpudp iptable_mangle nf_nat_ftp nf_conntrack_ftp iptable_nat 
ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack bridge llc 
container fan thermal processor button tulip
May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #2
May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144] 
warn_on_slowpath+0x5f/0x90
May  1 03:35:45 noki kernel:  [dev_queue_xmit+150/640] 
dev_queue_xmit+0x96/0x280
May  1 03:35:45 noki kernel:  [ip_finish_output+0/688] 
ip_finish_output+0x0/0x2b0
May  1 03:35:45 noki kernel:  [ip_finish_output+316/688] 
ip_finish_output+0x13c/0x2b0
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [tcp_ack+202/7232] tcp_ack+0xca/0x1c40
May  1 03:35:45 noki kernel:  [<d48876c5>] tcp_error+0x95/0x1d0 
[nf_conntrack]
May  1 03:35:45 noki kernel:  [tcp_init_tso_segs+50/80] 
tcp_init_tso_segs+0x32/0x50
May  1 03:35:45 noki kernel:  [ip_route_input+67/3344] 
ip_route_input+0x43/0xd10
May  1 03:35:45 noki kernel:  [<d481d566>] ipt_do_table+0x226/0x4a0 
[ip_tables]
May  1 03:35:45 noki kernel:  [tcp_rcv_established+899/1840] 
tcp_rcv_established+0x383/0x730
May  1 03:35:45 noki kernel:  [atomic_notifier_call_chain+23/32] 
atomic_notifier_call_chain+0x17/0x20
May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] 
tcp_v4_do_rcv+0xb3/0x1d0
May  1 03:35:45 noki kernel:  [nf_iterate+96/144] nf_iterate+0x60/0x90
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [tcp_v4_rcv+1577/1776] tcp_v4_rcv+0x629/0x6f0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+148/416] 
ip_local_deliver_finish+0x94/0x1a0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [ip_rcv_finish+259/800] 
ip_rcv_finish+0x103/0x320
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [ip_rcv+410/608] ip_rcv+0x19a/0x260
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [netif_receive_skb+672/1104] 
netif_receive_skb+0x2a0/0x450
May  1 03:35:45 noki kernel:  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
May  1 03:35:45 noki kernel:  [<d4825ca8>] tulip_interrupt+0x568/0x840 
[tulip]
May  1 03:35:45 noki kernel:  [tick_program_event+54/112] 
tick_program_event+0x36/0x70
May  1 03:35:45 noki kernel:  [net_rx_action+147/336] 
net_rx_action+0x93/0x150
May  1 03:35:45 noki kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
May  1 03:35:45 noki kernel:  [do_softirq+38/48] do_softirq+0x26/0x30
May  1 03:35:45 noki kernel:  [do_IRQ+74/128] do_IRQ+0x4a/0x80
May  1 03:35:45 noki kernel:  [tick_notify+427/624] tick_notify+0x1ab/0x270
May  1 03:35:45 noki kernel:  [common_interrupt+35/40] 
common_interrupt+0x23/0x28
May  1 03:35:45 noki kernel:  [<d483cd05>] 
acpi_idle_enter_simple+0x153/0x1c6 [processor]
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+107/160] 
cpuidle_idle_call+0x6b/0xa0
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+0/160] 
cpuidle_idle_call+0x0/0xa0
May  1 03:35:45 noki kernel:  [cpu_idle+38/112] cpu_idle+0x26/0x70
May  1 03:35:45 noki kernel:  =======================
May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
May  1 03:35:45 noki kernel: P: 0 L: 0 vs 0 S: 0 vs 0 F: 0 vs 2 w: 
2200792303-2200792303 (7)
May  1 03:35:45 noki kernel: head 0 d2dc91c0
May  1 03:35:45 noki kernel: skb 1 d2fb07a0
May  1 03:35:45 noki kernel: skb 2 d3b8cb60
May  1 03:35:45 noki kernel: skb 3 d1baca60
May  1 03:35:45 noki kernel: skb 4 d19ae380
May  1 03:35:45 noki kernel: skb 5 d1997ce0
May  1 03:35:45 noki kernel: skb 6 d2e084a0
May  1 03:35:45 noki kernel: skb 7 d19978c0
May  1 03:35:45 noki kernel: l0 s0 f2 p0 seq: su2200792303 hs2200792303 
sn2200792303
May  1 03:35:45 noki kernel: ------------[ cut here ]------------
May  1 03:35:45 noki kernel: WARNING: at net/ipv4/tcp_ipv4.c:239 
tcp_verify_wq+0x35f/0x3b0()
May  1 03:35:45 noki kernel: Modules linked in: saa7134_dvb tda826x 
mt352 tda10086 dvb_pll tuner tea5767 tda8290 tuner_xc2028 tda9887 
tuner_simple mt20xx tea5761 saa7134 videodev v4l1_compat compat_ioctl32 
v4l2_common ir_kbd_i2c ir_common tveeprom videobuf_dvb dvb_core 
videobuf_dma_sg videobuf_core nxt200x isl6421 tda1004x firmware_class 
tda827x cls_flow sch_ingress xt_mark xt_length xt_MARK cls_u32 sch_sfq 
cls_fw sch_htb ipt_REJECT xt_state iptable_filter xt_TCPMSS xt_tcpmss 
xt_tcpudp iptable_mangle nf_nat_ftp nf_conntrack_ftp iptable_nat 
ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack bridge llc 
container fan thermal processor button tulip
May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #2
May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144] 
warn_on_slowpath+0x5f/0x90
May  1 03:35:45 noki kernel:  [atomic_notifier_call_chain+23/32] 
atomic_notifier_call_chain+0x17/0x20
May  1 03:35:45 noki kernel:  [printk+27/32] printk+0x1b/0x20
May  1 03:35:45 noki kernel:  [tcp_print_queue+535/592] 
tcp_print_queue+0x217/0x250
May  1 03:35:45 noki kernel:  [dev_queue_xmit+150/640] 
dev_queue_xmit+0x96/0x280
May  1 03:35:45 noki kernel:  [ip_finish_output+0/688] 
ip_finish_output+0x0/0x2b0
May  1 03:35:45 noki kernel:  [ip_finish_output+316/688] 
ip_finish_output+0x13c/0x2b0
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [bictcp_acked+0/48] bictcp_acked+0x0/0x30
May  1 03:35:45 noki kernel:  [tcp_ack+1987/7232] tcp_ack+0x7c3/0x1c40
May  1 03:35:45 noki kernel:  [<d481d566>] ipt_do_table+0x226/0x4a0 
[ip_tables]
May  1 03:35:45 noki kernel:  [tcp_rcv_established+899/1840] 
tcp_rcv_established+0x383/0x730
May  1 03:35:45 noki kernel:  [atomic_notifier_call_chain+23/32] 
atomic_notifier_call_chain+0x17/0x20
May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] 
tcp_v4_do_rcv+0xb3/0x1d0
May  1 03:35:45 noki kernel:  [nf_iterate+96/144] nf_iterate+0x60/0x90
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [tcp_v4_rcv+1577/1776] tcp_v4_rcv+0x629/0x6f0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+148/416] 
ip_local_deliver_finish+0x94/0x1a0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [ip_rcv_finish+259/800] 
ip_rcv_finish+0x103/0x320
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [ip_rcv+410/608] ip_rcv+0x19a/0x260
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [netif_receive_skb+672/1104] 
netif_receive_skb+0x2a0/0x450
May  1 03:35:45 noki kernel:  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
May  1 03:35:45 noki kernel:  [<d4825ca8>] tulip_interrupt+0x568/0x840 
[tulip]
May  1 03:35:45 noki kernel:  [tick_program_event+54/112] 
tick_program_event+0x36/0x70
May  1 03:35:45 noki kernel:  [net_rx_action+147/336] 
net_rx_action+0x93/0x150
May  1 03:35:45 noki kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
May  1 03:35:45 noki kernel:  [do_softirq+38/48] do_softirq+0x26/0x30
May  1 03:35:45 noki kernel:  [do_IRQ+74/128] do_IRQ+0x4a/0x80
May  1 03:35:45 noki kernel:  [tick_notify+427/624] tick_notify+0x1ab/0x270
May  1 03:35:45 noki kernel:  [common_interrupt+35/40] 
common_interrupt+0x23/0x28
May  1 03:35:45 noki kernel:  [<d483cd05>] 
acpi_idle_enter_simple+0x153/0x1c6 [processor]
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+107/160] 
cpuidle_idle_call+0x6b/0xa0
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+0/160] 
cpuidle_idle_call+0x0/0xa0
May  1 03:35:45 noki kernel:  [cpu_idle+38/112] cpu_idle+0x26/0x70
May  1 03:35:45 noki kernel:  =======================
May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
May  1 03:35:45 noki kernel: ------------[ cut here ]------------
May  1 03:35:45 noki kernel: WARNING: at net/ipv4/tcp_input.c:2946 
tcp_ack+0x7ec/0x1c40()
May  1 03:35:45 noki kernel: Modules linked in: saa7134_dvb tda826x 
mt352 tda10086 dvb_pll tuner tea5767 tda8290 tuner_xc2028 tda9887 
tuner_simple mt20xx tea5761 saa7134 videodev v4l1_compat compat_ioctl32 
v4l2_common ir_kbd_i2c ir_common tveeprom videobuf_dvb dvb_core 
videobuf_dma_sg videobuf_core nxt200x isl6421 tda1004x firmware_class 
tda827x cls_flow sch_ingress xt_mark xt_length xt_MARK cls_u32 sch_sfq 
cls_fw sch_htb ipt_REJECT xt_state iptable_filter xt_TCPMSS xt_tcpmss 
xt_tcpudp iptable_mangle nf_nat_ftp nf_conntrack_ftp iptable_nat 
ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack bridge llc 
container fan thermal processor button tulip
May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #2
May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144] 
warn_on_slowpath+0x5f/0x90
May  1 03:35:45 noki kernel:  [dev_queue_xmit+150/640] 
dev_queue_xmit+0x96/0x280
May  1 03:35:45 noki kernel:  [ip_finish_output+0/688] 
ip_finish_output+0x0/0x2b0
May  1 03:35:45 noki kernel:  [ip_finish_output+316/688] 
ip_finish_output+0x13c/0x2b0
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [bictcp_acked+0/48] bictcp_acked+0x0/0x30
May  1 03:35:45 noki kernel:  [tcp_ack+2028/7232] tcp_ack+0x7ec/0x1c40
May  1 03:35:45 noki kernel:  [<d481d566>] ipt_do_table+0x226/0x4a0 
[ip_tables]
May  1 03:35:45 noki kernel:  [tcp_rcv_established+899/1840] 
tcp_rcv_established+0x383/0x730
May  1 03:35:45 noki kernel:  [atomic_notifier_call_chain+23/32] 
atomic_notifier_call_chain+0x17/0x20
May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] 
tcp_v4_do_rcv+0xb3/0x1d0
May  1 03:35:45 noki kernel:  [nf_iterate+96/144] nf_iterate+0x60/0x90
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [tcp_v4_rcv+1577/1776] tcp_v4_rcv+0x629/0x6f0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+148/416] 
ip_local_deliver_finish+0x94/0x1a0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [ip_rcv_finish+259/800] 
ip_rcv_finish+0x103/0x320
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [ip_rcv+410/608] ip_rcv+0x19a/0x260
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [netif_receive_skb+672/1104] 
netif_receive_skb+0x2a0/0x450
May  1 03:35:45 noki kernel:  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
May  1 03:35:45 noki kernel:  [<d4825ca8>] tulip_interrupt+0x568/0x840 
[tulip]
May  1 03:35:45 noki kernel:  [tick_program_event+54/112] 
tick_program_event+0x36/0x70
May  1 03:35:45 noki kernel:  [net_rx_action+147/336] 
net_rx_action+0x93/0x150
May  1 03:35:45 noki kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
May  1 03:35:45 noki kernel:  [do_softirq+38/48] do_softirq+0x26/0x30
May  1 03:35:45 noki kernel:  [do_IRQ+74/128] do_IRQ+0x4a/0x80
May  1 03:35:45 noki kernel:  [tick_notify+427/624] tick_notify+0x1ab/0x270
May  1 03:35:45 noki kernel:  [common_interrupt+35/40] 
common_interrupt+0x23/0x28
May  1 03:35:45 noki kernel:  [<d483cd05>] 
acpi_idle_enter_simple+0x153/0x1c6 [processor]
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+107/160] 
cpuidle_idle_call+0x6b/0xa0
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+0/160] 
cpuidle_idle_call+0x0/0xa0
May  1 03:35:45 noki kernel:  [cpu_idle+38/112] cpu_idle+0x26/0x70
May  1 03:35:45 noki kernel:  =======================
May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
May  1 03:35:45 noki kernel: P: 0 L: 0 vs 0 S: 0 vs 0 F: 0 vs 2 w: 
2200792303-2200792303 (7)
May  1 03:35:45 noki kernel: head 0 d2dc91c0
May  1 03:35:45 noki kernel: skb 1 d2fb07a0
May  1 03:35:45 noki kernel: skb 2 d3b8cb60
May  1 03:35:45 noki kernel: skb 3 d1baca60
May  1 03:35:45 noki kernel: skb 4 d19ae380
May  1 03:35:45 noki kernel: skb 5 d1997ce0
May  1 03:35:45 noki kernel: skb 6 d2e084a0
May  1 03:35:45 noki kernel: skb 7 d19978c0
May  1 03:35:45 noki kernel: l0 s0 f2 p0 seq: su2200792303 hs2200792303 
sn2200792303
May  1 03:35:45 noki kernel: ------------[ cut here ]------------
May  1 03:35:45 noki kernel: WARNING: at net/ipv4/tcp_ipv4.c:239 
tcp_verify_wq+0x35f/0x3b0()
May  1 03:35:45 noki kernel: Modules linked in: saa7134_dvb tda826x 
mt352 tda10086 dvb_pll tuner tea5767 tda8290 tuner_xc2028 tda9887 
tuner_simple mt20xx tea5761 saa7134 videodev v4l1_compat compat_ioctl32 
v4l2_common ir_kbd_i2c ir_common tveeprom videobuf_dvb dvb_core 
videobuf_dma_sg videobuf_core nxt200x isl6421 tda1004x firmware_class 
tda827x cls_flow sch_ingress xt_mark xt_length xt_MARK cls_u32 sch_sfq 
cls_fw sch_htb ipt_REJECT xt_state iptable_filter xt_TCPMSS xt_tcpmss 
xt_tcpudp iptable_mangle nf_nat_ftp nf_conntrack_ftp iptable_nat 
ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack bridge llc 
container fan thermal processor button tulip
May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #2
May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144] 
warn_on_slowpath+0x5f/0x90
May  1 03:35:45 noki kernel:  [atomic_notifier_call_chain+23/32] 
atomic_notifier_call_chain+0x17/0x20
May  1 03:35:45 noki kernel:  [printk+27/32] printk+0x1b/0x20
May  1 03:35:45 noki kernel:  [tcp_print_queue+535/592] 
tcp_print_queue+0x217/0x250
May  1 03:35:45 noki kernel:  [dev_queue_xmit+150/640] 
dev_queue_xmit+0x96/0x280
May  1 03:35:45 noki kernel:  [ip_finish_output+0/688] 
ip_finish_output+0x0/0x2b0
May  1 03:35:45 noki kernel:  [ip_finish_output+316/688] 
ip_finish_output+0x13c/0x2b0
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [tcp_ack+2348/7232] tcp_ack+0x92c/0x1c40
May  1 03:35:45 noki kernel:  [tcp_rcv_established+899/1840] 
tcp_rcv_established+0x383/0x730
May  1 03:35:45 noki kernel:  [atomic_notifier_call_chain+23/32] 
atomic_notifier_call_chain+0x17/0x20
May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] 
tcp_v4_do_rcv+0xb3/0x1d0
May  1 03:35:45 noki kernel:  [nf_iterate+96/144] nf_iterate+0x60/0x90
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [tcp_v4_rcv+1577/1776] tcp_v4_rcv+0x629/0x6f0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+148/416] 
ip_local_deliver_finish+0x94/0x1a0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [ip_rcv_finish+259/800] 
ip_rcv_finish+0x103/0x320
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [ip_rcv+410/608] ip_rcv+0x19a/0x260
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [netif_receive_skb+672/1104] 
netif_receive_skb+0x2a0/0x450
May  1 03:35:45 noki kernel:  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
May  1 03:35:45 noki kernel:  [<d4825ca8>] tulip_interrupt+0x568/0x840 
[tulip]
May  1 03:35:45 noki kernel:  [tick_program_event+54/112] 
tick_program_event+0x36/0x70
May  1 03:35:45 noki kernel:  [net_rx_action+147/336] 
net_rx_action+0x93/0x150
May  1 03:35:45 noki kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
May  1 03:35:45 noki kernel:  [do_softirq+38/48] do_softirq+0x26/0x30
May  1 03:35:45 noki kernel:  [do_IRQ+74/128] do_IRQ+0x4a/0x80
May  1 03:35:45 noki kernel:  [tick_notify+427/624] tick_notify+0x1ab/0x270
May  1 03:35:45 noki kernel:  [common_interrupt+35/40] 
common_interrupt+0x23/0x28
May  1 03:35:45 noki kernel:  [<d483cd05>] 
acpi_idle_enter_simple+0x153/0x1c6 [processor]
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+107/160] 
cpuidle_idle_call+0x6b/0xa0
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+0/160] 
cpuidle_idle_call+0x0/0xa0
May  1 03:35:45 noki kernel:  [cpu_idle+38/112] cpu_idle+0x26/0x70
May  1 03:35:45 noki kernel:  =======================
May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
May  1 03:35:45 noki kernel: ------------[ cut here ]------------
May  1 03:35:45 noki kernel: WARNING: at net/ipv4/tcp_input.c:2546 
tcp_ack+0x955/0x1c40()
May  1 03:35:45 noki kernel: Modules linked in: saa7134_dvb tda826x 
mt352 tda10086 dvb_pll tuner tea5767 tda8290 tuner_xc2028 tda9887 
tuner_simple mt20xx tea5761 saa7134 videodev v4l1_compat compat_ioctl32 
v4l2_common ir_kbd_i2c ir_common tveeprom videobuf_dvb dvb_core 
videobuf_dma_sg videobuf_core nxt200x isl6421 tda1004x firmware_class 
tda827x cls_flow sch_ingress xt_mark xt_length xt_MARK cls_u32 sch_sfq 
cls_fw sch_htb ipt_REJECT xt_state iptable_filter xt_TCPMSS xt_tcpmss 
xt_tcpudp iptable_mangle nf_nat_ftp nf_conntrack_ftp iptable_nat 
ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack bridge llc 
container fan thermal processor button tulip
May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #2
May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144] 
warn_on_slowpath+0x5f/0x90
May  1 03:35:45 noki kernel:  [dev_queue_xmit+150/640] 
dev_queue_xmit+0x96/0x280
May  1 03:35:45 noki kernel:  [ip_finish_output+0/688] 
ip_finish_output+0x0/0x2b0
May  1 03:35:45 noki kernel:  [ip_finish_output+316/688] 
ip_finish_output+0x13c/0x2b0
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [tcp_ack+2389/7232] tcp_ack+0x955/0x1c40
May  1 03:35:45 noki kernel:  [tcp_rcv_established+899/1840] 
tcp_rcv_established+0x383/0x730
May  1 03:35:45 noki kernel:  [atomic_notifier_call_chain+23/32] 
atomic_notifier_call_chain+0x17/0x20
May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] 
tcp_v4_do_rcv+0xb3/0x1d0
May  1 03:35:45 noki kernel:  [nf_iterate+96/144] nf_iterate+0x60/0x90
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [tcp_v4_rcv+1577/1776] tcp_v4_rcv+0x629/0x6f0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+148/416] 
ip_local_deliver_finish+0x94/0x1a0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [ip_rcv_finish+259/800] 
ip_rcv_finish+0x103/0x320
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [ip_rcv+410/608] ip_rcv+0x19a/0x260
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [netif_receive_skb+672/1104] 
netif_receive_skb+0x2a0/0x450
May  1 03:35:45 noki kernel:  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
May  1 03:35:45 noki kernel:  [<d4825ca8>] tulip_interrupt+0x568/0x840 
[tulip]
May  1 03:35:45 noki kernel:  [tick_program_event+54/112] 
tick_program_event+0x36/0x70
May  1 03:35:45 noki kernel:  [net_rx_action+147/336] 
net_rx_action+0x93/0x150
May  1 03:35:45 noki kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
May  1 03:35:45 noki kernel:  [do_softirq+38/48] do_softirq+0x26/0x30
May  1 03:35:45 noki kernel:  [do_IRQ+74/128] do_IRQ+0x4a/0x80
May  1 03:35:45 noki kernel:  [tick_notify+427/624] tick_notify+0x1ab/0x270
May  1 03:35:45 noki kernel:  [common_interrupt+35/40] 
common_interrupt+0x23/0x28
May  1 03:35:45 noki kernel:  [<d483cd05>] 
acpi_idle_enter_simple+0x153/0x1c6 [processor]
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+107/160] 
cpuidle_idle_call+0x6b/0xa0
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+0/160] 
cpuidle_idle_call+0x0/0xa0
May  1 03:35:45 noki kernel:  [cpu_idle+38/112] cpu_idle+0x26/0x70
May  1 03:35:45 noki kernel:  =======================
May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
May  1 03:35:45 noki kernel: ------------[ cut here ]------------
May  1 03:35:45 noki kernel: WARNING: at net/ipv4/tcp_input.c:2550 
tcp_ack+0x1bba/0x1c40()
May  1 03:35:45 noki kernel: Modules linked in: saa7134_dvb tda826x 
mt352 tda10086 dvb_pll tuner tea5767 tda8290 tuner_xc2028 tda9887 
tuner_simple mt20xx tea5761 saa7134 videodev v4l1_compat compat_ioctl32 
v4l2_common ir_kbd_i2c ir_common tveeprom videobuf_dvb dvb_core 
videobuf_dma_sg videobuf_core nxt200x isl6421 tda1004x firmware_class 
tda827x cls_flow sch_ingress xt_mark xt_length xt_MARK cls_u32 sch_sfq 
cls_fw sch_htb ipt_REJECT xt_state iptable_filter xt_TCPMSS xt_tcpmss 
xt_tcpudp iptable_mangle nf_nat_ftp nf_conntrack_ftp iptable_nat 
ip_tables nf_nat x_tables nf_conntrack_ipv4 nf_conntrack bridge llc 
container fan thermal processor button tulip
May  1 03:35:45 noki kernel: Pid: 0, comm: swapper Not tainted 2.6.25 #2
May  1 03:35:45 noki kernel:  [warn_on_slowpath+95/144] 
warn_on_slowpath+0x5f/0x90
May  1 03:35:45 noki kernel:  [dev_queue_xmit+150/640] 
dev_queue_xmit+0x96/0x280
May  1 03:35:45 noki kernel:  [ip_finish_output+0/688] 
ip_finish_output+0x0/0x2b0
May  1 03:35:45 noki kernel:  [ip_finish_output+316/688] 
ip_finish_output+0x13c/0x2b0
May  1 03:35:45 noki kernel:  [tcp_verify_wq+863/944] 
tcp_verify_wq+0x35f/0x3b0
May  1 03:35:45 noki kernel:  [tcp_ack+7098/7232] tcp_ack+0x1bba/0x1c40
May  1 03:35:45 noki kernel:  [tcp_rcv_established+899/1840] 
tcp_rcv_established+0x383/0x730
May  1 03:35:45 noki kernel:  [atomic_notifier_call_chain+23/32] 
atomic_notifier_call_chain+0x17/0x20
May  1 03:35:45 noki kernel:  [tcp_v4_do_rcv+179/464] 
tcp_v4_do_rcv+0xb3/0x1d0
May  1 03:35:45 noki kernel:  [nf_iterate+96/144] nf_iterate+0x60/0x90
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [tcp_v4_rcv+1577/1776] tcp_v4_rcv+0x629/0x6f0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+148/416] 
ip_local_deliver_finish+0x94/0x1a0
May  1 03:35:45 noki kernel:  [ip_local_deliver_finish+0/416] 
ip_local_deliver_finish+0x0/0x1a0
May  1 03:35:45 noki kernel:  [ip_rcv_finish+259/800] 
ip_rcv_finish+0x103/0x320
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [ip_rcv+410/608] ip_rcv+0x19a/0x260
May  1 03:35:45 noki kernel:  [ip_rcv_finish+0/800] ip_rcv_finish+0x0/0x320
May  1 03:35:45 noki kernel:  [netif_receive_skb+672/1104] 
netif_receive_skb+0x2a0/0x450
May  1 03:35:45 noki kernel:  [<d48254f8>] tulip_poll+0x3c8/0x610 [tulip]
May  1 03:35:45 noki kernel:  [<d4825ca8>] tulip_interrupt+0x568/0x840 
[tulip]
May  1 03:35:45 noki kernel:  [tick_program_event+54/112] 
tick_program_event+0x36/0x70
May  1 03:35:45 noki kernel:  [net_rx_action+147/336] 
net_rx_action+0x93/0x150
May  1 03:35:45 noki kernel:  [__do_softirq+66/160] __do_softirq+0x42/0xa0
May  1 03:35:45 noki kernel:  [do_softirq+38/48] do_softirq+0x26/0x30
May  1 03:35:45 noki kernel:  [do_IRQ+74/128] do_IRQ+0x4a/0x80
May  1 03:35:45 noki kernel:  [tick_notify+427/624] tick_notify+0x1ab/0x270
May  1 03:35:45 noki kernel:  [common_interrupt+35/40] 
common_interrupt+0x23/0x28
May  1 03:35:45 noki kernel:  [<d483cd05>] 
acpi_idle_enter_simple+0x153/0x1c6 [processor]
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+107/160] 
cpuidle_idle_call+0x6b/0xa0
May  1 03:35:45 noki kernel:  [cpuidle_idle_call+0/160] 
cpuidle_idle_call+0x0/0xa0
May  1 03:35:45 noki kernel:  [cpu_idle+38/112] cpu_idle+0x26/0x70
May  1 03:35:45 noki kernel:  =======================
May  1 03:35:45 noki kernel: ---[ end trace ca0e42fa80915e32 ]---
May  1 03:35:45 noki kernel: TCP DEBUG 2 0 4 7



