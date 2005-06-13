From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: udp.c
Date: Tue, 14 Jun 2005 09:04:22 +1000
Message-ID: <20050613230422.GA7269@gondor.apana.org.au>
References: <20050613.124515.104034144.davem@davemloft.net> <E1Dhwho-0001mn-00@gondolin.me.apana.org.au> <20050613.145716.88477054.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesper.juhl@gmail.com, mru@inprovide.com, rommer@active.by,
	bernd@firmix.at, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261652AbVFMXIL@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050613.145716.88477054.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2005 at 02:57:16PM -0700, David S. Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Tue, 14 Jun 2005 07:42:52 +1000
> 
> > It'll dump the stack anyway if we just make it a NULL pointer.
> 
> Some platforms don't handle that very cleanly, for example
> it may be necessary to have something mapped at page zero
> for one reason or another.

Are there any existing platforms that do that in kernel mode?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
