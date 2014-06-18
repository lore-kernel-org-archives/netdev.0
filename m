From: Jet Chen <jet.chen@intel.com>
Subject: [net] b58537a1f56: +89.2% netperf.Throughput_Mbps
Date: Wed, 18 Jun 2014 11:08:01 +0800
Message-ID: <53A10291.7090301@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030007000309040105040706"
Cc: netdev <netdev@vger.kernel.org>, lkp@01.org,
	Fengguang Wu <fengguang.wu@intel.com>
To: Daniel Borkmann <dborkman@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030007000309040105040706
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi Daniel,

FYI, we noticed the below changes on

commit b58537a1f5629bdc98a8b9dc2051ce0e952f6b4b ("net: sctp: fix permissions for rto_alpha and rto_beta knobs")

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
         950 ~ 1%     +93.7%       1841 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
         750 ~ 1%     +83.4%       1375 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
        1700 ~ 1%     +89.2%       3217 ~ 0%  TOTAL netperf.Throughput_Mbps

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        7841 ~ 0%     +50.4%      11792 ~ 0%  lkp-nex04/netperf/300s-200%-SCTP_RR
        7603 ~ 0%     +37.6%      10463 ~ 0%  lkp-nex05/netperf/300s-200%-SCTP_RR
       15445 ~ 0%     +44.1%      22256 ~ 0%  TOTAL netperf.Throughput_tps

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        5.93 ~ 1%     -99.0%       0.06 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        6.53 ~ 1%     -99.1%       0.06 ~12%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
       12.46 ~ 1%     -99.1%       0.12 ~ 6%  TOTAL perf-profile.cpu-cycles.sctp_get_af_specific.sctp_cmp_addr_exact.sctp_assoc_lookup_paddr.sctp_endpoint_lookup_assoc.sctp_sendmsg

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        6.35 ~ 0%     -98.3%       0.11 ~ 3%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        2.95 ~ 5%    -100.0%       0.00 ~ 0%  lkp-nex04/netperf/300s-200%-SCTP_RR
        2.26 ~ 6%    -100.0%       0.00 ~ 0%  lkp-nex05/netperf/300s-200%-SCTP_RR
        6.68 ~ 0%     -98.5%       0.10 ~10%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
       18.23 ~ 1%     -98.9%       0.21 ~ 7%  TOTAL perf-profile.cpu-cycles.sctp_get_af_specific.sctp_chunk_iif.sctp_ulpevent_make_rcvmsg.sctp_ulpq_tail_data.sctp_cmd_interpreter

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        3.07 ~ 0%     -99.0%       0.03 ~12%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        4.84 ~ 0%    -100.0%       0.00 ~ 0%  lkp-nex04/netperf/300s-200%-SCTP_RR
        3.92 ~ 5%    -100.0%       0.00 ~ 0%  lkp-nex05/netperf/300s-200%-SCTP_RR
        3.17 ~ 0%     -99.0%       0.03 ~12%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
       15.01 ~ 1%     -99.6%       0.06 ~12%  TOTAL perf-profile.cpu-cycles.sctp_get_af_specific.sctp_cmp_addr_exact.sctp_assoc_lookup_paddr.sctp_assoc_is_match.__sctp_lookup_association

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        1.92 ~ 1%     -97.9%       0.04 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        3.78 ~ 5%     -99.3%       0.03 ~18%  lkp-nex04/netperf/300s-200%-SCTP_RR
        2.91 ~ 5%     -99.0%       0.03 ~14%  lkp-nex05/netperf/300s-200%-SCTP_RR
        2.00 ~ 1%     -98.2%       0.04 ~13%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
       10.61 ~ 3%     -98.8%       0.13 ~10%  TOTAL perf-profile.cpu-cycles.sctp_get_af_specific.sctp_eat_data.sctp_sf_eat_data_6_2.sctp_do_sm.sctp_assoc_bh_rcv

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        3.36 ~ 0%     -97.1%       0.10 ~ 4%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        6.16 ~ 0%     -99.3%       0.04 ~23%  lkp-nex04/netperf/300s-200%-SCTP_RR
        4.91 ~ 5%     -98.9%       0.05 ~22%  lkp-nex05/netperf/300s-200%-SCTP_RR
        3.47 ~ 1%     -97.4%       0.09 ~ 7%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
       17.90 ~ 2%     -98.4%       0.28 ~11%  TOTAL perf-profile.cpu-cycles.sctp_get_af_specific.sctp_rcv.ip_local_deliver_finish.ip_local_deliver.ip_rcv_finish

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        6.94 ~ 0%     -97.3%       0.18 ~ 4%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        7.54 ~ 0%     -97.6%       0.18 ~10%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
       14.48 ~ 0%     -97.5%       0.36 ~ 7%  TOTAL perf-profile.cpu-cycles.sctp_get_af_specific.sctp_sockaddr_af.sctp_sendmsg.inet_sendmsg.sock_sendmsg

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        6207 ~ 0%    +273.8%      23202 ~36%  lkp-nex05/netperf/300s-200%-SCTP_RR
        6207 ~ 0%    +273.8%      23202 ~36%  TOTAL numa-vmstat.node3.nr_active_file

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
       24831 ~ 0%    +273.8%      92810 ~36%  lkp-nex05/netperf/300s-200%-SCTP_RR
       24831 ~ 0%    +273.8%      92810 ~36%  TOTAL numa-meminfo.node3.Active(file)

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
       27053 ~ 3%    +237.7%      91368 ~10%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
         606 ~26%     -68.2%        192 ~11%  lkp-nex05/netperf/300s-200%-SCTP_RR
       83164 ~14%    +322.9%     351725 ~26%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
      110824 ~12%    +300.0%     443286 ~23%  TOTAL cpuidle.C1E-NHM.usage

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
       16056 ~ 8%    +278.8%      60825 ~ 6%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
       56085 ~13%    +177.5%     155640 ~12%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
       72141 ~12%    +200.1%     216465 ~10%  TOTAL cpuidle.C1-NHM.usage

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        2.96 ~ 0%     +28.7%       3.81 ~ 4%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        4.55 ~ 2%     -86.3%       0.62 ~ 7%  lkp-nex04/netperf/300s-200%-SCTP_RR
        3.73 ~ 4%     -88.3%       0.44 ~ 2%  lkp-nex05/netperf/300s-200%-SCTP_RR
        3.04 ~ 0%     +65.8%       5.04 ~ 1%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
       14.29 ~ 2%     -30.6%       9.91 ~ 2%  TOTAL perf-profile.cpu-cycles.lock_timer_base.isra.34.mod_timer.sctp_transport_reset_timers.sctp_outq_flush.sctp_outq_uncork

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
       20838 ~ 3%     -42.8%      11916 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
       62995 ~10%     -78.7%      13392 ~10%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
       83834 ~ 8%     -69.8%      25309 ~ 6%  TOTAL cpuidle.C3-NHM.usage

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        2.21 ~ 1%     +22.3%       2.70 ~ 6%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        1.57 ~ 4%     -86.5%       0.21 ~11%  lkp-nex04/netperf/300s-200%-SCTP_RR
        1.29 ~ 6%     -89.2%       0.14 ~ 4%  lkp-nex05/netperf/300s-200%-SCTP_RR
        2.30 ~ 1%     +64.5%       3.79 ~ 2%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
        7.38 ~ 2%      -7.3%       6.84 ~ 4%  TOTAL perf-profile.cpu-cycles._raw_spin_lock_irqsave.mod_timer.sctp_transport_reset_timers.sctp_outq_flush.sctp_outq_uncork

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        6.74 ~ 0%     +17.9%       7.94 ~ 5%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        5.93 ~ 0%     -79.4%       1.22 ~ 4%  lkp-nex04/netperf/300s-200%-SCTP_RR
        4.78 ~ 6%     -80.4%       0.94 ~ 2%  lkp-nex05/netperf/300s-200%-SCTP_RR
        6.84 ~ 0%     +55.5%      10.63 ~ 1%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
       24.28 ~ 1%     -14.6%      20.73 ~ 3%  TOTAL perf-profile.cpu-cycles.sctp_transport_timeout.sctp_transport_reset_timers.sctp_outq_flush.sctp_outq_uncork.sctp_cmd_interpreter

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        0.86 ~ 4%    +172.3%       2.34 ~ 4%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        1.09 ~ 9%    +207.7%       3.34 ~ 5%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
        1.94 ~ 7%    +192.1%       5.68 ~ 5%  TOTAL perf-profile.cpu-cycles._raw_spin_lock.free_one_page.__free_pages_ok.__free_pages.__free_kmem_pages

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
       43260 ~ 2%    +158.2%     111705 ~28%  lkp-nex05/netperf/300s-200%-SCTP_RR
       43260 ~ 2%    +158.2%     111705 ~28%  TOTAL numa-meminfo.node3.Active

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
   1.439e+08 ~ 1%     +94.1%  2.793e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.434e+08 ~ 2%     +81.3%  2.599e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   2.872e+08 ~ 1%     +87.7%  5.392e+08 ~ 0%  TOTAL numa-numastat.node3.local_node

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
   1.439e+08 ~ 1%     +94.1%  2.793e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.434e+08 ~ 2%     +81.3%  2.599e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   2.873e+08 ~ 1%     +87.7%  5.392e+08 ~ 0%  TOTAL numa-numastat.node3.numa_hit

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
       52800 ~ 7%     -53.7%      24464 ~ 3%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
       52800 ~ 7%     -53.7%      24464 ~ 3%  TOTAL cpuidle.C6-NHM.usage

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        1.18 ~ 4%     +93.1%       2.28 ~ 5%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        1.38 ~ 6%    +141.2%       3.32 ~ 6%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
        2.56 ~ 5%    +119.0%       5.61 ~ 5%  TOTAL perf-profile.cpu-cycles._raw_spin_lock_irqsave.get_page_from_freelist.__alloc_pages_nodemask.alloc_kmem_pages_node.kmalloc_large_node

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
    33854097 ~ 2%    +111.8%   71718667 ~ 1%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
    56631220 ~ 2%     +99.7%  1.131e+08 ~ 1%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
    90485318 ~ 2%    +104.2%  1.848e+08 ~ 1%  TOTAL proc-vmstat.pgalloc_dma32

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
    71085188 ~ 1%     +93.5%  1.375e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
      165875 ~31%     +68.2%     279079 ~33%  lkp-nex05/netperf/300s-200%-SCTP_RR
    70852917 ~ 2%     +80.5%  1.279e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.421e+08 ~ 1%     +87.0%  2.657e+08 ~ 0%  TOTAL numa-vmstat.node3.numa_local

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
         568 ~16%     +42.3%        809 ~29%  lkp-nex04/netperf/300s-200%-SCTP_RR
         568 ~16%     +42.3%        809 ~29%  TOTAL numa-meminfo.node1.Mlocked

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
   1.452e+08 ~ 1%     +93.1%  2.804e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.426e+08 ~ 1%     +85.0%  2.638e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   2.878e+08 ~ 1%     +89.1%  5.442e+08 ~ 0%  TOTAL numa-numastat.node0.numa_hit

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
   1.452e+08 ~ 1%     +93.1%  2.804e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.426e+08 ~ 1%     +85.0%  2.638e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   2.878e+08 ~ 1%     +89.1%  5.442e+08 ~ 0%  TOTAL numa-numastat.node0.local_node

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
     5351090 ~19%     +66.0%    8883481 ~14%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
     7254502 ~10%    +103.9%   14794044 ~16%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
    12605592 ~14%     +87.8%   23677525 ~15%  TOTAL cpuidle.C1-NHM.time

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
   1.446e+08 ~ 1%     +93.2%  2.794e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.414e+08 ~ 0%     +84.4%  2.608e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
    2.86e+08 ~ 1%     +88.9%  5.402e+08 ~ 0%  TOTAL numa-numastat.node1.numa_hit

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
   1.446e+08 ~ 1%     +93.2%  2.794e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.414e+08 ~ 0%     +84.4%  2.608e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
    2.86e+08 ~ 1%     +88.9%  5.402e+08 ~ 0%  TOTAL numa-numastat.node1.local_node

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
   3.043e+09 ~ 1%     +93.6%  5.892e+09 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
   3.001e+09 ~ 1%     +83.4%  5.504e+09 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   6.044e+09 ~ 1%     +88.5%   1.14e+10 ~ 0%  TOTAL proc-vmstat.pgfree

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
   5.777e+08 ~ 1%     +93.5%  1.118e+09 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
   5.698e+08 ~ 1%     +83.3%  1.044e+09 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.147e+09 ~ 1%     +88.4%  2.162e+09 ~ 0%  TOTAL proc-vmstat.numa_local

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
   5.777e+08 ~ 1%     +93.5%  1.118e+09 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
   5.698e+08 ~ 1%     +83.3%  1.044e+09 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.148e+09 ~ 1%     +88.4%  2.162e+09 ~ 0%  TOTAL proc-vmstat.numa_hit

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
    71917522 ~ 1%     +92.1%  1.382e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
    70494566 ~ 0%     +84.2%  1.298e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.424e+08 ~ 1%     +88.2%   2.68e+08 ~ 0%  TOTAL numa-vmstat.node0.numa_local

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
    71921559 ~ 1%     +92.1%  1.382e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
    70498641 ~ 0%     +84.2%  1.298e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.424e+08 ~ 1%     +88.2%   2.68e+08 ~ 0%  TOTAL numa-vmstat.node0.numa_hit

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
   3.009e+09 ~ 1%     +93.4%   5.82e+09 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
   2.945e+09 ~ 1%     +83.1%  5.391e+09 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   5.954e+09 ~ 1%     +88.3%  1.121e+10 ~ 0%  TOTAL proc-vmstat.pgalloc_normal

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
    71389128 ~ 1%     +92.7%  1.376e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
    69896469 ~ 0%     +83.3%  1.281e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.413e+08 ~ 1%     +88.1%  2.657e+08 ~ 0%  TOTAL numa-vmstat.node1.numa_local

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
    71445543 ~ 1%     +92.7%  1.376e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
    69943098 ~ 0%     +83.2%  1.282e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.414e+08 ~ 1%     +88.0%  2.658e+08 ~ 0%  TOTAL numa-vmstat.node1.numa_hit

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
    71144941 ~ 1%     +93.4%  1.376e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
      244384 ~21%     +45.4%     355361 ~26%  lkp-nex05/netperf/300s-200%-SCTP_RR
    70900937 ~ 2%     +80.4%  1.279e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.423e+08 ~ 1%     +86.8%  2.659e+08 ~ 0%  TOTAL numa-vmstat.node3.numa_hit

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
    1.44e+08 ~ 1%     +93.7%  2.789e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.424e+08 ~ 3%     +82.4%  2.597e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   2.864e+08 ~ 2%     +88.1%  5.386e+08 ~ 0%  TOTAL numa-numastat.node2.numa_hit

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
    1.44e+08 ~ 1%     +93.7%  2.789e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.424e+08 ~ 3%     +82.4%  2.597e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   2.864e+08 ~ 2%     +88.1%  5.386e+08 ~ 0%  TOTAL numa-numastat.node2.local_node

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
    71218513 ~ 1%     +92.8%  1.373e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
    70566629 ~ 3%     +81.1%  1.278e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.418e+08 ~ 2%     +87.0%  2.652e+08 ~ 0%  TOTAL numa-vmstat.node2.numa_local

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
    71277689 ~ 1%     +92.8%  1.374e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
    70612117 ~ 3%     +81.1%  1.279e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   1.419e+08 ~ 2%     +86.9%  2.653e+08 ~ 0%  TOTAL numa-vmstat.node2.numa_hit

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
   1.049e+08 ~ 1%     +93.7%  2.031e+08 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
   3.011e+08 ~ 0%     +50.4%  4.528e+08 ~ 0%  lkp-nex04/netperf/300s-200%-SCTP_RR
    2.92e+08 ~ 0%     +37.6%  4.018e+08 ~ 0%  lkp-nex05/netperf/300s-200%-SCTP_RR
   1.034e+08 ~ 1%     +83.4%  1.897e+08 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
   8.014e+08 ~ 0%     +55.7%  1.247e+09 ~ 0%  TOTAL softirqs.NET_RX

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
         144 ~16%     +40.9%        203 ~29%  lkp-nex04/netperf/300s-200%-SCTP_RR
         234 ~15%     -16.4%        196 ~14%  lkp-nex05/netperf/300s-200%-SCTP_RR
         379 ~15%      +5.5%        400 ~21%  TOTAL numa-vmstat.node1.nr_unevictable

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
         578 ~16%     +41.0%        815 ~29%  lkp-nex04/netperf/300s-200%-SCTP_RR
         938 ~15%     -16.4%        784 ~14%  lkp-nex05/netperf/300s-200%-SCTP_RR
        1516 ~15%      +5.5%       1600 ~21%  TOTAL numa-meminfo.node1.Unevictable

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        4.99 ~ 0%     +58.4%       7.90 ~ 1%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        4.43 ~ 1%     +55.3%       6.87 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
        9.41 ~ 1%     +56.9%      14.77 ~ 1%  TOTAL perf-profile.cpu-cycles.copy_user_generic_string.sctp_user_addto_chunk.sctp_datamsg_from_user.sctp_sendmsg.inet_sendmsg

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
      156328 ~ 1%     +45.6%     227560 ~15%  lkp-nex05/netperf/300s-200%-SCTP_RR
      156328 ~ 1%     +45.6%     227560 ~15%  TOTAL numa-meminfo.node3.FilePages

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
       39081 ~ 1%     +45.6%      56889 ~15%  lkp-nex05/netperf/300s-200%-SCTP_RR
       39081 ~ 1%     +45.6%      56889 ~15%  TOTAL numa-vmstat.node3.nr_file_pages

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        1.09 ~12%     +42.2%       1.55 ~ 2%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        1.05 ~16%     +43.8%       1.51 ~ 6%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
        2.14 ~14%     +43.0%       3.06 ~ 4%  TOTAL perf-profile.cpu-cycles.get_page_from_freelist.__alloc_pages_nodemask.alloc_kmem_pages_node.kmalloc_large_node.__kmalloc_node_track_caller

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
    11745167 ~15%     +66.1%   19514308 ~22%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
    11745167 ~15%     +66.1%   19514308 ~22%  TOTAL cpuidle.C1E-NHM.time

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        3.95 ~ 1%     +47.3%       5.81 ~ 1%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        3.44 ~ 2%     +47.2%       5.06 ~ 1%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
        7.39 ~ 1%     +47.3%      10.88 ~ 1%  TOTAL perf-profile.cpu-cycles.memcpy.sctp_outq_flush.sctp_outq_uncork.sctp_cmd_interpreter.sctp_do_sm

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        2.14 ~ 1%     +44.7%       3.09 ~ 1%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        1.84 ~ 3%     +42.7%       2.63 ~ 2%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
        3.98 ~ 2%     +43.7%       5.72 ~ 1%  TOTAL perf-profile.cpu-cycles.memcpy.sctp_packet_transmit_chunk.sctp_outq_flush.sctp_outq_uncork.sctp_cmd_interpreter

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        5.27 ~ 0%     +44.6%       7.62 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        4.71 ~ 1%     +39.0%       6.55 ~ 1%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
        9.98 ~ 1%     +42.0%      14.17 ~ 1%  TOTAL perf-profile.cpu-cycles.copy_user_generic_string.skb_copy_datagram_iovec.sctp_recvmsg.sock_common_recvmsg.sock_recvmsg

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        0.92 ~ 3%     +44.9%       1.34 ~ 3%  lkp-nex04/netperf/300s-200%-SCTP_RR
        0.94 ~ 3%     +34.3%       1.26 ~ 4%  lkp-nex05/netperf/300s-200%-SCTP_RR
        1.86 ~ 3%     +39.5%       2.60 ~ 3%  TOTAL perf-profile.cpu-cycles.sctp_recvmsg

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        0.64 ~ 3%     +40.8%       0.90 ~ 8%  lkp-nex04/netperf/300s-200%-SCTP_RR
        0.64 ~ 3%     +40.8%       0.90 ~ 8%  TOTAL perf-profile.cpu-cycles.enqueue_entity.enqueue_task_fair.enqueue_task.activate_task.ttwu_do_activate

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        1.10 ~ 2%     +24.8%       1.37 ~ 3%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        1.10 ~ 3%     +55.9%       1.72 ~ 2%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
        2.20 ~ 2%     +40.4%       3.09 ~ 2%  TOTAL perf-profile.cpu-cycles.sctp_outq_flush.sctp_outq_uncork.sctp_cmd_interpreter.sctp_do_sm.sctp_assoc_bh_rcv

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        0.81 ~12%     +26.8%       1.03 ~ 2%  lkp-nex04/netperf/300s-200%-SCTP_RR
        0.81 ~12%     +26.8%       1.03 ~ 2%  TOTAL perf-profile.cpu-cycles.sctp_outq_flush.sctp_outq_uncork.sctp_cmd_interpreter.sctp_do_sm.sctp_primitive_SEND

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        0.94 ~ 3%     +40.4%       1.31 ~ 1%  lkp-nex04/netperf/300s-200%-SCTP_RR
        1.03 ~ 5%     +35.5%       1.39 ~ 4%  lkp-nex05/netperf/300s-200%-SCTP_RR
        1.96 ~ 4%     +37.8%       2.70 ~ 2%  TOTAL perf-profile.cpu-cycles.__schedule.schedule.schedule_timeout.sctp_recvmsg.sock_common_recvmsg

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        0.72 ~11%     +33.1%       0.96 ~ 2%  lkp-nex05/netperf/300s-200%-SCTP_RR
        0.72 ~11%     +33.1%       0.96 ~ 2%  TOTAL perf-profile.cpu-cycles.idle_cpu.select_task_rq_fair.try_to_wake_up.default_wake_function.autoremove_wake_function

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        1.14 ~ 7%     +36.1%       1.55 ~ 7%  lkp-nex04/netperf/300s-200%-SCTP_RR
        1.21 ~ 6%     +37.5%       1.66 ~ 4%  lkp-nex05/netperf/300s-200%-SCTP_RR
        2.34 ~ 7%     +36.8%       3.20 ~ 6%  TOTAL perf-profile.cpu-cycles.sctp_sendmsg.inet_sendmsg.sock_sendmsg.___sys_sendmsg.__sys_sendmsg

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        0.73 ~ 7%     +35.4%       0.99 ~ 2%  lkp-nex04/netperf/300s-200%-SCTP_RR
        0.75 ~ 4%     +32.3%       0.99 ~ 2%  lkp-nex05/netperf/300s-200%-SCTP_RR
        1.48 ~ 6%     +33.8%       1.98 ~ 2%  TOTAL perf-profile.cpu-cycles.select_task_rq_fair.try_to_wake_up.default_wake_function.autoremove_wake_function.__wake_up_common

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        0.76 ~ 9%     +38.9%       1.06 ~11%  lkp-nex04/netperf/300s-200%-SCTP_RR
        0.85 ~ 4%     +33.4%       1.13 ~ 5%  lkp-nex05/netperf/300s-200%-SCTP_RR
        1.61 ~ 6%     +36.0%       2.19 ~ 8%  TOTAL perf-profile.cpu-cycles.sctp_check_transmitted.sctp_outq_sack.sctp_cmd_interpreter.sctp_do_sm.sctp_assoc_bh_rcv

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        1897 ~18%     +27.9%       2427 ~11%  lkp-nex04/netperf/300s-200%-SCTP_RR
        1803 ~ 7%     +16.4%       2099 ~ 4%  lkp-nex05/netperf/300s-200%-SCTP_RR
        3700 ~12%     +22.3%       4527 ~ 8%  TOTAL proc-vmstat.pgmigrate_success

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        1897 ~18%     +27.9%       2427 ~11%  lkp-nex04/netperf/300s-200%-SCTP_RR
        1803 ~ 7%     +16.4%       2099 ~ 4%  lkp-nex05/netperf/300s-200%-SCTP_RR
        3700 ~12%     +22.3%       4527 ~ 8%  TOTAL proc-vmstat.numa_pages_migrated

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        0.63 ~ 9%     -14.2%       0.54 ~14%  lkp-nex04/netperf/300s-200%-SCTP_RR
        0.63 ~ 9%     -14.2%       0.54 ~14%  TOTAL turbostat.%c1

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        3097 ~ 3%     +19.3%       3695 ~ 8%  lkp-nex05/netperf/300s-200%-SCTP_RR
        3097 ~ 3%     +19.3%       3695 ~ 8%  TOTAL numa-vmstat.node3.nr_slab_reclaimable

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
       12389 ~ 3%     +19.3%      14780 ~ 8%  lkp-nex05/netperf/300s-200%-SCTP_RR
       12389 ~ 3%     +19.3%      14780 ~ 8%  TOTAL numa-meminfo.node3.SReclaimable

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
       10788 ~ 0%     +19.0%      12843 ~ 9%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
       10788 ~ 0%     +19.0%      12843 ~ 9%  TOTAL numa-meminfo.node0.SReclaimable

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        2696 ~ 0%     +19.0%       3210 ~ 9%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
        2696 ~ 0%     +19.0%       3210 ~ 9%  TOTAL numa-vmstat.node0.nr_slab_reclaimable

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
      634073 ~ 0%     +12.3%     712155 ~ 5%  lkp-nex05/netperf/300s-200%-SCTP_RR
      634073 ~ 0%     +12.3%     712155 ~ 5%  TOTAL numa-meminfo.node3.MemUsed

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
         727 ~ 4%     +12.1%        816 ~ 4%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
         727 ~ 4%     +12.1%        816 ~ 4%  TOTAL slabinfo.dnotify_mark.num_objs

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
         727 ~ 4%     +12.1%        816 ~ 4%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
         727 ~ 4%     +12.1%        816 ~ 4%  TOTAL slabinfo.dnotify_mark.active_objs

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
      121677 ~ 5%      -6.7%     113473 ~ 5%  lkp-nex04/netperf/300s-200%-SCTP_RR
      121677 ~ 5%      -6.7%     113473 ~ 5%  TOTAL meminfo.DirectMap4k

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
     1541914 ~ 3%     -10.5%    1380345 ~ 2%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
     1541914 ~ 3%     -10.5%    1380345 ~ 2%  TOTAL softirqs.RCU

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
       37167 ~ 3%     +10.3%      41005 ~ 2%  lkp-nex05/netperf/300s-200%-SCTP_RR
       37167 ~ 3%     +10.3%      41005 ~ 2%  TOTAL numa-meminfo.node3.Slab

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
       93363 ~ 0%      -9.2%      84779 ~ 1%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
       93363 ~ 0%      -9.2%      84779 ~ 1%  TOTAL proc-vmstat.pgactivate

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
        7017 ~ 3%     +15.3%       8091 ~14%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
        7017 ~ 3%     +15.3%       8091 ~14%  TOTAL numa-meminfo.node0.KernelStack

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
      174505 ~ 1%     +92.8%     336502 ~ 0%  lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY
     1942254 ~ 1%     +51.6%    2944825 ~ 0%  lkp-nex04/netperf/300s-200%-SCTP_RR
     1904295 ~ 0%     +37.7%    2621695 ~ 0%  lkp-nex05/netperf/300s-200%-SCTP_RR
      173470 ~ 1%     +82.5%     316560 ~ 0%  lkp-wsx02/netperf/300s-200%-10K-SCTP_STREAM_MANY
     4194525 ~ 0%     +48.3%    6219584 ~ 0%  TOTAL vmstat.system.cs

