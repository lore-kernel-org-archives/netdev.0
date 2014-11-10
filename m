From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] ipv4: Simplify raw_probe_proto_opt and avoid
 reading user iov twice
Date: Mon, 10 Nov 2014 14:26:20 -0500 (EST)
Message-ID: <20141110.142620.1948543767016798203.davem@davemloft.net>
References: <20141106.162808.1546139916210194279.davem@davemloft.net>
	<20141107020025.GC9101@gondor.apana.org.au>
	<20141107132553.GA20190@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org, nakam@linux-ipv6.org,
	yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141107132553.GA20190@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 7 Nov 2014 21:25:53 +0800

> This series rewrites the function raw_probe_proto_opt in a more
> readable fasion, and then fixes the long-standing bug where we
> read the probed bytes twice which means that what we're using to
> probe may in fact be invalid.

Series applied to net-next, thanks Herbert.
