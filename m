From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] bridge : Sanitize skb before it enters
 the IP stack
Date: Sun, 19 Sep 2010 13:24:12 -0700 (PDT)
Message-ID: <20100919.132412.102552920.davem@davemloft.net>
References: <20100919193433.GF31036@stratus.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	kaber@trash.net
To: bandan.das@stratus.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100919193433.GF31036@stratus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bandan Das <bandan.das@stratus.com>
Date: Sun, 19 Sep 2010 15:34:33 -0400

> Related dicussion here : http://lkml.org/lkml/2010/9/3/16
> 
> Introduce a function br_parse_ip_options that will audit the 
> skb and possibly refill IP options before a packet enters the
> IP stack. If no options are present, the function will zero out
> the skb cb area so that it is not misinterpreted as options by some
> unsuspecting IP layer routine. If packet consistency fails, drop it.
> 
> Signed-off-by: Bandan Das <bandan.das@stratus.com>

Applied, thanks a lot!
