From: Sergej Stepanov <Sergej.Stepanov@ids.de>
Subject: Re: [PATCH v2] using mii-bitbang on different processor ports
Date: Wed, 31 Oct 2007 08:30:58 +0100
Message-ID: <1193815858.2678.2.camel@p60635-ste.ids.de>
References: <1193767812.6244.46.camel@p60635-ste.ids.de>
	 <472776AE.2060009@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares.ids.de ([213.144.29.131]:48736 "EHLO ares.ids.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752709AbXJaHbE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 03:31:04 -0400
Received: from ares.ids.de (ares.ids.de [127.0.0.1])
	by ares.ids.de (PGP Universal) with ESMTP id 0BCFFF49184
	for <netdev@vger.kernel.org>; Wed, 31 Oct 2007 08:30:59 +0100 (CET)
In-Reply-To: <472776AE.2060009@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Dienstag, den 30.10.2007, 13:23 -0500 schrieb Scott Wood:
> Sergej Stepanov wrote:
> > +	if( !of_address_to_resource(np, 1, &res[1])) {
>=20
> The spacing is still wrong.
>=20
> > -	iounmap(bitbang->dir);
> > +	if ( bitbang->mdio.dir !=3D bitbang->mdc.dir)
> > +		iounmap(bitbang->mdio.dir);
> > +	iounmap(bitbang->mdc.dir);
>=20
> And here.
>=20
> -Scott
Oh, sorry.
--=20
Sergej I. Stepanov
E-PA
IDS GmbH
Nobelstr. 18, Zim. 2.1.05
D-76275 Ettlingen
T +49 (0) 72 43/2 18-615
=46 +49 (0) 72 43/2 18-400
Email: <Sergej.Stepanov@ids.de>

<http://www.ids.de>
Gesch=C3=A4ftsf=C3=BChrer: Norbert Wagner, Friedrich Abri=C3=9F=20
Sitz der Gesellschaft: Ettlingen=20
Amtsgericht Mannheim HRB 362503

