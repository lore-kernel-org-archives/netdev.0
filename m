From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: v6-in-v4 IPsec and NAT traversal
Date: Sat, 13 Mar 2004 21:06:01 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1B261p-0006gI-00@gondolin.me.apana.org.au>
References: <Pine.LNX.4.44.0403131137400.22557-100000@netcore.fi>
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi (Pekka Savola), netdev@oss.sgi.com
In-Reply-To: <Pine.LNX.4.44.0403131137400.22557-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pekka Savola <pekkas@netcore.fi> wrote:
> 
> I'm interested whether Linux IPsec implementations support:
> 
> 1) IPv6 payload inside IPv4 IPsec tunnel/transport?

It's not supported directly by the IPsec stack.  However, you can
setup an SIT tunnel over a transport IPv4 IPsec SA.

> 2) NAT-traversal? (There are at least some patches in OpenSWAN, etc. 
> for this).  This could be very handy combined with the above.

Yes.  In particular Non-ESP UDP encapsulation is supported.

I believe that OpenSWAN has the code to work with the Linux stack.

> [[ 3) Some feasible key management method, such as certificates.  I 
> think this exists, and doesn't require support in the kernel. ]]

OpenSWAN supports that.
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
