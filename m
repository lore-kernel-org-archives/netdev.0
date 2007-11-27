From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: e1000 driver problems
Date: Tue, 27 Nov 2007 18:44:56 +0100
Message-ID: <20071127174456.GH4365@ics.muni.cz>
References: <20061017205316.25914.qmail@web83109.mail.mud.yahoo.com> <45354850.6050900@intel.com> <20071120143803.GA5638@ics.muni.cz> <474B5610.4030800@intel.com> <20071127150700.GB4365@ics.muni.cz> <474C4A74.90705@intel.com> <20071127173146.GG4365@ics.muni.cz> <474C5678.3060609@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:48058 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756415AbXK0SCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 13:02:05 -0500
Content-Disposition: inline
In-Reply-To: <474C5678.3060609@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 09:40:08AM -0800, Kok, Auke wrote:
> > I'm afraid, I'm missing the point as you have stated that in-kernel=
 drivers
> > have problem with suspicious board hang...
>=20
> my mistake, sorry for that confusion.
>=20
> the fake hangs on 82562/6 devices occur on 10mbit link only. You can =
check in the
> code for a line that says:
>=20
> 	adapter->tx_timeout_factor =3D 8;
>=20
> change that number to 16 to cope with the problem on 10mbit link part=
ners.
> However this won't fix the issue on 100mbit partners and we need to
> investigate that if that is the case.

100mbit is the issue in my case.

--=20
Luk=E1=B9 Hejtm=E1nek
