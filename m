From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Thu, 30 Sep 2004 18:09:57 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040930080957.GA13401@gondor.apana.org.au>
References: <Pine.NEB.4.33.0409291648560.3434-100000@dexter.psc.edu> <415B24C0.2020208@us.ibm.com> <20040929145050.71afa1ac.davem@davemloft.net> <20040929215613.GC26714@wotan.suse.de> <20040929162923.796d142e.davem@davemloft.net> <20040930000515.GA10496@gondor.apana.org.au> <20040929213310.40f5f33a.davem@davemloft.net> <20040930054738.GA12667@gondor.apana.org.au> <20040930003922.3076f00f.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, niv@us.ibm.com, jheffner@psc.edu, andy.grover@gmail.com,
        anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040930003922.3076f00f.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Sep 30, 2004 at 12:39:22AM -0700, David S. Miller wrote:
> 
> The new 'seq' is equivalent to what end_seq would be of the
> TSO sub-packet.  Therefore the correct test type would be
> !before(seq, tp->snd_up), right?

You're absolutely right.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
