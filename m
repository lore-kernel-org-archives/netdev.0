From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [netfilter-core] [NETFILTER] Apply IPsec to ipt_REJECT packets
Date: Wed, 24 Nov 2004 08:17:05 +1100
Message-ID: <20041123211705.GA9843@gondor.apana.org.au>
References: <20041123084225.GA3514@gondor.apana.org.au> <41A37EC0.8010901@trash.net> <20041123211630.GA9805@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, coreteam@netfilter.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <20041123211630.GA9805@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 24, 2004 at 08:16:30AM +1100, herbert wrote:
> On Tue, Nov 23, 2004 at 07:17:36PM +0100, Patrick McHardy wrote:
> > 
> > The patch doesn't handle tcp resets sent in response to a forwarded packet.
> > I'll send a patch later tonight.
> 
> Isn't that handled by ip_forward itself?

In fact that's probably the reason why nobody has noticed this bug
until now :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
