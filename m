From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Minor IPSec bug + solution
Date: Mon, 20 Sep 2004 20:57:20 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920105720.GA14214@gondor.apana.org.au>
References: <E1C83f1-0002X7-00@gondolin.me.apana.org.au> <1095413173.2708.106.camel@mabouzek> <20040917102720.GA14579@gondor.apana.org.au> <1095666589.2723.8.camel@mabouzek>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Martin Bouzek <martin.bouzek@radas-atc.cz>
Content-Disposition: inline
In-Reply-To: <1095666589.2723.8.camel@mabouzek>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 20, 2004 at 09:49:49AM +0200, Martin Bouzek wrote:
> 
> Ok. And would it be possible to check the protocols too (eg.
> tmpl->id.proto == x->id.proto)? If it is realy not possible to make the

Obviously not, since IPCOMP != IPIP.

> IPComp/required tunnel to work, it would be nice to mention it in for
> example the setkey man page. It could save quite lot of time to some
> people. (like me :-) ).

IPComp is the main reason why we have optional SAs at all.  So
IPComp/required definitely does not make sense.

As to the documentation of this issue, feel free to write something up
and send it to either the kernel maintainers or one of the user-space
projects.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
