From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [TCP] Modular IPv6 support in tcpdiag
Date: Thu, 4 Nov 2004 07:43:21 +1100
Message-ID: <20041103204321.GA25470@gondor.apana.org.au>
References: <20041103094451.GA20220@gondor.apana.org.au> <20041103122050.50f6f556.davem@davemloft.net> <20041103203414.GB25279@gondor.apana.org.au> <20041103122941.71a5b440.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041103122941.71a5b440.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 03, 2004 at 12:29:41PM -0800, David S. Miller wrote:
>
> > If I used that then it'll break when TCPDIAG is built-in and
> > IPv6 is built as a module.
> 
> I see, you need the ipv6 tcp socket lookup symbols... hmmm.

Well it really should be turned into a plugin system.  However,
since any effort to do that might as well be spent doing a
generic socket info interface, I thought that we should just
patch up tcp_diag and mark it as obsolete once we have a new
interface.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
