From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for March 22 (net-sysfs.c)
Date: Mon, 22 Mar 2010 18:05:18 -0700 (PDT)
Message-ID: <20100322.180518.24600284.davem@davemloft.net>
References: <4BA78D3D.9090007@oracle.com>
	<20100322.102206.148561893.davem@davemloft.net>
	<1269290922.3043.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1269290922.3043.9.camel@edumazet-laptop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 22 Mar 2010 21:48:42 +0100

> [PATCH net-next-2.6] net: RPS depends on CONFIG_SYSFS
> 
> Randy Dunlap found net/core/net-sysfs.c could not compile if
> CONFIG_SYSFS=n
> 
> Defines CONFIG_RPS in net/Kconfig to let user disable RPS if wanted.
> 
> Reported-by: Randy Dunlap <randy.dunlap@oracle.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This is interesting but I'd like to be able to use some
of the RPS infrastructure unconditionally so I'm not ready
to apply something like this yet.

So I'll add Tom's fix for now, thanks Eric!
