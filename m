From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4/IPV6] Keep wmem accounting separate in ip*_push_pending_frames
Date: Mon, 16 May 2005 11:00:58 +1000
Message-ID: <20050516010058.GA20704@gondor.apana.org.au>
References: <20050515.152441.106262257.davem@davemloft.net> <20050515232020.GA19859@gondor.apana.org.au> <20050515235913.GA20242@gondor.apana.org.au> <20050515.173944.122590923.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050515.173944.122590923.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, May 15, 2005 at 05:39:44PM -0700, David S. Miller wrote:
> 
> This code should therefore just skb_orphan(), and nothing
> more.  Right?

Ideally we should move the ownership to the head skb here as well.
However, doing this would cause havoc when you have nasty users
sending fragments from two different sockets :)

So let's stick with just the skb_orphan.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
