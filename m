From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Thu, 24 Mar 2011 00:01:18 +0000
Message-ID: <1300924878.2638.38.camel@bwh-desktop>
References: <4D79F068.2080009@linaro.org> <201103232035.18232.arnd@arndb.de>
	 <AANLkTim7hPfTv3gDYnh+jGxHBg0OvX=r1FKYoHnH7H_o@mail.gmail.com>
	 <201103232057.18150.arnd@arndb.de>
	 <20110323125958.76285c0f.rdunlap@xenotime.net>
	 <8762r9l94h.fsf@erwin.mina86.com>  <4D8A8471.9060904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal Nazarewicz <mnazarewicz@gmail.com>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Arnd Bergmann <arnd@arndb.de>,
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
To: Steve Calfee <stevecalfee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D8A8471.9060904@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-03-23 at 16:38 -0700, Steve Calfee wrote:
> On 03/23/11 16:17, Michal Nazarewicz wrote:
> >>>>>>> @@ -97,6 +97,8 @@ struct driver_info {
> >>>>>>>
> >>>>>>>   #define FLAG_LINK_INTR       0x0800          /* updates lin=
k (carrier) status */
> >>>>>>>
> >>>>>>> +#define FLAG_PTP     0x1000          /* maybe use "usb%d" na=
mes */
> >
> >>>>> On Wednesday 23 March 2011 19:46:50 Greg KH wrote:
> >>>>>> "PTP"?  What does that stand for?
> >
> >>>> On Mar 23, 2011 8:36 PM, "Arnd Bergmann"<arnd@arndb.de>  wrote:
> >>>>> point-to-point, I'll improve the comment to spell it out when
> >>>>> I send the fixed version.
> >
> >>> On Wednesday 23 March 2011 20:53:13 Micha=C5=82 Nazarewicz wrote:
> >>>> I think P2P could be better.
> >
> >> On Wed, 23 Mar 2011 20:57:18 +0100 Arnd Bergmann wrote:
> >>> Yes, good idea.
> >
> > Randy Dunlap<rdunlap@xenotime.net>  writes:
> >> that's peer-to-peer.
> >>
> >> OTOH, I knew that PTP was point-to-point.
> >
> > It can be any of that, depending on context.  For me PTP is more li=
ke
> > Picture Transport Protocol, whereas "2" between two letters is usua=
lly
> > "to".
> >
> Well, my 2 cents, picture transport protocol is so obviously differen=
t=20
> than flags for network interfaces it does not cause a mental collisio=
n.=20

PTP is also Precision Time Protocol, which *is* used on network
interfaces (maybe not USB-connected interfaces though).

Anyway, these USB cable interfaces can presumably be bridged to standar=
d
Ethernet, so they are really no more point-to-point than any other
Ethernet link has been since the demise of the hub.

> However P2P is about to become a huge wifi issue, which definitely is=
 in=20
> the network space. So don't confuse things in the near future, don't =
use=20
> P2P.
>
> Maybe a completely different, not so overused flag name would be bett=
er.

How about FLAG_NON_IEEE, meaning that the physical layer is not based o=
n
an IEEE 802.3, 802.11 or other standard physical layer.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
