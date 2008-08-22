From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Fri, 22 Aug 2008 05:23:28 +0300
Message-ID: <200808220523.28242.denys@visp.net.lb>
References: <200808220457.40892.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:34548 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753416AbYHVCYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 22:24:46 -0400
In-Reply-To: <200808220457.40892.denys@visp.net.lb>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 22 August 2008, Denys Fedoryshchenko wrote:

Most significant event types where i notice getnstimeofday at top of list.

Additions:
Counted MEMORY_REQUESTS events (Memory requests by type) with a unit mask of 
0x01 (Requests to non-cacheable (UC) memory) count 5000
samples  %        samples  %        symbol name
129      31.0843  596      31.1879  getnstimeofday
54       13.0120  251      13.1345  __napi_schedule
36        8.6747  178       9.3145  default_idle
34        8.1928  164       8.5819  irq_entries_start
23        5.5422  143       7.4830  __do_softirq

and
CPU: AMD64 processors, speed 2193.74 MHz (estimated)
Counted INTERRUPTS_MASKED_CYCLES events (Cycles with interrupts masked (IF=0)) 
with a unit mask of 0x00 (No unit mask) count 5000
samples  %        symbol name
630015   62.4741  getnstimeofday
28634     2.8394  get_next_timer_interrupt
23279     2.3084  __slab_alloc
15775     1.5643  schedule
14765     1.4641  __slab_free
11154     1.1061  native_read_tsc
10953     1.0861  kmem_cache_alloc
10918     1.0827  tick_nohz_stop_sched_tick
10752     1.0662  update_wall_time
10430     1.0343  net_rx_action
10220     1.0134  __do_softirq
9895      0.9812  __update_sched_clock
