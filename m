From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 30 Sep 2004 10:10:07 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930001007.GB10496@gondor.apana.org.au>
References: <20040929162923.796d142e.davem@davemloft.net> <Pine.NEB.4.33.0409291945100.3434-100000@dexter.psc.edu> <20040929170310.46c58095.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Heffner <jheffner@psc.edu>, ak@suse.de, niv@us.ibm.com,
        andy.grover@gmail.com, anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040929170310.46c58095.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 29, 2004 at 05:03:10PM -0700, David S. Miller wrote:
>
> I think there are some other things we can do to make TSO work
> even better.  We turn off TSO currently when we get SACKs, that

Great.  This way we can also fix the fack_count in
tcp_sacktag_write_queue().  Currently it always counts
tso_factor packets even though the sack may only cover
part of the TSO packet.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
