From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH net-next] IPv6: enable TCP to use an anycast address
Date: Sat, 11 Jan 2014 14:46:59 +0100
Message-ID: <20140111134659.GC4698@cpaasch-mac>
References: <CAMrnHh6pBYMLn+zsR2P_oo8KufJq7Dkjm-cSq2N2Hi638yrUog@mail.gmail.com>
 <1389445570.24657.YahooMailBasic@web125502.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: =?iso-8859-1?Q?Fran=E7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:51157 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751343AbaAKNrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 08:47:08 -0500
Content-Disposition: inline
In-Reply-To: <1389445570.24657.YahooMailBasic@web125502.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/01/14 - 05:06:10, Fran=E7ois-Xavier Le Bail wrote:
> On Sat, 1/11/14, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:
> As said in http://tools.ietf.org/html/draft-iab-anycast-arch-implicat=
ions-12.html#section-2.1
> (this informational draft is in RCF queue)

This draft does not say that TCP should be used with anycast
addresses. Rather the opposite:

"  This document does not treat in any depth
   the fact that there are deployed services with TCP transport using
   anycast today.  Evidence exists to suggest that such practice is not
   "safe" in the traditional and architectural sense (as described in
   Section 4.2). "

And Section 4.2 gives more information.
http://tools.ietf.org/html/draft-iab-anycast-arch-implications-12.html#=
section-4.2


Christoph

>=20
> "  No firm conclusion was reached regarding
>    use of TCP with anycasted services, but it was observed that
>    anycasting was useful for DNS, although it did introduce some new
>    complexities."
>=20
> For this works, there is need for appropriate routing (BGP, ...).
>=20
> Many DNS root-servers use TCP with anycast (IPv4 and IPV6).
>=20
> see : http://tools.ietf.org/html/draft-jabley-dnsop-anycast-mapping-0=
4#section-4
>=20
> "   L-Root service is provided using a single IPv4 address (199.7.83.=
42)
>    and a single IPv6 address (2001:500:3::42).  It should be noted th=
at
>    it is preferable to refer to the service using its DNS name (L.ROO=
T-
>    SERVERS.NET) rather than literal addresses, since addresses can
>    change from time to time."
>=20
> Fran=E7ois-Xavier Le Bail
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
