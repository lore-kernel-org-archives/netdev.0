From: =?utf-8?Q?=C3=89meric?= Vigier
	<emeric.vigier@savoirfairelinux.com>
Subject: Re: [PATCH] smsc95xx: support ethtool get_regs
Date: Mon, 9 Jul 2012 09:44:26 -0400 (EDT)
Message-ID: <1804367527.89256.1341841466229.JavaMail.root@mail.savoirfairelinux.com>
References: <1341690959.25597.168.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Glendinning <steve@shawell.net>,
	steve glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org, Nancy Lin <nancy.lin@smsc.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([209.172.62.77]:47016 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664Ab2GINod convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 09:44:33 -0400
In-Reply-To: <1341690959.25597.168.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- Mail original -----
> On Sat, 2012-07-07 at 09:58 -0400, =C3=89meric Vigier wrote:
> [...]
> > > > +	for (i =3D 0; i <=3D PHY_SPECIAL; i++)
> > > > +		data[j++] =3D smsc95xx_mdio_read(netdev, dev->mii.phy_id, i)=
;
> > > > +}
> > >=20
> > > Again, why use PHY_SPECIAL (+ 1) here as opposed to 32 in the
> > > calculation of the length?
> >=20
> > 32 was ok, but I hesitated between defining a SMSC95XX_PHY_END or
> > using the last defined register.
> > Are 32 register-PHY generic to most devices? I mean could 32 be use
> > widely?
>=20
> Yes, the address space for the original MDIO protocol ('clause 22')
> allows for 32 registers.  Perhaps that number should be named in
> <linux/mii.h>.

I have not found any definition of this in mii.h.

>=20
> As another reviewer commented, though, MDIO PHY registers should be
> accessible with SIOCGMIIREG and mii-tool so it's not really necessary
> to
> duplicate them here.

Ok, I remove this then.

>=20
> Ben.
>=20
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>=20
>=20

--=20
Emeric
