From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: ipv6: make sure multicast packets are
 not forwarded beyond the different scopes
Date: Tue, 02 May 2017 14:59:23 -0400 (EDT)
Message-ID: <20170502.145923.66844914584656456.davem@davemloft.net>
References: <20170427071202.84403-1-donatas.abraitis@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: donatas.abraitis@gmail.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170427071202.84403-1-donatas.abraitis@gmail.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Donatas Abraitis <donatas.abraitis@gmail.com>
Date: Thu, 27 Apr 2017 10:12:02 +0300

> 	    RFC4291 2.7 Routers must not forward any multicast packets
> 	    beyond of the scope indicated by the scop field in the
> 	    destination multicast address.
> 
> Signed-off-by: Donatas Abraitis <donatas.abraitis@gmail.com>

I think it's a ">=" test which is needed here, not pure equality.
Scopes are subsets of other scopes and are therefore allowed within
eachother.

Did you actually see misbehavior due to this issue, or see a real
bonafide conformance test fail?

If you're just reading the RFC and sticking tests here and there based
upon what you read, without any testing or real life verification of
the issue, this is _strongly_ discouraged.

It would even be ok if you merely showed how another open source
networking stack makes this test.
