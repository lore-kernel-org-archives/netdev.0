From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Check connect address in NETLINK
Date: Wed, 30 Jun 2004 22:08:28 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040630120828.GA31498@gondor.apana.org.au>
References: <20040628231439.GA3021@gondor.apana.org.au> <20040629082252.GA26866@ms2.inr.ac.ru> <20040629084552.GA6202@gondor.apana.org.au> <20040629111433.GA28463@ms2.inr.ac.ru> <20040629111833.GA22880@gondor.apana.org.au> <20040630112751.GA31160@gondor.apana.org.au> <20040630120045.GA7973@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20040630120045.GA7973@ms2.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jun 30, 2004 at 04:00:45PM +0400, Alexey Kuznetsov wrote:
> 
> > +	if (sock->sk_socket->state == SS_CONNECTED &&
> > +	    nlk->dst_pid != nlk_sk(ssk)->pid) {
> 
> No-no-no! sock->sk_socket can be NULL at this point.
> 
> You can use sock->sk_state =  TCP_ESTABLISHED, forxample.

OK.  Can you give me a code path that allows sk_socket to be NULL
at this point?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
