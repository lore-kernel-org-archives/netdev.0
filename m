From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fwd: [2.6] ethertap and af_inet.c assertion failures
Date: Sun, 16 Jan 2005 05:30:23 +1100
Message-ID: <20050115183023.GA31211@gondor.apana.org.au>
References: <E1Cpo1q-0007lI-00@gondolin.me.apana.org.au> <41E942AF.3030202@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon.roscic@chello.at, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommy Christensen <tommy.christensen@tpack.net>
Content-Disposition: inline
In-Reply-To: <41E942AF.3030202@tpack.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jan 15, 2005 at 05:19:59PM +0100, Tommy Christensen wrote:
> 
> Shouldn't there be a check for skb_shared as well? Or are the
> callers of netlink_unicast/broadcast supposed to avoid this.

Had anyone been using shared skb's here before they would've got into
trouble a long time ago with calls such as skb_orphan in the path.

Even if they managed to do that and not notice then the pskb_expand_head
call in netlink_trim would've likely caught it as well.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
