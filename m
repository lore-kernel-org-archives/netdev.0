From: Howard Chu <hyc@symas.com>
Subject: Re: TCP 2MSL on loopback
Date: Tue, 06 Mar 2007 12:28:37 -0800
Message-ID: <45EDCEF5.1070401@symas.com>
References: <45EBFD13.1060106@symas.com> <200703051528.02564.dada1@cosmosbay.com> <45ED32CA.5080709@symas.com> <200703061142.00261.dada1@cosmosbay.com> <45EDB55C.2080803@symas.com> <45EDCA15.4060704@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from highlandsun.propagation.net ([66.221.212.168]:2199 "EHLO
	highlandsun.propagation.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751338AbXCFUeU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 15:34:20 -0500
In-Reply-To: <45EDCA15.4060704@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Let me see, any chance you can try the prog on 2.6.20 ?

Not any time soon.
> 
> If not, please send :
> 
> grep . /proc/sys/net/ipv4/*

This is the output on the laptop:
/proc/sys/net/ipv4/icmp_echo_ignore_all:0
/proc/sys/net/ipv4/icmp_echo_ignore_broadcasts:1
/proc/sys/net/ipv4/icmp_errors_use_inbound_ifaddr:0
/proc/sys/net/ipv4/icmp_ignore_bogus_error_responses:1
/proc/sys/net/ipv4/icmp_ratelimit:250
/proc/sys/net/ipv4/icmp_ratemask:6168
/proc/sys/net/ipv4/igmp_max_memberships:20
/proc/sys/net/ipv4/igmp_max_msf:10
/proc/sys/net/ipv4/inet_peer_gc_maxtime:120
/proc/sys/net/ipv4/inet_peer_gc_mintime:10
/proc/sys/net/ipv4/inet_peer_maxttl:600
/proc/sys/net/ipv4/inet_peer_minttl:120
/proc/sys/net/ipv4/inet_peer_threshold:65664
/proc/sys/net/ipv4/ip_default_ttl:64
/proc/sys/net/ipv4/ip_dynaddr:0
/proc/sys/net/ipv4/ip_forward:0
/proc/sys/net/ipv4/ipfrag_high_thresh:262144
/proc/sys/net/ipv4/ipfrag_low_thresh:196608
/proc/sys/net/ipv4/ipfrag_max_dist:64
/proc/sys/net/ipv4/ipfrag_secret_interval:600
/proc/sys/net/ipv4/ipfrag_time:30
/proc/sys/net/ipv4/ip_local_port_range:32768    61000
/proc/sys/net/ipv4/ip_nonlocal_bind:0
/proc/sys/net/ipv4/ip_no_pmtu_disc:0
/proc/sys/net/ipv4/tcp_abc:0
/proc/sys/net/ipv4/tcp_abort_on_overflow:0
/proc/sys/net/ipv4/tcp_adv_win_scale:2
/proc/sys/net/ipv4/tcp_app_win:31
/proc/sys/net/ipv4/tcp_base_mss:512
/proc/sys/net/ipv4/tcp_congestion_control:reno
/proc/sys/net/ipv4/tcp_dma_copybreak:4096
/proc/sys/net/ipv4/tcp_dsack:1
/proc/sys/net/ipv4/tcp_ecn:0
/proc/sys/net/ipv4/tcp_fack:1
/proc/sys/net/ipv4/tcp_fin_timeout:60
/proc/sys/net/ipv4/tcp_frto:0
/proc/sys/net/ipv4/tcp_keepalive_intvl:75
/proc/sys/net/ipv4/tcp_keepalive_probes:9
/proc/sys/net/ipv4/tcp_keepalive_time:7200
/proc/sys/net/ipv4/tcp_low_latency:0
/proc/sys/net/ipv4/tcp_max_orphans:32768
/proc/sys/net/ipv4/tcp_max_syn_backlog:1024
/proc/sys/net/ipv4/tcp_max_tw_buckets:180000
/proc/sys/net/ipv4/tcp_mem:98304        131072  196608
/proc/sys/net/ipv4/tcp_moderate_rcvbuf:1
/proc/sys/net/ipv4/tcp_mtu_probing:0
/proc/sys/net/ipv4/tcp_no_metrics_save:0
/proc/sys/net/ipv4/tcp_orphan_retries:0
/proc/sys/net/ipv4/tcp_reordering:3
/proc/sys/net/ipv4/tcp_retrans_collapse:1
/proc/sys/net/ipv4/tcp_retries1:3
/proc/sys/net/ipv4/tcp_retries2:15
/proc/sys/net/ipv4/tcp_rfc1337:0
/proc/sys/net/ipv4/tcp_rmem:4096        87380   4194304
/proc/sys/net/ipv4/tcp_sack:1
/proc/sys/net/ipv4/tcp_slow_start_after_idle:1
/proc/sys/net/ipv4/tcp_stdurg:0
/proc/sys/net/ipv4/tcp_synack_retries:5
/proc/sys/net/ipv4/tcp_syncookies:1
/proc/sys/net/ipv4/tcp_syn_retries:5
/proc/sys/net/ipv4/tcp_timestamps:1
/proc/sys/net/ipv4/tcp_tso_win_divisor:3
/proc/sys/net/ipv4/tcp_tw_recycle:0
/proc/sys/net/ipv4/tcp_tw_reuse:0
/proc/sys/net/ipv4/tcp_window_scaling:1
/proc/sys/net/ipv4/tcp_wmem:4096        16384   4194304
/proc/sys/net/ipv4/tcp_workaround_signed_windows:0



-- 
   -- Howard Chu
   Chief Architect, Symas Corp.  http://www.symas.com
   Director, Highland Sun        http://highlandsun.com/hyc
   Chief Architect, OpenLDAP     http://www.openldap.org/project/
