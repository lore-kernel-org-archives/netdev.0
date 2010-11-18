From: David Miller <davem@davemloft.net>
Subject: Re: error while building the kernel Mainline
Date: Thu, 18 Nov 2010 09:50:46 -0800 (PST)
Message-ID: <20101118.095046.28818361.davem@davemloft.net>
References: <1290093135.2781.167.camel@edumazet-laptop>
	<4CE561A2.2020600@gmail.com>
	<1290102497.2781.242.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: justinmattock@gmail.com, linux-net@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	horms@verge.net.au, netfilter-devel@vger.kernel.org,
	kaber@trash.net
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1290102497.2781.242.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Nov 2010 18:48:17 +0100

> Let me guess...
> 
> net/netfilter/nf_conntrack_core is compiled as a module, and ip_vs
> statically (in vmlinux) ?
> 
> CONFIG_NF_CONNTRACK=m
> CONFIG_IP_VS=y
> 
> We probably need some Kconfig magic ;)

Randy Dunlap made a similar report today with a sample .config
that triggers the problem.

I'll look into it after lunch.