e4f7ae930afafd4  b58537a1f5629bdc98a8b9dc2
---------------  -------------------------
       66725 ~ 0%      +3.8%      69259 ~ 0%  lkp-nex04/netperf/300s-200%-SCTP_RR
       67344 ~ 0%      +2.5%      69040 ~ 0%  lkp-nex05/netperf/300s-200%-SCTP_RR
      134069 ~ 0%      +3.2%     138300 ~ 0%  TOTAL vmstat.system.in


Legend:
	~XX%    - stddev percent
	[+-]XX% - change percent


                                netperf.Throughput_Mbps

    1900 O+------O------------------------------------------------------------+
    1800 ++ O O     O O  O  O O  O  O O  O  O O  O O  O  O                    |
         |                                                                    |
    1700 ++                                                                   |
    1600 ++                                                                   |
         |                                                                    |
    1500 ++                                                                   |
    1400 ++                                                                   |
    1300 ++                                                                   |
         |                                                                    |
    1200 ++                                                                   |
    1100 ++                                                                   |
         |                                                                    |
    1000 *+. .*..*..*.*..*..*.  .*..*.*..*..*.*..*.  .*..*.  .*..*.*..*..*.  .*
     900 ++-*-----------------*--------------------*-------*---------------*--+


                                    vmstat.system.cs

    360000 ++-----------------------------------------------------------------+
    340000 O+      O    O            O            O                           |
           |  O O    O    O  O  O O    O  O  O O    O  O O                    |
    320000 ++                                                                 |
    300000 ++                                                                 |
           |                                                                  |
    280000 ++                                                                 |
    260000 ++                                                                 |
    240000 ++                                                                 |
           |                                                                  |
    220000 ++                                                                 |
    200000 ++                                                                 |
           |                                                                  |
    180000 *+.*.*..*.*..*.*..*..*.*..*.*..*..*.*..*.*..*.*..*..*.*..*.*..*.*..*
    160000 ++-----------------------------------------------------------------+


	[*] bisect-good sample
	[O] bisect-bad  sample


