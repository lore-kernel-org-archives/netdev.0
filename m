From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: vxlan/veth performance issues on net.git + latest kernels
Date: Tue, 3 Dec 2013 23:39:43 +0100
Message-ID: <20131203223943.GA27512@order.stressinduktion.org>
References: <CAJZOPZL9LxB5HdqS=+gQW-MjvW2NsZOt3NPB7v1iOFoEB7SsMQ@mail.gmail.com> <1386105850.30495.38.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZ+vnqLpdjS0TNdxDa4CNTzzfqp1=Ftjf86Fd5Lb+QdSzw@mail.gmail.com> <20131203.165034.1085515763685633822.davem@davemloft.net> <1386107714.30495.40.camel@edumazet-glaptop2.roam.corp.google.com> <CAJZOPZL2dq2c=5tmx+2VHX9eD1gG=pqyiQcvCvCGT+_3SDFKkQ@mail.gmail.com> <20131203223053.GA26282@order.stressinduktion.org> <CAJZOPZLHFpUFmj26cW541LauWy89=VO=iq99OMX_tf-aWAn-ag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:57260 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755150Ab3LCWjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 17:39:45 -0500
Content-Disposition: inline
In-Reply-To: <CAJZOPZLHFpUFmj26cW541LauWy89=VO=iq99OMX_tf-aWAn-ag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 04, 2013 at 12:35:37AM +0200, Or Gerlitz wrote:
> Sorry, it doesn't help, I get the same error even with the oerf
> kernel.org tree which has these events (no sign for skb's)
> 
> 
> List of pre-defined events (to be used in -e):
>   cpu-cycles OR cycles                               [Hardware event]
>   instructions                                       [Hardware event]
>   cache-references                                   [Hardware event]
>   cache-misses                                       [Hardware event]
>   branch-instructions OR branches                    [Hardware event]
>   branch-misses                                      [Hardware event]
>   bus-cycles                                         [Hardware event]
>   stalled-cycles-frontend OR idle-cycles-frontend    [Hardware event]
>   stalled-cycles-backend OR idle-cycles-backend      [Hardware event]
>   ref-cycles                                         [Hardware event]
> 
>   cpu-clock                                          [Software event]
>   task-clock                                         [Software event]
>   page-faults OR faults                              [Software event]
>   context-switches OR cs                             [Software event]
>   cpu-migrations OR migrations                       [Software event]
>   minor-faults                                       [Software event]
>   major-faults                                       [Software event]
>   alignment-faults                                   [Software event]
>   emulation-faults                                   [Software event]
> 
>   L1-dcache-loads                                    [Hardware cache event]
>   L1-dcache-load-misses                              [Hardware cache event]
>   L1-dcache-stores                                   [Hardware cache event]
>   L1-dcache-store-misses                             [Hardware cache event]
>   L1-dcache-prefetches                               [Hardware cache event]
>   L1-dcache-prefetch-misses                          [Hardware cache event]
>   L1-icache-loads                                    [Hardware cache event]
>   L1-icache-load-misses                              [Hardware cache event]
>   L1-icache-prefetches                               [Hardware cache event]
>   L1-icache-prefetch-misses                          [Hardware cache event]
>   LLC-loads                                          [Hardware cache event]
>   LLC-load-misses                                    [Hardware cache event]
>   LLC-stores                                         [Hardware cache event]
>   LLC-store-misses                                   [Hardware cache event]
>   LLC-prefetches                                     [Hardware cache event]
>   LLC-prefetch-misses                                [Hardware cache event]
>   dTLB-loads                                         [Hardware cache event]
>   dTLB-load-misses                                   [Hardware cache event]
>   dTLB-stores                                        [Hardware cache event]
>   dTLB-store-misses                                  [Hardware cache event]
>   dTLB-prefetches                                    [Hardware cache event]

Is this the whole output of perf list? Then you seem to be missing some
tracepoint options, CONFIG_TRACEPOINTS e.g.?

I can confirm it works for me on a current net build.

Greetings,

  Hannes
