From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bug in ipv6_ifa_notify?
Date: Wed, 10 Nov 2004 07:35:09 +1100
Message-ID: <20041109203509.GA5109@gondor.apana.org.au>
References: <20041108121040.GA3618@gondor.apana.org.au> <20041108203741.GA993@gondor.apana.org.au> <20041109114839.GA1942@gondor.apana.org.au> <20041109.095759.109272072.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, acme@conectiva.com.br, netdev@oss.sgi.com,
        jgarzik@pobox.com, buytenh@wantstofly.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20041109.095759.109272072.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Nov 09, 2004 at 09:57:59AM -0500, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> I think this only happens when you shut down interface while DAD;
> for example, "ifup eth0 &; ifdown eth0" or something like that.

Exactly.  However, since ifup doesn't wait for DAD to complete,
you need something like 'ifup eth0; sleep 3; ifdown eth0' to
trigger it.

BTW, couldn't we move stuff like DAD to user-space?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
