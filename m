From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: route-cache performance
Date: Wed, 27 Aug 2003 18:02:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16204.54790.564102.63649@robur.slu.se>
References: <Pine.LNX.4.51.0308252328140.26713@ns.istop.com>
	<Pine.LNX.4.51.0308262255110.6892@ns.istop.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: ralph+d@istop.com
In-Reply-To: <Pine.LNX.4.51.0308262255110.6892@ns.istop.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello!

Ralph Doncaster writes:

 > Here's the profile details:

You should see the fib/hash functions in your profile.
Below is oprofile on 2.6 during DoS. About 110 kpps throughput.

Cpu type: P4 / Xeon
Cpu speed was (MHz estimation) : 1800.98
Counter 0 counted GLOBAL_POWER_EVENTS events (time during which processor is not stopped) 
with a unit mask of 0x01 (count cycles when processor is active) count 180000
vma      samples  %           symbol name
c0247fc8 95046    30.6702     fn_hash_lookup
c021bd30 23382    7.54509     ip_route_input
c01329bc 14384    4.64154     free_block
c021b590 13912    4.48923     ip_route_input_slow
c0132b14 11488    3.70704     kmem_cache_alloc
c01be81c 10614    3.42501     e1000_clean_rx_irq
c0216078 9394     3.03133     eth_type_trans
c021a218 7662     2.47243     rt_intern_hash
c0220348 6720     2.16846     ip_output
c021cebc 6552     2.11425     dst_free
c020ba20 6128     1.97743     skb_release_data
c012619c 5871     1.8945      rcu_do_batch
c020b8e0 5734     1.85029     alloc_skb
c0132bf0 4887     1.57698     kfree
c0211a28 4446     1.43467     dst_alloc
c01bebf0 4338     1.39982     e1000_alloc_rx_buffers
c0215f10 4228     1.36432     eth_header
c0132804 4222     1.36239     cache_alloc_refill
c01bd778 4213     1.35948     e1000_xmit_frame
c0212080 4136     1.33464     neigh_lookup
c01be674 3947     1.27365     e1000_clean_tx_irq
c0132bb4 3823     1.23364     kmem_cache_free
c02465bc 3631     1.17168     fib_validate_source
c0219950 3178     1.0255      rt_hash_code
c020bb28 2962     0.955801    __kfree_skb
c021b26c 2944     0.949993    rt_set_nexthop


Cheers.
					--ro
