From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Bug in 2.6.11.11 - udp_poll(), fragments + CONFIG_HIGHMEM
Date: Mon, 30 May 2005 15:50:37 -0700 (PDT)
Message-ID: <20050530.155037.128618730.davem@davemloft.net>
References: <E1DclTK-0002qE-00@mta1.cl.cam.ac.uk>
	<E1Dcs8Y-0006bl-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Steven.Hand@cl.cam.ac.uk, linux-net@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <E1Dcs8Y-0006bl-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 31 May 2005 07:49:30 +1000

> Thanks for catching this.  The receive queue lock is never taken
> in IRQs (and should never be) so we can simply substitute bh for
> irq.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
