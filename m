From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bad TSO performance in 2.6.9-rc2-BK
Date: Fri, 24 Sep 2004 11:07:41 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040924010741.GA5452@gondor.apana.org.au>
References: <20040923161141.4ea9be4c.davem@davemloft.net> <E1CAdCy-0001FM-00@gondolin.me.apana.org.au> <20040923164149.5368d291.davem@davemloft.net> <20040924001225.GA5051@gondor.apana.org.au> <20040924004038.GA5252@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, niv@us.ibm.com, andy.grover@gmail.com, anton@samba.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040924004038.GA5252@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 24, 2004 at 10:40:38AM +1000, herbert wrote:
> 
> Probably not.  There many things (such as snd_cwnd) in the stack
> that doesn't work properly when the mss changes drastically like this.

Perhaps we should start counting in bytes instead of packets?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
