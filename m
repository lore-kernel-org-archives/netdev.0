From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC]: Protect against BHs in xfrm_user_policy()
Date: Mon, 4 Apr 2005 14:06:03 +1000
Message-ID: <20050404040603.GA18025@gondor.apana.org.au>
References: <4250160D.2040405@trash.net> <20050404012040.GA16960@gondor.apana.org.au> <Pine.LNX.4.62.0504040544010.19728@kaber.coreworks.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.62.0504040544010.19728@kaber.coreworks.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Apr 04, 2005 at 05:47:44AM +0200, Patrick McHardy wrote:
> On Mon, 4 Apr 2005, Herbert Xu wrote:
> >We want the same thing for km_query, no?
> 
> In all other places were BHs are not explicitly disabled
> but need to be they are already disabled by the caller,
> so I left them as they are.

Yes you're right.  I missed the spin_lock_bh in xfrm_state_find.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
