From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next v5] IPv6: add the option to use anycast addresses as source addresses in echo reply
Date: Wed, 8 Jan 2014 09:22:54 +0100
Message-ID: <20140108082254.GE9007@order.stressinduktion.org>
References: <20140107205101.GJ30393@order.stressinduktion.org> <1389169066.26962.YahooMailBasic@web125506.mail.ne1.yahoo.com>
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
Received: from order.stressinduktion.org ([87.106.68.36]:47531 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754987AbaAHIWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 03:22:55 -0500
Content-Disposition: inline
In-Reply-To: <1389169066.26962.YahooMailBasic@web125506.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 08, 2014 at 12:17:46AM -0800, Fran=C3=A7ois-Xavier Le Bail =
wrote:
> On Tue, 1/7/14, Hannes Frederic Sowa <hannes@stressinduktion.org> wro=
te:
>=20
> > On Tue, Jan 07, 2014 at 02:57:27PM +0100, Francois-Xavier Le Bail w=
rote:
> > > --- a/include/net/netns/ipv6.h
> > > +++ b/include/net/netns/ipv6.h
> > > @@ -73,6 +73,7 @@ struct netns_ipv6 {
> > >  #endif
> > >  	atomic_t		dev_addr_genid;
> > >  	atomic_t		rt_genid;
> > > +	int			anycast_src_echo_reply;
> > >  };
>=20
> > Sorry, I missed that on first review and you could also do that as =
a
> > follow-up:
>=20
> > Could you move anycast_src_echo_reply to netns_sysctl_ipv6?
>=20
> I can do that, but please explain what this change is needed.

I think it is just a matter of style so that the ipv6 knobs are kept
together.

Greetings,

  Hannes
