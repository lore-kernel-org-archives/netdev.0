From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v4] IPv6: use anycast addresses as source addresses in echo reply
Date: Tue, 7 Jan 2014 14:09:38 +0100
Message-ID: <20140107130938.GE24730@order.stressinduktion.org>
References: <1389098318.83283.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45029 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750966AbaAGNJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 08:09:40 -0500
Content-Disposition: inline
In-Reply-To: <1389098318.83283.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 04:38:38AM -0800, Fran=C3=A7ois-Xavier Le Bail =
wrote:
> On Mon, 1/6/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wro=
te:
>=20
> >>But if an echo request arrive on an interface
> >> which do not listen at this LL anycast, is a reply can occur ?
> =20
> > I thought quite the opposite with anycast + forwarding
> > enabled, that=C2=A0 we would process the packet.
>=20
> yes, for a global scope anycast.
> But a routers must not forward any packets with link-local source or =
destination addresses to other links, thus also ll anycast.

Of course, but in this case I hesitated because I haven't dealt a lot
with anycast recently in routing code and it seemed like RTF_ANYCAST is
exclusive-or with RTF_LOCAL. So I was really unsure if this protection
was really in place. We already had some illegal forwarding/input paths
in the past. ;)

Greetings,

  Hannes
