From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix fib metrics
Date: Thu, 24 Mar 2011 15:36:23 -0700 (PDT)
Message-ID: <20110324.153623.45921344.davem@davemloft.net>
References: <1301005107.2714.113.camel@edumazet-laptop>
	<AANLkTinv+XGBjbFoK6vpyiDW6gBEBKFjUef+mCAMJU9i@mail.gmail.com>
	<1301005946.2714.130.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alessandro.suardi@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1301005946.2714.130.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Mar 2011 23:32:26 +0100

> Then it doesnt work anymore because it parses an ipip field from
> ip route get ...
> 
> $ ip ro get 192.168.1.1
> 192.168.1.1 dev wlan0  src 192.168.1.21 
>     cache  ipid 0x784c mtu 1500 advmss 1460 hoplimit 64
> 
> 
> Maybe you upgraded iproute2

I'm leaning towards app bug too.

These default metrics wouldn't get printed before, but now because of
how metrics are handled, they will.

Userland needs to cope properly with this.
