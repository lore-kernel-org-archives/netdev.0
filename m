From: Alex Dubov <oakad@yahoo.com>
Subject: Re: Bad TCP timestamps on non-PC platforms
Date: Thu, 6 Jan 2011 22:39:39 -0800 (PST)
Message-ID: <543528.19748.qm@web37605.mail.mud.yahoo.com>
References: <1294366281.2704.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web37605.mail.mud.yahoo.com ([209.191.87.88]:26836 "HELO
	web37605.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751328Ab1AGGjl convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jan 2011 01:39:41 -0500
In-Reply-To: <1294366281.2704.36.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> 
> You dont give new informations ;)
> 
> I asked if you could give information on the other side :
> The bug is to
> drop this legal packet.
> 
> uname -a
> sysctl -a | grep tcp
> 

One of the other machines:

Linux sunapp 2.6.31.3 #2 SMP Mon Oct 12 21:32:20 EST 2009 x86_64 Dual-Core AMD Opteron(tm) Processor 8220 AuthenticAMD GNU/Linux

error: permission denied on key 'net.ipv4.route.flush'                          
fs.nfs.nlm_tcpport = 0
fs.nfs.nfs_callback_tcpport = 0
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_retrans_collapse = 1
net.ipv4.tcp_syn_retries = 5
net.ipv4.tcp_synack_retries = 5
net.ipv4.tcp_max_orphans = 65536
net.ipv4.tcp_max_tw_buckets = 180000
net.ipv4.tcp_keepalive_time = 7200
net.ipv4.tcp_keepalive_probes = 9
net.ipv4.tcp_keepalive_intvl = 75
net.ipv4.tcp_retries1 = 3
net.ipv4.tcp_retries2 = 15
net.ipv4.tcp_fin_timeout = 60
net.ipv4.tcp_syncookies = 0
net.ipv4.tcp_tw_recycle = 0
net.ipv4.tcp_abort_on_overflow = 0
net.ipv4.tcp_stdurg = 0
net.ipv4.tcp_rfc1337 = 0
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_orphan_retries = 0
net.ipv4.tcp_fack = 1
net.ipv4.tcp_reordering = 3
net.ipv4.tcp_ecn = 2
net.ipv4.tcp_dsack = 1
net.ipv4.tcp_mem = 3095040      4126720 6190080
net.ipv4.tcp_wmem = 4096        16384   4194304
net.ipv4.tcp_rmem = 4096        87380   4194304
net.ipv4.tcp_app_win = 31
net.ipv4.tcp_adv_win_scale = 2
net.ipv4.tcp_tw_reuse = 0
net.ipv4.tcp_frto = 2
net.ipv4.tcp_frto_response = 0
net.ipv4.tcp_low_latency = 0
net.ipv4.tcp_no_metrics_save = 0
net.ipv4.tcp_moderate_rcvbuf = 1
net.ipv4.tcp_tso_win_divisor = 3
net.ipv4.tcp_congestion_control = reno
net.ipv4.tcp_abc = 0
net.ipv4.tcp_mtu_probing = 0
net.ipv4.tcp_base_mss = 512
net.ipv4.tcp_workaround_signed_windows = 0
net.ipv4.tcp_dma_copybreak = 4096
net.ipv4.tcp_slow_start_after_idle = 1
net.ipv4.tcp_available_congestion_control = reno
net.ipv4.tcp_allowed_congestion_control = reno
net.ipv4.tcp_max_ssthresh = 0
error: permission denied on key 'net.ipv6.route.flush'
sunrpc.transports = tcp 1048576
sunrpc.tcp_slot_table_entries = 16
sunrpc.tcp_fin_timeout = 15




      
