From: Baruch Even <baruch@ev-en.org>
Subject: Re: TCP performance drop 2.6.6->2.6.7
Date: Wed, 13 Apr 2005 00:59:25 +0100
Message-ID: <425C60DD.5090007@ev-en.org>
References: <425C493B.5040206@ev-en.org> <20050412160752.46c82f0c@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090709020305080106070102"
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050412160752.46c82f0c@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090709020305080106070102
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Stephen Hemminger wrote:
> On Tue, 12 Apr 2005 23:18:35 +0100
> Baruch Even <baruch@ev-en.org> wrote:
>>The setup for the tests, vanilla kernels, dummynet with 100 Mbit/s and 
>>40ms rtt using the BIC protocol. No patches applied whatsoever.
>>
>>iperf tests for 2.6.6 get about 90Mbit/s while 2.6.7 gets 30Mbit/s.
> 
> 
> Haven't measured old kernels recently. But haven't seen that with the
> newest stuff I tested last night. At 40ms delay  with netem
> over 1G to 100M bridge.
> 	Reno	99.6
> 	Vegas	61.6
> 	BIC	  97.8
> 	Hstcp	 99.4
> 	Westwood 99.4

I've now tested 2.6.11.7 and I get about 50Mbit/s, it starts at about 
100 and drops to about 45. Tested for about a minute but it didn't show 
signs of recovery.

> What are your sysctl settings. 

Attached.

Baruch

--------------090709020305080106070102
Content-Type: text/plain;
 name="sysctls"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sysctls"

icmp_echo_ignore_all 0
icmp_echo_ignore_broadcasts 0
icmp_ignore_bogus_error_responses 0
icmp_ratelimit 1000
icmp_ratemask 6168
igmp_max_memberships 20
igmp_max_msf 10
inet_peer_gc_maxtime 120
inet_peer_gc_mintime 10
inet_peer_maxttl 600
inet_peer_minttl 120
inet_peer_threshold 65664
ip_autoconfig 0
ip_default_ttl 64
ip_dynaddr 0
ip_forward 0
ip_local_port_range 32768 61000
ip_no_pmtu_disc 0
ip_nonlocal_bind 0
ipfrag_high_thresh 262144
ipfrag_low_thresh 196608
ipfrag_secret_interval 600
ipfrag_time 30
tcp_abort_on_overflow 0
tcp_adv_win_scale 2
tcp_app_win 31
tcp_bic 1
tcp_bic_beta 819
tcp_bic_fast_convergence 1
tcp_bic_low_window 14
tcp_dsack 1
tcp_ecn 0
tcp_fack 1
tcp_fin_timeout 60
tcp_frto 0
tcp_keepalive_intvl 75
tcp_keepalive_probes 9
tcp_keepalive_time 7200
tcp_low_latency 0
tcp_max_orphans 8192
tcp_max_syn_backlog 1024
tcp_max_tw_buckets 180000
tcp_mem 8388608 8388608 8388608
tcp_moderate_rcvbuf 1
tcp_no_metrics_save 0
tcp_orphan_retries 0
tcp_reordering 3
tcp_retrans_collapse 1
tcp_retries1 3
tcp_retries2 15
tcp_rfc1337 0
tcp_rmem 4096 87380 8388608
tcp_sack 1
tcp_stdurg 0
tcp_syn_retries 5
tcp_synack_retries 5
tcp_timestamps 1
tcp_tso_win_divisor 8
tcp_tw_recycle 0
tcp_tw_reuse 0
tcp_vegas_alpha 2
tcp_vegas_beta 6
tcp_vegas_cong_avoid 0
tcp_vegas_gamma 2
tcp_westwood 0
tcp_window_scaling 1
tcp_wmem 4096 87380 8388608

--------------090709020305080106070102--
