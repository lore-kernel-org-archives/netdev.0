From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [loopback] b17c706987f: +175.7% netperf.Throughput_Mbps
Date: Wed, 1 Oct 2014 15:54:40 +0800
Message-ID: <20141001075440.GC21294@wfg-t540p.sh.intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="i0/AhcQY5QxfSsSZ"
Content-Transfer-Encoding: 8bit
Cc: Dave Hansen <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, lkp@01.org,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--i0/AhcQY5QxfSsSZ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hi Daniel,

FYI, we noticed nice performance improvement in commit

b17c706987fa6f28bdc1771c8266e7a69e22adcb ("loopback: sctp: add NETIF_F_SCTP_CSUM to device features")

test case: lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8 
---------------  ------------------------- 
     %stddev        %change               %stddev
            \          |                 /
       664 ± 0%    +175.7%       1832 ± 0%  TOTAL netperf.Throughput_Mbps
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[63]:/.nr_running
    947669 ± 2%    +681.8%    7408572 ± 1%  TOTAL sched_debug.cfs_rq[63]:/.min_vruntime
     19701 ± 3%   +2814.0%     574098 ± 1%  TOTAL sched_debug.cpu#63.ttwu_local
     41754 ± 1%     -99.5%        200 ±43%  TOTAL softirqs.HRTIMER
         5 ±20%    +400.0%         29 ± 2%  TOTAL sched_debug.cpu#63.cpu_load[4]
      2.59 ± 1%    -100.0%       0.00 ± 0%  TOTAL perf-profile.cpu-cycles.intel_idle.cpuidle_enter_state.cpuidle_idle_call.arch_cpu_idle.cpu_startup_entry
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#63.nr_running
        72 ±48%     -95.8%          3 ±42%  TOTAL sched_debug.cfs_rq[62]:/.blocked_load_avg
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[62]:/.nr_running
      0.24 ± 7%   +2565.6%       6.50 ± 4%  TOTAL perf-profile.cpu-cycles.sctp_transport_timeout.sctp_transport_reset_timers.sctp_outq_flush.sctp_outq_uncork.sctp_cmd_interpreter
      0.22 ± 3%   +1442.3%       3.42 ± 2%  TOTAL perf-profile.cpu-cycles._raw_spin_lock_irqsave.get_page_from_freelist.__alloc_pages_nodemask.kmalloc_large_node.__kmalloc_node_track_caller
      0.27 ± 6%   +1100.0%       3.29 ± 2%  TOTAL perf-profile.cpu-cycles._raw_spin_lock.free_one_page.__free_pages_ok.__free_pages.__free_memcg_kmem_pages
      0.04 ±10%   +8463.2%       3.25 ± 2%  TOTAL perf-profile.cpu-cycles.lock_timer_base.isra.35.mod_timer.sctp_transport_reset_timers.sctp_outq_flush.sctp_outq_uncork
      0.04 ±13%   +6227.8%       2.28 ± 3%  TOTAL perf-profile.cpu-cycles.memcpy.sctp_packet_transmit_chunk.sctp_outq_flush.sctp_outq_uncork.sctp_cmd_interpreter
      0.00           +Inf%       1.97 ± 8%  TOTAL perf-profile.cpu-cycles._raw_spin_lock_irqsave.mod_timer.sctp_transport_reset_timers.sctp_outq_flush.sctp_outq_uncork
        11 ±44%   +9151.8%       1036 ±31%  TOTAL sched_debug.cfs_rq[62]:/.nr_spread_over
      1.15 ± 7%     -94.4%       0.06 ± 7%  TOTAL perf-profile.cpu-cycles._raw_spin_lock_bh.lock_sock_nested.sctp_recvmsg.sock_common_recvmsg.sock_recvmsg
  33688875 ± 2%     -89.6%    3504734 ±18%  TOTAL cpuidle.C1-NHM.time
    281217 ± 2%     -90.9%      25698 ±41%  TOTAL cpuidle.C1-NHM.usage
  45558795 ± 0%     -99.9%      27898 ±39%  TOTAL cpuidle.C3-NHM.usage
     39.61 ± 0%     -99.7%       0.11 ±30%  TOTAL turbostat.%c1
      5.60 ± 0%     -94.0%       0.34 ± 1%  TOTAL turbostat.%c3
    876992 ± 3%    +736.3%    7333987 ± 1%  TOTAL sched_debug.cfs_rq[62]:/.min_vruntime
     19686 ± 2%   +2810.9%     573039 ± 1%  TOTAL sched_debug.cpu#62.ttwu_local
         5 ±25%    +403.4%         29 ± 3%  TOTAL sched_debug.cpu#62.cpu_load[4]
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#62.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[61]:/.nr_running
         8 ±22%  +13481.4%       1168 ±36%  TOTAL sched_debug.cfs_rq[61]:/.nr_spread_over
    899343 ± 6%    +715.7%    7335525 ± 2%  TOTAL sched_debug.cfs_rq[61]:/.min_vruntime
     19673 ± 4%   +2790.5%     568655 ± 2%  TOTAL sched_debug.cpu#61.ttwu_local
    989853 ± 2%     -99.2%       7480 ±48%  TOTAL sched_debug.cpu#61.sched_goidle
         4 ±40%    +581.0%         28 ± 3%  TOTAL sched_debug.cpu#61.cpu_load[4]
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#61.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[60]:/.nr_running
    893662 ± 5%    +724.8%    7370847 ± 0%  TOTAL sched_debug.cfs_rq[60]:/.min_vruntime
     19607 ± 3%   +2827.4%     573986 ± 1%  TOTAL sched_debug.cpu#60.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#60.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[59]:/.nr_running
     86308 ±18%   +7142.5%    6250836 ± 8%  TOTAL sched_debug.cfs_rq[59]:/.max_vruntime
    899110 ± 4%    +717.5%    7350607 ± 0%  TOTAL sched_debug.cfs_rq[59]:/.min_vruntime
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#0.nr_running
     86308 ±18%   +7142.5%    6250836 ± 8%  TOTAL sched_debug.cfs_rq[59]:/.MIN_vruntime
     20221 ± 4%   +2739.2%     574120 ± 1%  TOTAL sched_debug.cpu#59.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#59.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[58]:/.nr_running
    370050 ± 3%     -98.8%       4378 ±24%  TOTAL sched_debug.cpu#0.sched_goidle
     32479 ± 4%   +1698.6%     584171 ± 1%  TOTAL sched_debug.cpu#0.ttwu_local
    947194 ± 4%    +676.5%    7354983 ± 1%  TOTAL sched_debug.cfs_rq[58]:/.min_vruntime
        19 ±12%  +26074.0%       5025 ±32%  TOTAL sched_debug.cfs_rq[0]:/.nr_spread_over
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[0]:/.nr_running
     20721 ± 4%   +2663.3%     572601 ± 1%  TOTAL sched_debug.cpu#58.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#58.nr_running
         0 ± 0%      +Inf%          1 ±33%  TOTAL sched_debug.cfs_rq[57]:/.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#1.nr_running
    964313 ± 4%    +662.7%    7355115 ± 0%  TOTAL sched_debug.cfs_rq[57]:/.min_vruntime
     21834 ± 6%   +2531.4%     574540 ± 1%  TOTAL sched_debug.cpu#57.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#57.nr_running
    354246 ± 1%     -98.7%       4745 ±38%  TOTAL sched_debug.cpu#1.sched_goidle
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[56]:/.nr_running
     28829 ± 5%   +1914.4%     580717 ± 0%  TOTAL sched_debug.cpu#1.ttwu_local
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[1]:/.nr_running
    960131 ± 3%    +667.5%    7368750 ± 1%  TOTAL sched_debug.cfs_rq[56]:/.min_vruntime
     21418 ± 2%   +2584.0%     574857 ± 0%  TOTAL sched_debug.cpu#56.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#2.nr_running
         4 ±17%    +534.8%         29 ± 3%  TOTAL sched_debug.cpu#56.cpu_load[4]
         5 ±18%    +433.3%         28 ± 2%  TOTAL sched_debug.cpu#56.cpu_load[3]
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#56.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[55]:/.nr_running
     71260 ±42%   +8857.8%    6383312 ± 6%  TOTAL sched_debug.cfs_rq[55]:/.max_vruntime
    935340 ± 4%    +686.3%    7354731 ± 1%  TOTAL sched_debug.cfs_rq[55]:/.min_vruntime
    363420 ± 1%     -98.9%       3993 ±40%  TOTAL sched_debug.cpu#2.sched_goidle
     71260 ±42%   +8857.8%    6383312 ± 6%  TOTAL sched_debug.cfs_rq[55]:/.MIN_vruntime
     19268 ± 3%   +2867.0%     571688 ± 2%  TOTAL sched_debug.cpu#55.ttwu_local
     29222 ± 4%   +1889.9%     581489 ± 0%  TOTAL sched_debug.cpu#2.ttwu_local
         5 ±33%    +457.7%         29 ± 2%  TOTAL sched_debug.cpu#55.cpu_load[4]
        21 ±10%   +5539.8%       1218 ±19%  TOTAL sched_debug.cfs_rq[2]:/.nr_spread_over
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[2]:/.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#55.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[54]:/.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#3.nr_running
     45064 ±18%  +14562.1%    6607460 ± 5%  TOTAL sched_debug.cfs_rq[54]:/.max_vruntime
    934539 ± 6%    +685.1%    7337176 ± 1%  TOTAL sched_debug.cfs_rq[54]:/.min_vruntime
     45064 ±18%  +14562.1%    6607460 ± 5%  TOTAL sched_debug.cfs_rq[54]:/.MIN_vruntime
     19262 ± 6%   +2872.1%     572494 ± 1%  TOTAL sched_debug.cpu#54.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#54.nr_running
    356613 ± 1%     -99.2%       2934 ±29%  TOTAL sched_debug.cpu#3.sched_goidle
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[53]:/.nr_running
     27577 ± 5%   +2003.9%     580222 ± 1%  TOTAL sched_debug.cpu#3.ttwu_local
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[3]:/.nr_running
    933523 ± 4%    +686.2%    7339367 ± 1%  TOTAL sched_debug.cfs_rq[53]:/.min_vruntime
     19832 ± 3%   +2803.2%     575758 ± 1%  TOTAL sched_debug.cpu#53.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#4.nr_running
         5 ±46%    +410.7%         28 ± 4%  TOTAL sched_debug.cpu#53.cpu_load[3]
         6 ±47%    +354.8%         28 ± 5%  TOTAL sched_debug.cpu#53.cpu_load[0]
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#53.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[52]:/.nr_running
    923091 ± 3%    +698.0%    7366148 ± 2%  TOTAL sched_debug.cfs_rq[52]:/.min_vruntime
    348410 ± 2%     -98.8%       4230 ±39%  TOTAL sched_debug.cpu#4.sched_goidle
     19701 ± 3%   +2820.0%     575293 ± 1%  TOTAL sched_debug.cpu#52.ttwu_local
     26645 ± 4%   +2076.8%     580019 ± 1%  TOTAL sched_debug.cpu#4.ttwu_local
    178678 ±25%   +3627.5%    6660167 ± 3%  TOTAL sched_debug.cfs_rq[4]:/.MIN_vruntime
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#52.nr_running
    178678 ±25%   +3627.5%    6660167 ± 3%  TOTAL sched_debug.cfs_rq[4]:/.max_vruntime
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[4]:/.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[51]:/.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#5.nr_running
    929685 ± 4%    +688.0%    7325719 ± 1%  TOTAL sched_debug.cfs_rq[51]:/.min_vruntime
     19761 ± 4%   +2813.8%     575800 ± 1%  TOTAL sched_debug.cpu#51.ttwu_local
         5 ±37%    +461.5%         29 ± 2%  TOTAL sched_debug.cpu#51.cpu_load[4]
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#51.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[50]:/.nr_running
     26189 ± 3%   +2110.9%     579032 ± 0%  TOTAL sched_debug.cpu#5.ttwu_local
    963932 ± 3%    +657.4%    7301196 ± 1%  TOTAL sched_debug.cfs_rq[50]:/.min_vruntime
     23557 ± 2%   +2326.4%     571608 ± 2%  TOTAL sched_debug.cpu#23.ttwu_local
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[5]:/.nr_running
     20098 ± 5%   +2752.9%     573394 ± 1%  TOTAL sched_debug.cpu#50.ttwu_local
         6 ±34%    +380.0%         28 ± 1%  TOTAL sched_debug.cpu#50.cpu_load[4]
         6 ±35%    +343.8%         28 ± 1%  TOTAL sched_debug.cpu#50.cpu_load[3]
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#6.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#50.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[49]:/.nr_running
        16 ± 8%   +4700.0%        768 ±49%  TOTAL sched_debug.cfs_rq[49]:/.nr_spread_over
     25690 ± 2%   +2152.9%     578774 ± 1%  TOTAL sched_debug.cpu#6.ttwu_local
    988774 ± 1%    +643.1%    7347606 ± 1%  TOTAL sched_debug.cfs_rq[49]:/.min_vruntime
        17 ±16%   +6484.7%       1119 ±36%  TOTAL sched_debug.cfs_rq[6]:/.nr_spread_over
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[6]:/.nr_running
     21655 ± 3%   +2554.9%     574933 ± 1%  TOTAL sched_debug.cpu#49.ttwu_local
    917931 ± 0%     -99.2%       7364 ±47%  TOTAL sched_debug.cpu#49.sched_goidle
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#49.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#7.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[48]:/.nr_running
    963896 ± 5%    +662.9%    7353616 ± 1%  TOTAL sched_debug.cfs_rq[48]:/.min_vruntime
     20962 ± 5%   +2638.5%     574061 ± 1%  TOTAL sched_debug.cpu#48.ttwu_local
    342563 ± 2%     -99.0%       3297 ±40%  TOTAL sched_debug.cpu#7.sched_goidle
     25834 ± 4%   +2138.5%     578300 ± 0%  TOTAL sched_debug.cpu#7.ttwu_local
         4 ±48%    +500.0%         28 ± 1%  TOTAL sched_debug.cpu#48.cpu_load[3]
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[7]:/.nr_running
         4 ±44%    +513.0%         28 ± 1%  TOTAL sched_debug.cpu#48.cpu_load[0]
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#48.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#8.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[47]:/.nr_running
   1026500 ± 4%    +606.8%    7255532 ± 1%  TOTAL sched_debug.cfs_rq[47]:/.min_vruntime
     21776 ± 3%   +2530.7%     572873 ± 1%  TOTAL sched_debug.cpu#47.ttwu_local
    940486 ± 1%     -99.3%       6905 ±46%  TOTAL sched_debug.cpu#47.sched_goidle
    375887 ± 2%     -98.8%       4502 ±40%  TOTAL sched_debug.cpu#8.sched_goidle
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#47.nr_running
        46 ±43%     -94.0%          2 ±41%  TOTAL sched_debug.cfs_rq[46]:/.blocked_load_avg
     27667 ± 3%   +1978.0%     574926 ± 1%  TOTAL sched_debug.cpu#8.ttwu_local
         6 ±34%    +370.0%         28 ± 1%  TOTAL sched_debug.cfs_rq[46]:/.runnable_load_avg
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[46]:/.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[8]:/.nr_running
    973194 ± 3%    +646.5%    7264433 ± 1%  TOTAL sched_debug.cfs_rq[46]:/.min_vruntime
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#9.nr_running
     22161 ± 2%   +2482.1%     572230 ± 1%  TOTAL sched_debug.cpu#46.ttwu_local
         4 ±15%    +525.0%         30 ± 2%  TOTAL sched_debug.cpu#46.cpu_load[4]
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#46.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[45]:/.nr_running
    359971 ± 2%     -99.1%       3085 ±41%  TOTAL sched_debug.cpu#9.sched_goidle
   1018595 ± 4%    +611.1%    7243421 ± 1%  TOTAL sched_debug.cfs_rq[45]:/.min_vruntime
     27131 ± 2%   +2017.8%     574580 ± 1%  TOTAL sched_debug.cpu#9.ttwu_local
    134404 ±31%   +4758.2%    6529609 ± 8%  TOTAL sched_debug.cfs_rq[9]:/.MIN_vruntime
     22294 ± 4%   +2467.1%     572326 ± 1%  TOTAL sched_debug.cpu#45.ttwu_local
    134404 ±31%   +4758.2%    6529609 ± 8%  TOTAL sched_debug.cfs_rq[9]:/.max_vruntime
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[9]:/.nr_running
         5 ±22%    +455.6%         30 ± 2%  TOTAL sched_debug.cpu#45.cpu_load[4]
         0 ± 0%      +Inf%          2 ±18%  TOTAL sched_debug.cpu#45.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[44]:/.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#10.nr_running
    360383 ± 1%     -98.8%       4421 ±45%  TOTAL sched_debug.cpu#10.sched_goidle
     27338 ± 3%   +2000.0%     574125 ± 1%  TOTAL sched_debug.cpu#10.ttwu_local
   1021430 ± 4%    +609.5%    7247197 ± 1%  TOTAL sched_debug.cfs_rq[44]:/.min_vruntime
    231918 ±24%   +2549.3%    6144271 ± 8%  TOTAL sched_debug.cfs_rq[10]:/.MIN_vruntime
    231918 ±24%   +2549.3%    6144271 ± 8%  TOTAL sched_debug.cfs_rq[10]:/.max_vruntime
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[10]:/.nr_running
     22562 ± 3%   +2442.1%     573549 ± 1%  TOTAL sched_debug.cpu#44.ttwu_local
         5 ±25%    +492.0%         29 ± 1%  TOTAL sched_debug.cpu#44.cpu_load[4]
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#11.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#44.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[43]:/.nr_running
   1019742 ± 2%    +614.0%    7280699 ± 1%  TOTAL sched_debug.cfs_rq[43]:/.min_vruntime
    366743 ± 3%     -98.8%       4544 ±48%  TOTAL sched_debug.cpu#11.sched_goidle
     22781 ± 3%   +2411.2%     572090 ± 1%  TOTAL sched_debug.cpu#43.ttwu_local
     27283 ± 5%   +1994.9%     571569 ± 1%  TOTAL sched_debug.cpu#11.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#43.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[11]:/.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[42]:/.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#12.nr_running
   1013625 ± 3%    +610.3%    7199592 ± 1%  TOTAL sched_debug.cfs_rq[42]:/.min_vruntime
     23285 ± 2%   +2357.3%     572199 ± 1%  TOTAL sched_debug.cpu#42.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#42.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[41]:/.nr_running
    363201 ± 5%     -99.2%       3010 ±32%  TOTAL sched_debug.cpu#12.sched_goidle
   1026049 ± 2%    +605.1%    7234511 ± 2%  TOTAL sched_debug.cfs_rq[41]:/.min_vruntime
     26558 ± 1%   +2059.8%     573625 ± 1%  TOTAL sched_debug.cpu#12.ttwu_local
     24712 ± 3%   +2225.8%     574772 ± 1%  TOTAL sched_debug.cpu#41.ttwu_local
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[12]:/.nr_running
    908047 ± 0%     -99.3%       6771 ±46%  TOTAL sched_debug.cpu#41.sched_goidle
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#41.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[40]:/.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#13.nr_running
   1045087 ± 1%    +592.6%    7238603 ± 1%  TOTAL sched_debug.cfs_rq[40]:/.min_vruntime
     23905 ± 4%   +2300.9%     573931 ± 1%  TOTAL sched_debug.cpu#40.ttwu_local
    362073 ± 4%     -99.0%       3783 ±43%  TOTAL sched_debug.cpu#13.sched_goidle
         6 ±45%    +383.3%         29 ± 0%  TOTAL sched_debug.cpu#40.cpu_load[4]
     27170 ± 6%   +2006.6%     572362 ± 1%  TOTAL sched_debug.cpu#13.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#40.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[13]:/.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[39]:/.nr_running
    956859 ± 2%    +664.8%    7318047 ± 1%  TOTAL sched_debug.cfs_rq[39]:/.min_vruntime
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#14.nr_running
     22156 ± 6%   +2515.2%     579425 ± 1%  TOTAL sched_debug.cpu#39.ttwu_local
         5 ±20%    +400.0%         29 ± 2%  TOTAL sched_debug.cpu#39.cpu_load[4]
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#39.nr_running
    342979 ± 2%     -99.1%       3153 ±32%  TOTAL sched_debug.cpu#14.sched_goidle
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[38]:/.nr_running
     25831 ± 2%   +2108.8%     570574 ± 1%  TOTAL sched_debug.cpu#14.ttwu_local
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[14]:/.nr_running
    998185 ± 4%    +630.6%    7292251 ± 1%  TOTAL sched_debug.cfs_rq[38]:/.min_vruntime
     21969 ± 3%   +2536.5%     579224 ± 1%  TOTAL sched_debug.cpu#38.ttwu_local
         0 ± 0%      +Inf%          2 ±18%  TOTAL sched_debug.cpu#15.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#38.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[37]:/.nr_running
         8 ±22%   +7077.3%        631 ±47%  TOTAL sched_debug.cfs_rq[37]:/.nr_spread_over
    976930 ± 2%    +653.4%    7359797 ± 1%  TOTAL sched_debug.cfs_rq[37]:/.min_vruntime
    365758 ± 2%     -98.9%       3877 ±47%  TOTAL sched_debug.cpu#15.sched_goidle
     22211 ± 5%   +2503.0%     578152 ± 0%  TOTAL sched_debug.cpu#37.ttwu_local
     25988 ± 4%   +2107.9%     573784 ± 1%  TOTAL sched_debug.cpu#15.ttwu_local
         4 ±23%    +559.1%         29 ± 2%  TOTAL sched_debug.cpu#37.cpu_load[4]
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[15]:/.nr_running
         5 ±14%    +442.3%         28 ± 2%  TOTAL sched_debug.cpu#37.cpu_load[3]
         5 ± 9%    +414.8%         27 ± 2%  TOTAL sched_debug.cpu#37.cpu_load[2]
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#37.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[36]:/.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#16.nr_running
        10 ±17%   +6420.8%        691 ±26%  TOTAL sched_debug.cfs_rq[36]:/.nr_spread_over
    951225 ± 5%    +672.6%    7349084 ± 1%  TOTAL sched_debug.cfs_rq[36]:/.min_vruntime
     22668 ± 5%   +2450.8%     578229 ± 1%  TOTAL sched_debug.cpu#36.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#36.nr_running
     25231 ± 3%   +2177.7%     574692 ± 1%  TOTAL sched_debug.cpu#16.ttwu_local
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[35]:/.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[16]:/.nr_running
    969215 ± 3%    +658.8%    7354084 ± 2%  TOTAL sched_debug.cfs_rq[35]:/.min_vruntime
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#17.nr_running
     22948 ± 6%   +2424.6%     579345 ± 1%  TOTAL sched_debug.cpu#35.ttwu_local
         4 ±44%    +615.0%         28 ± 3%  TOTAL sched_debug.cpu#35.cpu_load[4]
         4 ±48%    +518.2%         27 ± 4%  TOTAL sched_debug.cpu#35.cpu_load[0]
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#35.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[34]:/.nr_running
     24619 ± 2%   +2234.0%     574630 ± 1%  TOTAL sched_debug.cpu#17.ttwu_local
    985770 ± 4%    +646.0%    7353877 ± 1%  TOTAL sched_debug.cfs_rq[34]:/.min_vruntime
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[17]:/.nr_running
     23297 ± 6%   +2389.1%     579887 ± 1%  TOTAL sched_debug.cpu#34.ttwu_local
         4 ±42%    +534.8%         29 ± 2%  TOTAL sched_debug.cpu#34.cpu_load[4]
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#18.nr_running
         5 ±41%    +429.6%         28 ± 3%  TOTAL sched_debug.cpu#34.cpu_load[3]
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#34.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[33]:/.nr_running
        11 ±39%   +7127.3%        795 ±29%  TOTAL sched_debug.cfs_rq[33]:/.nr_spread_over
    952580 ± 1%    +670.8%    7342099 ± 1%  TOTAL sched_debug.cfs_rq[33]:/.min_vruntime
     24246 ± 4%   +2265.3%     573496 ± 1%  TOTAL sched_debug.cpu#18.ttwu_local
     24645 ± 6%   +2249.7%     579112 ± 1%  TOTAL sched_debug.cpu#33.ttwu_local
    933626 ± 1%     -99.3%       6613 ±47%  TOTAL sched_debug.cpu#33.sched_goidle
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[18]:/.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#33.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[32]:/.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#19.nr_running
    950196 ± 2%    +670.3%    7319391 ± 2%  TOTAL sched_debug.cfs_rq[32]:/.min_vruntime
     25033 ± 5%   +2211.6%     578682 ± 1%  TOTAL sched_debug.cpu#32.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#32.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[31]:/.nr_running
     23931 ± 3%   +2304.2%     575367 ± 1%  TOTAL sched_debug.cpu#19.ttwu_local
     23792 ± 1%   +2309.0%     573173 ± 1%  TOTAL sched_debug.cpu#31.ttwu_local
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[19]:/.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#31.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[30]:/.nr_running
     45.19 ± 0%    -100.0%       0.00 ± 0%  TOTAL perf-profile.cpu-cycles.__crc32c_le.chksum_update.crypto_shash_update.crc32c.sctp_csum_update
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#20.nr_running
     23990 ± 2%   +2299.0%     575544 ± 1%  TOTAL sched_debug.cpu#30.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#30.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[29]:/.nr_running
    333744 ± 2%     -99.1%       3032 ±30%  TOTAL sched_debug.cpu#20.sched_goidle
     23769 ± 2%   +2321.8%     575648 ± 1%  TOTAL sched_debug.cpu#20.ttwu_local
     23963 ± 2%   +2289.1%     572507 ± 1%  TOTAL sched_debug.cpu#29.ttwu_local
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[20]:/.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#29.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[28]:/.nr_running
        16 ±16%  +14806.2%       2385 ±48%  TOTAL sched_debug.cfs_rq[28]:/.nr_spread_over
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#21.nr_running
     23955 ± 2%   +2294.9%     573707 ± 1%  TOTAL sched_debug.cpu#28.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#28.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[27]:/.nr_running
    200672 ±41%   +3130.2%    6482112 ±11%  TOTAL sched_debug.cfs_rq[27]:/.max_vruntime
    333344 ± 3%     -99.4%       2160 ±44%  TOTAL sched_debug.cpu#21.sched_goidle
    200672 ±41%   +3130.2%    6482112 ±11%  TOTAL sched_debug.cfs_rq[27]:/.MIN_vruntime
     24388 ± 2%   +2254.3%     574189 ± 1%  TOTAL sched_debug.cpu#27.ttwu_local
     23766 ± 2%   +2316.8%     574378 ± 1%  TOTAL sched_debug.cpu#21.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#27.nr_running
        16 ±23%   +8230.9%       1349 ±31%  TOTAL sched_debug.cfs_rq[21]:/.nr_spread_over
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[21]:/.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[26]:/.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#22.nr_running
     24877 ± 2%   +2200.2%     572209 ± 1%  TOTAL sched_debug.cpu#26.ttwu_local
    333909 ± 4%     -98.5%       4876 ±31%  TOTAL sched_debug.cpu#26.sched_goidle
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#26.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[25]:/.nr_running
        21 ±22%   +8784.9%       1883 ±35%  TOTAL sched_debug.cfs_rq[25]:/.nr_spread_over
     24697 ± 4%   +2214.3%     571582 ± 1%  TOTAL sched_debug.cpu#25.ttwu_local
     24175 ± 5%   +2283.3%     576162 ± 1%  TOTAL sched_debug.cpu#22.ttwu_local
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#25.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[22]:/.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[24]:/.nr_running
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#23.nr_running
     25076 ± 2%   +2194.8%     575457 ± 1%  TOTAL sched_debug.cpu#24.ttwu_local
    336969 ± 2%     -99.1%       3193 ±49%  TOTAL sched_debug.cpu#24.sched_goidle
         0 ± 0%      +Inf%          2 ± 0%  TOTAL sched_debug.cpu#24.nr_running
         0 ± 0%      +Inf%          1 ± 0%  TOTAL sched_debug.cfs_rq[23]:/.nr_running
    420529 ±14%     -80.8%      80883 ± 6%  TOTAL sched_debug.cpu#24.avg_idle
        35 ± 1%    +394.3%        174 ± 0%  TOTAL vmstat.procs.r
    320932 ±15%     -77.7%      71461 ± 8%  TOTAL sched_debug.cpu#26.avg_idle
    295750 ±21%     -76.1%      70793 ±17%  TOTAL sched_debug.cpu#2.avg_idle
    623387 ± 0%     -79.5%     127567 ± 1%  TOTAL softirqs.SCHED
         6 ±42%    +320.6%         28 ± 1%  TOTAL sched_debug.cpu#40.cpu_load[3]
         6 ±33%    +376.7%         28 ± 3%  TOTAL sched_debug.cpu#51.cpu_load[3]
         6 ±27%    +358.1%         28 ± 4%  TOTAL sched_debug.cpu#62.cpu_load[3]
         6 ±27%    +358.1%         28 ± 2%  TOTAL sched_debug.cpu#59.cpu_load[4]
         5 ±20%    +403.4%         29 ± 2%  TOTAL sched_debug.cpu#44.cpu_load[3]
         5 ±25%    +437.0%         29 ± 2%  TOTAL sched_debug.cpu#38.cpu_load[4]
         6 ±21%    +361.3%         28 ± 3%  TOTAL sched_debug.cpu#46.cpu_load[1]
         6 ±10%    +380.0%         28 ± 4%  TOTAL sched_debug.cpu#46.cpu_load[2]
         6 ±18%    +364.5%         28 ± 2%  TOTAL sched_debug.cpu#44.cpu_load[2]
         6 ±32%    +364.5%         28 ± 1%  TOTAL sched_debug.cpu#36.cpu_load[4]
         6 ±21%    +358.1%         28 ± 2%  TOTAL sched_debug.cpu#44.cpu_load[1]
         6 ±29%    +354.8%         28 ± 3%  TOTAL sched_debug.cpu#44.cpu_load[0]
         6 ±44%    +361.3%         28 ± 1%  TOTAL sched_debug.cpu#32.cpu_load[4]
         6 ±33%    +373.3%         28 ± 2%  TOTAL sched_debug.cpu#55.cpu_load[3]
         6 ±28%    +323.5%         28 ± 4%  TOTAL sched_debug.cpu#46.cpu_load[0]
         5 ± 6%    +406.9%         29 ± 3%  TOTAL sched_debug.cpu#46.cpu_load[3]
    340647 ±14%     -77.1%      77839 ±14%  TOTAL sched_debug.cpu#25.avg_idle
         6 ±18%    +376.7%         28 ± 2%  TOTAL sched_debug.cpu#38.cpu_load[3]
         4 ±37%    +508.7%         28 ± 2%  TOTAL sched_debug.cpu#35.cpu_load[3]
         6 ±29%    +314.7%         28 ± 4%  TOTAL sched_debug.cpu#56.cpu_load[0]
         6 ±15%    +346.9%         28 ± 2%  TOTAL sched_debug.cpu#63.cpu_load[3]
         7 ±47%    +305.7%         28 ± 1%  TOTAL sched_debug.cpu#32.cpu_load[3]
         6 ±17%    +317.6%         28 ± 3%  TOTAL sched_debug.cpu#52.cpu_load[4]
         6 ±15%    +343.8%         28 ± 3%  TOTAL sched_debug.cpu#56.cpu_load[2]
         6 ±37%    +337.5%         28 ± 3%  TOTAL sched_debug.cpu#55.cpu_load[2]
         6 ±23%    +343.8%         28 ± 1%  TOTAL sched_debug.cpu#39.cpu_load[3]
         6 ±29%    +351.6%         28 ± 5%  TOTAL sched_debug.cpu#34.cpu_load[1]
         6 ±31%    +354.8%         28 ± 4%  TOTAL sched_debug.cpu#34.cpu_load[2]
         6 ±42%    +358.1%         28 ± 5%  TOTAL sched_debug.cpu#53.cpu_load[1]
         6 ±40%    +373.3%         28 ± 3%  TOTAL sched_debug.cpu#53.cpu_load[2]
         6 ±28%    +327.3%         28 ± 1%  TOTAL sched_debug.cpu#36.cpu_load[3]
         6 ±20%    +327.3%         28 ± 2%  TOTAL sched_debug.cpu#56.cpu_load[1]
         7 ±29%    +297.1%         27 ± 1%  TOTAL sched_debug.cpu#50.cpu_load[2]
         7 ±44%    +265.8%         27 ± 1%  TOTAL sched_debug.cpu#32.cpu_load[2]
    317802 ± 9%     -77.7%      70785 ± 9%  TOTAL sched_debug.cpu#4.avg_idle
    346844 ±10%     -77.6%      77616 ± 8%  TOTAL sched_debug.cpu#16.avg_idle
         4 ±40%    +475.0%         27 ± 2%  TOTAL sched_debug.cpu#35.cpu_load[1]
         5 ±35%    +452.0%         27 ± 2%  TOTAL sched_debug.cfs_rq[48]:/.runnable_load_avg
         4 ±40%    +470.8%         27 ± 2%  TOTAL sched_debug.cpu#35.cpu_load[2]
         5 ±18%    +385.7%         27 ± 4%  TOTAL sched_debug.cpu#37.cpu_load[0]
         5 ± 6%    +369.0%         27 ± 2%  TOTAL sched_debug.cpu#37.cpu_load[1]
    366939 ±13%     -78.7%      78115 ± 9%  TOTAL sched_debug.cpu#30.avg_idle
      1023 ±37%    +323.5%       4333 ± 2%  TOTAL sched_debug.cpu#48.curr->pid
    327585 ± 9%     -77.2%      74734 ±11%  TOTAL sched_debug.cpu#17.avg_idle
     12595 ± 0%     -76.7%       2929 ± 0%  TOTAL uptime.idle
    338343 ±14%     -78.4%      73057 ± 5%  TOTAL sched_debug.cpu#31.avg_idle
         6 ±37%    +353.1%         29 ± 4%  TOTAL sched_debug.cpu#58.cpu_load[4]
         7 ±23%    +322.9%         29 ± 3%  TOTAL sched_debug.cpu#47.cpu_load[4]
         7 ±28%    +316.7%         30 ± 2%  TOTAL sched_debug.cpu#42.cpu_load[4]
    316565 ±15%     -74.7%      80204 ±11%  TOTAL sched_debug.cpu#23.avg_idle
    295009 ±22%     -75.0%      73750 ± 9%  TOTAL sched_debug.cpu#22.avg_idle
  19299589 ± 1%    +316.6%   80411460 ± 1%  TOTAL proc-vmstat.pgalloc_dma32
         6 ±26%    +311.8%         28 ± 4%  TOTAL sched_debug.cpu#62.cpu_load[2]
         6 ±21%    +393.3%         29 ± 2%  TOTAL sched_debug.cpu#45.cpu_load[3]
         7 ±18%    +311.4%         28 ± 2%  TOTAL sched_debug.cpu#45.cpu_load[2]
         7 ±10%    +286.8%         29 ± 1%  TOTAL sched_debug.cfs_rq[45]:/.runnable_load_avg
         8 ±27%    +234.9%         28 ± 2%  TOTAL sched_debug.cpu#42.cpu_load[1]
         6 ±19%    +323.5%         28 ± 4%  TOTAL sched_debug.cpu#60.cpu_load[4]
         8 ±26%    +265.0%         29 ± 2%  TOTAL sched_debug.cpu#42.cpu_load[3]
         7 ±13%    +297.2%         28 ± 5%  TOTAL sched_debug.cfs_rq[38]:/.runnable_load_avg
         8 ±27%    +234.9%         28 ± 2%  TOTAL sched_debug.cpu#42.cpu_load[2]
         6 ±40%    +364.5%         28 ± 4%  TOTAL sched_debug.cpu#54.cpu_load[4]
    306463 ±16%     -72.5%      84417 ±11%  TOTAL sched_debug.cpu#7.avg_idle
    294085 ±13%     -74.4%      75243 ±11%  TOTAL sched_debug.cpu#58.avg_idle
    295178 ± 8%     -74.8%      74330 ±13%  TOTAL sched_debug.cpu#19.avg_idle
    310735 ±12%     -74.4%      79628 ±23%  TOTAL sched_debug.cpu#12.avg_idle
         7 ±21%    +275.7%         27 ± 3%  TOTAL sched_debug.cpu#59.cpu_load[3]
         7 ±30%    +277.8%         27 ± 5%  TOTAL sched_debug.cpu#62.cpu_load[1]
         7 ±40%    +300.0%         28 ± 0%  TOTAL sched_debug.cpu#40.cpu_load[2]
         6 ±34%    +314.7%         28 ± 2%  TOTAL sched_debug.cpu#51.cpu_load[2]
         7 ±49%    +280.6%         27 ± 4%  TOTAL sched_debug.cfs_rq[40]:/.runnable_load_avg
         7 ±34%    +297.1%         27 ± 4%  TOTAL sched_debug.cpu#55.cpu_load[1]
         8 ±20%    +245.0%         27 ± 1%  TOTAL sched_debug.cpu#36.cpu_load[1]
         7 ±23%    +286.1%         27 ± 1%  TOTAL sched_debug.cpu#36.cpu_load[2]
         7 ±16%    +288.9%         28 ± 3%  TOTAL sched_debug.cpu#52.cpu_load[3]
         7 ±13%    +278.4%         28 ± 2%  TOTAL sched_debug.cpu#63.cpu_load[2]
         7 ±23%    +288.9%         28 ± 2%  TOTAL sched_debug.cpu#39.cpu_load[2]
         7 ±28%    +271.1%         28 ± 1%  TOTAL sched_debug.cpu#39.cpu_load[1]
         7 ±18%    +288.9%         28 ± 5%  TOTAL sched_debug.cfs_rq[63]:/.runnable_load_avg
         6 ±28%    +302.9%         27 ± 2%  TOTAL sched_debug.cfs_rq[37]:/.runnable_load_avg
         7 ±30%    +255.3%         27 ± 6%  TOTAL sched_debug.cpu#38.cpu_load[0]
         7 ±25%    +283.3%         27 ± 4%  TOTAL sched_debug.cpu#38.cpu_load[1]
         6 ±22%    +324.2%         28 ± 3%  TOTAL sched_debug.cpu#38.cpu_load[2]
         6 ±25%    +308.8%         27 ± 1%  TOTAL sched_debug.cfs_rq[56]:/.runnable_load_avg
         7 ±38%    +267.6%         27 ± 5%  TOTAL sched_debug.cpu#62.cpu_load[0]
    317966 ±13%     -74.2%      82042 ± 9%  TOTAL sched_debug.cpu#27.avg_idle
    296746 ±16%     -74.7%      75078 ± 9%  TOTAL sched_debug.cpu#14.avg_idle
    298670 ±15%     -73.3%      79831 ±22%  TOTAL sched_debug.cpu#6.avg_idle
         6 ±32%    +302.9%         27 ± 5%  TOTAL sched_debug.cpu#34.cpu_load[0]
         7 ±10%    +260.5%         27 ± 3%  TOTAL sched_debug.cpu#52.cpu_load[2]
         6 ±23%    +297.1%         27 ± 0%  TOTAL sched_debug.cfs_rq[61]:/.runnable_load_avg
         8 ±39%    +216.3%         27 ± 1%  TOTAL sched_debug.cpu#32.cpu_load[1]
         7 ±30%    +252.6%         26 ± 2%  TOTAL sched_debug.cpu#50.cpu_load[0]
         6 ±38%    +302.9%         27 ± 1%  TOTAL sched_debug.cpu#40.cpu_load[1]
         7 ±16%    +283.3%         27 ± 2%  TOTAL sched_debug.cpu#63.cpu_load[1]
         7 ±27%    +255.3%         27 ± 2%  TOTAL sched_debug.cpu#50.cpu_load[1]
         6 ±44%    +335.5%         27 ± 3%  TOTAL sched_debug.cfs_rq[35]:/.runnable_load_avg
         6 ±39%    +300.0%         27 ± 2%  TOTAL sched_debug.cpu#40.cpu_load[0]
    294207 ±16%     -73.9%      76789 ±18%  TOTAL sched_debug.cpu#20.avg_idle
      1454 ±47%    +193.6%       4270 ± 1%  TOTAL sched_debug.cpu#32.curr->pid
    274384 ±28%     -64.9%      96227 ±33%  TOTAL sched_debug.cpu#33.avg_idle
    287321 ± 8%     -73.1%      77157 ±10%  TOTAL sched_debug.cpu#3.avg_idle
         7 ±10%    +255.3%         27 ± 4%  TOTAL sched_debug.cpu#52.cpu_load[1]
      1284 ±29%    +228.6%       4222 ± 0%  TOTAL sched_debug.cpu#43.curr->pid
    349008 ±15%     -74.2%      90084 ± 6%  TOTAL sched_debug.cpu#21.avg_idle
         9 ±11%    +230.6%         32 ± 4%  TOTAL sched_debug.cpu#49.cpu_load[4]
         7 ±30%    +281.6%         29 ± 2%  TOTAL sched_debug.cpu#43.cpu_load[2]
         7 ±29%    +297.3%         29 ± 2%  TOTAL sched_debug.cpu#43.cpu_load[3]
         6 ±38%    +323.5%         28 ± 4%  TOTAL sched_debug.cpu#54.cpu_load[3]
         8 ±29%    +223.3%         27 ±10%  TOTAL sched_debug.cfs_rq[58]:/.runnable_load_avg
         7 ±18%    +271.8%         29 ± 2%  TOTAL sched_debug.cpu#47.cpu_load[3]
         7 ±31%    +322.9%         29 ± 2%  TOTAL sched_debug.cpu#43.cpu_load[4]
         7 ±32%    +283.8%         28 ± 4%  TOTAL sched_debug.cpu#58.cpu_load[3]
         9 ±25%    +222.2%         29 ± 3%  TOTAL sched_debug.cpu#42.cpu_load[0]
    291808 ±12%     -72.2%      81207 ±12%  TOTAL sched_debug.cpu#0.avg_idle
     12900 ± 6%    +248.9%      45016 ± 0%  TOTAL sched_debug.cfs_rq[61]:/.avg->runnable_avg_sum
       282 ± 6%    +247.8%        982 ± 0%  TOTAL sched_debug.cfs_rq[61]:/.tg_runnable_contrib
    307360 ±20%     -75.2%      76165 ± 7%  TOTAL sched_debug.cpu#13.avg_idle
      1213 ±36%    +252.3%       4273 ± 0%  TOTAL sched_debug.cpu#35.curr->pid
   2108032 ± 5%     -71.2%     607806 ± 1%  TOTAL sched_debug.cpu#34.sched_count
   2130952 ± 9%     -71.4%     609735 ± 1%  TOTAL sched_debug.cpu#33.sched_count
         7 ±39%    +268.4%         28 ± 3%  TOTAL sched_debug.cpu#54.cpu_load[0]
         7 ±39%    +278.4%         28 ± 3%  TOTAL sched_debug.cfs_rq[53]:/.runnable_load_avg
         8 ±23%    +223.3%         27 ± 2%  TOTAL sched_debug.cpu#36.cpu_load[0]
         7 ±20%    +286.1%         27 ± 4%  TOTAL sched_debug.cpu#60.cpu_load[3]
         7 ±21%    +265.8%         27 ± 4%  TOTAL sched_debug.cfs_rq[50]:/.runnable_load_avg
         7 ±31%    +276.3%         28 ± 2%  TOTAL sched_debug.cpu#45.cpu_load[0]
         8 ±24%    +226.2%         27 ± 2%  TOTAL sched_debug.cfs_rq[55]:/.runnable_load_avg
         6 ±36%    +320.6%         28 ± 4%  TOTAL sched_debug.cfs_rq[44]:/.runnable_load_avg
         7 ±26%    +281.1%         28 ± 2%  TOTAL sched_debug.cpu#51.cpu_load[1]
         7 ±27%    +265.8%         27 ± 4%  TOTAL sched_debug.cpu#51.cpu_load[0]
         8 ±27%    +233.3%         28 ± 2%  TOTAL sched_debug.cpu#39.cpu_load[0]
         7 ±21%    +276.3%         28 ± 2%  TOTAL sched_debug.cpu#45.cpu_load[1]
       293 ± 8%    +234.7%        980 ± 0%  TOTAL sched_debug.cfs_rq[56]:/.tg_runnable_contrib
   2074224 ± 3%     -70.6%     609675 ± 2%  TOTAL sched_debug.cpu#63.sched_count
   2127419 ± 6%     -71.7%     601604 ± 1%  TOTAL sched_debug.cpu#46.sched_count
   2115949 ± 3%     -65.2%     737051 ±35%  TOTAL sched_debug.cpu#36.sched_count
     13414 ± 8%    +235.7%      45027 ± 0%  TOTAL sched_debug.cfs_rq[56]:/.avg->runnable_avg_sum
    267808 ±13%     -72.1%      74782 ±10%  TOTAL sched_debug.cpu#5.avg_idle
   2069493 ± 8%     -68.4%     654987 ±18%  TOTAL sched_debug.cpu#45.sched_count
     14044 ±11%    +220.7%      45039 ± 0%  TOTAL sched_debug.cfs_rq[55]:/.avg->runnable_avg_sum
   2053686 ± 4%     -70.7%     602700 ± 2%  TOTAL sched_debug.cpu#52.sched_count
    289450 ±13%     -68.8%      90401 ±15%  TOTAL sched_debug.cpu#1.avg_idle
       307 ±11%    +219.5%        980 ± 0%  TOTAL sched_debug.cfs_rq[55]:/.tg_runnable_contrib
   2002864 ± 8%     -69.9%     602844 ± 1%  TOTAL sched_debug.cpu#40.sched_count
   2035365 ± 2%     -70.3%     603651 ± 1%  TOTAL sched_debug.cpu#47.sched_count
         9 ±24%    +197.8%         26 ± 1%  TOTAL sched_debug.cfs_rq[59]:/.runnable_load_avg
         8 ±24%    +226.8%         26 ± 6%  TOTAL sched_debug.cpu#60.cpu_load[0]
         8 ±23%    +235.0%         26 ± 4%  TOTAL sched_debug.cpu#59.cpu_load[1]
         7 ±19%    +252.6%         26 ± 4%  TOTAL sched_debug.cpu#60.cpu_load[1]
         8 ±23%    +234.1%         27 ± 3%  TOTAL sched_debug.cpu#59.cpu_load[2]
         8 ±36%    +209.1%         27 ± 2%  TOTAL sched_debug.cfs_rq[32]:/.runnable_load_avg
         7 ±20%    +253.8%         27 ± 2%  TOTAL sched_debug.cpu#63.cpu_load[0]
         8 ±16%    +206.8%         27 ± 4%  TOTAL sched_debug.cfs_rq[52]:/.runnable_load_avg
         7 ±19%    +257.9%         27 ± 4%  TOTAL sched_debug.cpu#60.cpu_load[2]
   2008711 ± 1%     -70.0%     602980 ± 1%  TOTAL sched_debug.cpu#61.nr_switches
   2100707 ± 7%     -71.1%     606142 ± 2%  TOTAL sched_debug.cpu#53.sched_count
   2046800 ± 1%     -65.3%     710307 ±28%  TOTAL sched_debug.cpu#60.sched_count
   2091856 ± 3%     -70.6%     614687 ± 3%  TOTAL sched_debug.cpu#38.sched_count
   2062814 ± 3%     -70.7%     604560 ± 2%  TOTAL sched_debug.cpu#54.sched_count
     13554 ±11%    +232.3%      45048 ± 0%  TOTAL sched_debug.cfs_rq[35]:/.avg->runnable_avg_sum
       296 ±11%    +231.2%        982 ± 0%  TOTAL sched_debug.cfs_rq[35]:/.tg_runnable_contrib
      1474 ±29%    +188.2%       4249 ± 0%  TOTAL sched_debug.cpu#62.curr->pid
   2049101 ± 6%     -70.4%     607303 ± 2%  TOTAL sched_debug.cpu#41.sched_count
   2167538 ± 9%     -71.9%     609753 ± 2%  TOTAL sched_debug.cpu#39.sched_count
   2036680 ± 3%     -70.3%     605379 ± 1%  TOTAL sched_debug.cpu#51.sched_count
   2017924 ± 1%     -70.0%     604898 ± 0%  TOTAL sched_debug.cpu#59.sched_count
     14509 ±13%    +210.5%      45046 ± 0%  TOTAL sched_debug.cfs_rq[63]:/.avg->runnable_avg_sum
   2076058 ± 5%     -69.2%     640162 ±10%  TOTAL sched_debug.cpu#37.sched_count
      1225 ±36%    +253.2%       4329 ± 3%  TOTAL sched_debug.cpu#53.curr->pid
      1148 ±27%    +268.3%       4230 ± 1%  TOTAL sched_debug.cpu#61.curr->pid
     14570 ±13%    +209.0%      45024 ± 0%  TOTAL sched_debug.cfs_rq[34]:/.avg->runnable_avg_sum
   2020274 ± 0%     -69.8%     610215 ± 2%  TOTAL sched_debug.cpu#62.nr_switches
       319 ±13%    +208.0%        982 ± 0%  TOTAL sched_debug.cfs_rq[34]:/.tg_runnable_contrib
       317 ±13%    +208.1%        978 ± 0%  TOTAL sched_debug.cfs_rq[63]:/.tg_runnable_contrib
   2042951 ± 1%     -69.7%     618701 ± 2%  TOTAL sched_debug.cpu#62.sched_count
   2058101 ± 7%     -70.8%     600726 ± 1%  TOTAL sched_debug.cpu#44.sched_count
   1984924 ± 1%     -69.5%     604880 ± 0%  TOTAL sched_debug.cpu#59.nr_switches
   1971315 ± 1%     -69.3%     604542 ± 2%  TOTAL sched_debug.cpu#54.nr_switches
   2014162 ± 6%     -65.2%     700760 ±28%  TOTAL sched_debug.cpu#42.sched_count
   1953776 ± 2%     -68.8%     609656 ± 2%  TOTAL sched_debug.cpu#63.nr_switches
   2055362 ± 7%     -65.1%     717767 ±33%  TOTAL sched_debug.cpu#43.sched_count
      1231 ±29%    +249.4%       4303 ± 2%  TOTAL sched_debug.cpu#50.curr->pid
       313 ±10%    +213.7%        982 ± 0%  TOTAL sched_debug.cfs_rq[62]:/.tg_runnable_contrib
         7 ±13%    +255.3%         27 ± 6%  TOTAL sched_debug.cpu#52.cpu_load[0]
         8 ±31%    +202.3%         26 ± 3%  TOTAL sched_debug.cpu#32.cpu_load[0]
   1991792 ± 1%     -69.3%     611077 ± 1%  TOTAL sched_debug.cpu#60.nr_switches
     14342 ±10%    +214.0%      45031 ± 0%  TOTAL sched_debug.cfs_rq[62]:/.avg->runnable_avg_sum
   1942697 ± 1%     -69.0%     602682 ± 2%  TOTAL sched_debug.cpu#52.nr_switches
   1950644 ± 1%     -69.2%     601592 ± 1%  TOTAL sched_debug.cpu#46.nr_switches
   1992472 ± 1%     -61.6%     765257 ±25%  TOTAL sched_debug.cpu#50.sched_count
         8 ±20%    +241.5%         28 ± 4%  TOTAL sched_debug.cpu#58.cpu_load[1]
         9 ±12%    +215.6%         28 ± 2%  TOTAL sched_debug.cfs_rq[39]:/.runnable_load_avg
         7 ±31%    +283.8%         28 ± 2%  TOTAL sched_debug.cpu#54.cpu_load[2]
         8 ±22%    +238.1%         28 ± 2%  TOTAL sched_debug.cpu#47.cpu_load[2]
         8 ±26%    +250.0%         28 ± 4%  TOTAL sched_debug.cpu#58.cpu_load[2]
     13572 ±12%    +232.0%      45056 ± 0%  TOTAL sched_debug.cfs_rq[37]:/.avg->runnable_avg_sum
   2047201 ± 6%     -67.2%     670954 ±18%  TOTAL sched_debug.cpu#35.sched_count
       297 ±12%    +230.8%        983 ± 0%  TOTAL sched_debug.cfs_rq[37]:/.tg_runnable_contrib
   1955174 ± 2%     -69.1%     603605 ± 1%  TOTAL sched_debug.cpu#55.nr_switches
   1971669 ± 5%     -69.1%     608414 ± 1%  TOTAL sched_debug.cpu#49.sched_count
   1939844 ± 1%     -68.8%     605845 ± 1%  TOTAL sched_debug.cpu#36.nr_switches
   1949899 ± 1%     -68.9%     606124 ± 2%  TOTAL sched_debug.cpu#53.nr_switches
       315 ±12%    +211.7%        984 ± 0%  TOTAL sched_debug.cfs_rq[51]:/.tg_runnable_contrib
        12 ±27%    +166.7%         32 ± 6%  TOTAL sched_debug.cpu#49.cpu_load[2]
        11 ±21%    +184.2%         32 ± 5%  TOTAL sched_debug.cpu#49.cpu_load[3]
     14438 ±12%    +212.0%      45043 ± 0%  TOTAL sched_debug.cfs_rq[51]:/.avg->runnable_avg_sum
   2001341 ± 4%     -66.4%     671981 ±17%  TOTAL sched_debug.cpu#57.sched_count
    303710 ±17%     -70.0%      91263 ±13%  TOTAL sched_debug.cpu#9.avg_idle
   1900887 ± 1%     -68.4%     600434 ± 1%  TOTAL sched_debug.cpu#45.nr_switches
     14272 ±12%    +215.8%      45065 ± 0%  TOTAL sched_debug.cfs_rq[59]:/.avg->runnable_avg_sum
   1937164 ± 0%     -68.5%     609385 ± 1%  TOTAL sched_debug.cpu#37.nr_switches
   1974368 ± 1%     -69.1%     609730 ± 2%  TOTAL sched_debug.cpu#39.nr_switches
   1973848 ± 2%     -62.6%     738151 ±35%  TOTAL sched_debug.cpu#58.sched_count
   1912735 ± 1%     -68.5%     603190 ± 2%  TOTAL sched_debug.cpu#50.nr_switches
   1931643 ± 2%     -68.6%     607250 ± 2%  TOTAL sched_debug.cpu#58.nr_switches
      1377 ±14%    +216.7%       4363 ± 1%  TOTAL sched_debug.cpu#49.curr->pid
       312 ±12%    +214.1%        981 ± 0%  TOTAL sched_debug.cfs_rq[59]:/.tg_runnable_contrib
   1944033 ± 1%     -68.9%     605363 ± 1%  TOTAL sched_debug.cpu#51.nr_switches
   1915699 ± 1%     -68.1%     610629 ± 1%  TOTAL sched_debug.cpu#35.nr_switches
     15047 ±12%    +199.1%      45011 ± 0%  TOTAL sched_debug.cfs_rq[32]:/.avg->runnable_avg_sum
     46418 ± 2%    +213.2%     145374 ± 0%  TOTAL sched_debug.cfs_rq[62]:/.exec_clock
   1924241 ± 2%     -68.3%     609789 ± 2%  TOTAL sched_debug.cpu#38.nr_switches
   1912400 ± 1%     -68.4%     603629 ± 1%  TOTAL sched_debug.cpu#47.nr_switches
       329 ±12%    +197.8%        979 ± 0%  TOTAL sched_debug.cfs_rq[32]:/.tg_runnable_contrib
   1895051 ± 2%     -68.3%     600708 ± 1%  TOTAL sched_debug.cpu#44.nr_switches
     13983 ±14%    +222.1%      45044 ± 0%  TOTAL sched_debug.cfs_rq[44]:/.avg->runnable_avg_sum
   1901704 ± 1%     -67.9%     609715 ± 1%  TOTAL sched_debug.cpu#33.nr_switches
     14514 ± 2%    +214.1%      45583 ± 0%  TOTAL sched_debug.cfs_rq[33]:/.avg->runnable_avg_sum
       306 ±14%    +221.0%        982 ± 0%  TOTAL sched_debug.cfs_rq[44]:/.tg_runnable_contrib
   1926663 ± 0%     -68.2%     613403 ± 2%  TOTAL sched_debug.cpu#48.sched_count
       317 ± 2%    +212.6%        993 ± 0%  TOTAL sched_debug.cfs_rq[33]:/.tg_runnable_contrib
      1203 ±34%    +258.3%       4310 ± 1%  TOTAL sched_debug.cpu#56.curr->pid
     46837 ± 2%    +210.4%     145375 ± 0%  TOTAL sched_debug.cfs_rq[60]:/.exec_clock
   1874381 ± 1%     -67.9%     600905 ± 1%  TOTAL sched_debug.cpu#42.nr_switches
         8 ±16%    +238.1%         28 ± 3%  TOTAL sched_debug.cfs_rq[47]:/.runnable_load_avg
         9 ±12%    +200.0%         27 ± 4%  TOTAL sched_debug.cpu#58.cpu_load[0]
         9 ±24%    +213.3%         28 ± 2%  TOTAL sched_debug.cpu#47.cpu_load[1]
         9 ±28%    +200.0%         28 ± 1%  TOTAL sched_debug.cpu#47.cpu_load[0]
         8 ±34%    +239.0%         27 ± 4%  TOTAL sched_debug.cpu#55.cpu_load[0]
         8 ±15%    +222.7%         28 ± 3%  TOTAL sched_debug.cfs_rq[36]:/.runnable_load_avg
         8 ±23%    +246.3%         28 ± 3%  TOTAL sched_debug.cpu#43.cpu_load[1]
         8 ±22%    +250.0%         28 ± 2%  TOTAL sched_debug.cfs_rq[43]:/.runnable_load_avg
         9 ±37%    +213.3%         28 ± 4%  TOTAL sched_debug.cfs_rq[34]:/.runnable_load_avg
         7 ±32%    +268.4%         28 ± 3%  TOTAL sched_debug.cpu#54.cpu_load[1]
         9 ±37%    +208.9%         27 ± 4%  TOTAL sched_debug.cfs_rq[51]:/.runnable_load_avg
   1916043 ± 2%     -68.3%     607993 ± 2%  TOTAL sched_debug.cpu#57.nr_switches
    265392 ±17%     -64.3%      94795 ±22%  TOTAL sched_debug.cpu#43.avg_idle
   1889707 ± 1%     -68.3%     599744 ± 1%  TOTAL sched_debug.cpu#43.nr_switches
         9 ±29%    +227.1%         31 ± 3%  TOTAL sched_debug.cpu#33.cpu_load[4]
        39 ±46%    +117.4%         84 ±32%  TOTAL sched_debug.cfs_rq[17]:/.tg_load_contrib
   1867119 ± 0%     -67.6%     605812 ± 1%  TOTAL sched_debug.cpu#49.nr_switches
   1889889 ± 1%     -67.8%     607783 ± 1%  TOTAL sched_debug.cpu#34.nr_switches
     47035 ± 4%    +209.1%     145403 ± 0%  TOTAL sched_debug.cfs_rq[61]:/.exec_clock
   1860154 ± 1%     -67.6%     602684 ± 2%  TOTAL sched_debug.cpu#48.nr_switches
       325 ±10%    +202.2%        982 ± 0%  TOTAL sched_debug.cfs_rq[39]:/.tg_runnable_contrib
  66798546 ± 0%    +206.8%  2.049e+08 ± 0%  TOTAL softirqs.NET_RX
     13894 ±13%    +224.1%      45029 ± 0%  TOTAL sched_debug.cfs_rq[48]:/.avg->runnable_avg_sum
     14866 ±10%    +202.7%      44994 ± 0%  TOTAL sched_debug.cfs_rq[39]:/.avg->runnable_avg_sum
     14874 ±11%    +207.3%      45713 ± 0%  TOTAL sched_debug.cfs_rq[57]:/.avg->runnable_avg_sum
   1893238 ± 1%     -67.9%     608368 ± 1%  TOTAL sched_debug.cpu#56.sched_count
       304 ±13%    +222.6%        981 ± 0%  TOTAL sched_debug.cfs_rq[48]:/.tg_runnable_contrib
   1850633 ± 0%     -67.2%     606443 ± 2%  TOTAL sched_debug.cpu#41.nr_switches
    273840 ±22%     -69.2%      84378 ± 8%  TOTAL sched_debug.cpu#60.avg_idle
       325 ±12%    +206.1%        996 ± 0%  TOTAL sched_debug.cfs_rq[57]:/.tg_runnable_contrib
     14957 ±12%    +201.5%      45098 ± 0%  TOTAL sched_debug.cfs_rq[58]:/.avg->runnable_avg_sum
     47628 ± 2%    +205.5%     145491 ± 0%  TOTAL sched_debug.cfs_rq[51]:/.exec_clock
    271141 ±15%     -64.6%      96084 ±33%  TOTAL sched_debug.cpu#47.avg_idle
     47097 ± 2%    +208.9%     145500 ± 0%  TOTAL sched_debug.cfs_rq[59]:/.exec_clock
      1395 ±13%    +210.6%       4334 ± 2%  TOTAL sched_debug.cpu#55.curr->pid
     15193 ±10%    +196.8%      45096 ± 0%  TOTAL sched_debug.cfs_rq[50]:/.avg->runnable_avg_sum
       326 ±12%    +200.6%        981 ± 0%  TOTAL sched_debug.cfs_rq[58]:/.tg_runnable_contrib
       315 ± 8%    +211.4%        982 ± 0%  TOTAL sched_debug.cfs_rq[38]:/.tg_runnable_contrib
     14456 ± 8%    +211.3%      45004 ± 0%  TOTAL sched_debug.cfs_rq[38]:/.avg->runnable_avg_sum
     47896 ± 3%    +203.5%     145372 ± 0%  TOTAL sched_debug.cfs_rq[54]:/.exec_clock
       332 ±10%    +195.7%        984 ± 0%  TOTAL sched_debug.cfs_rq[50]:/.tg_runnable_contrib
   1865184 ± 2%     -67.4%     608353 ± 1%  TOTAL sched_debug.cpu#56.nr_switches
     47722 ± 2%    +204.7%     145411 ± 0%  TOTAL sched_debug.cfs_rq[55]:/.exec_clock
     47334 ± 2%    +207.3%     145475 ± 0%  TOTAL sched_debug.cfs_rq[52]:/.exec_clock
     15320 ± 5%    +193.8%      45011 ± 0%  TOTAL sched_debug.cfs_rq[46]:/.avg->runnable_avg_sum
     48192 ± 1%    +201.6%     145362 ± 0%  TOTAL sched_debug.cfs_rq[63]:/.exec_clock
     48037 ± 1%    +202.7%     145411 ± 0%  TOTAL sched_debug.cfs_rq[32]:/.exec_clock
      1497 ±19%    +193.5%       4395 ± 5%  TOTAL sched_debug.cpu#52.curr->pid
   1846875 ± 0%     -67.1%     607481 ± 1%  TOTAL sched_debug.cpu#32.nr_switches
    287922 ±23%     -70.6%      84722 ±16%  TOTAL sched_debug.cpu#11.avg_idle
     48162 ± 3%    +202.0%     145448 ± 0%  TOTAL sched_debug.cfs_rq[36]:/.exec_clock
       335 ± 5%    +192.7%        982 ± 0%  TOTAL sched_debug.cfs_rq[46]:/.tg_runnable_contrib
     47591 ± 2%    +205.6%     145417 ± 0%  TOTAL sched_debug.cfs_rq[53]:/.exec_clock
    270817 ±22%     -66.3%      91254 ±13%  TOTAL sched_debug.cpu#63.avg_idle
     15169 ±10%    +196.9%      45031 ± 0%  TOTAL sched_debug.cfs_rq[36]:/.avg->runnable_avg_sum
       332 ±10%    +196.3%        984 ± 0%  TOTAL sched_debug.cfs_rq[36]:/.tg_runnable_contrib
         9 ±31%    +195.7%         27 ± 3%  TOTAL sched_debug.cfs_rq[54]:/.runnable_load_avg
      1552 ±27%    +175.8%       4281 ± 2%  TOTAL sched_debug.cpu#60.curr->pid
     49056 ± 1%    +199.2%     146799 ± 0%  TOTAL sched_debug.cfs_rq[33]:/.exec_clock
      1431 ±22%    +201.8%       4321 ± 1%  TOTAL sched_debug.cpu#34.curr->pid
     48712 ± 2%    +198.8%     145545 ± 0%  TOTAL sched_debug.cfs_rq[50]:/.exec_clock
     48311 ± 1%    +201.0%     145402 ± 0%  TOTAL sched_debug.cfs_rq[39]:/.exec_clock
       332 ± 9%    +201.0%        999 ± 0%  TOTAL sched_debug.cfs_rq[49]:/.tg_runnable_contrib
    226926 ±13%     -62.6%      84981 ±24%  TOTAL sched_debug.cpu#38.avg_idle
     15180 ± 9%    +201.5%      45763 ± 0%  TOTAL sched_debug.cfs_rq[49]:/.avg->runnable_avg_sum
     48719 ± 2%    +198.5%     145438 ± 0%  TOTAL sched_debug.cfs_rq[56]:/.exec_clock
   1795031 ± 0%     -66.4%     602823 ± 1%  TOTAL sched_debug.cpu#40.nr_switches
     48496 ± 2%    +199.9%     145443 ± 0%  TOTAL sched_debug.cfs_rq[58]:/.exec_clock
     15260 ±11%    +195.2%      45042 ± 0%  TOTAL sched_debug.cfs_rq[40]:/.avg->runnable_avg_sum
    285472 ±25%     -68.5%      89860 ±28%  TOTAL sched_debug.cpu#15.avg_idle
       334 ±11%    +194.3%        982 ± 0%  TOTAL sched_debug.cfs_rq[40]:/.tg_runnable_contrib
     49933 ± 2%    +194.4%     147012 ± 0%  TOTAL sched_debug.cfs_rq[57]:/.exec_clock
     49101 ± 2%    +196.1%     145384 ± 0%  TOTAL sched_debug.cfs_rq[37]:/.exec_clock
     49003 ± 1%    +196.8%     145444 ± 0%  TOTAL sched_debug.cfs_rq[35]:/.exec_clock
      1390 ±22%    +206.7%       4265 ± 0%  TOTAL sched_debug.cpu#37.curr->pid
     48581 ± 3%    +199.4%     145429 ± 0%  TOTAL sched_debug.cfs_rq[48]:/.exec_clock
      1630 ±25%    +160.5%       4247 ± 2%  TOTAL sched_debug.cpu#47.curr->pid
     49123 ± 2%    +196.0%     145404 ± 0%  TOTAL sched_debug.cfs_rq[46]:/.exec_clock
    266050 ±20%     -59.4%     107922 ±24%  TOTAL sched_debug.cpu#52.avg_idle
     14978 ±10%    +200.9%      45075 ± 0%  TOTAL sched_debug.cfs_rq[45]:/.avg->runnable_avg_sum
      1417 ±21%    +204.3%       4312 ± 2%  TOTAL sched_debug.cpu#39.curr->pid
        12 ±26%    +160.7%         31 ± 9%  TOTAL sched_debug.cpu#49.cpu_load[1]
       327 ±10%    +198.7%        978 ± 0%  TOTAL sched_debug.cfs_rq[45]:/.tg_runnable_contrib
    270121 ±17%     -61.7%     103375 ±20%  TOTAL sched_debug.cpu#32.avg_idle
     50428 ± 2%    +189.1%     145774 ± 0%  TOTAL sched_debug.cfs_rq[42]:/.exec_clock
      1574 ±34%    +166.5%       4194 ± 1%  TOTAL sched_debug.cpu#45.curr->pid
     50663 ± 1%    +189.6%     146717 ± 0%  TOTAL sched_debug.cfs_rq[49]:/.exec_clock
     49273 ± 2%    +195.3%     145509 ± 0%  TOTAL sched_debug.cfs_rq[34]:/.exec_clock
     15310 ±13%    +194.0%      45007 ± 0%  TOTAL sched_debug.cfs_rq[60]:/.avg->runnable_avg_sum
    236078 ±11%     -65.9%      80473 ±14%  TOTAL sched_debug.cpu#41.avg_idle
     49673 ± 2%    +192.7%     145415 ± 0%  TOTAL sched_debug.cfs_rq[38]:/.exec_clock
         8 ±26%    +235.0%         26 ± 5%  TOTAL sched_debug.cpu#59.cpu_load[0]
     50433 ± 2%    +188.4%     145447 ± 0%  TOTAL sched_debug.cfs_rq[45]:/.exec_clock
     15213 ± 5%    +196.2%      45068 ± 0%  TOTAL sched_debug.cfs_rq[52]:/.avg->runnable_avg_sum
       334 ±13%    +193.4%        980 ± 0%  TOTAL sched_debug.cfs_rq[60]:/.tg_runnable_contrib
     50577 ± 1%    +187.9%     145609 ± 0%  TOTAL sched_debug.cfs_rq[43]:/.exec_clock
    249630 ±15%     -65.3%      86741 ± 5%  TOTAL sched_debug.cpu#8.avg_idle
       332 ± 5%    +194.9%        980 ± 0%  TOTAL sched_debug.cfs_rq[52]:/.tg_runnable_contrib
    235932 ± 9%     -62.3%      88954 ±19%  TOTAL sched_debug.cpu#34.avg_idle
     50890 ± 2%    +185.7%     145384 ± 0%  TOTAL sched_debug.cfs_rq[47]:/.exec_clock
     50930 ± 1%    +185.7%     145517 ± 0%  TOTAL sched_debug.cfs_rq[40]:/.exec_clock
     14328 ±16%    +214.3%      45037 ± 0%  TOTAL sched_debug.cfs_rq[53]:/.avg->runnable_avg_sum
     16062 ± 9%    +180.4%      45031 ± 0%  TOTAL sched_debug.cfs_rq[47]:/.avg->runnable_avg_sum
     51840 ± 1%    +183.3%     146858 ± 0%  TOTAL sched_debug.cfs_rq[41]:/.exec_clock
      1499 ±20%    +187.0%       4301 ± 1%  TOTAL sched_debug.cpu#51.curr->pid
     50662 ± 2%    +187.3%     145570 ± 0%  TOTAL sched_debug.cfs_rq[44]:/.exec_clock
    269032 ± 7%     -66.8%      89230 ±17%  TOTAL sched_debug.cpu#59.avg_idle
       313 ±16%    +212.5%        980 ± 0%  TOTAL sched_debug.cfs_rq[53]:/.tg_runnable_contrib
     16303 ±17%    +176.2%      45035 ± 0%  TOTAL sched_debug.cfs_rq[54]:/.avg->runnable_avg_sum
       356 ±17%    +174.9%        979 ± 0%  TOTAL sched_debug.cfs_rq[54]:/.tg_runnable_contrib
       351 ± 9%    +178.0%        977 ± 0%  TOTAL sched_debug.cfs_rq[47]:/.tg_runnable_contrib
     15587 ±11%    +189.2%      45070 ± 0%  TOTAL sched_debug.cfs_rq[43]:/.avg->runnable_avg_sum
       341 ±11%    +187.8%        982 ± 0%  TOTAL sched_debug.cfs_rq[43]:/.tg_runnable_contrib
  99841369 ± 0%    +180.1%  2.796e+08 ± 1%  TOTAL numa-numastat.node2.local_node
  99843858 ± 0%    +180.1%  2.796e+08 ± 1%  TOTAL numa-numastat.node2.numa_hit
        10 ±17%    +196.2%         30 ± 3%  TOTAL sched_debug.cpu#57.cpu_load[4]
        11 ±12%    +189.1%         31 ± 8%  TOTAL sched_debug.cpu#41.cpu_load[4]
      1560 ±11%    +175.1%       4292 ± 1%  TOTAL sched_debug.cpu#59.curr->pid
  49642548 ± 0%    +177.8%  1.379e+08 ± 1%  TOTAL numa-vmstat.node2.numa_local
         8 ±28%    +220.5%         28 ± 4%  TOTAL sched_debug.cpu#43.cpu_load[0]
  49698361 ± 0%    +177.6%   1.38e+08 ± 1%  TOTAL numa-vmstat.node2.numa_hit
    219871 ±18%     -57.9%      92485 ±15%  TOTAL sched_debug.cpu#62.avg_idle
  50123901 ± 0%    +178.0%  1.393e+08 ± 1%  TOTAL numa-vmstat.node0.numa_local
  50127863 ± 0%    +177.9%  1.393e+08 ± 1%  TOTAL numa-vmstat.node0.numa_hit
     16250 ± 5%    +178.5%      45253 ± 0%  TOTAL sched_debug.cfs_rq[42]:/.avg->runnable_avg_sum
  49861680 ± 0%    +176.2%  1.377e+08 ± 1%  TOTAL numa-vmstat.node3.numa_local
       355 ± 5%    +177.0%        985 ± 0%  TOTAL sched_debug.cfs_rq[42]:/.tg_runnable_contrib
  49917445 ± 0%    +176.0%  1.378e+08 ± 1%  TOTAL numa-vmstat.node3.numa_hit
      1564 ±12%    +175.2%       4304 ± 2%  TOTAL sched_debug.cpu#54.curr->pid
  49911338 ± 0%    +175.9%  1.377e+08 ± 1%  TOTAL numa-vmstat.node1.numa_local
    248524 ±15%     -58.0%     104482 ±29%  TOTAL sched_debug.cpu#46.avg_idle
  49966794 ± 0%    +175.7%  1.377e+08 ± 1%  TOTAL numa-vmstat.node1.numa_hit
      1429 ±20%    +198.6%       4269 ± 0%  TOTAL sched_debug.cpu#44.curr->pid
     16484 ± 8%    +175.8%      45465 ± 0%  TOTAL sched_debug.cfs_rq[41]:/.avg->runnable_avg_sum
       361 ± 8%    +174.8%        992 ± 0%  TOTAL sched_debug.cfs_rq[41]:/.tg_runnable_contrib
      1453 ±23%    +197.1%       4318 ± 1%  TOTAL sched_debug.cpu#57.curr->pid
      1424 ±28%    +213.8%       4470 ± 5%  TOTAL sched_debug.cpu#63.curr->pid
      1420 ±23%    +201.2%       4278 ± 3%  TOTAL sched_debug.cpu#58.curr->pid
    211265 ±21%     -57.9%      88934 ±31%  TOTAL sched_debug.cpu#39.avg_idle
        37 ±32%    +129.8%         86 ±10%  TOTAL sched_debug.cfs_rq[3]:/.tg_load_contrib
   2788857 ± 1%    +163.2%    7340919 ± 1%  TOTAL sched_debug.cfs_rq[16]:/.min_vruntime
    224622 ±17%     -59.3%      91521 ±15%  TOTAL sched_debug.cpu#35.avg_idle
   2764205 ± 1%    +161.1%    7216910 ± 1%  TOTAL sched_debug.cfs_rq[8]:/.min_vruntime
   2819278 ± 1%    +156.7%    7238266 ± 1%  TOTAL sched_debug.cfs_rq[10]:/.min_vruntime
   2837162 ± 1%    +159.3%    7357411 ± 1%  TOTAL sched_debug.cfs_rq[24]:/.min_vruntime
   2817770 ± 1%    +160.8%    7349390 ± 1%  TOTAL sched_debug.cfs_rq[17]:/.min_vruntime
        12 ±31%    +160.0%         31 ± 4%  TOTAL sched_debug.cpu#33.cpu_load[3]
   2839736 ± 1%    +154.5%    7225910 ± 1%  TOTAL sched_debug.cfs_rq[13]:/.min_vruntime
        37 ±38%     +86.6%         69 ±45%  TOTAL sched_debug.cfs_rq[27]:/.tg_load_contrib
      1826 ±15%    +133.4%       4262 ± 0%  TOTAL sched_debug.cpu#36.curr->pid
   2880692 ± 3%    +154.0%    7316909 ± 1%  TOTAL sched_debug.cfs_rq[0]:/.min_vruntime
      1543 ±16%    +175.8%       4257 ± 0%  TOTAL sched_debug.cpu#46.curr->pid
   2903723 ± 1%    +153.0%    7346423 ± 1%  TOTAL sched_debug.cfs_rq[20]:/.min_vruntime
   2853451 ± 1%    +156.8%    7328372 ± 1%  TOTAL sched_debug.cfs_rq[18]:/.min_vruntime
   2881811 ± 2%    +154.8%    7342530 ± 0%  TOTAL sched_debug.cfs_rq[25]:/.min_vruntime
      3.22 ± 1%    +149.8%       8.05 ± 3%  TOTAL perf-profile.cpu-cycles.copy_user_generic_string.sctp_user_addto_chunk.sctp_datamsg_from_user.sctp_sendmsg.inet_sendmsg
   2848635 ± 1%    +153.7%    7225776 ± 1%  TOTAL sched_debug.cfs_rq[12]:/.min_vruntime
   2878875 ± 2%    +155.2%    7346322 ± 1%  TOTAL sched_debug.cfs_rq[2]:/.min_vruntime
    222782 ±27%     -61.7%      85268 ± 9%  TOTAL sched_debug.cpu#56.avg_idle
   2831503 ± 1%    +154.5%    7205461 ± 1%  TOTAL sched_debug.cfs_rq[11]:/.min_vruntime
   2835663 ± 1%    +154.6%    7218527 ± 1%  TOTAL sched_debug.cfs_rq[9]:/.min_vruntime
      1704 ±26%    +152.9%       4309 ± 1%  TOTAL sched_debug.cpu#41.curr->pid
        12 ±35%    +130.6%         28 ± 2%  TOTAL sched_debug.cfs_rq[48]:/.load
   2844115 ± 0%    +154.4%    7235577 ± 1%  TOTAL sched_debug.cfs_rq[15]:/.min_vruntime
      1665 ±28%    +159.1%       4315 ± 1%  TOTAL sched_debug.cpu#33.curr->pid
   2892891 ± 1%    +154.2%    7353510 ± 1%  TOTAL sched_debug.cfs_rq[19]:/.min_vruntime
   2901579 ± 2%    +152.7%    7332677 ± 1%  TOTAL sched_debug.cfs_rq[22]:/.min_vruntime
   2896475 ± 2%    +154.3%    7366784 ± 0%  TOTAL sched_debug.cfs_rq[23]:/.min_vruntime
   2911824 ± 1%    +151.7%    7327805 ± 1%  TOTAL sched_debug.cfs_rq[1]:/.min_vruntime
   2966470 ± 1%    +147.9%    7354082 ± 1%  TOTAL sched_debug.cfs_rq[29]:/.min_vruntime
   2884101 ± 0%    +150.3%    7219627 ± 1%  TOTAL sched_debug.cfs_rq[14]:/.min_vruntime
   2925842 ± 1%    +151.9%    7369360 ± 1%  TOTAL sched_debug.cfs_rq[31]:/.min_vruntime
   2902721 ± 1%    +152.7%    7334172 ± 1%  TOTAL sched_debug.cfs_rq[21]:/.min_vruntime
   2924791 ± 2%    +150.8%    7336302 ± 1%  TOTAL sched_debug.cfs_rq[26]:/.min_vruntime
        11 ±26%    +154.2%         30 ± 2%  TOTAL sched_debug.cpu#57.cpu_load[3]
   2910713 ± 1%    +151.6%    7322791 ± 1%  TOTAL sched_debug.cfs_rq[3]:/.min_vruntime
   2952231 ± 2%    +149.6%    7369935 ± 0%  TOTAL sched_debug.cfs_rq[27]:/.min_vruntime
      1327 ±42%    +219.3%       4239 ± 0%  TOTAL sched_debug.cpu#40.curr->pid
   2975600 ± 0%    +146.9%    7348061 ± 1%  TOTAL sched_debug.cfs_rq[28]:/.min_vruntime
   2927020 ± 2%    +150.3%    7326407 ± 1%  TOTAL sched_debug.cfs_rq[5]:/.min_vruntime
   2937147 ± 0%    +148.1%    7287431 ± 1%  TOTAL sched_debug.cfs_rq[7]:/.min_vruntime
        12 ±16%    +151.6%         32 ±12%  TOTAL sched_debug.cpu#49.cpu_load[0]
   2972203 ± 1%    +146.7%    7331240 ± 0%  TOTAL sched_debug.cfs_rq[30]:/.min_vruntime
   2917430 ± 1%    +149.9%    7291729 ± 1%  TOTAL sched_debug.cfs_rq[4]:/.min_vruntime
         9 ±19%    +177.6%         27 ± 4%  TOTAL sched_debug.cfs_rq[60]:/.runnable_load_avg
   2903992 ± 2%    +150.8%    7282050 ± 1%  TOTAL sched_debug.cfs_rq[6]:/.min_vruntime
        37 ±31%    +113.3%         80 ±23%  TOTAL sched_debug.cfs_rq[29]:/.tg_load_contrib
    230273 ±17%     -51.7%     111201 ±32%  TOTAL sched_debug.cpu#50.avg_idle
      0.70 ± 1%    +140.3%       1.68 ± 3%  TOTAL perf-profile.cpu-cycles.get_page_from_freelist.__alloc_pages_nodemask.kmalloc_large_node.__kmalloc_node_track_caller.__kmalloc_reserve
    206691 ±15%     -57.8%      87201 ± 8%  TOTAL sched_debug.cpu#61.avg_idle
    259396 ± 5%    +122.7%     577766 ± 1%  TOTAL sched_debug.cpu#62.ttwu_count
        12 ±34%    +134.9%         29 ± 3%  TOTAL sched_debug.cpu#57.cpu_load[2]
    269666 ±16%     -57.7%     114191 ±17%  TOTAL sched_debug.cpu#36.avg_idle
        14 ±36%    +119.7%         31 ± 5%  TOTAL sched_debug.cpu#33.cpu_load[2]
      1706 ±16%    +149.8%       4262 ± 0%  TOTAL sched_debug.cpu#38.curr->pid
    242840 ± 4%     -54.8%     109685 ±27%  TOTAL sched_debug.cpu#45.avg_idle
    262430 ± 5%    +120.6%     578956 ± 1%  TOTAL sched_debug.cpu#60.ttwu_count
    139692 ± 4%     -54.6%      63480 ± 2%  TOTAL proc-vmstat.numa_hint_faults
        12 ±19%    +148.4%         31 ± 9%  TOTAL sched_debug.cpu#41.cpu_load[3]
    264847 ± 9%    +116.3%     572756 ± 2%  TOTAL sched_debug.cpu#61.ttwu_count
      0.50 ± 7%    +122.0%       1.11 ±12%  TOTAL perf-profile.cpu-cycles.sctp_sendmsg.inet_sendmsg.sock_sendmsg.___sys_sendmsg.__sys_sendmsg
        30 ±12%    +115.3%         64 ±46%  TOTAL sched_debug.cfs_rq[19]:/.tg_load_contrib
        11 ±28%    +139.0%         28 ± 5%  TOTAL sched_debug.cfs_rq[42]:/.runnable_load_avg
    263882 ± 5%    +119.9%     580288 ± 1%  TOTAL sched_debug.cpu#59.ttwu_count
        15 ±41%    +105.3%         30 ± 7%  TOTAL sched_debug.cpu#33.cpu_load[1]
        15 ±41%     +97.5%         31 ±10%  TOTAL sched_debug.cpu#33.cpu_load[0]
    232649 ± 8%     -53.9%     107165 ± 9%  TOTAL sched_debug.cpu#37.avg_idle
      1870 ±19%    +126.4%       4234 ± 0%  TOTAL sched_debug.cpu#42.curr->pid
    276936 ± 2%    +110.2%     582259 ± 1%  TOTAL sched_debug.cpu#32.ttwu_count
        32 ±13%    +116.7%         70 ±31%  TOTAL sched_debug.cfs_rq[24]:/.tg_load_contrib
      3.48 ± 0%    +111.1%       7.35 ± 1%  TOTAL perf-profile.cpu-cycles.copy_user_generic_string.skb_copy_datagram_iovec.sctp_recvmsg.sock_common_recvmsg.sock_recvmsg
    276884 ± 2%    +111.1%     584406 ± 1%  TOTAL sched_debug.cpu#33.ttwu_count
    278248 ± 4%    +107.0%     575968 ± 2%  TOTAL sched_debug.cpu#55.ttwu_count
    276813 ± 5%    +109.4%     579782 ± 1%  TOTAL sched_debug.cpu#51.ttwu_count
    274908 ± 2%    +110.4%     578527 ± 1%  TOTAL sched_debug.cpu#52.ttwu_count
    276883 ± 5%    +108.8%     578248 ± 1%  TOTAL sched_debug.cpu#53.ttwu_count
        13 ±48%    +127.3%         30 ± 8%  TOTAL sched_debug.cpu#57.cpu_load[0]
        12 ±42%    +130.2%         29 ± 3%  TOTAL sched_debug.cpu#57.cpu_load[1]
        12 ±47%    +159.0%         31 ±13%  TOTAL sched_debug.cfs_rq[41]:/.runnable_load_avg
     96427 ± 3%     -51.4%      46839 ± 0%  TOTAL proc-vmstat.numa_hint_faults_local
        14 ±23%    +113.5%         31 ±11%  TOTAL sched_debug.cpu#41.cpu_load[2]
    281119 ± 3%    +105.5%     577638 ± 1%  TOTAL sched_debug.cpu#63.ttwu_count
    279804 ± 7%    +105.6%     575372 ± 1%  TOTAL sched_debug.cpu#54.ttwu_count
    285799 ± 3%    +104.0%     583075 ± 1%  TOTAL sched_debug.cpu#39.ttwu_count
    291642 ±21%     -55.2%     130660 ±18%  TOTAL sched_debug.cpu#40.avg_idle
       140 ±31%     -57.1%         60 ±44%  TOTAL sched_debug.cfs_rq[43]:/.tg_load_contrib
     13879 ± 0%    +104.3%      28362 ± 0%  TOTAL proc-vmstat.pgactivate
    251355 ±27%     -49.9%     126023 ±33%  TOTAL sched_debug.cpu#42.avg_idle
    284829 ± 5%    +104.2%     581719 ± 1%  TOTAL sched_debug.cpu#36.ttwu_count
    287754 ± 5%    +101.5%     579892 ± 1%  TOTAL sched_debug.cpu#57.ttwu_count
    290676 ± 4%     +98.4%     576782 ± 1%  TOTAL sched_debug.cpu#50.ttwu_count
        15 ±34%     +92.4%         30 ±11%  TOTAL sched_debug.cfs_rq[33]:/.runnable_load_avg
        28 ±12%    +100.7%         57 ±30%  TOTAL sched_debug.cfs_rq[31]:/.tg_load_contrib
    287909 ± 4%    +101.5%     580220 ± 0%  TOTAL sched_debug.cpu#56.ttwu_count
    281438 ± 6%    +105.0%     576839 ± 1%  TOTAL sched_debug.cpu#58.ttwu_count
    223246 ±22%     -59.3%      90847 ±16%  TOTAL sched_debug.cpu#57.avg_idle
    292834 ± 2%     +98.9%     582416 ± 1%  TOTAL sched_debug.cpu#35.ttwu_count
    299007 ± 1%     +93.8%     579492 ± 1%  TOTAL sched_debug.cpu#49.ttwu_count
    296051 ± 3%     +96.4%     581581 ± 0%  TOTAL sched_debug.cpu#37.ttwu_count
    155938 ± 3%     -48.9%      79614 ± 2%  TOTAL proc-vmstat.numa_pte_updates
    292818 ± 4%     +99.2%     583153 ± 1%  TOTAL sched_debug.cpu#34.ttwu_count
    291339 ± 3%     +97.8%     576203 ± 1%  TOTAL sched_debug.cpu#46.ttwu_count
   1173228 ±19%     -48.8%     601063 ± 1%  TOTAL sched_debug.cpu#8.sched_count
    291043 ± 6%     +98.2%     576756 ± 1%  TOTAL sched_debug.cpu#48.ttwu_count
     32644 ± 0%     +92.8%      62936 ± 0%  TOTAL sched_debug.cfs_rq[0]:/.tg->runnable_avg
     32648 ± 0%     +92.8%      62937 ± 0%  TOTAL sched_debug.cfs_rq[1]:/.tg->runnable_avg
     32650 ± 0%     +92.8%      62937 ± 0%  TOTAL sched_debug.cfs_rq[2]:/.tg->runnable_avg
     32654 ± 0%     +92.7%      62937 ± 0%  TOTAL sched_debug.cfs_rq[3]:/.tg->runnable_avg
     32665 ± 0%     +92.7%      62937 ± 0%  TOTAL sched_debug.cfs_rq[4]:/.tg->runnable_avg
     32674 ± 0%     +92.6%      62938 ± 0%  TOTAL sched_debug.cfs_rq[5]:/.tg->runnable_avg
     32689 ± 0%     +92.5%      62938 ± 0%  TOTAL sched_debug.cfs_rq[8]:/.tg->runnable_avg
     32678 ± 0%     +92.6%      62937 ± 0%  TOTAL sched_debug.cfs_rq[6]:/.tg->runnable_avg
     32690 ± 0%     +92.5%      62938 ± 0%  TOTAL sched_debug.cfs_rq[10]:/.tg->runnable_avg
     32691 ± 0%     +92.5%      62938 ± 0%  TOTAL sched_debug.cfs_rq[9]:/.tg->runnable_avg
     32686 ± 0%     +92.6%      62937 ± 0%  TOTAL sched_debug.cfs_rq[7]:/.tg->runnable_avg
     32692 ± 0%     +92.5%      62938 ± 0%  TOTAL sched_debug.cfs_rq[11]:/.tg->runnable_avg
     32696 ± 0%     +92.5%      62938 ± 0%  TOTAL sched_debug.cfs_rq[12]:/.tg->runnable_avg
     32701 ± 0%     +92.5%      62938 ± 0%  TOTAL sched_debug.cfs_rq[13]:/.tg->runnable_avg
     32704 ± 0%     +92.4%      62938 ± 0%  TOTAL sched_debug.cfs_rq[14]:/.tg->runnable_avg
     32702 ± 0%     +92.5%      62938 ± 0%  TOTAL sched_debug.cfs_rq[15]:/.tg->runnable_avg
     32717 ± 0%     +92.4%      62937 ± 0%  TOTAL sched_debug.cfs_rq[18]:/.tg->runnable_avg
     32707 ± 0%     +92.4%      62938 ± 0%  TOTAL sched_debug.cfs_rq[16]:/.tg->runnable_avg
     32713 ± 0%     +92.4%      62937 ± 0%  TOTAL sched_debug.cfs_rq[17]:/.tg->runnable_avg
     32722 ± 0%     +92.3%      62938 ± 0%  TOTAL sched_debug.cfs_rq[19]:/.tg->runnable_avg
     32727 ± 0%     +92.3%      62938 ± 0%  TOTAL sched_debug.cfs_rq[20]:/.tg->runnable_avg
     32732 ± 0%     +92.3%      62938 ± 0%  TOTAL sched_debug.cfs_rq[21]:/.tg->runnable_avg
     32740 ± 0%     +92.2%      62938 ± 0%  TOTAL sched_debug.cfs_rq[24]:/.tg->runnable_avg
     32739 ± 0%     +92.2%      62938 ± 0%  TOTAL sched_debug.cfs_rq[23]:/.tg->runnable_avg
     32743 ± 0%     +92.2%      62938 ± 0%  TOTAL sched_debug.cfs_rq[26]:/.tg->runnable_avg
     32739 ± 0%     +92.2%      62938 ± 0%  TOTAL sched_debug.cfs_rq[22]:/.tg->runnable_avg
     32743 ± 0%     +92.2%      62937 ± 0%  TOTAL sched_debug.cfs_rq[27]:/.tg->runnable_avg
     32746 ± 0%     +92.2%      62938 ± 0%  TOTAL sched_debug.cfs_rq[25]:/.tg->runnable_avg
     32751 ± 0%     +92.2%      62938 ± 0%  TOTAL sched_debug.cfs_rq[29]:/.tg->runnable_avg
     32751 ± 0%     +92.2%      62938 ± 0%  TOTAL sched_debug.cfs_rq[30]:/.tg->runnable_avg
     32747 ± 0%     +92.2%      62938 ± 0%  TOTAL sched_debug.cfs_rq[28]:/.tg->runnable_avg
     32752 ± 0%     +92.2%      62939 ± 0%  TOTAL sched_debug.cfs_rq[31]:/.tg->runnable_avg
     32752 ± 0%     +92.2%      62939 ± 0%  TOTAL sched_debug.cfs_rq[32]:/.tg->runnable_avg
     32759 ± 0%     +92.1%      62939 ± 0%  TOTAL sched_debug.cfs_rq[33]:/.tg->runnable_avg
     32770 ± 0%     +92.1%      62939 ± 0%  TOTAL sched_debug.cfs_rq[37]:/.tg->runnable_avg
     32757 ± 0%     +92.1%      62939 ± 0%  TOTAL sched_debug.cfs_rq[34]:/.tg->runnable_avg
     32766 ± 0%     +92.1%      62939 ± 0%  TOTAL sched_debug.cfs_rq[36]:/.tg->runnable_avg
     32765 ± 0%     +92.1%      62939 ± 0%  TOTAL sched_debug.cfs_rq[35]:/.tg->runnable_avg
     32767 ± 0%     +92.1%      62939 ± 0%  TOTAL sched_debug.cfs_rq[38]:/.tg->runnable_avg
     32774 ± 0%     +92.0%      62939 ± 0%  TOTAL sched_debug.cfs_rq[41]:/.tg->runnable_avg
     32775 ± 0%     +92.0%      62939 ± 0%  TOTAL sched_debug.cfs_rq[42]:/.tg->runnable_avg
     32774 ± 0%     +92.0%      62939 ± 0%  TOTAL sched_debug.cfs_rq[39]:/.tg->runnable_avg
     32779 ± 0%     +92.0%      62939 ± 0%  TOTAL sched_debug.cfs_rq[43]:/.tg->runnable_avg
     32773 ± 0%     +92.0%      62939 ± 0%  TOTAL sched_debug.cfs_rq[40]:/.tg->runnable_avg
     32822 ± 0%     +91.8%      62940 ± 0%  TOTAL sched_debug.cfs_rq[63]:/.tg->runnable_avg
     32820 ± 0%     +91.8%      62940 ± 0%  TOTAL sched_debug.cfs_rq[62]:/.tg->runnable_avg
     32793 ± 0%     +91.9%      62939 ± 0%  TOTAL sched_debug.cfs_rq[47]:/.tg->runnable_avg
     32796 ± 0%     +91.9%      62940 ± 0%  TOTAL sched_debug.cfs_rq[48]:/.tg->runnable_avg
     32818 ± 0%     +91.8%      62940 ± 0%  TOTAL sched_debug.cfs_rq[61]:/.tg->runnable_avg
     32821 ± 0%     +91.8%      62940 ± 0%  TOTAL sched_debug.cfs_rq[60]:/.tg->runnable_avg
     32790 ± 0%     +91.9%      62939 ± 0%  TOTAL sched_debug.cfs_rq[44]:/.tg->runnable_avg
     32791 ± 0%     +91.9%      62939 ± 0%  TOTAL sched_debug.cfs_rq[46]:/.tg->runnable_avg
     32819 ± 0%     +91.8%      62941 ± 0%  TOTAL sched_debug.cfs_rq[59]:/.tg->runnable_avg
     32793 ± 0%     +91.9%      62939 ± 0%  TOTAL sched_debug.cfs_rq[45]:/.tg->runnable_avg
     32812 ± 0%     +91.8%      62940 ± 0%  TOTAL sched_debug.cfs_rq[56]:/.tg->runnable_avg
     32817 ± 0%     +91.8%      62940 ± 0%  TOTAL sched_debug.cfs_rq[57]:/.tg->runnable_avg
     32809 ± 0%     +91.8%      62940 ± 0%  TOTAL sched_debug.cfs_rq[52]:/.tg->runnable_avg
     32811 ± 0%     +91.8%      62940 ± 0%  TOTAL sched_debug.cfs_rq[55]:/.tg->runnable_avg
     32801 ± 0%     +91.9%      62940 ± 0%  TOTAL sched_debug.cfs_rq[49]:/.tg->runnable_avg
     32822 ± 0%     +91.8%      62941 ± 0%  TOTAL sched_debug.cfs_rq[58]:/.tg->runnable_avg
     32808 ± 0%     +91.8%      62940 ± 0%  TOTAL sched_debug.cfs_rq[54]:/.tg->runnable_avg
     32812 ± 0%     +91.8%      62940 ± 0%  TOTAL sched_debug.cfs_rq[53]:/.tg->runnable_avg
     32809 ± 0%     +91.8%      62940 ± 0%  TOTAL sched_debug.cfs_rq[51]:/.tg->runnable_avg
     32804 ± 0%     +91.9%      62940 ± 0%  TOTAL sched_debug.cfs_rq[50]:/.tg->runnable_avg
    309179 ± 2%     +87.8%     580793 ± 1%  TOTAL sched_debug.cpu#41.ttwu_count
        81 ±44%     -62.2%         30 ± 4%  TOTAL sched_debug.cfs_rq[62]:/.tg_load_contrib
   5254994 ± 0%     +89.6%    9963624 ± 0%  TOTAL softirqs.TIMER
      3.69 ± 1%     +86.0%       6.87 ± 4%  TOTAL perf-profile.cpu-cycles.memcpy.sctp_outq_flush.sctp_outq_uncork.sctp_cmd_interpreter.sctp_do_sm
    308199 ± 4%     +86.7%     575358 ± 1%  TOTAL sched_debug.cpu#42.ttwu_count
    305544 ± 4%     +90.6%     582390 ± 1%  TOTAL sched_debug.cpu#38.ttwu_count
    309614 ± 1%     +86.5%     577365 ± 1%  TOTAL sched_debug.cpu#43.ttwu_count
        14 ±33%     +98.6%         28 ± 2%  TOTAL sched_debug.cpu#35.load
    309719 ± 5%     +85.8%     575506 ± 1%  TOTAL sched_debug.cpu#45.ttwu_count
   1081161 ± 1%     -46.1%     582374 ± 1%  TOTAL sched_debug.cpu#29.ttwu_count
    316152 ± 3%     +82.7%     577646 ± 1%  TOTAL sched_debug.cpu#40.ttwu_count
        27 ± 8%    +107.9%         57 ±49%  TOTAL sched_debug.cfs_rq[9]:/.tg_load_contrib
   1083438 ± 0%     -45.9%     586638 ± 0%  TOTAL sched_debug.cpu#7.ttwu_count
    315864 ± 5%     +82.6%     576755 ± 1%  TOTAL sched_debug.cpu#47.ttwu_count
        31 ± 7%     +69.2%         52 ±36%  TOTAL sched_debug.cfs_rq[13]:/.tg_load_contrib
   1084154 ± 1%     -45.7%     588437 ± 1%  TOTAL sched_debug.cpu#30.ttwu_count
    311962 ± 5%     +84.9%     576905 ± 1%  TOTAL sched_debug.cpu#44.ttwu_count
   1060523 ± 1%     -45.1%     582533 ± 1%  TOTAL sched_debug.cpu#21.ttwu_count
   1054699 ± 1%     -45.1%     579000 ± 1%  TOTAL sched_debug.cpu#14.ttwu_count
        17 ±22%     +70.8%         30 ± 2%  TOTAL sched_debug.cpu#8.cpu_load[4]
        15 ±26%    +103.9%         31 ±12%  TOTAL sched_debug.cpu#41.cpu_load[1]
        28 ± 4%     +85.4%         53 ±38%  TOTAL sched_debug.cfs_rq[30]:/.tg_load_contrib
   1075268 ± 1%     -45.5%     586405 ± 1%  TOTAL sched_debug.cpu#28.ttwu_count
   1059908 ± 2%     -44.9%     584032 ± 1%  TOTAL sched_debug.cpu#31.ttwu_count
   1068780 ± 1%     -45.5%     582915 ± 1%  TOTAL sched_debug.cpu#27.ttwu_count
   1068310 ± 0%     -44.9%     588354 ± 1%  TOTAL sched_debug.cpu#5.ttwu_count
   1055705 ± 2%     -45.0%     580123 ± 2%  TOTAL sched_debug.cpu#23.ttwu_count
   1054570 ± 1%     -44.7%     583394 ± 1%  TOTAL sched_debug.cpu#20.ttwu_count
    254366 ±43%     -59.3%     103437 ±13%  TOTAL sched_debug.cpu#54.avg_idle
   1063589 ± 2%     -44.7%     587718 ± 1%  TOTAL sched_debug.cpu#6.ttwu_count
   1058139 ± 3%     -44.6%     585929 ± 1%  TOTAL sched_debug.cpu#22.ttwu_count
   1067145 ± 1%     -44.9%     588220 ± 1%  TOTAL sched_debug.cpu#4.ttwu_count
   1057669 ± 0%     -44.3%     588982 ± 1%  TOTAL sched_debug.cpu#1.ttwu_count
   1059310 ± 1%     -44.3%     589806 ± 1%  TOTAL sched_debug.cpu#3.ttwu_count
   1043843 ± 1%     -44.2%     581948 ± 1%  TOTAL sched_debug.cpu#18.ttwu_count
   1031973 ± 1%     -43.9%     579237 ± 1%  TOTAL sched_debug.cpu#11.ttwu_count
        18 ±24%     +70.7%         31 ±13%  TOTAL sched_debug.cpu#41.cpu_load[0]
   1047788 ± 2%     -44.3%     583196 ± 1%  TOTAL sched_debug.cpu#19.ttwu_count
   1044163 ± 2%     -44.2%     583017 ± 1%  TOTAL sched_debug.cpu#26.ttwu_count
   1288766 ±38%     -52.8%     608462 ± 1%  TOTAL sched_debug.cpu#1.sched_count
   1032898 ± 1%     -43.8%     579984 ± 1%  TOTAL sched_debug.cpu#13.ttwu_count
   1049631 ± 1%     -43.7%     590788 ± 0%  TOTAL sched_debug.cpu#2.ttwu_count
   1034514 ± 1%     -43.7%     582699 ± 1%  TOTAL sched_debug.cpu#15.ttwu_count
        16 ±20%     +75.0%         29 ± 4%  TOTAL sched_debug.cpu#9.cpu_load[0]
   1023516 ± 1%     -43.1%     582541 ± 1%  TOTAL sched_debug.cpu#17.ttwu_count
   1039799 ± 3%     -44.3%     579547 ± 2%  TOTAL sched_debug.cpu#25.ttwu_count
   1302779 ±36%     -54.0%     598642 ± 1%  TOTAL sched_debug.cpu#9.sched_count
   1012139 ± 0%     -42.5%     581867 ± 1%  TOTAL sched_debug.cpu#9.ttwu_count
   1032088 ± 2%     -43.7%     581367 ± 1%  TOTAL sched_debug.cpu#12.ttwu_count
   1015497 ± 1%     -42.6%     582939 ± 1%  TOTAL sched_debug.cpu#16.ttwu_count
   1023139 ± 1%     -43.1%     582533 ± 1%  TOTAL sched_debug.cpu#10.ttwu_count
   1039034 ± 1%     -42.7%     595606 ± 1%  TOTAL sched_debug.cpu#0.ttwu_count
   1125131 ±22%     -46.7%     600109 ± 2%  TOTAL sched_debug.cpu#12.sched_count
      9019 ± 6%     -42.0%       5232 ±10%  TOTAL proc-vmstat.pgmigrate_success
      9019 ± 6%     -42.0%       5232 ±10%  TOTAL proc-vmstat.numa_pages_migrated
   1020221 ± 2%     -42.6%     586085 ± 1%  TOTAL sched_debug.cpu#24.ttwu_count
        18 ± 9%     +69.2%         30 ± 2%  TOTAL sched_debug.cpu#9.cpu_load[4]
        19 ±14%     +84.8%         36 ±34%  TOTAL sched_debug.cfs_rq[38]:/.load
        30 ±12%     +56.7%         47 ±18%  TOTAL sched_debug.cfs_rq[25]:/.tg_load_contrib
        17 ±13%     +62.5%         28 ± 3%  TOTAL sched_debug.cpu#1.cpu_load[0]
        17 ±15%     +64.4%         28 ± 1%  TOTAL sched_debug.cpu#22.cpu_load[3]
        19 ±16%     +52.1%         29 ± 2%  TOTAL sched_debug.cpu#25.cpu_load[3]
    991690 ± 0%     -41.2%     582981 ± 1%  TOTAL sched_debug.cpu#8.ttwu_count
        18 ±12%     +60.2%         29 ± 4%  TOTAL sched_debug.cpu#15.cpu_load[4]
        18 ±22%     +66.7%         30 ± 2%  TOTAL sched_debug.cpu#8.cpu_load[3]
        17 ±11%     +72.4%         30 ± 2%  TOTAL sched_debug.cpu#9.cpu_load[3]
        21 ±26%     +70.5%         35 ±38%  TOTAL sched_debug.cpu#61.load
        19 ±25%     +56.8%         29 ± 2%  TOTAL sched_debug.cpu#43.load
        18 ±16%     +52.7%         27 ± 1%  TOTAL sched_debug.cpu#30.cpu_load[2]
        18 ±18%     +56.0%         28 ± 3%  TOTAL sched_debug.cpu#26.cpu_load[4]
        17 ±17%     +59.1%         28 ± 3%  TOTAL sched_debug.cpu#22.cpu_load[1]
        17 ± 4%     +58.0%         27 ± 4%  TOTAL sched_debug.cpu#3.cpu_load[0]
        17 ±16%     +55.1%         27 ± 3%  TOTAL sched_debug.cpu#22.cpu_load[0]
        18 ±19%     +56.7%         28 ± 4%  TOTAL sched_debug.cpu#26.cpu_load[3]
        17 ±17%     +64.0%         28 ± 2%  TOTAL sched_debug.cpu#22.cpu_load[2]
      2664 ±15%     +63.7%       4362 ± 1%  TOTAL sched_debug.cpu#20.curr->pid
        19 ±14%     +56.6%         31 ± 3%  TOTAL sched_debug.cfs_rq[45]:/.load
        71 ±43%     -52.1%         34 ±13%  TOTAL sched_debug.cfs_rq[47]:/.tg_load_contrib
     13306 ± 0%     +61.5%      21495 ± 0%  TOTAL proc-vmstat.nr_shmem
     53249 ± 0%     +61.5%      85996 ± 0%  TOTAL meminfo.Shmem
        18 ± 8%     +58.7%         29 ± 1%  TOTAL sched_debug.cpu#11.cpu_load[3]
        18 ±12%     +57.1%         28 ± 1%  TOTAL sched_debug.cpu#30.cpu_load[3]
        17 ±22%     +65.2%         29 ± 3%  TOTAL sched_debug.cfs_rq[9]:/.runnable_load_avg
        19 ± 6%     +54.7%         29 ± 1%  TOTAL sched_debug.cpu#23.cpu_load[4]
        17 ±15%     +69.8%         29 ± 3%  TOTAL sched_debug.cpu#9.cpu_load[2]
        18 ± 7%     +59.1%         29 ± 2%  TOTAL sched_debug.cpu#11.cpu_load[4]
        17 ±17%     +70.6%         29 ± 4%  TOTAL sched_debug.cpu#9.cpu_load[1]
        18 ± 8%     +55.4%         28 ± 3%  TOTAL sched_debug.cpu#1.cpu_load[1]
        18 ± 7%     +55.3%         29 ± 3%  TOTAL sched_debug.cpu#1.cpu_load[2]
        19 ±14%     +54.7%         29 ± 1%  TOTAL sched_debug.cpu#25.cpu_load[4]
        17 ±14%     +65.5%         28 ± 1%  TOTAL sched_debug.cpu#22.cpu_load[4]
        18 ± 9%     +53.8%         28 ± 4%  TOTAL sched_debug.cfs_rq[13]:/.runnable_load_avg
        19 ±11%     +54.7%         29 ± 5%  TOTAL sched_debug.cpu#15.cpu_load[3]
        18 ±12%     +55.4%         28 ± 1%  TOTAL sched_debug.cfs_rq[23]:/.runnable_load_avg
        18 ± 2%     +57.1%         28 ± 3%  TOTAL sched_debug.cpu#3.cpu_load[3]
        18 ± 2%     +60.4%         29 ± 2%  TOTAL sched_debug.cpu#3.cpu_load[4]
        17 ± 2%     +60.7%         28 ± 3%  TOTAL sched_debug.cpu#3.cpu_load[2]
      2777 ±10%     +60.7%       4463 ± 7%  TOTAL sched_debug.cpu#27.curr->pid
      2744 ±13%     +58.3%       4342 ± 3%  TOTAL sched_debug.cpu#22.curr->pid
    988578 ±10%     -38.9%     604501 ± 1%  TOTAL sched_debug.cpu#24.sched_count
   1083808 ±31%     -42.7%     621044 ± 7%  TOTAL sched_debug.cpu#6.sched_count
        19 ±12%     +53.1%         29 ± 4%  TOTAL sched_debug.cpu#19.cpu_load[3]
        19 ±13%     +53.6%         29 ± 4%  TOTAL sched_debug.cpu#19.cpu_load[4]
    966177 ±24%     -37.8%     600790 ± 2%  TOTAL sched_debug.cpu#27.sched_count
   1146030 ±46%     -46.9%     608122 ± 1%  TOTAL sched_debug.cpu#2.sched_count
        18 ± 3%     +55.6%         28 ± 3%  TOTAL sched_debug.cpu#3.cpu_load[1]
        19 ±19%     +41.4%         28 ± 2%  TOTAL sched_debug.cpu#5.cpu_load[0]
        17 ± 9%     +58.4%         28 ± 5%  TOTAL sched_debug.cfs_rq[3]:/.runnable_load_avg
        18 ±19%     +52.2%         28 ± 5%  TOTAL sched_debug.cpu#26.cpu_load[2]
        18 ±17%     +50.5%         28 ± 3%  TOTAL sched_debug.cpu#30.cpu_load[0]
        18 ±17%     +50.5%         27 ± 2%  TOTAL sched_debug.cpu#30.cpu_load[1]
        19 ±11%     +49.0%         28 ± 4%  TOTAL sched_debug.cpu#15.cpu_load[2]
        18 ±12%     +56.7%         28 ± 1%  TOTAL sched_debug.cpu#13.cpu_load[0]
        20 ±13%     +38.0%         27 ± 3%  TOTAL sched_debug.cfs_rq[31]:/.runnable_load_avg
        20 ±18%     +40.0%         28 ± 2%  TOTAL sched_debug.cpu#5.cpu_load[1]
        18 ±22%     +56.5%         28 ± 5%  TOTAL sched_debug.cpu#8.cpu_load[0]
        19 ±16%     +49.0%         28 ± 2%  TOTAL sched_debug.cpu#25.cpu_load[2]
   1040164 ±27%     -37.2%     653364 ±10%  TOTAL sched_debug.cpu#19.sched_count
        80 ±29%     -45.9%         43 ±26%  TOTAL sched_debug.cfs_rq[37]:/.tg_load_contrib
      2953 ±10%     +47.1%       4345 ± 2%  TOTAL sched_debug.cpu#14.curr->pid
    923395 ± 6%     -24.6%     695896 ±17%  TOTAL sched_debug.cpu#21.sched_count
      2800 ± 5%     +52.5%       4269 ± 1%  TOTAL sched_debug.cpu#11.curr->pid
      2746 ±15%     +57.0%       4312 ± 2%  TOTAL sched_debug.cpu#8.curr->pid
        20 ±12%     +44.1%         29 ± 1%  TOTAL sched_debug.cpu#5.cpu_load[4]
        18 ±13%     +58.1%         29 ± 1%  TOTAL sched_debug.cpu#13.cpu_load[2]
        18 ± 7%     +54.8%         28 ± 2%  TOTAL sched_debug.cpu#11.cpu_load[1]
        18 ±13%     +56.5%         28 ± 1%  TOTAL sched_debug.cpu#13.cpu_load[1]
        18 ±22%     +60.9%         29 ± 5%  TOTAL sched_debug.cpu#8.cpu_load[2]
        19 ± 6%     +47.9%         28 ± 2%  TOTAL sched_debug.cpu#7.cpu_load[2]
        19 ±12%     +51.6%         28 ± 2%  TOTAL sched_debug.cpu#11.cpu_load[0]
        18 ±12%     +58.7%         29 ± 3%  TOTAL sched_debug.cfs_rq[11]:/.runnable_load_avg
        18 ±11%     +62.6%         29 ± 5%  TOTAL sched_debug.cfs_rq[1]:/.runnable_load_avg
        19 ± 5%     +50.5%         28 ± 1%  TOTAL sched_debug.cpu#23.cpu_load[3]
        19 ±21%     +48.0%         29 ± 3%  TOTAL sched_debug.cpu#27.cpu_load[4]
        18 ±12%     +57.0%         29 ± 2%  TOTAL sched_debug.cpu#30.cpu_load[4]
        18 ± 7%     +53.2%         28 ± 2%  TOTAL sched_debug.cpu#11.cpu_load[2]
        19 ± 4%     +58.9%         30 ± 9%  TOTAL sched_debug.cfs_rq[2]:/.runnable_load_avg
   1101084 ±30%     -44.5%     611225 ± 2%  TOTAL sched_debug.cpu#4.sched_count
      2942 ±10%     +44.9%       4263 ± 2%  TOTAL sched_debug.cpu#7.curr->pid
      2905 ± 7%     +53.9%       4471 ± 2%  TOTAL sched_debug.cpu#23.curr->pid
   1035532 ±19%     -41.9%     601372 ± 1%  TOTAL sched_debug.cpu#15.sched_count
       663 ± 7%     +48.7%        987 ± 0%  TOTAL sched_debug.cfs_rq[8]:/.tg_runnable_contrib
     30382 ± 7%     +49.0%      45275 ± 0%  TOTAL sched_debug.cfs_rq[8]:/.avg->runnable_avg_sum
     30719 ± 7%     +46.5%      44998 ± 0%  TOTAL sched_debug.cfs_rq[15]:/.avg->runnable_avg_sum
       671 ± 7%     +45.8%        979 ± 0%  TOTAL sched_debug.cfs_rq[15]:/.tg_runnable_contrib
        20 ± 9%     +46.1%         29 ± 2%  TOTAL sched_debug.cpu#18.cpu_load[4]
        20 ± 6%     +45.6%         30 ± 4%  TOTAL sched_debug.cpu#1.cpu_load[4]
        19 ± 9%     +52.0%         29 ± 2%  TOTAL sched_debug.cpu#14.cpu_load[4]
        19 ±10%     +57.3%         30 ± 2%  TOTAL sched_debug.cpu#13.cpu_load[4]
        19 ±12%     +55.2%         29 ± 2%  TOTAL sched_debug.cpu#13.cpu_load[3]
        20 ±13%     +35.6%         27 ± 1%  TOTAL sched_debug.cfs_rq[22]:/.runnable_load_avg
        19 ±11%     +43.8%         27 ± 2%  TOTAL sched_debug.cfs_rq[5]:/.runnable_load_avg
        19 ±13%     +42.7%         27 ± 3%  TOTAL sched_debug.cpu#31.cpu_load[0]
      1045 ± 1%     +52.1%       1589 ± 7%  TOTAL numa-vmstat.node0.nr_alloc_batch
    737654 ± 1%     +50.3%    1108371 ± 0%  TOTAL softirqs.RCU
      2824 ±15%     +54.7%       4370 ± 1%  TOTAL sched_debug.cpu#31.curr->pid
      2900 ± 3%     +48.4%       4303 ± 1%  TOTAL sched_debug.cpu#17.curr->pid
      1117 ± 2%     +42.8%       1595 ± 6%  TOTAL numa-vmstat.node3.nr_alloc_batch
     31475 ± 6%     +43.6%      45205 ± 0%  TOTAL sched_debug.cfs_rq[26]:/.avg->runnable_avg_sum
      2819 ±13%     +51.7%       4276 ± 2%  TOTAL sched_debug.cpu#26.curr->pid
     31215 ± 4%     +44.3%      45055 ± 0%  TOTAL sched_debug.cfs_rq[30]:/.avg->runnable_avg_sum
     30904 ± 4%     +46.4%      45232 ± 0%  TOTAL sched_debug.cfs_rq[10]:/.avg->runnable_avg_sum
       675 ± 4%     +45.9%        985 ± 0%  TOTAL sched_debug.cfs_rq[10]:/.tg_runnable_contrib
       687 ± 6%     +42.7%        981 ± 0%  TOTAL sched_debug.cfs_rq[26]:/.tg_runnable_contrib
        19 ± 3%     +47.9%         28 ± 3%  TOTAL sched_debug.cpu#4.cpu_load[1]
        21 ±18%     +32.1%         28 ± 2%  TOTAL sched_debug.cpu#31.cpu_load[2]
        19 ±12%     +44.9%         28 ± 5%  TOTAL sched_debug.cpu#15.cpu_load[1]
        18 ±21%     +57.6%         29 ± 6%  TOTAL sched_debug.cpu#8.cpu_load[1]
        19 ±17%     +47.4%         28 ± 3%  TOTAL sched_debug.cpu#25.cpu_load[0]
        19 ± 3%     +49.0%         28 ± 6%  TOTAL sched_debug.cpu#4.cpu_load[0]
        20 ±13%     +42.0%         28 ± 1%  TOTAL sched_debug.cpu#5.cpu_load[3]
        20 ±10%     +41.0%         28 ± 4%  TOTAL sched_debug.cfs_rq[15]:/.runnable_load_avg
        19 ± 4%     +45.9%         28 ± 2%  TOTAL sched_debug.cpu#4.cpu_load[2]
        19 ± 7%     +47.4%         28 ± 2%  TOTAL sched_debug.cpu#23.cpu_load[2]
        18 ± 3%     +47.9%         27 ± 3%  TOTAL sched_debug.cpu#7.cpu_load[0]
        19 ±13%     +46.9%         28 ± 6%  TOTAL sched_debug.cpu#15.cpu_load[0]
        19 ± 8%     +44.8%         27 ± 2%  TOTAL sched_debug.cpu#23.cpu_load[1]
        19 ±16%     +45.4%         28 ± 1%  TOTAL sched_debug.cpu#25.cpu_load[1]
        19 ±11%     +40.8%         27 ± 1%  TOTAL sched_debug.cpu#23.cpu_load[0]
        20 ±14%     +39.6%         28 ± 1%  TOTAL sched_debug.cpu#5.cpu_load[2]
        19 ±14%     +41.4%         28 ± 2%  TOTAL sched_debug.cpu#31.cpu_load[1]
        19 ± 6%     +45.8%         28 ± 2%  TOTAL sched_debug.cpu#7.cpu_load[1]
        20 ±13%     +40.6%         28 ± 3%  TOTAL sched_debug.cfs_rq[25]:/.runnable_load_avg
      2943 ± 8%     +45.8%       4289 ± 0%  TOTAL sched_debug.cpu#1.curr->pid
      2703 ±11%     +59.2%       4302 ± 1%  TOTAL sched_debug.cpu#4.curr->pid
      2989 ±13%     +42.7%       4265 ± 2%  TOTAL sched_debug.cpu#24.curr->pid
      3048 ± 8%     +42.7%       4349 ± 1%  TOTAL sched_debug.cpu#3.curr->pid
     30576 ± 6%     +47.4%      45060 ± 0%  TOTAL sched_debug.cfs_rq[22]:/.avg->runnable_avg_sum
       682 ± 4%     +43.6%        979 ± 0%  TOTAL sched_debug.cfs_rq[30]:/.tg_runnable_contrib
      1100 ± 3%     +49.4%       1643 ± 4%  TOTAL numa-vmstat.node1.nr_alloc_batch
      4389 ± 1%     +46.7%       6439 ± 1%  TOTAL proc-vmstat.nr_alloc_batch
       668 ± 6%     +46.9%        982 ± 0%  TOTAL sched_debug.cfs_rq[22]:/.tg_runnable_contrib
      3115 ± 9%     +38.4%       4310 ± 1%  TOTAL sched_debug.cpu#5.curr->pid
       695 ± 4%     +41.8%        985 ± 0%  TOTAL sched_debug.cfs_rq[18]:/.tg_runnable_contrib
     31812 ± 4%     +42.5%      45324 ± 0%  TOTAL sched_debug.cfs_rq[18]:/.avg->runnable_avg_sum
      1157 ± 4%     +40.2%       1622 ± 7%  TOTAL numa-vmstat.node2.nr_alloc_batch
        19 ± 6%     +51.6%         28 ± 2%  TOTAL sched_debug.cpu#7.cpu_load[3]
        19 ± 6%     +51.5%         29 ± 1%  TOTAL sched_debug.cpu#2.cpu_load[4]
        19 ± 6%     +53.7%         29 ± 2%  TOTAL sched_debug.cpu#7.cpu_load[4]
        19 ±13%     +51.0%         29 ± 3%  TOTAL sched_debug.cpu#19.cpu_load[2]
        19 ±10%     +49.5%         29 ± 4%  TOTAL sched_debug.cpu#2.cpu_load[2]
        19 ±13%     +50.0%         28 ± 4%  TOTAL sched_debug.cpu#19.cpu_load[1]
        19 ± 6%     +49.5%         29 ± 3%  TOTAL sched_debug.cpu#2.cpu_load[3]
        20 ± 8%     +45.5%         29 ± 1%  TOTAL sched_debug.cpu#18.cpu_load[3]
        19 ± 5%     +51.0%         29 ± 2%  TOTAL sched_debug.cpu#20.cpu_load[4]
        20 ± 7%     +41.2%         28 ± 2%  TOTAL sched_debug.cpu#18.cpu_load[2]
        20 ± 7%     +47.0%         29 ± 2%  TOTAL sched_debug.cpu#4.cpu_load[4]
        20 ± 5%     +45.0%         29 ± 2%  TOTAL sched_debug.cpu#4.cpu_load[3]
        19 ±16%     +50.5%         28 ± 1%  TOTAL sched_debug.cpu#27.cpu_load[3]
        19 ±12%     +44.9%         28 ± 4%  TOTAL sched_debug.cpu#16.cpu_load[0]
        19 ± 5%     +48.5%         29 ± 3%  TOTAL sched_debug.cpu#1.cpu_load[3]
        19 ± 6%     +50.0%         29 ± 1%  TOTAL sched_debug.cpu#20.cpu_load[3]
      2924 ±10%     +48.1%       4330 ± 2%  TOTAL sched_debug.cpu#13.curr->pid
      2942 ± 7%     +45.9%       4291 ± 2%  TOTAL sched_debug.cpu#15.curr->pid
      2957 ± 5%     +44.4%       4269 ± 1%  TOTAL sched_debug.cpu#9.curr->pid
      2930 ±12%     +47.6%       4326 ± 3%  TOTAL sched_debug.cpu#16.curr->pid
       684 ± 7%     +44.1%        986 ± 0%  TOTAL sched_debug.cfs_rq[27]:/.tg_runnable_contrib
     32158 ± 4%     +40.1%      45057 ± 0%  TOTAL sched_debug.cfs_rq[24]:/.avg->runnable_avg_sum
      2949 ± 9%     +46.3%       4315 ± 2%  TOTAL sched_debug.cpu#19.curr->pid
        20 ± 9%     +46.5%         29 ± 1%  TOTAL sched_debug.cpu#16.cpu_load[4]
        19 ±14%     +51.0%         29 ± 5%  TOTAL sched_debug.cpu#19.cpu_load[0]
     31356 ± 7%     +43.8%      45098 ± 0%  TOTAL sched_debug.cfs_rq[27]:/.avg->runnable_avg_sum
     33090 ± 7%     +36.2%      45061 ± 0%  TOTAL sched_debug.cfs_rq[29]:/.avg->runnable_avg_sum
       721 ± 7%     +35.7%        979 ± 0%  TOTAL sched_debug.cfs_rq[29]:/.tg_runnable_contrib
     31372 ± 5%     +43.7%      45081 ± 0%  TOTAL sched_debug.cfs_rq[11]:/.avg->runnable_avg_sum
       701 ± 4%     +39.8%        980 ± 0%  TOTAL sched_debug.cfs_rq[24]:/.tg_runnable_contrib
      3005 ± 6%     +44.1%       4331 ± 2%  TOTAL sched_debug.cpu#28.curr->pid
       722 ± 5%     +36.2%        983 ± 0%  TOTAL sched_debug.cfs_rq[28]:/.tg_runnable_contrib
     32215 ± 6%     +40.3%      45183 ± 0%  TOTAL sched_debug.cfs_rq[19]:/.avg->runnable_avg_sum
     32108 ± 3%     +40.5%      45102 ± 0%  TOTAL sched_debug.cfs_rq[13]:/.avg->runnable_avg_sum
       703 ± 6%     +39.9%        983 ± 0%  TOTAL sched_debug.cfs_rq[19]:/.tg_runnable_contrib
     33049 ± 5%     +36.4%      45063 ± 0%  TOTAL sched_debug.cfs_rq[28]:/.avg->runnable_avg_sum
       685 ± 5%     +43.1%        981 ± 0%  TOTAL sched_debug.cfs_rq[11]:/.tg_runnable_contrib
       702 ± 3%     +39.7%        981 ± 0%  TOTAL sched_debug.cfs_rq[13]:/.tg_runnable_contrib
     32365 ± 1%     +39.3%      45086 ± 0%  TOTAL sched_debug.cfs_rq[20]:/.avg->runnable_avg_sum
       706 ± 1%     +38.9%        982 ± 0%  TOTAL sched_debug.cfs_rq[20]:/.tg_runnable_contrib
   1120854 ±41%     -45.0%     616182 ± 4%  TOTAL sched_debug.cpu#5.sched_count
     31452 ± 3%     +44.5%      45437 ± 1%  TOTAL sched_debug.cfs_rq[9]:/.avg->runnable_avg_sum
     32534 ± 5%     +38.4%      45040 ± 0%  TOTAL sched_debug.cfs_rq[31]:/.avg->runnable_avg_sum
       687 ± 3%     +44.1%        990 ± 1%  TOTAL sched_debug.cfs_rq[9]:/.tg_runnable_contrib
       702 ± 7%     +40.4%        985 ± 0%  TOTAL sched_debug.cfs_rq[25]:/.tg_runnable_contrib
       694 ± 5%     +41.6%        983 ± 0%  TOTAL sched_debug.cfs_rq[14]:/.tg_runnable_contrib
        19 ±24%     +50.0%         28 ± 7%  TOTAL sched_debug.cfs_rq[8]:/.runnable_load_avg
        19 ± 9%     +46.9%         28 ± 3%  TOTAL sched_debug.cpu#20.cpu_load[2]
        19 ±12%     +42.4%         28 ± 4%  TOTAL sched_debug.cpu#16.cpu_load[1]
        19 ±10%     +47.5%         29 ± 6%  TOTAL sched_debug.cpu#2.cpu_load[1]
        19 ±14%     +43.9%         28 ± 2%  TOTAL sched_debug.cpu#20.cpu_load[0]
        20 ±13%     +33.7%         27 ± 2%  TOTAL sched_debug.cpu#24.cpu_load[1]
        20 ±13%     +50.0%         30 ±11%  TOTAL sched_debug.cpu#2.cpu_load[0]
        18 ±16%     +48.9%         28 ± 3%  TOTAL sched_debug.cpu#27.cpu_load[2]
        18 ±19%     +46.8%         27 ± 5%  TOTAL sched_debug.cpu#26.cpu_load[1]
        19 ±14%     +43.3%         27 ± 4%  TOTAL sched_debug.cfs_rq[30]:/.runnable_load_avg
        20 ± 6%     +41.6%         28 ± 4%  TOTAL sched_debug.cfs_rq[4]:/.runnable_load_avg
        20 ±11%     +40.0%         28 ± 2%  TOTAL sched_debug.cfs_rq[16]:/.runnable_load_avg
        20 ± 4%     +36.3%         27 ± 2%  TOTAL sched_debug.cfs_rq[20]:/.runnable_load_avg
        19 ±13%     +44.9%         28 ± 1%  TOTAL sched_debug.cpu#16.cpu_load[2]
       710 ± 5%     +38.1%        981 ± 0%  TOTAL sched_debug.cfs_rq[31]:/.tg_runnable_contrib
     32116 ± 7%     +40.5%      45109 ± 0%  TOTAL sched_debug.cfs_rq[25]:/.avg->runnable_avg_sum
     31789 ± 5%     +41.7%      45041 ± 0%  TOTAL sched_debug.cfs_rq[14]:/.avg->runnable_avg_sum
     31727 ± 4%     +42.1%      45080 ± 0%  TOTAL sched_debug.cfs_rq[17]:/.avg->runnable_avg_sum
       696 ± 6%     +41.2%        983 ± 0%  TOTAL sched_debug.cfs_rq[0]:/.tg_runnable_contrib
     31871 ± 6%     +41.4%      45051 ± 0%  TOTAL sched_debug.cfs_rq[0]:/.avg->runnable_avg_sum
     32292 ± 5%     +39.4%      45011 ± 0%  TOTAL sched_debug.cfs_rq[7]:/.avg->runnable_avg_sum
       699 ± 3%     +40.5%        982 ± 0%  TOTAL sched_debug.cfs_rq[16]:/.tg_runnable_contrib
       706 ± 5%     +39.0%        981 ± 0%  TOTAL sched_debug.cfs_rq[7]:/.tg_runnable_contrib
      3025 ±16%     +43.2%       4334 ± 2%  TOTAL sched_debug.cpu#10.curr->pid
     32043 ± 3%     +40.6%      45060 ± 0%  TOTAL sched_debug.cfs_rq[16]:/.avg->runnable_avg_sum
       705 ± 4%     +39.8%        985 ± 0%  TOTAL sched_debug.cfs_rq[3]:/.tg_runnable_contrib
     32260 ± 4%     +39.8%      45100 ± 0%  TOTAL sched_debug.cfs_rq[3]:/.avg->runnable_avg_sum
       694 ± 4%     +41.3%        980 ± 0%  TOTAL sched_debug.cfs_rq[17]:/.tg_runnable_contrib
     32722 ± 3%     +38.1%      45195 ± 0%  TOTAL sched_debug.cfs_rq[2]:/.avg->runnable_avg_sum
      2869 ±11%     +52.0%       4362 ± 3%  TOTAL sched_debug.cpu#30.curr->pid
       698 ± 5%     +40.6%        982 ± 0%  TOTAL sched_debug.cfs_rq[23]:/.tg_runnable_contrib
     32007 ± 5%     +40.7%      45031 ± 0%  TOTAL sched_debug.cfs_rq[23]:/.avg->runnable_avg_sum
        21 ± 7%     +34.3%         29 ± 3%  TOTAL sched_debug.cfs_rq[18]:/.runnable_load_avg
        20 ±11%     +40.8%         29 ± 2%  TOTAL sched_debug.cpu#24.cpu_load[3]
        21 ±10%     +34.6%         28 ± 4%  TOTAL sched_debug.cpu#29.cpu_load[3]
        21 ±10%     +36.8%         29 ± 3%  TOTAL sched_debug.cpu#29.cpu_load[4]
        21 ± 9%     +39.0%         29 ± 1%  TOTAL sched_debug.cpu#24.cpu_load[4]
        21 ±12%     +34.9%         28 ± 5%  TOTAL sched_debug.cpu#29.cpu_load[2]
        20 ±11%     +41.7%         29 ± 2%  TOTAL sched_debug.cpu#21.cpu_load[3]
        20 ±10%     +45.0%         29 ± 2%  TOTAL sched_debug.cpu#14.cpu_load[3]
        20 ±15%     +38.2%         28 ± 3%  TOTAL sched_debug.cpu#14.cpu_load[1]
        20 ±11%     +45.0%         29 ± 2%  TOTAL sched_debug.cpu#16.cpu_load[3]
        23 ±10%     +25.2%         28 ± 2%  TOTAL sched_debug.cpu#55.load
        21 ± 6%     +34.6%         28 ± 2%  TOTAL sched_debug.cpu#28.cpu_load[4]
        20 ± 6%     +38.8%         28 ± 3%  TOTAL sched_debug.cfs_rq[7]:/.runnable_load_avg
        20 ±11%     +44.1%         29 ± 1%  TOTAL sched_debug.cpu#21.cpu_load[4]
      2959 ± 8%     +45.8%       4315 ± 1%  TOTAL sched_debug.cpu#6.curr->pid
     33054 ± 2%     +36.8%      45208 ± 0%  TOTAL sched_debug.cfs_rq[1]:/.avg->runnable_avg_sum
       715 ± 2%     +37.4%        983 ± 0%  TOTAL sched_debug.cfs_rq[2]:/.tg_runnable_contrib
     32267 ± 5%     +39.7%      45074 ± 0%  TOTAL sched_debug.cfs_rq[4]:/.avg->runnable_avg_sum
       705 ± 4%     +38.9%        979 ± 0%  TOTAL sched_debug.cfs_rq[4]:/.tg_runnable_contrib
      2983 ±12%     +47.3%       4394 ± 2%  TOTAL sched_debug.cpu#2.curr->pid
     32679 ± 5%     +37.9%      45073 ± 0%  TOTAL sched_debug.cfs_rq[6]:/.avg->runnable_avg_sum
       722 ± 2%     +35.8%        981 ± 0%  TOTAL sched_debug.cfs_rq[1]:/.tg_runnable_contrib
      2841 ±20%     +54.9%       4399 ± 1%  TOTAL sched_debug.cpu#0.curr->pid
     32684 ± 5%     +37.8%      45024 ± 0%  TOTAL sched_debug.cfs_rq[21]:/.avg->runnable_avg_sum
       714 ± 5%     +37.3%        980 ± 0%  TOTAL sched_debug.cfs_rq[6]:/.tg_runnable_contrib
        22 ±10%     +33.3%         29 ± 1%  TOTAL sched_debug.cpu#12.cpu_load[4]
   1044460 ±29%     -42.8%     597073 ± 1%  TOTAL sched_debug.cpu#31.sched_count
      2962 ±10%     +45.6%       4314 ± 2%  TOTAL sched_debug.cpu#21.curr->pid
    107755 ± 0%     +35.8%     146314 ± 0%  TOTAL sched_debug.cfs_rq[16]:/.exec_clock
      3040 ±14%     +45.8%       4431 ± 3%  TOTAL sched_debug.cpu#18.curr->pid
       713 ± 5%     +37.3%        980 ± 0%  TOTAL sched_debug.cfs_rq[21]:/.tg_runnable_contrib
    107444 ± 0%     +36.2%     146370 ± 0%  TOTAL sched_debug.cfs_rq[8]:/.exec_clock
     33921 ± 7%     +32.9%      45070 ± 0%  TOTAL sched_debug.cfs_rq[5]:/.avg->runnable_avg_sum
        19 ±16%     +41.7%         27 ± 4%  TOTAL sched_debug.cpu#27.cpu_load[0]
        18 ±16%     +46.8%         27 ± 4%  TOTAL sched_debug.cpu#27.cpu_load[1]
        20 ±13%     +35.3%         27 ± 4%  TOTAL sched_debug.cpu#24.cpu_load[0]
    110484 ± 1%     +34.1%     148181 ± 0%  TOTAL sched_debug.cfs_rq[10]:/.exec_clock
    108447 ± 0%     +34.7%     146038 ± 0%  TOTAL sched_debug.cfs_rq[17]:/.exec_clock
       741 ± 7%     +32.3%        980 ± 0%  TOTAL sched_debug.cfs_rq[5]:/.tg_runnable_contrib
      3131 ±10%     +40.9%       4412 ± 5%  TOTAL sched_debug.cpu#29.curr->pid
    108894 ± 1%     +33.9%     145821 ± 0%  TOTAL sched_debug.cfs_rq[24]:/.exec_clock
    108897 ± 0%     +34.3%     146281 ± 0%  TOTAL sched_debug.cfs_rq[9]:/.exec_clock
    110117 ± 2%     +32.5%     145856 ± 0%  TOTAL sched_debug.cfs_rq[25]:/.exec_clock
    109871 ± 1%     +32.8%     145922 ± 0%  TOTAL sched_debug.cfs_rq[15]:/.exec_clock
    110887 ± 1%     +32.8%     147227 ± 0%  TOTAL sched_debug.cfs_rq[12]:/.exec_clock
        20 ±13%     +40.2%         28 ± 4%  TOTAL sched_debug.cpu#0.cpu_load[3]
        21 ± 7%     +30.5%         27 ± 2%  TOTAL sched_debug.cfs_rq[28]:/.runnable_load_avg
        20 ± 7%     +37.9%         28 ± 1%  TOTAL sched_debug.cpu#18.cpu_load[1]
        21 ± 9%     +30.6%         28 ± 2%  TOTAL sched_debug.cfs_rq[29]:/.runnable_load_avg
        19 ±12%     +43.4%         28 ± 1%  TOTAL sched_debug.cpu#20.cpu_load[1]
        20 ± 9%     +38.8%         28 ± 2%  TOTAL sched_debug.cpu#21.cpu_load[2]
        21 ± 5%     +33.0%         28 ± 2%  TOTAL sched_debug.cpu#28.cpu_load[3]
        21 ± 5%     +32.4%         27 ± 2%  TOTAL sched_debug.cpu#28.cpu_load[1]
        20 ± 5%     +33.7%         27 ± 2%  TOTAL sched_debug.cpu#28.cpu_load[2]
        21 ± 9%     +29.0%         27 ± 5%  TOTAL sched_debug.cpu#29.cpu_load[0]
        21 ±13%     +35.2%         28 ± 3%  TOTAL sched_debug.cpu#24.cpu_load[2]
        21 ± 9%     +34.3%         28 ± 1%  TOTAL sched_debug.cpu#18.cpu_load[0]
      3098 ±11%     +39.9%       4335 ± 2%  TOTAL sched_debug.cpu#25.curr->pid
    109876 ± 0%     +33.3%     146491 ± 0%  TOTAL sched_debug.cfs_rq[11]:/.exec_clock
    268016 ± 3%     +32.8%     355948 ± 9%  TOTAL meminfo.Committed_AS
    109686 ± 1%     +33.3%     146181 ± 0%  TOTAL sched_debug.cfs_rq[13]:/.exec_clock
    109930 ± 1%     +33.3%     146529 ± 0%  TOTAL sched_debug.cfs_rq[18]:/.exec_clock
    110814 ± 2%     +31.8%     146073 ± 0%  TOTAL sched_debug.cfs_rq[22]:/.exec_clock
    111231 ± 1%     +31.2%     145955 ± 0%  TOTAL sched_debug.cfs_rq[26]:/.exec_clock
    792742 ± 2%     -24.3%     599925 ± 1%  TOTAL sched_debug.cpu#8.nr_switches
        20 ±13%     +40.6%         28 ± 2%  TOTAL sched_debug.cpu#14.cpu_load[2]
        22 ±11%     +30.4%         29 ± 1%  TOTAL sched_debug.cpu#12.cpu_load[3]
        22 ±10%     +32.7%         29 ± 3%  TOTAL sched_debug.cfs_rq[21]:/.runnable_load_avg
        22 ±11%     +26.5%         28 ± 1%  TOTAL sched_debug.cpu#12.cpu_load[2]
        20 ±11%     +43.1%         29 ± 5%  TOTAL sched_debug.cpu#0.cpu_load[4]
        22 ±11%     +29.1%         28 ± 2%  TOTAL sched_debug.cpu#12.cpu_load[1]
        22 ±21%     +30.0%         28 ± 2%  TOTAL sched_debug.cpu#17.cpu_load[3]
    896719 ±18%     -31.3%     615816 ± 4%  TOTAL sched_debug.cpu#30.sched_count
    110467 ± 1%     +32.0%     145847 ± 0%  TOTAL sched_debug.cfs_rq[19]:/.exec_clock
    110856 ± 1%     +31.7%     145977 ± 0%  TOTAL sched_debug.cfs_rq[20]:/.exec_clock
    112749 ± 1%     +32.1%     148960 ± 0%  TOTAL sched_debug.cfs_rq[2]:/.exec_clock
    110628 ± 1%     +32.0%     146083 ± 0%  TOTAL sched_debug.cfs_rq[23]:/.exec_clock
    116500 ± 1%     +31.0%     152586 ± 0%  TOTAL sched_debug.cfs_rq[0]:/.exec_clock
     33803 ± 6%     +33.2%      45033 ± 0%  TOTAL sched_debug.cfs_rq[12]:/.avg->runnable_avg_sum
       738 ± 6%     +32.9%        981 ± 0%  TOTAL sched_debug.cfs_rq[12]:/.tg_runnable_contrib
    111685 ± 0%     +30.4%     145683 ± 0%  TOTAL sched_debug.cfs_rq[4]:/.exec_clock
    111045 ± 1%     +31.3%     145845 ± 0%  TOTAL sched_debug.cfs_rq[21]:/.exec_clock
    111156 ± 0%     +31.3%     145923 ± 0%  TOTAL sched_debug.cfs_rq[14]:/.exec_clock
    111731 ± 0%     +30.3%     145623 ± 0%  TOTAL sched_debug.cfs_rq[5]:/.exec_clock
    111147 ± 1%     +31.0%     145641 ± 0%  TOTAL sched_debug.cfs_rq[6]:/.exec_clock
      3172 ± 3%     +33.8%       4245 ± 0%  TOTAL sched_debug.cpu#12.curr->pid
    111847 ± 0%     +30.4%     145836 ± 0%  TOTAL sched_debug.cfs_rq[1]:/.exec_clock
        20 ±39%     +43.1%         29 ± 3%  TOTAL sched_debug.cpu#63.load
    111241 ± 0%     +31.0%     145727 ± 0%  TOTAL sched_debug.cfs_rq[3]:/.exec_clock
    111457 ± 1%     +30.7%     145630 ± 0%  TOTAL sched_debug.cfs_rq[31]:/.exec_clock
    112620 ± 1%     +29.4%     145693 ± 0%  TOTAL sched_debug.cfs_rq[27]:/.exec_clock
    112963 ± 1%     +28.9%     145645 ± 0%  TOTAL sched_debug.cfs_rq[29]:/.exec_clock
    112421 ± 0%     +29.6%     145673 ± 0%  TOTAL sched_debug.cfs_rq[7]:/.exec_clock
      7338 ±11%     +23.3%       9050 ± 7%  TOTAL numa-vmstat.node3.nr_anon_pages
     29353 ±11%     +23.3%      36204 ± 7%  TOTAL numa-meminfo.node3.AnonPages
    766344 ± 4%     -22.2%     596356 ± 1%  TOTAL sched_debug.cpu#12.nr_switches
    112871 ± 0%     +29.0%     145613 ± 0%  TOTAL sched_debug.cfs_rq[28]:/.exec_clock
    785724 ± 2%     -22.0%     612543 ± 0%  TOTAL sched_debug.cpu#0.nr_switches
    770632 ± 2%     -22.3%     598517 ± 1%  TOTAL sched_debug.cpu#15.nr_switches
    113328 ± 0%     +28.5%     145614 ± 0%  TOTAL sched_debug.cfs_rq[30]:/.exec_clock
        19 ±16%     +40.2%         27 ± 2%  TOTAL sched_debug.cfs_rq[0]:/.runnable_load_avg
        19 ±23%     +39.2%         27 ± 4%  TOTAL sched_debug.cfs_rq[26]:/.runnable_load_avg
    763775 ± 3%     -21.8%     596955 ± 1%  TOTAL sched_debug.cpu#13.nr_switches
        21 ±10%     +30.6%         28 ± 4%  TOTAL sched_debug.cpu#29.cpu_load[1]
        20 ±10%     +36.5%         28 ± 3%  TOTAL sched_debug.cpu#21.cpu_load[1]
        21 ±18%     +31.1%         27 ± 1%  TOTAL sched_debug.cpu#0.cpu_load[1]
        22 ± 4%     +30.0%         28 ± 4%  TOTAL sched_debug.cpu#52.load
        21 ±11%     +30.8%         28 ± 3%  TOTAL sched_debug.cpu#21.cpu_load[0]
        21 ± 6%     +28.4%         28 ± 3%  TOTAL sched_debug.cpu#28.cpu_load[0]
        21 ±19%     +31.8%         28 ± 2%  TOTAL sched_debug.cpu#17.cpu_load[2]
        19 ±20%     +45.8%         28 ± 3%  TOTAL sched_debug.cpu#26.cpu_load[0]
        22 ±16%     +27.3%         28 ± 5%  TOTAL sched_debug.cfs_rq[27]:/.runnable_load_avg
        21 ±17%     +29.4%         28 ± 2%  TOTAL sched_debug.cpu#17.cpu_load[0]
        21 ±12%     +32.1%         28 ± 2%  TOTAL sched_debug.cfs_rq[24]:/.runnable_load_avg
        20 ±17%     +34.6%         28 ± 2%  TOTAL sched_debug.cpu#0.cpu_load[2]
    773695 ± 2%     -22.5%     599935 ± 1%  TOTAL sched_debug.cpu#11.nr_switches
    760832 ± 2%     -21.3%     598498 ± 1%  TOTAL sched_debug.cpu#9.nr_switches
        23 ±17%     +20.3%         28 ± 5%  TOTAL sched_debug.cfs_rq[52]:/.load
    761399 ± 1%     -21.2%     600107 ± 1%  TOTAL sched_debug.cpu#10.nr_switches
    770683 ± 1%     -21.1%     607908 ± 1%  TOTAL sched_debug.cpu#2.nr_switches
    757803 ± 4%     -20.7%     600923 ± 1%  TOTAL sched_debug.cpu#6.nr_switches
    750665 ± 1%     -19.1%     606952 ± 0%  TOTAL sched_debug.cpu#1.nr_switches
    744077 ± 2%     -19.6%     598358 ± 0%  TOTAL sched_debug.cpu#16.nr_switches
    753828 ± 1%     -19.6%     605817 ± 1%  TOTAL sched_debug.cpu#3.nr_switches
    742810 ± 2%     -18.9%     602251 ± 0%  TOTAL sched_debug.cpu#5.nr_switches
    732991 ± 2%     -18.5%     597448 ± 1%  TOTAL sched_debug.cpu#17.nr_switches
    725349 ± 2%     -17.9%     595187 ± 1%  TOTAL sched_debug.cpu#14.nr_switches
        21 ±18%     +29.6%         28 ± 2%  TOTAL sched_debug.cpu#17.cpu_load[1]
        22 ±14%     +28.2%         28 ± 2%  TOTAL sched_debug.cpu#12.cpu_load[0]
    736992 ± 2%     -17.8%     605506 ± 1%  TOTAL sched_debug.cpu#4.nr_switches
    724402 ± 1%     -16.7%     603369 ± 0%  TOTAL sched_debug.cpu#7.nr_switches
    712130 ± 2%     -15.5%     602079 ± 1%  TOTAL sched_debug.cpu#24.nr_switches
    715409 ± 5%     -16.1%     600473 ± 2%  TOTAL sched_debug.cpu#22.nr_switches
    169672 ± 0%     +19.0%     201867 ± 0%  TOTAL meminfo.Active(anon)
     42418 ± 0%     +18.9%      50446 ± 0%  TOTAL proc-vmstat.nr_active_anon
    710553 ± 3%     -16.0%     597062 ± 1%  TOTAL sched_debug.cpu#31.nr_switches
    723251 ± 2%     -17.1%     599549 ± 1%  TOTAL sched_debug.cpu#18.nr_switches
    706093 ± 4%     -14.9%     601183 ± 1%  TOTAL sched_debug.cpu#26.nr_switches
    704669 ± 2%     -14.9%     599338 ± 1%  TOTAL sched_debug.cpu#20.nr_switches
    703753 ± 3%     -15.3%     596238 ± 1%  TOTAL sched_debug.cpu#21.nr_switches
    702440 ± 5%     -15.1%     596380 ± 1%  TOTAL sched_debug.cpu#25.nr_switches
    702660 ± 4%     -14.7%     599141 ± 1%  TOTAL sched_debug.cpu#19.nr_switches
        22 ±14%     +28.2%         28 ± 4%  TOTAL sched_debug.cfs_rq[12]:/.runnable_load_avg
        22 ±22%     +32.4%         29 ± 1%  TOTAL sched_debug.cpu#34.load
    701182 ± 4%     -14.6%     598606 ± 1%  TOTAL sched_debug.cpu#23.nr_switches
      0.23 ± 5%     -15.8%       0.19 ± 6%  TOTAL turbostat.%pc3
    238557 ± 0%     +13.5%     270767 ± 0%  TOTAL meminfo.Active
    135003 ± 0%     +12.7%     152182 ± 0%  TOTAL sched_debug.cpu#56.nr_load_updates
    135518 ± 1%     +12.2%     152028 ± 0%  TOTAL sched_debug.cpu#63.nr_load_updates
    668473 ± 4%     -10.5%     598372 ± 1%  TOTAL sched_debug.cpu#29.nr_switches
    137963 ± 0%     +11.9%     154381 ± 0%  TOTAL sched_debug.cpu#57.nr_load_updates
    135802 ± 0%     +12.1%     152194 ± 0%  TOTAL sched_debug.cpu#58.nr_load_updates
    673342 ± 3%     -10.3%     604167 ± 2%  TOTAL sched_debug.cpu#30.nr_switches
    136075 ± 0%     +11.8%     152117 ± 0%  TOTAL sched_debug.cpu#60.nr_load_updates
    136265 ± 0%     +11.6%     152124 ± 0%  TOTAL sched_debug.cpu#59.nr_load_updates
    136657 ± 0%     +11.5%     152399 ± 0%  TOTAL sched_debug.cpu#48.nr_load_updates
    672367 ± 4%     -10.6%     600775 ± 2%  TOTAL sched_debug.cpu#27.nr_switches
    136400 ± 0%     +11.6%     152176 ± 0%  TOTAL sched_debug.cpu#61.nr_load_updates
    136146 ± 0%     +11.7%     152103 ± 0%  TOTAL sched_debug.cpu#62.nr_load_updates
      1848 ± 2%     +10.9%       2049 ± 5%  TOTAL numa-meminfo.node0.Mapped
    136683 ± 0%     +11.4%     152199 ± 0%  TOTAL sched_debug.cpu#55.nr_load_updates
    137175 ± 0%     +11.0%     152310 ± 0%  TOTAL sched_debug.cpu#51.nr_load_updates
    139156 ± 0%     +10.8%     154236 ± 0%  TOTAL sched_debug.cpu#49.nr_load_updates
    137076 ± 0%     +11.1%     152253 ± 0%  TOTAL sched_debug.cpu#53.nr_load_updates
    672781 ± 3%     -10.5%     601982 ± 1%  TOTAL sched_debug.cpu#28.nr_switches
    136873 ± 1%     +11.2%     152248 ± 0%  TOTAL sched_debug.cpu#52.nr_load_updates
    137601 ± 0%     +10.8%     152404 ± 0%  TOTAL sched_debug.cpu#50.nr_load_updates
    137409 ± 0%     +10.8%     152228 ± 0%  TOTAL sched_debug.cpu#54.nr_load_updates
    608198 ± 1%   +5895.2%   36462984 ± 0%  TOTAL time.voluntary_context_switches
     62.13 ± 1%    +247.4%     215.86 ± 1%  TOTAL time.user_time
    560843 ± 0%     -53.2%     262235 ± 0%  TOTAL vmstat.system.cs
     54.79 ± 0%     +81.7%      99.56 ± 0%  TOTAL turbostat.%c0
     38022 ± 0%     +76.6%      67144 ± 0%  TOTAL vmstat.system.in
      2726 ± 0%     +68.6%       4596 ± 0%  TOTAL time.percent_of_cpu_this_job_got
      8155 ± 0%     +67.2%      13638 ± 0%  TOTAL time.system_time
    951709 ± 0%     +53.4%    1459554 ± 0%  TOTAL time.involuntary_context_switches
    227030 ± 1%     -16.1%     190393 ± 0%  TOTAL time.minor_page_faults


                                     qperf.sctp.bw

   1.3e+09 ++---------------------------------------------------------------+
   1.2e+09 ++    O                                         O              O |
           O OO O  O       O          O  O  O OO   OO OO O     O    O  O O  |
   1.1e+09 ++        OO OO  O O OO OO   O  O     O            O  OO   O     O
     1e+09 ++                                               O               |
           |                                                                |
     9e+08 ++                                                               |
     8e+08 ++                                                               |
     7e+08 ++                                                               |
           |                                                                |
     6e+08 ++                                                               |
     5e+08 ++                                                               |
           |                                      .**.         *. *.        |
     4e+08 *+**.**.*. *.**.**.*.**.**.*.**.**.**.*    **.*.**.*  *  *.**    |
     3e+08 ++--------*------------------------------------------------------+

	[*] bisect-good sample
	[O] bisect-bad  sample

