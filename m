From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix a lockdep splat
Date: Wed, 22 Sep 2010 21:23:32 -0700 (PDT)
Message-ID: <20100922.212332.45886457.davem@davemloft.net>
References: <4C9A7F7F.5010507@gmail.com>
	<1285195419.2380.39.camel@edumazet-laptop>
	<20100922.205324.68141587.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, penguin-kernel@I-love.SAKURA.ne.jp,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20100922.205324.68141587.davem@davemloft.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 22 Sep 2010 20:53:24 -0700 (PDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 23 Sep 2010 00:43:39 +0200
> 
>> (A) (this is used in net/sunrpc/xprtsock.c)
>> read_lock(&sk->sk_callback_lock) (without blocking BH)
>> <BH>
>> spin_lock(&sk->sk_slock.slock);
>> ...
>> read_lock(&sk->sk_callback_lock);
>> ...
> 
> What's the exact path that leads to this?  I looked quickly and couldn't
> find which sunrpc callback override does it.

Sorry, I'm being unusually dense at the moment, ignore this question :-)
