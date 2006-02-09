From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ppp: don't use 0 in pointer context
Date: Thu, 9 Feb 2006 11:06:31 +1100
Message-ID: <20060209000631.GA26438@gondor.apana.org.au>
References: <20060208232214.GC14543@mipter.zuzino.mipt.ru> <E1F6z45-0006qL-00@gondolin.me.apana.org.au> <20060208.155859.82670094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: adobriyan@gmail.com, dlstevens@us.ibm.com,
	carlsonj@workingcode.com, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	viro@ftp.linux.org.uk
Return-path: <linux-ppp-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060208.155859.82670094.davem@davemloft.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 08, 2006 at 03:58:59PM -0800, David S. Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 09 Feb 2006 10:49:37 +1100
> 
> > The difference between gcc -pedantic and sparse is that it doesn't
> > warn about obviously correct cases like p != 0 or p = 0.
> 
> So obviously correct that you left out an equals sign in the
> second case :-)

Actually I intended that to be an assignment as this is something that
has generated many sparse patches.  Now if this was a comparison
mistakenly written as an assignment, gcc would pick it up anyway:

a.c:3: warning: suggest parentheses around assignment used as truth value

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
