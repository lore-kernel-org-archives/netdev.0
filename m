From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Check connect address in NETLINK
Date: Tue, 29 Jun 2004 21:18:33 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629111833.GA22880@gondor.apana.org.au>
References: <20040628231439.GA3021@gondor.apana.org.au> <20040629082252.GA26866@ms2.inr.ac.ru> <20040629084552.GA6202@gondor.apana.org.au> <20040629111433.GA28463@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20040629111433.GA28463@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 29, 2004 at 03:14:33PM +0400, Alexey Kuznetsov wrote:
> 
> > Or we can set the disconnected pid to a negative value since POSIX
> > requires pid_t to be signed.  I see that you've reserved everything
> > between -4096 and 0.  So perhaps we can pick -1?
> 
> I think we can.

Great.  I'll code it up then.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