To reproduce:

	apt-get install ruby ruby-oj
	git clone git://git.kernel.org/pub/scm/linux/kernel/git/wfg/lkp-tests.git
	cd lkp-tests
	bin/setup-local job.yaml # the job file attached in this email
	bin/run-local   job.yaml

Disclaimer:
Results have been estimated based on internal Intel analysis and are provided
for informational purposes only. Any difference in system hardware or software
design or configuration may affect actual performance.

Thanks,
Fengguang

--i0/AhcQY5QxfSsSZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="job.yaml"

---
testcase: netperf
default_monitors:
  watch-oom: 
  wait: pre-test
  uptime: 
  iostat: 
  vmstat: 
  numa-numastat: 
  numa-vmstat: 
  numa-meminfo: 
  proc-vmstat: 
  proc-stat: 
  meminfo: 
  slabinfo: 
  interrupts: 
  lock_stat: 
  latency_stats: 
  softirqs: 
  bdi_dev_mapping: 
  diskstats: 
  energy: 
  cpuidle: 
  cpufreq: 
  turbostat: 
  sched_debug:
    interval: 10
  pmeter: 
model: Nehalem-EX
memory: 256G
nr_ssd_partitions: 6
ssd_partitions: "/dev/disk/by-id/ata-INTEL_SSD*part1"
swap_partitions: "/dev/disk/by-id/ata-WDC_WD10EARS-00Y5B1_WD-WCAV5F059074-part2"
runtime: 300s
nr_threads:
- 200%
perf-profile:
  freq: 800
