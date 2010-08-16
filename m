From: Jiri Olsa <jolsa@redhat.com>
Subject: Re: PROBLEM: raw sockets rewriting IP ID in rare cases.
Date: Mon, 16 Aug 2010 08:50:00 +0200
Message-ID: <20100816065000.GA1973@jolsa.brq.redhat.com>
References: <201008131307.38381.morgon.j.kanter@dartmouth.edu>
 <20100814.223532.242143460.davem@davemloft.net>
 <20100815135741.1iud2jvgw0wwg4kw@webmail.dartmouth.edu>
 <20100815.131359.191392588.davem@davemloft.net>
 <1281905220.2942.57.camel@edumazet-laptop>
 <1281939985.2942.79.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Michael Kerrisk <mtk.manpages@gmail.com>,
	Morgon.J.Kanter@Dartmouth.edu, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29519 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752107Ab0HPGuK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Aug 2010 02:50:10 -0400
Content-Disposition: inline
In-Reply-To: <1281939985.2942.79.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 16, 2010 at 08:26:25AM +0200, Eric Dumazet wrote:
> Le dimanche 15 ao=FBt 2010 =E0 22:47 +0200, Eric Dumazet a =E9crit :
>=20
> > Jiri Olsa added IP_NODEFRAG option some weeks ago (commit 7b2ff18e)=
,
> > we probably could implement IP_NOIDENT option for RAW sockets ?
> >=20
> >=20
>=20
> Hmm, it seems we forgot to send to Michael some updates for
> documentation.
>=20
> http://www.kernel.org/doc/man-pages/online/pages/man7/ip.7.html
>=20
> misses IP_FREEBIND, IP_IPSEC_POLICY, IP_XFRM_POLICY, IP_PASSSEC
> IP_TRANSPARENT, IP_ORIGDSTADDR, IP_MINTTL and IP_NODEFRAG bits
>=20
>=20
>=20

hi,
I've sent out the IP_NODEFRAG man bits together with the change
http://kerneltrap.org/mailarchive/linux-netdev/2010/6/26/6280033

jirka
