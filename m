From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix fib metrics
Date: Thu, 24 Mar 2011 11:59:13 -0700 (PDT)
Message-ID: <20110324.115913.13727143.davem@davemloft.net>
References: <AANLkTikZhT5LaA-UEXniDvkneH8JScaVaCaCd4LT59cV@mail.gmail.com>
	<1300983340.3747.44.camel@edumazet-laptop>
	<1300986084.3747.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alessandro.suardi@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300986084.3747.101.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Mar 2011 18:01:24 +0100

> [PATCH] ipv4: fix fib metrics
> 
> Alessandro Suardi reported that we could not change route metrics :
> 
> ip ro change default .... advmss 1400
> 
> This regression came with commit 9c150e82ac50 (Allocate fib metrics
> dynamically). fib_metrics is no longer an array, but a pointer to an
> array.
> 
> Reported-by: Alessandro Suardi <alessandro.suardi@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks a lot Eric.