netperf:
  send_size: 10K
  test:
  - SCTP_STREAM_MANY
branch: linus/master
commit: 19583ca584d6f574384e17fe7613dfaeadcdc4a6
repeat_to: 3
enqueue_time: 2014-09-25 21:41:16.275537552 +08:00
testbox: lkp-nex04
kconfig: x86_64-rhel
kernel: "/kernel/x86_64-rhel/19583ca584d6f574384e17fe7613dfaeadcdc4a6/vmlinuz-3.16.0"
user: lkp
queue: wfg
result_root: "/result/lkp-nex04/netperf/300s-200%-10K-SCTP_STREAM_MANY/debian-x86_64.cgz/x86_64-rhel/19583ca584d6f574384e17fe7613dfaeadcdc4a6/0"
job_file: "/lkp/scheduled/lkp-nex04/wfg_netperf-300s-200%-10K-SCTP_STREAM_MANY-x86_64-rhel-19583ca584d6f574384e17fe7613dfaeadcdc4a6-2.yaml"
dequeue_time: 2014-09-30 00:21:40.347862294 +08:00
history_time: 300
job_state: finished
loadavg: 139.56 108.61 48.96 2/529 13193
start_time: '1412007779'
end_time: '1412008083'
version: "/lkp/lkp/.src-20140929-152043"

--i0/AhcQY5QxfSsSZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=reproduce

netserver
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K
netperf -t SCTP_STREAM_MANY -c -C -l 300 -- -m 10K

--i0/AhcQY5QxfSsSZ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

_______________________________________________
LKP mailing list
LKP@linux.intel.com

--i0/AhcQY5QxfSsSZ--