Disclaimer:
Results have been estimated based on internal Intel analysis and are provided
for informational purposes only. Any difference in system hardware or software
design or configuration may affect actual performance.

Thanks,
Jet


--------------030007000309040105040706
Content-Type: text/plain; charset=UTF-8;
 name="reproduce"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="reproduce"

ZWNobyBwZXJmb3JtYW5jZSA+IC9zeXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTAvY3B1ZnJl
cS9zY2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMvc3lz
dGVtL2NwdS9jcHUxL2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5vcgplY2hvIHBlcmZvcm1hbmNl
ID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1MTAvY3B1ZnJlcS9zY2FsaW5nX2dvdmVy
bm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMvc3lzdGVtL2NwdS9jcHUxMS9j
cHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJmb3JtYW5jZSA+IC9zeXMvZGV2aWNl
cy9zeXN0ZW0vY3B1L2NwdTEyL2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5vcgplY2hvIHBlcmZv
cm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1MTMvY3B1ZnJlcS9zY2FsaW5n
X2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMvc3lzdGVtL2NwdS9j
cHUxNC9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJmb3JtYW5jZSA+IC9zeXMv
ZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTE1L2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5vcgplY2hv
IHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1MTYvY3B1ZnJlcS9z
Y2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMvc3lzdGVt
L2NwdS9jcHUxNy9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJmb3JtYW5jZSA+
IC9zeXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTE4L2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5v
cgplY2hvIHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1MTkvY3B1
ZnJlcS9zY2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMv
c3lzdGVtL2NwdS9jcHUyL2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5vcgplY2hvIHBlcmZvcm1h
bmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1MjAvY3B1ZnJlcS9zY2FsaW5nX2dv
dmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMvc3lzdGVtL2NwdS9jcHUy
MS9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJmb3JtYW5jZSA+IC9zeXMvZGV2
aWNlcy9zeXN0ZW0vY3B1L2NwdTIyL2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5vcgplY2hvIHBl
cmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1MjMvY3B1ZnJlcS9zY2Fs
aW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMvc3lzdGVtL2Nw
dS9jcHUyNC9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJmb3JtYW5jZSA+IC9z
eXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTI1L2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5vcgpl
Y2hvIHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1MjYvY3B1ZnJl
cS9zY2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMvc3lz
dGVtL2NwdS9jcHUyNy9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJmb3JtYW5j
ZSA+IC9zeXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTI4L2NwdWZyZXEvc2NhbGluZ19nb3Zl
cm5vcgplY2hvIHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1Mjkv
Y3B1ZnJlcS9zY2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2Rldmlj
ZXMvc3lzdGVtL2NwdS9jcHUzL2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5vcgplY2hvIHBlcmZv
cm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1MzAvY3B1ZnJlcS9zY2FsaW5n
X2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMvc3lzdGVtL2NwdS9j
cHUzMS9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJmb3JtYW5jZSA+IC9zeXMv
ZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTMyL2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5vcgplY2hv
IHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1MzMvY3B1ZnJlcS9z
Y2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMvc3lzdGVt
L2NwdS9jcHUzNC9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJmb3JtYW5jZSA+
IC9zeXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTM1L2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5v
cgplY2hvIHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1MzYvY3B1
ZnJlcS9zY2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMv
c3lzdGVtL2NwdS9jcHUzNy9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJmb3Jt
YW5jZSA+IC9zeXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTM4L2NwdWZyZXEvc2NhbGluZ19n
b3Zlcm5vcgplY2hvIHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1
MzkvY3B1ZnJlcS9zY2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2Rl
dmljZXMvc3lzdGVtL2NwdS9jcHU0L2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5vcgplY2hvIHBl
cmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1NDAvY3B1ZnJlcS9zY2Fs
aW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMvc3lzdGVtL2Nw
dS9jcHU0MS9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJmb3JtYW5jZSA+IC9z
eXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTQyL2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5vcgpl
Y2hvIHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1NDMvY3B1ZnJl
cS9zY2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMvc3lz
dGVtL2NwdS9jcHU0NC9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJmb3JtYW5j
ZSA+IC9zeXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTQ1L2NwdWZyZXEvc2NhbGluZ19nb3Zl
cm5vcgplY2hvIHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1NDYv
Y3B1ZnJlcS9zY2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2Rldmlj
ZXMvc3lzdGVtL2NwdS9jcHU0Ny9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJm
b3JtYW5jZSA+IC9zeXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTQ4L2NwdWZyZXEvc2NhbGlu
Z19nb3Zlcm5vcgplY2hvIHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUv
Y3B1NDkvY3B1ZnJlcS9zY2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lz
L2RldmljZXMvc3lzdGVtL2NwdS9jcHU1L2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5vcgplY2hv
IHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1NTAvY3B1ZnJlcS9z
Y2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMvc3lzdGVt
L2NwdS9jcHU1MS9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJmb3JtYW5jZSA+
IC9zeXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTUyL2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5v
cgplY2hvIHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1NTMvY3B1
ZnJlcS9zY2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMv
c3lzdGVtL2NwdS9jcHU1NC9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJmb3Jt
YW5jZSA+IC9zeXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTU1L2NwdWZyZXEvc2NhbGluZ19n
b3Zlcm5vcgplY2hvIHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1
NTYvY3B1ZnJlcS9zY2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2Rl
dmljZXMvc3lzdGVtL2NwdS9jcHU1Ny9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBw
ZXJmb3JtYW5jZSA+IC9zeXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTU4L2NwdWZyZXEvc2Nh
bGluZ19nb3Zlcm5vcgplY2hvIHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9j
cHUvY3B1NTkvY3B1ZnJlcS9zY2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAv
c3lzL2RldmljZXMvc3lzdGVtL2NwdS9jcHU2L2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5vcgpl
Y2hvIHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1NjAvY3B1ZnJl
cS9zY2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2RldmljZXMvc3lz
dGVtL2NwdS9jcHU2MS9jcHVmcmVxL3NjYWxpbmdfZ292ZXJub3IKZWNobyBwZXJmb3JtYW5j
ZSA+IC9zeXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2NwdTYyL2NwdWZyZXEvc2NhbGluZ19nb3Zl
cm5vcgplY2hvIHBlcmZvcm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1NjMv
Y3B1ZnJlcS9zY2FsaW5nX2dvdmVybm9yCmVjaG8gcGVyZm9ybWFuY2UgPiAvc3lzL2Rldmlj
ZXMvc3lzdGVtL2NwdS9jcHU3L2NwdWZyZXEvc2NhbGluZ19nb3Zlcm5vcgplY2hvIHBlcmZv
cm1hbmNlID4gL3N5cy9kZXZpY2VzL3N5c3RlbS9jcHUvY3B1OC9jcHVmcmVxL3NjYWxpbmdf
Z292ZXJub3IKZWNobyBwZXJmb3JtYW5jZSA+IC9zeXMvZGV2aWNlcy9zeXN0ZW0vY3B1L2Nw
dTkvY3B1ZnJlcS9zY2FsaW5nX2dvdmVybm9yCm5ldHNlcnZlcgpuZXRwZXJmIC10IFNDVFBf
U1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RS
RUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFN
X01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01B
TlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkg
LWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMg
LUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMg
LWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwg
MzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAw
IC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0t
IC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1t
IDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEw
SwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpu
ZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRw
ZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJm
IC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10
IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFND
VFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBf
U1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RS
RUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFN
X01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01B
TlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkg
LWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMg
LUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMg
LWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwg
MzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAw
IC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0t
IC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1t
IDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEw
SwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpu
ZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRw
ZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJm
IC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10
IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFND
VFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBf
U1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RS
RUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFN
X01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01B
TlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkg
LWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMg
LUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMg
LWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwg
MzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAw
IC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0t
IC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1t
IDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEw
SwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpu
ZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRw
ZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJm
IC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10
IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFND
VFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBf
U1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RS
RUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFN
X01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01B
TlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkg
LWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMg
LUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMg
LWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwg
MzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAw
IC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0t
IC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1t
IDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEw
SwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpu
ZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRw
ZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJm
IC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10
IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFND
VFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBf
U1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RS
RUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFN
X01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01B
TlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkg
LWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMg
LUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMg
LWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwg
MzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAw
IC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0t
IC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1t
IDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEw
SwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpu
ZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRw
ZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJm
IC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10
IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFND
VFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBf
U1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RS
RUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFN
X01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01B
TlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkg
LWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMg
LUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMg
LWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwg
MzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAw
IC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0t
IC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1t
IDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEw
SwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpu
ZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRw
ZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJm
IC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10
IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFND
VFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBf
U1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RS
RUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFN
X01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01B
TlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkg
LWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMg
LUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMg
LWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwg
MzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAw
IC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0t
IC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1t
IDEwSwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEw
SwpuZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpu
ZXRwZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRw
ZXJmIC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJm
IC10IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10
IFNDVFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFND
VFBfU1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBf
U1RSRUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwpuZXRwZXJmIC10IFNDVFBfU1RS
RUFNX01BTlkgLWMgLUMgLWwgMzAwIC0tIC1tIDEwSwoKCg==
--------------030007000309040105040706--
