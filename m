From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] Limit sysctl_tcp_mem and sysctl_udp_mem initializers
 to prevent integer overflows.
Date: Tue, 05 Oct 2010 14:50:55 -0700 (PDT)
Message-ID: <20101005.145055.63017205.davem@davemloft.net>
References: <20101002112405.951704198@gulag1.americas.sgi.com>
	<20101002112419.248437367@gulag1.americas.sgi.com>
	<1286025736.2582.1827.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: holt@sgi.com, akpm@linux-foundation.org, w@1wt.eu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1286025736.2582.1827.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 02 Oct 2010 15:22:16 +0200

> [PATCH] net: avoid limits overflow
> 
> Robin Holt tried to boot a 16TB machine and found some limits were
> reached : sysctl_tcp_mem[2], sysctl_udp_mem[2]
> 
> We can switch infrastructure to use long "instead" of "int", now
> atomic_long_t primitives are available for free.
> 
> Reported-by: Robin Holt <holt@sgi.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Eric please resubmit this when the sysctl fix is resolved.

Thanks.
