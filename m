From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: WARNING on latest vanilla 2.6.25-rc6-git2
Date: Wed, 19 Mar 2008 17:45:24 +0200
Message-ID: <20080319154409.M59844@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:57988 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758891AbYCSUSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 16:18:09 -0400
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id A872BBD5A8
	for <netdev@vger.kernel.org>; Wed, 19 Mar 2008 17:45:24 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If .config matter, i will send it. Not sure if i can reproduce this.

Proxy-Karam114 ~ # uname -a
Linux Proxy-Karam114 2.6.25-rc6-git2-build-0024 #8 SMP Wed Mar 19 02:33:47 
EET 2008 i686 unknown

Proxy-Karam114 ~ # sysctl -a|grep tcp
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_retrans_collapse = 1
net.ipv4.tcp_syn_retries = 5
net.ipv4.tcp_synack_retries = 5
net.ipv4.tcp_max_orphans = 262144
net.ipv4.tcp_max_tw_buckets = 180000
net.ipv4.tcp_keepalive_time = 7200
net.ipv4.tcp_keepalive_probes = 9
net.ipv4.tcp_keepalive_intvl = 75
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 15
net.ipv4.tcp_fin_timeout = 60
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_abort_on_overflow = 0
net.ipv4.tcp_stdurg = 0
net.ipv4.tcp_rfc1337 = 1
net.ipv4.tcp_max_syn_backlog = 10240
sysctl: error: permission denied on key 'net.ipv4.route.flush'
net.ipv4.tcp_orphan_retries = 0
net.ipv4.tcp_fack = 1
net.ipv4.tcp_reordering = 3
net.ipv4.tcp_ecn = 0
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_mem = 375648       500864  751296
net.ipv4.tcp_wmem = 4096        16384   32768
net.ipv4.tcp_rmem = 4096        8192    32768
net.ipv4.tcp_app_win = 31
net.ipv4.tcp_adv_win_scale = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_frto = 0
net.ipv4.tcp_frto_response = 0
net.ipv4.tcp_low_latency = 1
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_moderate_rcvbuf = 1
net.ipv4.tcp_tso_win_divisor = 3
net.ipv4.tcp_congestion_control = lp
net.ipv4.tcp_abc = 0
net.ipv4.tcp_mtu_probing = 0
net.ipv4.tcp_base_mss = 512
net.ipv4.tcp_workaround_signed_windows = 0
net.ipv4.tcp_dma_copybreak = 4096
net.ipv4.tcp_slow_start_after_idle = 1
net.ipv4.tcp_available_congestion_control = lp cubic reno
net.ipv4.tcp_allowed_congestion_control = lp cubic reno
net.ipv4.tcp_max_ssthresh = 0
net.netfilter.nf_conntrack_tcp_timeout_syn_sent = 120
net.netfilter.nf_conntrack_tcp_timeout_syn_recv = 60
net.netfilter.nf_conntrack_tcp_timeout_established = 432000
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_last_ack = 30
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_close = 10
net.netfilter.nf_conntrack_tcp_timeout_max_retrans = 300
net.netfilter.nf_conntrack_tcp_loose = 1
net.netfilter.nf_conntrack_tcp_be_liberal = 3
net.netfilter.nf_conntrack_tcp_max_retrans = 3


