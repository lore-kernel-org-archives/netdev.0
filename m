From: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
Subject: Re: [8390] Do not use dev->name before register_netdev
Date: Fri, 12 Mar 2004 23:16:34 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040313041634.GV32439@ruslug.rutgers.edu>
References: <20040313025859.GA8186@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20040313025859.GA8186@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Mar 13, 2004 at 01:58:59PM +1100, Herbert Xu wrote:
> Hi:
> 
> This patch replaces/removes all uses of dev->name in 8390 drivers.
> As it is, these drivers will do printks or allocate resources with
> the name eth%d.

Why is using dev->name a bad thing? 

	Luis

-- 
GnuPG Key fingerprint = 113F B290 C6D2 0251 4D84  A34A 6ADD 4937 E20A 525E
