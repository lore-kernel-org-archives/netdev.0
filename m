From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Tue, 3 May 2005 07:45:45 +1000
Message-ID: <20050502214545.GA13462@gondor.apana.org.au>
References: <E1DRFqC-00028H-Qi@tigger> <E1DRGWv-0003aa-00@gondolin.me.apana.org.au> <20050429093521.274adf9a.davem@davemloft.net> <20050429224931.GA18616@gondor.apana.org.au> <427623B8.8050107@wetlettuce.com> <20050502124358.7186447f.davem@davemloft.net> <20050502213220.GC16177@gondor.apana.org.au> <20050502143232.1dbec2d6.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: markb@wetlettuce.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050502143232.1dbec2d6.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 02, 2005 at 02:32:32PM -0700, David S. Miller wrote:
> On Tue, 3 May 2005 07:32:20 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > However, AFAIK the tulip driver doesn't care about other interrupts.
> 
> Even the netdev watchdog?  :-)

The watchdog runs in softirq context which is disabled while the IRQ
handler is running.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
