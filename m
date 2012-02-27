From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] mm: add a low limit to alloc_large_system_hash
Date: Mon, 27 Feb 2012 01:45:46 -0500 (EST)
Message-ID: <20120227.014546.2244934355313645351.davem@davemloft.net>
References: <CAP=VYLp7+Apubm=PHRLSw50V9zBKmV-xFRvcO4-qAogJVp7jcw@mail.gmail.com>
	<1330147182.2462.25.camel@edumazet-laptop>
	<1330322597.3330.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, tim.bird@am.sony.com,
	kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330322597.3330.5.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Feb 2012 07:03:17 +0100

> UDP stack needs a minimum hash size value for proper operation and also
> uses alloc_large_system_hash() for proper NUMA distribution of its hash
> tables and automatic sizing depending on available system memory.
> 
> On some low memory situations, udp_table_init() must ignore the
> alloc_large_system_hash() result and reallocs a bigger memory area.
> 
> As we cannot easily free old hash table, we leak it and kmemleak can
> issue a warning.
> 
> This patch adds a low limit parameter to alloc_large_system_hash() to
> solve this problem.
> 
> We then specify UDP_HTABLE_SIZE_MIN for UDP/UDPLite hash table
> allocation.
> 
> Reported-by: Mark Asselstine <mark.asselstine@windriver.com>
> Reported-by: Tim Bird <tim.bird@am.sony.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: David S. Miller <davem@davemloft.net>

Who wants to take this?
