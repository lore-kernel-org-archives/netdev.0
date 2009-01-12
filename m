From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: Remove redundant NAPI functions
Date: Mon, 12 Jan 2009 14:09:50 +0000
Message-ID: <1231769390.3075.2.camel@achroite>
References: <1231446610.3893.17.camel@achroite>
	 <20090112071317.GA4212@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>, shemminger@vyatta.com,
	netdev@vger.kernel.org,
	Krzysztof =?UTF-8?Q?Ha=C5=82asa?= <khc@pm.waw.pl>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:47577 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751380AbZALOJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 09:09:59 -0500
In-Reply-To: <20090112071317.GA4212@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-01-12 at 07:13 +0000, Jarek Poplawski wrote:
> On Thu, Jan 08, 2009 at 08:30:10PM +0000, Ben Hutchings wrote:
> > Following the removal of the unused struct net_device * parameter f=
rom
> > the NAPI functions named *netif_rx_* in commit 908a7a1, they are
> > exactly equivalent to the corresponding *napi_* functions and are
> > therefore redundant.
> >=20
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > ---
> ...
>=20
> Alas I wasn't able to send this earlier, but here is some issue
> (I see Krzysztof tried to patch this too):
>
> > diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_=
hss.c
> > index 2dc2416..9ea167b 100644
> > --- a/drivers/net/wan/ixp4xx_hss.c
> > +++ b/drivers/net/wan/ixp4xx_hss.c
[...]
=EF=BB=BF
What's the issue - does it conflict with another change to this file?

> Plus a missing chunk for: drivers/staging/benet/be_int.c.

That didn't go in via net-next-2.6.

Since the merge window is closed I assume this will now be deferred to
2.6.30.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

