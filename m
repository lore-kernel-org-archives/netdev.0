From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [loopback] b17c706987f: +197.7% qperf.sctp.bw
Date: Fri, 4 Apr 2014 21:56:33 +0800
Message-ID: <20140404135633.GA22386@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	lkp@01.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Daniel,

We are glad to find big SCTP performance improvements

git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next.git master
commit b17c706987fa6f28bdc1771c8266e7a69e22adcb ("loopback: sctp: add NETIF_F_SCTP_CSUM to device features")

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
 3.848e+08 ~ 6%    +197.7%  1.146e+09 ~ 5%  bens/micro/qperf/600s
 3.848e+08 ~ 6%    +197.7%  1.146e+09 ~ 5%  TOTAL qperf.sctp.bw

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
     39.30 ~ 3%     +91.0%      75.06 ~11%  lkp-a06/micro/qperf/600s
     39.30 ~ 3%     +91.0%      75.06 ~11%  TOTAL qperf.sctp.bw

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
       126 ~ 0%      -3.2%        122 ~ 0%  lkp-a06/micro/qperf/600s
       126 ~ 0%      -3.2%        122 ~ 0%  TOTAL qperf.sctp.latency

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
    216270 ~ 2%     -46.5%     115740 ~ 4%  lkp-a06/micro/qperf/600s
    216270 ~ 2%     -46.5%     115740 ~ 4%  TOTAL cpuidle.C4.usage

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
  48722971 ~ 5%     +45.1%   70681678 ~ 7%  lkp-a06/micro/qperf/600s
  48722971 ~ 5%     +45.1%   70681678 ~ 7%  TOTAL cpuidle.C2.time

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
    370655 ~ 2%     +46.8%     543952 ~ 7%  lkp-a06/micro/qperf/600s
    370655 ~ 2%     +46.8%     543952 ~ 7%  TOTAL cpuidle.C2.usage

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
      1.00 ~13%     -22.8%       0.77 ~15%  lkp-a06/micro/qperf/600s
      1.00 ~13%     -22.8%       0.77 ~15%  TOTAL perf-profile.cpu-cycles.acpi_processor_ffh_cstate_enter.acpi_idle_enter_bm.cpuidle_enter_state.cpuidle_idle_call.arch_cpu_idle

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
  18055616 ~ 4%     +28.5%   23205101 ~ 2%  bens/micro/qperf/600s
  18055616 ~ 4%     +28.5%   23205101 ~ 2%  TOTAL proc-vmstat.numa_local

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
  18055616 ~ 4%     +28.5%   23205101 ~ 2%  bens/micro/qperf/600s
  18055616 ~ 4%     +28.5%   23205101 ~ 2%  TOTAL proc-vmstat.numa_hit

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
  51480524 ~ 4%     +37.7%   70886229 ~ 2%  bens/micro/qperf/600s
  15233974 ~ 0%     +14.2%   17397187 ~ 3%  lkp-a06/micro/qperf/600s
  66714498 ~ 3%     +32.3%   88283417 ~ 2%  TOTAL proc-vmstat.pgalloc_normal

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
 2.109e+08 ~ 4%     +37.7%  2.904e+08 ~ 2%  bens/micro/qperf/600s
  24268359 ~ 0%     +14.2%   27716949 ~ 3%  lkp-a06/micro/qperf/600s
 2.352e+08 ~ 3%     +35.3%  3.181e+08 ~ 2%  TOTAL proc-vmstat.pgfree

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
 1.594e+08 ~ 4%     +37.7%  2.195e+08 ~ 2%  bens/micro/qperf/600s
   9034872 ~ 0%     +14.2%   10321019 ~ 3%  lkp-a06/micro/qperf/600s
 1.685e+08 ~ 4%     +36.4%  2.299e+08 ~ 2%  TOTAL proc-vmstat.pgalloc_dma32

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
     51262 ~ 2%     -10.0%      46151 ~ 3%  lkp-a06/micro/qperf/600s
     51262 ~ 2%     -10.0%      46151 ~ 3%  TOTAL time.involuntary_context_switches

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
     65268 ~ 1%      +6.8%      69676 ~ 0%  bens/micro/qperf/600s
     65268 ~ 1%      +6.8%      69676 ~ 0%  TOTAL vmstat.system.in

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
  33939624 ~29%     +22.6%   41609509 ~ 0%  bens/micro/qperf/600s
   4125867 ~ 1%      +3.9%    4285302 ~ 0%  lkp-a06/micro/qperf/600s
  38065492 ~26%     +20.6%   45894812 ~ 0%  TOTAL time.voluntary_context_switches

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
    129649 ~ 1%      +6.8%     138432 ~ 0%  bens/micro/qperf/600s
     13874 ~ 1%      +4.8%      14540 ~ 0%  lkp-a06/micro/qperf/600s
    143523 ~ 1%      +6.6%     152972 ~ 0%  TOTAL vmstat.system.cs

72f8e06f3ea022d  b17c706987fa6f28bdc1771c8  
---------------  -------------------------  
       739 ~19%     +12.0%        827 ~ 0%  bens/micro/qperf/600s
       812 ~ 0%      -3.4%        784 ~ 1%  lkp-a06/micro/qperf/600s
      1551 ~ 9%      +3.9%       1612 ~ 0%  TOTAL time.system_time


Legend:
	~XX%    - stddev percent
	[+-]XX% - change percent


                                     qperf.sctp.bw

   1.3e+09 ++---------------------------------------------------------------+
   1.2e+09 ++O                                             O                |
           |   O  O O                  O O        O   O  O                  |
   1.1e+09 O+         O O O O  O O O        O O O   O        O              |
     1e+09 ++                        O                                      |
           |                                                                |
     9e+08 ++                                                               |
     8e+08 ++                                                               |
     7e+08 ++                                                               |
           |                                                                |
     6e+08 ++                                                               |
     5e+08 ++                                                               |
           |                                         .*..     .*.    .*.    |
     4e+08 *+*.*..*.*.*. .*.*..*.*.*.*.*.*..*.*.*.*.*    *.*.*   *.*.   *.*.*
     3e+08 ++-----------*---------------------------------------------------+


	[*] bisect-good sample
	[O] bisect-bad  sample

Thanks,
Fengguang
