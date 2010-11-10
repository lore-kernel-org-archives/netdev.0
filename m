From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: avoid limits overflow
Date: Wed, 10 Nov 2010 12:12:37 -0800 (PST)
Message-ID: <20101110.121237.28791448.davem@davemloft.net>
References: <20101005.145055.63017205.davem@davemloft.net>
	<20101110061507.GF4330@sgi.com>
	<1289381066.2860.109.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: holt@sgi.com, akpm@linux-foundation.org, w@1wt.eu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1289381066.2860.109.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 10 Nov 2010 10:24:26 +0100

> [PATCH] net: avoid limits overflow
> 
> Robin Holt tried to boot a 16TB machine and found some limits were
> reached : sysctl_tcp_mem[2], sysctl_udp_mem[2]
> 
> We can switch infrastructure to use long "instead" of "int", now
> atomic_long_t primitives are available for free.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Reported-by: Robin Holt <holt@sgi.com>
> Reviewed-by: Robin Holt <holt@sgi.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
