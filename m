From: =?ISO-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Subject: Is this normal?
Date: Tue, 27 Jan 2009 15:05:37 +0100
Message-ID: <497F14B1.7070306@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.iq.pl ([86.111.241.19]:44144 "EHLO smtp.iq.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751423AbZA0OFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2009 09:05:45 -0500
Received: from unknown (HELO [192.168.1.10]) (itcare_pstaszewski@[83.7.203.157])
          (envelope-sender <pstaszewski@itcare.pl>)
          by smtp.iq.pl with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 27 Jan 2009 14:05:41 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have Linux that works as Router + traffic management with connection 
tracking enabled but without making NAT

About 600Mbit/s TX and 600Mbit/s RX forwarded traffic

iptables -L -n -v -t raw
Chain PREROUTING (policy ACCEPT 3340M packets, 2623G bytes)
 pkts bytes target     prot opt in     out     source               
destination
3339M 2621G NOTRACK    all  --  *      *       0.0.0.0/0            
0.0.0.0/0

Chain OUTPUT (policy ACCEPT 1978K packets, 157M bytes)
 pkts bytes target     prot opt in     out     source               
destination

iptables -L -n -v -t nat
Chain PREROUTING (policy ACCEPT 4073K packets, 299M bytes)
 pkts bytes target     prot opt in     out     source               
destination

Chain POSTROUTING (policy ACCEPT 3916K packets, 285M bytes)
 pkts bytes target     prot opt in     out     source               
destination

Chain OUTPUT (policy ACCEPT 604 packets, 29792 bytes)
 pkts bytes target     prot opt in     out     source               
destination


kernel 2.6.28.2
CPU: Core 2, speed 2999.98 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a 
unit mask of 0x00 (Unhalted core cycles) count 100000
samples  %        image name               app name                 
symbol name
14544205 15.8604  vmlinux                  vmlinux                  
ctnetlink_del_expect
11616986 12.6683  vmlinux                  vmlinux                  
native_read_tsc
6920732   7.5470  vmlinux                  vmlinux                  
_raw_spin_lock
3343941   3.6466  vmlinux                  vmlinux                  
mwait_idle
2176884   2.3739  vmlinux                  vmlinux                  
e1000_irq_enable
1513595   1.6506  vmlinux                  vmlinux                  
e1000_intr_msi
1319634   1.4391  vmlinux                  vmlinux                  
getnstimeofday
1265908   1.3805  vmlinux                  vmlinux                  
qdisc_graft
1178958   1.2857  vmlinux                  vmlinux                  
ip_rt_frag_needed
1170814   1.2768  vmlinux                  vmlinux                  
_raw_read_lock
1113191   1.2139  vmlinux                  vmlinux                  
delay_tsc
1093099   1.1920  vmlinux                  vmlinux                  
irq_entries_start
995446    1.0855  vmlinux                  vmlinux                  
reset_pollfunc
975392    1.0637  vmlinux                  vmlinux                  
e1000_xmit_frame
946739    1.0324  vmlinux                  vmlinux                  
tc_fill_qdisc
907080    0.9892  vmlinux                  vmlinux                  
tfilter_notify
797603    0.8698  vmlinux                  vmlinux                  
neigh_dump_info
769436    0.8391  vmlinux                  vmlinux                  
pci_add_new_bus
769383    0.8390  vmlinux                  vmlinux                  
ip_append_data
744820    0.8122  vmlinux                  vmlinux                  
tcp_sendpage
739239    0.8061  vmlinux                  vmlinux                  
e1000_clean_tx_irq
738983    0.8059  vmlinux                  vmlinux                  
ip_route_input
710808    0.7751  vmlinux                  vmlinux                  
tcp_read_sock
678607    0.7400  vmlinux                  vmlinux                  
get_next_timer_interrupt
653004    0.7121  vmlinux                  vmlinux                  
neigh_create
639425    0.6973  vmlinux                  vmlinux                  
e1000_clean_rx_irq
636684    0.6943  vmlinux                  vmlinux                  
try_to_identify
602787    0.6573  vmlinux                  vmlinux                  
neigh_update
602690    0.6572  vmlinux                  vmlinux                  
ide_config_drive_speed
575112    0.6272  vmlinux                  vmlinux                  
__linkwatch_run_queue
574527    0.6265  vmlinux                  vmlinux                  
check_addr
563458    0.6144  vmlinux                  vmlinux                  
ide_timing_compute
561892    0.6127  vmlinux                  vmlinux                  
ctrl_fill_info
547057    0.5966  vmlinux                  vmlinux                  
sfq_classify
522893    0.5702  vmlinux                  vmlinux                  
__do_softirq
516265    0.5630  vmlinux                  vmlinux                  kfree
507132    0.5530  vmlinux                  vmlinux                  
_raw_read_unlock
490762    0.5352  vmlinux                  vmlinux                  
_raw_write_lock
464860    0.5069  vmlinux                  vmlinux                  
ide_output_data
464615    0.5067  vmlinux                  vmlinux                  __delay
434003    0.4733  vmlinux                  vmlinux                  
_raw_spin_trylock
430010    0.4689  vmlinux                  vmlinux                  
tcp_disconnect
429545    0.4684  vmlinux                  vmlinux                  
nlattr_to_tcp
427496    0.4662  vmlinux                  vmlinux                  
_raw_spin_unlock
423345    0.4617  vmlinux                  vmlinux                  
pci_scan_single_device
421229    0.4593  vmlinux                  vmlinux                  
tick_nohz_stop_sched_tick
398204    0.4342  vmlinux                  vmlinux                  
neigh_table_clear
387181    0.4222  vmlinux                  vmlinux                  rb_erase
355428    0.3876  vmlinux                  vmlinux                  
rb_insert_color
336426    0.3669  vmlinux                  vmlinux                  
ide_input_data
309541    0.3376  oprofiled                oprofiled                (no 
symbols)
308007    0.3359  vmlinux                  vmlinux                  
nfnetlink_rcv_msg
306387    0.3341  vmlinux                  vmlinux                  
nf_unregister_queue_handler
300561    0.3278  vmlinux                  vmlinux                  put_page
297577    0.3245  vmlinux                  vmlinux                  
apic_timer_interrupt
296236    0.3230  vmlinux                  vmlinux                  
hfsc_reset_qdisc

 mpstat -P ALL 30
Linux 2.6.28.2 (GWR_01)         01/27/09

15:00:00     CPU   %user   %nice    %sys %iowait    %irq   %soft  
%steal   %idle    intr/s
15:00:30     all    0.09    0.00    0.04    0.00    0.45    7.37    
0.00   92.04 210216.87
15:00:30       0    0.37    0.00    0.00    0.00    0.00    0.00    
0.00   99.63      2.70
15:00:30       1    0.03    0.00    0.03    0.00    0.00    0.00    
0.00   99.93      2.70
15:00:30       2    0.07    0.00    0.03    0.00    0.00    0.00    
0.00   99.90      2.70
15:00:30       3    0.03    0.00    0.03    0.00    0.00    0.27    
0.00   99.67      2.70
15:00:30       4    0.20    0.00    0.00    0.00    1.43   16.25    
0.00   82.11  14010.83
15:00:30       5    0.00    0.00    0.07    0.00    0.00    0.00    
0.00   99.93      2.70
15:00:30       6    0.00    0.00    0.14    0.00    1.52   43.55    
0.00   54.79  56355.63
15:00:30       7    0.03    0.00    0.03    0.00    0.71    0.27    
0.00   98.95  51138.07


And another question:
Is LRO in ixgbe enabled by default ?
because this is router with ip_forwarding enabled
but:
 ethtool -S eth2
NIC statistics:
     rx_packets: 1719428796
     tx_packets: 1664288522
     rx_bytes: 3847311464
     tx_bytes: 2565533207
     lsc_int: 0
     tx_busy: 0
     non_eop_descs: 0
     rx_errors: 0
     tx_errors: 0
     rx_dropped: 0
     tx_dropped: 0
     multicast: 1486
     broadcast: 2038411
     rx_no_buffer_count: 0
     collisions: 0
     rx_over_errors: 0
     rx_crc_errors: 0
     rx_frame_errors: 0
     rx_fifo_errors: 0
     rx_missed_errors: 1526
     tx_aborted_errors: 0
     tx_carrier_errors: 0
     tx_fifo_errors: 0
     tx_heartbeat_errors: 0
     tx_timeout_count: 0
     tx_restart_queue: 0
     rx_long_length_errors: 0
     rx_short_length_errors: 0
     tx_tcp4_seg_ctxt: 0
     tx_tcp6_seg_ctxt: 0
     tx_flow_control_xon: 0
     rx_flow_control_xon: 0
     tx_flow_control_xoff: 0
     rx_flow_control_xoff: 0
     rx_csum_offload_good: 1680016740
     rx_csum_offload_errors: 2655
     tx_csum_offload_ctxt: 1670168232
     rx_header_split: 922926893
     alloc_rx_page_failed: 0
     alloc_rx_buff_failed: 0
     lro_aggregated: 11
     lro_flushed: 11
     tx_queue_0_packets: 222332847
     tx_queue_0_bytes: 167106714629
     tx_queue_1_packets: 200903291
     tx_queue_1_bytes: 155466221410
     tx_queue_2_packets: 209795520
     tx_queue_2_bytes: 173006255549
     tx_queue_3_packets: 217234971
     tx_queue_3_bytes: 186577501045
     tx_queue_4_packets: 209987843
     tx_queue_4_bytes: 179770929576
     tx_queue_5_packets: 190626670
     tx_queue_5_bytes: 144592465568
     tx_queue_6_packets: 215430893
     tx_queue_6_bytes: 177450717600
     tx_queue_7_packets: 203901846
     tx_queue_7_bytes: 167990992857
     rx_queue_0_packets: 223733090
     rx_queue_0_bytes: 181299694069
     rx_queue_1_packets: 208431607
     rx_queue_1_bytes: 157070054015
     rx_queue_2_packets: 212732207
     rx_queue_2_bytes: 161635409877
     rx_queue_3_packets: 219814455
     rx_queue_3_bytes: 168129281364
     rx_queue_4_packets: 220623171
     rx_queue_4_bytes: 162174698013
     rx_queue_5_packets: 206934276
     rx_queue_5_bytes: 160278411161
     rx_queue_6_packets: 207468151
     rx_queue_6_bytes: 165883360811
     rx_queue_7_packets: 220417106
     rx_queue_7_bytes: 179389219953


Counters like:
     lro_aggregated: 11
     lro_flushed: 11
Sometimes increase by 1 i don't know why
So i want to disable LRO in kernel config but i can't and:
cat .config | grep LRO
CONFIG_INET_LRO=y
and in menuconfig LRO in networking is hard checked (some dependencies 
maybee check LRO)
but i use ixgbe driver that have only checked DCA and nothing else.


##############################################################
And another thing is that host that is make NAT + TC with the same 
volume of traffic is performing better:
iptables -L  -n -v -t nat  | wc -l
9387

kernel 2.6.28-git9
CPU: Core 2, speed 2659.92 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Clock cycles when not halted) with a 
unit mask of 0x00 (Unhalted core cycles) count 100000
samples  %        app name                 symbol name
358238   13.9887  vmlinux                  u32_classify
263698   10.2970  vmlinux                  rb_next
180179    7.0357  vmlinux                  hfsc_dequeue
88596     3.4595  vmlinux                  rb_prev
73585     2.8734  vmlinux                  e1000_get_hw_control
65094     2.5418  vmlinux                  ipt_do_table
56184     2.1939  vmlinux                  _raw_spin_lock
53310     2.0817  vmlinux                  poll_idle
50998     1.9914  vmlinux                  e1000_intr_msi
45660     1.7830  vmlinux                  e1000_clean_rx_irq
44269     1.7286  vmlinux                  ip_route_input
41880     1.6354  vmlinux                  read_tsc
40750     1.5912  vmlinux                  hfsc_enqueue
33611     1.3125  vmlinux                  getnstimeofday
29305     1.1443  vmlinux                  rtsc_y2x
28617     1.1175  vmlinux                  rb_erase
28455     1.1111  vmlinux                  e1000_xmit_frame
27994     1.0931  vmlinux                  sfq_dequeue
27267     1.0647  vmlinux                  sfq_enqueue
27151     1.0602  vmlinux                  cftree_insert
25924     1.0123  vmlinux                  e1000_clean_tx_irq
24365     0.9514  vmlinux                  update_vf
23599     0.9215  vmlinux                  nf_iterate
23574     0.9205  vmlinux                  rb_last
22934     0.8955  vmlinux                  __nf_conntrack_find
22347     0.8726  vmlinux                  vttree_insert
21863     0.8537  vmlinux                  apic_timer_interrupt
20195     0.7886  vmlinux                  ip_forward
19602     0.7654  vmlinux                  get_next_timer_interrupt
18372     0.7174  vmlinux                  irq_entries_start
15870     0.6197  vmlinux                  __qdisc_run
15836     0.6184  vmlinux                  kfree
15825     0.6179  vmlinux                  __alloc_skb
15483     0.6046  vmlinux                  tcp_packet
14320     0.5592  vmlinux                  rb_insert_color
12174     0.4754  vmlinux                  rb_first
11826     0.4618  vmlinux                  ip_rcv
11391     0.4448  vmlinux                  native_sched_clock
11007     0.4298  vmlinux                  mwait_idle
10802     0.4218  vmlinux                  fn_trie_lookup
10686     0.4173  vmlinux                  skb_release_head_state
10606     0.4141  vmlinux                  __hash_conntrack
10084     0.3938  vmlinux                  dev_hard_start_xmit
9861      0.3851  vmlinux                  _raw_read_lock
9422      0.3679  vmlinux                  dst_release
9375      0.3661  vmlinux                  __nf_ct_refresh_acct
9303      0.3633  vmlinux                  __kmalloc
9255      0.3614  vmlinux                  dev_queue_xmit
9224      0.3602  vmlinux                  _raw_spin_trylock
8885      0.3469  vmlinux                  kmem_cache_alloc
8595      0.3356  vmlinux                  __do_softirq
8411      0.3284  vmlinux                  rtsc_x2y
8104      0.3164  vmlinux                  _raw_spin_unlock
7907      0.3088  vmlinux                  hrtimer_interrupt
7714      0.3012  vmlinux                  nf_conntrack_in
7615      0.2974  vmlinux                  hrtimer_start_range_ns

mpstat -P ALL 30
Linux 2.6.28-git9 (Main-NAT)    01/27/09

17:00:09     CPU   %user   %nice    %sys %iowait    %irq   %soft  
%steal   %idle    intr/s
17:00:39     all    1.07    0.00    0.26    0.02    0.08    1.65    
0.00   96.92  93550.23
17:00:39       0    0.73    0.00    0.33    0.03    0.03    2.13    
0.00   96.74  12124.87
17:00:39       1    1.43    0.00    0.23    0.00    0.10    1.14    
0.00   97.10  16517.13






