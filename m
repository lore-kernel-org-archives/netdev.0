From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Minor IPSec bug + solution
Date: Fri, 17 Sep 2004 20:27:20 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040917102720.GA14579@gondor.apana.org.au>
References: <E1C83f1-0002X7-00@gondolin.me.apana.org.au> <1095413173.2708.106.camel@mabouzek>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Bouzek <martin.bouzek@radas-atc.cz>
Content-Disposition: inline
In-Reply-To: <1095413173.2708.106.camel@mabouzek>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 17, 2004 at 11:26:13AM +0200, Martin Bouzek wrote:
>
> > > function. For tunnels it returns 
> > > 
> > > tmpl->optional && !xfrm_state_addr_cmp(tmpl, x, family);
> 
> Well, I am not expierienced with the networking kernel code,
> nevertheless I still think the check is not correct. 

If you change the && to ||, then an ESP tunnel SA marked as required
can be matched by a simple IPIP SA with the same addresses.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
