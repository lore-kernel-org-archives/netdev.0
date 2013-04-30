From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4_en: fix a build error on 32bit arches
Date: Tue, 30 Apr 2013 19:01:28 -0400 (EDT)
Message-ID: <20130430.190128.2033981457511481406.davem@davemloft.net>
References: <1367350578.11020.4.camel@edumazet-glaptop>
	<51802BE9.7020805@infradead.org>
	<1367355231.11020.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdunlap@infradead.org, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, amirv@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1367355231.11020.10.camel@edumazet-glaptop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Apr 2013 13:53:51 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit b6c39bfcf1d7d63 ("net/mlx4_en: Add a service task")
> added a build error on 32bit arches.
> 
> ERROR: "__udivdi3" [drivers/net/ethernet/mellanox/mlx4/mlx4_en.ko]
> undefined!
> 
> Fix this problem by using do_div()
> 
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Randy Dunlap <rdunlap@infradead.org>

Applied, thanks for fixing this Eric.
