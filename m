From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [8390] Do not use dev->name before register_netdev
Date: Sat, 13 Mar 2004 16:42:47 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040313054247.GA4492@gondor.apana.org.au>
References: <20040313025859.GA8186@gondor.apana.org.au> <20040313041634.GV32439@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
Content-Disposition: inline
In-Reply-To: <20040313041634.GV32439@ruslug.rutgers.edu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 12, 2004 at 11:16:34PM -0500, Luis R. Rodriguez wrote:
> On Sat, Mar 13, 2004 at 01:58:59PM +1100, Herbert Xu wrote:
> > 
> > This patch replaces/removes all uses of dev->name in 8390 drivers.
> > As it is, these drivers will do printks or allocate resources with
> > the name eth%d.
> 
> Why is using dev->name a bad thing? 

It's a bad thing if it's set to eth%d and a number hasn't been
allocated yet.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
