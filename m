From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Openswan Users] Invalid argument NULL
Date: Mon, 16 Aug 2004 18:17:17 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040816181717.4b943e31.davem@redhat.com>
References: <BD428BAA.4BBE%jiva@ixiacom.com>
	<E1BwINn-0000ZX-00@gondolin.me.apana.org.au>
	<20040815112548.GA2864@gondor.apana.org.au>
	<20040815195313.31bacf13.davem@redhat.com>
	<20040817004141.GA18789@gondor.apana.org.au>
	<20040816180350.780e4912.davem@redhat.com>
	<20040817011717.GA18992@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jiva@ixiacom.com, users@lists.openswan.org, dev@lists.openswan.org,
        kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040817011717.GA18992@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 17 Aug 2004 11:17:17 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I mean that we should keep the numbers internally.  So xfrm_user.c
> will translate the names given by existing applications into numbers
> as the patch that you've just applied does.

Ok, that works.

> We can then create a new NETLINK payload type that uses numbers if
> we wish.

I think that will just be bloat.
