From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Wed, 23 Mar 2011 12:59:58 -0700
Message-ID: <20110323125958.76285c0f.rdunlap@xenotime.net>
References: <4D79F068.2080009@linaro.org>
	<201103232035.18232.arnd@arndb.de>
	<AANLkTim7hPfTv3gDYnh+jGxHBg0OvX=r1FKYoHnH7H_o@mail.gmail.com>
	<201103232057.18150.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgg==?= Nazarewicz <mnazarewicz@gmail.com>,
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
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201103232057.18150.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Mar 2011 20:57:18 +0100 Arnd Bergmann wrote:

> On Wednesday 23 March 2011 20:53:13 Micha=C5=82 Nazarewicz wrote:
> > On Mar 23, 2011 8:36 PM, "Arnd Bergmann" <arnd@arndb.de> wrote:
> >  >
> >  > On Wednesday 23 March 2011 19:46:50 Greg KH wrote:
> >  > > > @@ -97,6 +97,8 @@ struct driver_info {
> >  > > >
> >  > > >  #define FLAG_LINK_INTR       0x0800          /* updates lin=
k (carrier) status */
> >  > > >
> >  > > > +#define FLAG_PTP     0x1000          /* maybe use "usb%d" n=
ames */
> >  > >
> >  > > "PTP"?  What does that stand for?
> >  >
> >  > point-to-point, I'll improve the comment to spell it out when I =
send the
> >  > fixed version.
> > =20
> > I think P2P could be better.
>=20
> Yes, good idea.

that's peer-to-peer.

OTOH, I knew that PTP was point-to-point.

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your cod=
e ***
