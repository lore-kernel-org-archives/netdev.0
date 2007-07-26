From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH] IPv6: ipv6_addr_type() doesn't know about RFC4193 addresses
Date: Thu, 26 Jul 2007 21:06:48 +0300
Message-ID: <200707262106.49131.rdenis@simphalempin.com>
References: <18087.57717.495366.413571@zeus.sw.starentnetworks.com> <46A8D837.1030400@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	Srinivas Akkipeddi <sakkiped@starentnetworks.com>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poy.chewa.net ([194.242.114.73]:4713 "EHLO poy.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765458AbXGZSGz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 14:06:55 -0400
In-Reply-To: <46A8D837.1030400@simon.arlott.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 26 July 2007 20:21:59 Simon Arlott wrote:
> On 26/07/07 00:49, Dave Johnson wrote:
> > ipv6_addr_type() doesn't check for 'Unique Local IPv6 Unicast
> > Addresses' (RFC4193) and returns IPV6_ADDR_RESERVED for that range.
> >
> > +	if ((st & htonl(0xFE000000)) =3D=3D htonl(0xFC000000))
> > +		return (IPV6_ADDR_UNICAST |
> > +			IPV6_ADDR_SCOPE_TYPE(IPV6_ADDR_SCOPE_GLOBAL));			/* RFC 4193 */
>
> But ULA's scope isn't global, shouldn't it be IPV6_ADDR_SCOPE_ORGLOCA=
L ?

Yes it is - global.

--=20
R=C3=A9mi Denis-Courmont
