From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] sundance: Fix oopses with corrupted
 skb_shared_info
Date: Sat, 25 Dec 2010 19:42:10 -0800 (PST)
Message-ID: <20101225.194210.104056075.davem@davemloft.net>
References: <20101225121044.GA1841@del.dom.local>
	<4D15F6C9.50700@scarlet.be>
	<20101225151217.GA1994@del.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: soete.joel@scarlet.be, eric.dumazet@gmail.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101225151217.GA1994@del.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 25 Dec 2010 16:12:17 +0100

> [PATCH net-2.6] sundance: Fix oopses with corrupted skb_shared_info
> 
> Joel Soete reported oopses at the beginning of pppoe connections since
> v2.6.35. After debugging the bug was found in sundance skb allocation
> and dma mapping code, where skb_reserve() bytes aren't taken into
> account. This is an old bug, only uncovered by some change in 2.6.35.
> 
> Initial debugging patch by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Reported-by: Joel Soete <soete.joel@scarlet.be>
> Tested-by: Joel Soete <soete.joel@scarlet.be>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>

Applied, great work Jarek.

I was auditing ppp_generic.c hoping I'd find something, but
if I had that backtrace I wouldn't have bothered :-)
