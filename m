From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v2] ftmac100: use GFP_ATOMIC allocations
 where needed
Date: Mon, 14 Mar 2011 15:40:52 -0700 (PDT)
Message-ID: <20110314.154052.45887678.davem@davemloft.net>
References: <1300048193.2761.55.camel@edumazet-laptop>
	<AANLkTi=grwkfYpBFJEyQHXbFaTov5Tc+tAR2ebzw0Bht@mail.gmail.com>
	<1300112791.3423.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ratbert.chuang@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ratbert@faraday-tech.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300112791.3423.31.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Mar 2011 15:26:31 +0100

> When running in softirq context, we should use GFP_ATOMIC allocations
> instead of GFP_KERNEL ones.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Po-Yu Chuang <ratbert@faraday-tech.com>
> Acked-by: Po-Yu Chuang <ratbert@faraday-tech.com>

Applied, thanks everyone.
