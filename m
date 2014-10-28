From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next] net: skb_segment() should preserve backpressure
Date: Tue, 28 Oct 2014 21:15:44 +0900
Message-ID: <544F88F0.7090706@lab.ntt.co.jp>
References: <1414405781.4492.38.camel@ubuntu-vm-makita>	 <1414422089.16231.8.camel@edumazet-glaptop2.roam.corp.google.com>	 <1414424388.16231.13.camel@edumazet-glaptop2.roam.corp.google.com> <1414431051.16231.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:47914 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751650AbaJ1MP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 08:15:59 -0400
In-Reply-To: <1414431051.16231.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/10/28 2:30, Eric Dumazet wrote:
> From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> 
> This patch generalizes commit d6a4a1041176 ("tcp: GSO should be TSQ
> friendly") to protocols using skb_set_owner_w()
> 
> TCP uses its own destructor (tcp_wfree) and needs a more complex scheme
> as explained in commit 6ff50cd55545 ("tcp: gso: do not generate out of
> order packets")
> 
> This allows UDP sockets using UFO to get proper backpressure,
> thus avoiding qdisc drops and excessive cpu usage.
> 
...
> [edumazet] Rewrote patch and changelog.

This looks better in performance.
I tested this patch and couldn't find any problem.

Thank you for your reviewing and suggesting,
Toshiaki Makita
