From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Tulip interrupt uses non IRQ safe spinlock
Date: Tue, 3 May 2005 07:28:19 +1000
Message-ID: <20050502212819.GA16177@gondor.apana.org.au>
References: <E1DRFqC-00028H-Qi@tigger> <E1DRGWv-0003aa-00@gondolin.me.apana.org.au> <20050429093521.274adf9a.davem@davemloft.net> <20050429214336.04b40b3f.vsu@altlinux.ru> <4276238E.4060606@wetlettuce.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergey Vlasov <vsu@altlinux.ru>, "David S. Miller" <davem@davemloft.net>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mark Broadbent <markb@wetlettuce.com>
Content-Disposition: inline
In-Reply-To: <4276238E.4060606@wetlettuce.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, May 02, 2005 at 01:56:46PM +0100, Mark Broadbent wrote:
>
> > If what you wrote above is really correct, this means that
> > Documentation/DocBook/kernel-locking.sgml contains wrong information:
> 
> See Documentation/spin-locking.txt line 137, this states that
> spin_[un]lock() should not be used in IRQ handlers.

Line 137 in my spin-locking.txt is a blank line :) Please quote the
exact text.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
