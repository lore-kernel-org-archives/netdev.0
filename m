From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: skb_checksum_help
Date: Mon, 24 Jan 2005 15:56:35 +1100
Message-ID: <20050124045635.GA30372@gondor.apana.org.au>
References: <20050124005348.GL23931@postel.suug.ch> <E1Cst4o-0007bD-00@gondolin.me.apana.org.au> <20050123202715.281ac87c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, kaber@trash.net, david@davidcoulson.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050123202715.281ac87c.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jan 23, 2005 at 08:27:15PM -0800, David S. Miller wrote:
> 
> My current guess is that this is some successful exploit
> of some as-yet-unknown issue in netfilter's fragmentation
> handling.  But that's just a guess.  If some code underruns
> skb->data somehow while unfragging/refragging, that's a sure
> fire way to corrupt things such as the skb->ip_summed field.

Another possibility is some bogus netfilter module that the
reporter is using.  His backtrace was showing an ipq_kill which
isn't in the main tree.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
