From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Mon, 2 May 2005 14:32:32 -0700
Message-ID: <20050502143232.1dbec2d6.davem@davemloft.net>
References: <E1DRFqC-00028H-Qi@tigger>
	<E1DRGWv-0003aa-00@gondolin.me.apana.org.au>
	<20050429093521.274adf9a.davem@davemloft.net>
	<20050429224931.GA18616@gondor.apana.org.au>
	<427623B8.8050107@wetlettuce.com>
	<20050502124358.7186447f.davem@davemloft.net>
	<20050502213220.GC16177@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: markb@wetlettuce.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050502213220.GC16177@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 May 2005 07:32:20 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> However, AFAIK the tulip driver doesn't care about other interrupts.

Even the netdev watchdog?  :-)

tulip_tx_timeout takes the tp->lock.  Therefore it seems that Mark's
patch is correct _and_ needed, after all.
