From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec tunnel mode bug - malformed, misaddressed packets
Date: Mon, 18 Oct 2004 11:08:16 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018010816.GA30059@gondor.apana.org.au>
References: <41725CF5.2010606@gwi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Christopher K. Johnson" <ckjohnson@gwi.net>
Content-Disposition: inline
In-Reply-To: <41725CF5.2010606@gwi.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 17, 2004 at 11:52:21AM +0000, Christopher K. Johnson wrote:
> There is an ipsec bug in FC2 kernel 2.6.8-1.521 for ipsec tunnel mode.
> I have proven with a packet trace that some packets are
> misaddressed.  Specifically it constructs a packet of the form:
> IP header1 | AH header | IP header2 | ESP

This is purely a user-space error.  The Linux IPsec stack is
very flexible.  In particular, you can configure it to generate
non-sense such as the above quite easily.

In this case, racoon needs to be taught that only the inner SA
should be marked as tunnel mode.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
