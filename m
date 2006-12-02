From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Multiple end-points behind same NAT
Date: Sat, 02 Dec 2006 14:24:40 +1100
Message-ID: <E1GqLUW-0006hZ-00@gondolin.me.apana.org.au>
References: <45709151.6060803@trustedcs.com>
Cc: netdev@vger.kernel.org, dgoeddel@trustedcs.com,
	chanson@trustedcs.com, bphan@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48654 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1759377AbWLBDYt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Dec 2006 22:24:49 -0500
To: vyekkirala@trustedcs.com (Venkat Yekkirala)
In-Reply-To: <45709151.6060803@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Venkat Yekkirala <vyekkirala@trustedcs.com> wrote:
> 
> I am wondering if 26sec supports NAT-Traversal for multiple
> endpoints behind the same NAT. In looking at xfrm_tmpl it's
> not obvious to me that it's supported, at least going by the
> following from the setkey man page:
> 
>             When NAT-T is enabled in the kernel, policy matching for ESP over
>             UDP packets may be done on endpoint addresses and port (this
>             depends on the system.  System that do not perform the port check
>             cannot support multiple endpoints behind the same NAT).  When
>             using ESP over UDP, you can specify port numbers in the endpoint
>             addresses to get the correct matching.  Here is an example:
> 
>             spdadd 10.0.11.0/24[any] 10.0.11.33/32[any] any -P out ipsec
>                 esp/tunnel/192.168.0.1[4500]-192.168.1.2[30000]/require ;
> 
> Or is this to be accomplished in a different way?

It depends on whether it's transport mode or tunnel mode.  In tunnel
mode it should work just fine.  Transport mode on the other hand
has fundamental problems with NAT-T that go beyond the Linux
implementation.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
