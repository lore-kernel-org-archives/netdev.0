From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [TCP] Modular IPv6 support in tcpdiag
Date: Thu, 4 Nov 2004 07:34:14 +1100
Message-ID: <20041103203414.GB25279@gondor.apana.org.au>
References: <20041103094451.GA20220@gondor.apana.org.au> <20041103122050.50f6f556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041103122050.50f6f556.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 03, 2004 at 12:20:50PM -0800, David S. Miller wrote:
> 
> Any particular reason you didn't use the same config ifdef
> tests we use for structure layouts?  Ie.
> 
> #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)

If I used that then it'll break when TCPDIAG is built-in and
IPv6 is built as a module.

> I don't see the need for the special new config option.

The user won't see it at all since it's a def_bool.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
