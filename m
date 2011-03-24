From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Thu, 24 Mar 2011 14:13:54 +0100
Message-ID: <201103241413.54599.arnd@arndb.de>
References: <4D79F068.2080009@linaro.org> <4D8A8471.9060904@gmail.com> <1300924878.2638.38.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Steve Calfee <stevecalfee@gmail.com>,
	Michal Nazarewicz <mnazarewicz@gmail.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
	broonie@opensource.wolfsonmicro.com,
	lkml <linux-kernel@vger.kernel.org>,
	Nicolas Pitre <nicolas.pitre@linaro.org>,
	Greg KH <greg@kroah.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, grant.likely@secretlab.ca,
	Linux USB list <linux-usb@vger.kernel.org>,
	andy.green@linaro.org, netdev@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	roger.quadros@nokia.com,
	Jaswinder Singh <jaswinder.singh@linaro.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300924878.2638.38.camel@bwh-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 24 March 2011, Ben Hutchings wrote:
> On Wed, 2011-03-23 at 16:38 -0700, Steve Calfee wrote:
> > On 03/23/11 16:17, Michal Nazarewicz wrote:
> > >>> On Wednesday 23 March 2011 20:53:13 Micha=C5=82 Nazarewicz wrot=
e:
> > >>>> I think P2P could be better.
> > >>
> > >> OTOH, I knew that PTP was point-to-point.
> > >
> > > It can be any of that, depending on context.  For me PTP is more =
like
> > > Picture Transport Protocol, whereas "2" between two letters is us=
ually
> > > "to".
> > >
> > Well, my 2 cents, picture transport protocol is so obviously differ=
ent=20
> > than flags for network interfaces it does not cause a mental collis=
ion.=20
>=20
> PTP is also Precision Time Protocol, which *is* used on network
> interfaces (maybe not USB-connected interfaces though).
>=20
> How about FLAG_NON_IEEE, meaning that the physical layer is not based=
 on
> an IEEE 802.3, 802.11 or other standard physical layer.

I think that doesn't really express the meaning, since FLAG_WWAN is
presumably also not IEEE, right?

Thanks for the bike shedding everyone, I'll just use my own color then
and call it FLAG_POINTTOPOINT.

	Arnd
