From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPSEC: on behavior of acquire
Date: Sat, 2 Apr 2005 12:12:36 +1000
Message-ID: <20050402021236.GA25054@gondor.apana.org.au>
References: <1112405144.1096.33.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        psec-tools-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112405144.1096.33.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 01, 2005 at 08:25:44PM -0500, jamal wrote:
> 
> The conclusion we reached in our discussion is:
> a) -ERESTART is the correct signal to return
> b) number of acquire retries should be configurable preferably a system
> wide value.
> 
> Thoughts?

Once we have the xfrm resolution stuff that Patrick is working on,
we can have knobs for these cases just like those in the neighbour
code.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