[  361.275307] ------------[ cut here ]------------
[  361.275316] WARNING: at net/ipv4/tcp_input.c:2173 tcp_mark_head_lost+0x11e/
0x126()
[  361.275319] Modules linked in: tcp_lp xt_dscp xt_owner xt_tcpudp mptspi 
mptsas scsi_transport_spi scsi_transport_sas mptscsih mptbase xfs em_nbyte 
cls_tcindex act_gact cls_rsvp sch_htb cls_fw act_mirred em_u32 sch_red 
sch_sfq sch_tbf sch_teql cls_basic act_police sch_gred act_pedit sch_hfsc 
cls_rsvp6 sch_ingress em_meta em_text act_ipt sch_dsmark sch_prio sch_netem 
act_simple cls_u32 em_cmp sch_cbq cls_route xt_TCPMSS iptable_nat 
nf_conntrack_ipv4 ipt_LOG ipt_MASQUERADE ipt_REDIRECT nf_nat nf_conntrack 
nfnetlink iptable_filter ip_tables x_tables 8021q tun tulip r8169 sky2 
via_velocity via_rhine sis900 ne2k_pci 8390 skge tg3 8139too e1000 e100 
usb_storage mtdblock mtd_blkdevs usbhid uhci_hcd ehci_hcd ohci_hcd usbcore
[  361.275370] Pid: 1577, comm: squid Not tainted 2.6.25-rc6-git2-build-0024 
#8
[  361.275383]  [<c0121048>] warn_on_slowpath+0x41/0x51
[  361.275427]  [<c013bdc3>] ? mark_held_locks+0x41/0x5c
[  361.275436]  [<c012575a>] ? local_bh_enable_ip+0xb0/0xb6
[  361.275446]  [<c013bf40>] ? trace_hardirqs_on+0xd3/0x111
[  361.275453]  [<f89f2984>] ? __nf_ct_refresh_acct+0xd3/0x10b [nf_conntrack]
[  361.275477]  [<c02beb1c>] ? _spin_unlock_bh+0x25/0x28
[  361.275488]  [<f89f2984>] ? __nf_ct_refresh_acct+0xd3/0x10b [nf_conntrack]
[  361.275513]  [<f89f60c6>] ? tcp_packet+0x9a7/0x9e5 [nf_conntrack]
[  361.275543]  [<c013ce1f>] ? __lock_acquire+0xaef/0xb37
[  361.275575]  [<c02931d7>] tcp_mark_head_lost+0x11e/0x126
[  361.275592]  [<c02956ac>] tcp_ack+0x1535/0x17c3
[  361.275670]  [<c0297f53>] tcp_rcv_established+0xce/0x7df
[  361.275696]  [<c029d136>] tcp_v4_do_rcv+0x28/0x181
[  361.275717]  [<c029ec34>] tcp_v4_rcv+0x663/0x6af
[  361.275745]  [<c0287544>] ip_local_deliver_finish+0xdc/0x15f
[  361.275757]  [<c0287929>] ip_local_deliver+0x64/0x6f
[  361.275766]  [<c028742e>] ip_rcv_finish+0x2ba/0x2f4
[  361.275783]  [<c028789b>] ip_rcv+0x202/0x22c
[  361.275798]  [<c026c809>] netif_receive_skb+0x38d/0x3ec
[  361.275826]  [<f890642b>] e1000_clean_rx_irq+0x369/0x42f [e1000]
[  361.275883]  [<f8903db6>] e1000_clean+0x62/0x1fd [e1000]
[  361.275913]  [<c026e977>] net_rx_action+0xb3/0x1d8
[  361.275935]  [<c0125846>] __do_softirq+0x6f/0xe9
[  361.275949]  [<c01060ab>] do_softirq+0x5e/0xa8
[  361.275965]  [<c0125688>] local_bh_enable+0xba/0xdc
[  361.275973]  [<c026f3d6>] dev_queue_xmit+0x2bf/0x2e9
[  361.275985]  [<c028aadf>] ip_finish_output+0x1d3/0x20b
[  361.276002]  [<c028adcc>] ip_output+0x81/0x86
[  361.276010]  [<c028a63d>] ip_local_out+0x18/0x1b
[  361.276019]  [<c028a8aa>] ip_push_pending_frames+0x26a/0x2cc
[  361.276038]  [<c02a1aff>] udp_push_pending_frames+0x2c1/0x343
[  361.276069]  [<c02a2b07>] udp_sendmsg+0x424/0x514
[  361.276163]  [<c02a7d9f>] inet_sendmsg+0x3b/0x48
[  361.276181]  [<c0263336>] sock_sendmsg+0xca/0xe1
[  361.276220]  [<c013122e>] ? autoremove_wake_function+0x0/0x33
[  361.276243]  [<c0108141>] ? native_sched_clock+0x9a/0xaf
[  361.276276]  [<c01626e5>] ? fget_light+0x90/0xb0
[  361.276293]  [<c01f2d52>] ? copy_from_user+0x3b/0x5e
[  361.276313]  [<c026359b>] sys_sendto+0xa4/0xc3
[  361.276327]  [<c0161545>] ? do_sync_read+0xab/0xe9
[  361.276368]  [<c013122e>] ? autoremove_wake_function+0x0/0x33
[  361.276385]  [<c0108141>] ? native_sched_clock+0x9a/0xaf
[  361.276423]  [<c02640cc>] sys_socketcall+0xde/0x166
[  361.276457]  [<c01038f6>] sysenter_past_esp+0x5f/0xa5
[  361.276502]  =======================
[  361.276504] ---[ end trace 1d98aa796f2bac59 ]---


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

