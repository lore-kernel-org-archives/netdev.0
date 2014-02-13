From: John Ogness <john.ogness@linutronix.de>
Subject: Re: nonagle flags for TSQ
Date: Thu, 13 Feb 2014 10:34:19 +0100
Message-ID: <878utfuzj8.fsf@linutronix.de>
References: <87fvnv2c5k.fsf@linutronix.de>
	<1391787297.10160.50.camel@edumazet-glaptop2.roam.corp.google.com>
	<878utm3mq9.fsf@linutronix.de>
	<1391792743.10160.59.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:58652 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbaBMJeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 04:34:23 -0500
In-Reply-To: <1391792743.10160.59.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Fri, 07 Feb 2014 09:05:43 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Since the patch has already been pulled, I don't know how much energy
you want to spend to track this down. I am acting as a middle-man for
the person with the problem, which is the reason for the large latency
in my responses.

On 2014-02-07, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> I cant see how TSQ would even trigger with this test.

The problem is appearing on a kernel with the PREEMPT_RT patch
(3.10.20-rt17). I do not see anything in the PREEMPT_RT patch that would
affect the use of TSQ.

> What value do you have on /proc/sys/net/ipv4/tcp_limit_output_bytes ?

conf 	: icmp_echo_ignore_all 	: 0
icmp_echo_ignore_broadcasts 	: 1
icmp_echo_sysrq 	: 0
icmp_errors_use_inbound_ifaddr 	: 0
icmp_ignore_bogus_error_responses 	: 1
icmp_ratelimit 	: 1000
icmp_ratemask 	: 6168
igmp_max_memberships 	: 20
igmp_max_msf 	: 10
inet_peer_maxttl 	: 600
inet_peer_minttl 	: 120
inet_peer_threshold 	: 65664
ip_default_ttl 	: 64
ip_dynaddr 	: 0
ip_early_demux 	: 1
ip_forward 	: 0
ip_local_port_range 	: 32768	61000
ip_local_reserved_ports 	: 
ip_no_pmtu_disc 	: 0
ip_nonlocal_bind 	: 0
ipfrag_high_thresh 	: 4194304
ipfrag_low_thresh 	: 3145728
ipfrag_max_dist 	: 64
ipfrag_secret_interval 	: 600
ipfrag_time 	: 30
neigh 	: ping_group_range 	: 1	0
route 	: tcp_abort_on_overflow 	: 0
tcp_adv_win_scale 	: 1
tcp_allowed_congestion_control 	: cubic reno
tcp_app_win 	: 31
tcp_available_congestion_control 	: cubic reno
tcp_base_mss 	: 512
tcp_challenge_ack_limit 	: 100
tcp_congestion_control 	: cubic
tcp_dsack 	: 1
tcp_early_retrans 	: 3
tcp_ecn 	: 2
tcp_fack 	: 1
tcp_fastopen 	: 0
tcp_fastopen_key 	: fe6450bc-a4524655-c76e138c-10df4490
tcp_fin_timeout 	: 60
tcp_frto 	: 2
tcp_keepalive_intvl 	: 75
tcp_keepalive_probes 	: 9
tcp_keepalive_time 	: 7200
tcp_limit_output_bytes 	: 131072
tcp_low_latency 	: 0
tcp_max_orphans 	: 4096
tcp_max_ssthresh 	: 0
tcp_max_syn_backlog 	: 128
tcp_max_tw_buckets 	: 4096
tcp_mem 	: 20187	26919	40374
tcp_min_tso_segs 	: 2
tcp_moderate_rcvbuf 	: 1
tcp_mtu_probing 	: 0
tcp_no_metrics_save 	: 0
tcp_orphan_retries 	: 0
tcp_reordering 	: 3
tcp_retrans_collapse 	: 1
tcp_retries1 	: 3
tcp_retries2 	: 15
tcp_rfc1337 	: 0
tcp_rmem 	: 4096	87380	6291456
tcp_sack 	: 1
tcp_slow_start_after_idle 	: 1
tcp_stdurg 	: 0
tcp_syn_retries 	: 6
tcp_synack_retries 	: 5
tcp_syncookies 	: 1
tcp_thin_dupack 	: 0
tcp_thin_linear_timeouts 	: 0
tcp_timestamps 	: 1
tcp_tso_win_divisor 	: 3
tcp_tw_recycle 	: 0
tcp_tw_reuse 	: 0
tcp_window_scaling 	: 1
tcp_wmem 	: 4096	16384	4194304
tcp_workaround_signed_windows 	: 0
udp_mem 	: 20319	27093	40638
udp_rmem_min 	: 4096
udp_wmem_min 	: 4096

John Ogness
