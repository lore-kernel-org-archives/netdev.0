From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] korina: set dev field of allocated socketbufs
Date: Mon, 19 Jan 2009 16:24:20 -0800 (PST)
Message-ID: <20090119.162420.70179317.davem@davemloft.net>
References: <1232058598-15811-3-git-send-email-n0-1@freewrt.org>
	<20090115223035.AD41B4043839@mail.nwl.cc>
	<200901192208.01586.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: n0-1@freewrt.org, netdev@vger.kernel.org, jeff@garzik.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49553
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764766AbZATAYT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 19:24:19 -0500
In-Reply-To: <200901192208.01586.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Mon, 19 Jan 2009 22:08:00 +0100

> Le Thursday 15 January 2009 23:29:58 Phil Sutter, vous avez =E9crit=A0=
:
> > I'm not sure if this is necessary, but the original driver did it a=
nd
> > apparently also many other drivers do it, so it should not be compl=
etely
> > wrong to do it.
> >
> > Signed-off-by: Phil Sutter <n0-1@freewrt.org>
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

The eth_type_trans() call does the 'skb->dev =3D dev;' assignment
for you.

Not applied.
