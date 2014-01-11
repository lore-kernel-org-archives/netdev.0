From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next] IPv6: enable TCP to use an anycast address
Date: Sat, 11 Jan 2014 05:06:10 -0800 (PST)
Message-ID: <1389445570.24657.YahooMailBasic@web125502.mail.ne1.yahoo.com>
References: <CAMrnHh6pBYMLn+zsR2P_oo8KufJq7Dkjm-cSq2N2Hi638yrUog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm44.bullet.mail.ne1.yahoo.com ([98.138.120.51]:26475 "HELO
	nm44.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752343AbaAKNGX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jan 2014 08:06:23 -0500
In-Reply-To: <CAMrnHh6pBYMLn+zsR2P_oo8KufJq7Dkjm-cSq2N2Hi638yrUog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 1/11/14, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru> wrote:

> Hello!

> I am just curious: since when is TCP allowed to use anycast addresses=
?

As said in http://tools.ietf.org/html/draft-iab-anycast-arch-implicatio=
ns-12.html#section-2.1
(this informational draft is in RCF queue)

"  No firm conclusion was reached regarding
   use of TCP with anycasted services, but it was observed that
   anycasting was useful for DNS, although it did introduce some new
   complexities."

=46or this works, there is need for appropriate routing (BGP, ...).

Many DNS root-servers use TCP with anycast (IPv4 and IPV6).

see : http://tools.ietf.org/html/draft-jabley-dnsop-anycast-mapping-04#=
section-4

"   L-Root service is provided using a single IPv4 address (199.7.83.42=
)
   and a single IPv6 address (2001:500:3::42).  It should be noted that
   it is preferable to refer to the service using its DNS name (L.ROOT-
   SERVERS.NET) rather than literal addresses, since addresses can
   change from time to time."

=46ran=E7ois-Xavier Le Bail
