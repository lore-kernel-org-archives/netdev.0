From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v2] IPv6: add option to use Subnet-Router anycast addresses as source addresses
Date: Fri, 3 Jan 2014 08:09:09 +0100
Message-ID: <20140103070909.GM22494@order.stressinduktion.org>
References: <20140103063041.GJ22494@order.stressinduktion.org> <1388731742.39393.YahooMailBasic@web125506.mail.ne1.yahoo.com> <20140103070426.GL22494@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36738 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751420AbaACHJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jan 2014 02:09:11 -0500
Content-Disposition: inline
In-Reply-To: <20140103070426.GL22494@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 03, 2014 at 08:04:26AM +0100, Hannes Frederic Sowa wrote:
> On Thu, Jan 02, 2014 at 10:49:02PM -0800, Fran=C3=A7ois-Xavier Le Bai=
l wrote:
> > On Fri, 1/3/14, Hannes Frederic Sowa <hannes@stressinduktion.org> w=
rote:
> >=20
> > On Thu, Jan 02, 2014 at 10:19:24PM  -0800, Fran=C3=A7ois-Xavier Le =
Bail wrote:
> >=20
> > >> Some setup may use a ping to Subnet-Router anycast
> > >> address and expect a reply to discover a unicast address
> > >> (not very secure, but ...).
> > >>
> > >> It is the reason why, I want to keep existing default.
> > =20
> > > Yep, with pre-defined anycast address I actually meant the
> > > subnet router
> > > anycast address. We currently don't need to deal with more
> > > than that one:
> > > https://www.iana.org/assignments/ipv6-anycast-addresses/ipv6-anyc=
ast-addresses.xhtml
> > =20
> > > As soon as this patch gets applied, we have to keep the knob stab=
le
> > > in its semantic.=C2=A0 So my proposal would be to change the knob=
 to just
> > > control the behaviour of ping replies and also change its
> > > name to reflect this.
> > =20
> > > Leave datagram sending with specific anycast address as
> > > source just open and
> > > don't protect it with this knob. Would that be a plan?
> > =20
> > But service discovery may be done also with UDP, so I see the knob =
as a router policy:
> > It enable or not anycast source.
>=20
> Wouldn't distributions just enable this unconditionally and no one wi=
ll ever
> look at this option again?
>=20
> IMHO it would be better if it could be controlled per application, be=
cause
> they ultimately know how their discovery protocol works. In case of p=
ing, it
> is ok, because applications cannot control the source address here.

And actually, my preferred setup would be to use anycast addresses as s=
ource
addresses, but still have ping use the unicast address. This current pa=
tch
does not allow that?

Greetings,

  Hannes
