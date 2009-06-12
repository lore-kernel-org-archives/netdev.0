From: David Miller <davem@davemloft.net>
Subject: Re: CONFIG_ARPD help text
Date: Thu, 11 Jun 2009 20:59:06 -0700 (PDT)
Message-ID: <20090611.205906.215886308.davem@davemloft.net>
References: <4A314CC5.9090505@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46610
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758172AbZFLD7E convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 23:59:04 -0400
In-Reply-To: <4A314CC5.9090505@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Timo Ter=E4s <timo.teras@iki.fi>
Date: Thu, 11 Jun 2009 21:28:21 +0300

> I just re-read again the CONFIG_ARPD help text. It says it's
> "experimental and also obsolete".
>=20
> But as opennhrp relies on this, and has shown the usefulness for
> this interface - it can be used to implement other protocols that
> resolve neighbor address than ARP in userland. In this case the
> NHRP protocol.
>=20
> Would it be acceptable to remove the designation as "obsolete"?
>=20
> Also, I'm running the opennhrp on production with reasonable
> size network (100+ nodes in gre subnet). And with the fix I sent
> previously it seems to work very stable. Is there something more
> to be done, or could the "experimental" marking be removed also?
>=20
> I could also update the help to explain where the option is useful.
> Or should the option be renamed to something like NEIGH_NETLINK?
> It also seems that IPv6 supports CONFIG_ARPD so it should probably
> be moved from net/ipv4/Kconfig to likely net/core/Kconfig?

I think it's rediculious to have these tags on something that's
been in active, useful, use for years.  Feel free to remove them
and to expand the help text.

Thanks!
