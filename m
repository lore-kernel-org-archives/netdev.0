From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] select appropriate skb size in tcp_sendmsg when TSO is used
Date: Wed, 27 Oct 2004 11:41:11 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027014111.GA5548@gondor.apana.org.au>
References: <OF96546AB5.ACE12043-ONC1256F33.0027BC6B-C1256F33.002D4A6E@de.ibm.com> <E1CKE5P-0005SP-00@gondolin.me.apana.org.au> <20041020163510.6d13e9c7.davem@davemloft.net> <20041026111912.GA18095@gondor.apana.org.au> <20041026235126.GA4733@gondor.apana.org.au> <417EE3BB.6040902@pobox.com> <20041027000724.GA4869@gondor.apana.org.au> <20041026170344.262bb3ec.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, thomas.spatzier@de.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041026170344.262bb3ec.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 26, 2004 at 05:03:44PM -0700, David S. Miller wrote:
>
> Yes and no.  SG support requires TX csum support.  See the tests we
> make at register_netdev() time.
> 
> So as long as you enforce that rule, which I believe you are,
> things are fine.

That's right, the patch will turn off SG whenever TX csum is turned off.
And if you try to turn SG on while TX csum is off, it'll return EINVAL.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
