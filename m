From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] vlan: allow TSO setting on vlan interfaces
Date: Thu, 08 Jul 2010 17:05:09 +0100
Message-ID: <1278605109.16013.52.camel@achroite.uk.solarflarecom.com>
References: <1278522874.5906.9.camel@edumazet-laptop>
	 <1278523511.2080.3.camel@achroite.uk.solarflarecom.com>
	 <1278571587.2543.9.camel@edumazet-laptop>
	 <1278581971.2651.10.camel@edumazet-laptop>
	 <1278603804.16013.24.camel@achroite.uk.solarflarecom.com>
	 <1278604198.16013.35.camel@achroite.uk.solarflarecom.com>
	 <1278604830.2651.32.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:51919 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381Ab0GHQFM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 12:05:12 -0400
In-Reply-To: <1278604830.2651.32.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-07-08 at 18:00 +0200, Eric Dumazet wrote:
> Le jeudi 08 juillet 2010 =C3=A0 16:49 +0100, Ben Hutchings a =C3=A9cr=
it :
> > On Thu, 2010-07-08 at 16:43 +0100, Ben Hutchings wrote:
> > > On Thu, 2010-07-08 at 11:39 +0200, Eric Dumazet wrote:
> > > > When we need to shape traffic with low speeds, we need to disab=
le tso on
> > > > network interface :
> > > >=20
> > > > ethtool -K eth0.2240 tso off
> > > >=20
> > > > It seems vlan interfaces miss the set_tso() ethtool method.
> > > > Propagating tso changes from lower device is not always wanted,=
 some
> > > > vlans want TSO on, others want TSO off.
> > [...]
> > > I think the vlan driver should also have a netdev notifier to han=
dle
> > > feature changes on the underlying device.
> >=20
> > To clarify, I think offload features should be disabled on a vlan d=
evice
> > if they are later disabled on the underlying device.  Propagating
> > changes to enable features, as you say, might not be wanted.
>=20
> OK, but isnt it already done ?
[...]

Yes, sorry for the noise.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

