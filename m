From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v2] ipvlan: Initial check-in of the IPVLAN
 driver.
Date: Fri, 21 Nov 2014 01:20:36 +0000
Message-ID: <1416532836.7215.13.camel@decadent.org.uk>
References: <1416205634-26611-1-git-send-email-maheshb@google.com>
	 <20141118.155437.1582768084232091503.davem@davemloft.net>
	 <CAF2d9jjrN4cDmtN_yKTe0BS+cAqE=hqgsT_6mOEBuMTTPOaPRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-o58o+A7NmxNd/vmGU8av"
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>, brandon.philips@coreos.com,
	xemul@parallels.com
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33592 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757536AbaKUBUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 20:20:50 -0500
In-Reply-To: <CAF2d9jjrN4cDmtN_yKTe0BS+cAqE=hqgsT_6mOEBuMTTPOaPRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-o58o+A7NmxNd/vmGU8av
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-11-18 at 21:27 -0800, Mahesh Bandewar wrote:
> On Tue, Nov 18, 2014 at 12:54 PM, David Miller <davem@davemloft.net> wrot=
e:
> >
> > From: Mahesh Bandewar <maheshb@google.com>
> > Date: Sun, 16 Nov 2014 22:27:14 -0800
> >
> > > +/* Define IPVL_DEBUG and set the appropriate dbg_level for debugging=
. */
> > > +#ifdef       IPVL_DEBUG
> > > +/*
> > > + * 1 : non-datapath debugging
> > > + * 2 : Custom
> > > + * 3 : function enters and exists.
> > > + * 4 : printk in data path (be careful!)
> > > + */
> > > +#define IPVL_DBG_LEVEL 1
> > > +#define ipvlan_dbg(level, msg...)    do { \
> > > +                                             if (level <=3D IPVL_DBG=
_LEVEL) \
> > > +                                             printk(KERN_DEBUG msg);=
 \
> > > +                                     } while (0)
> > > +#else
> > > +#define ipvlan_dbg(level, msg...) do { ; } while (0)
> > > +#endif
> >
> > The day of having code use custom local debug logging facilities is lon=
g
> > gone, please use a standard mechanism for this rather than home cooked
> > reimplementations.
> >
> Do you mean pr_err() / pr_warn() / pr_debug() etc.? or something else?
[...]

There are also netdev_err() etc. for logging with a net device as
context.

You can use the netif_err(), netif_dbg() etc. functions and implement
the ethtool {get,set}_msglevel operations to allow turning on and off
broad classes of log messages.

Finally, if CONFIG_DYNAMIC_DEBUG is enabled then debug logging messages
can be turned on and off at run-time (individually or by function, file
or module).

Ben.

--=20
Ben Hutchings
Beware of bugs in the above code;
I have only proved it correct, not tried it. - Donald Knuth

--=-o58o+A7NmxNd/vmGU8av
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVG6Taue/yOyVhhEJAQrXGQ/9GaZbVnSrO8OREvN31ufBf/Uc5Jykbp0x
kmSoRAs3UeZ3lhm+euIvN2+XZWhj7EuUzrewKkkabvFYq3ZkmiyazmTF1r3PHKWC
XMxqMhwA7EwcWD7Ck6x/Z8y/OcOgGtJzsFUS6OlpsV6mZVSlAHLX1qCGefwSicX9
RaDem/hdvN3zqQDaNEx2iGj23IjYjH68k9wMTyS10+9Syn2PKZaZzL1f5KheHv+p
a7KIUTn9+8SHiRd8fFSGxI4IPj8ghAWeS5lZXQZio7FaAUzR6GZ21HT6pdw5yTnn
4a9ok8N6WhKLcL8rg4EDlzkQupZQlTqwHsRkq8OBP+bs2UMZ/YT3TXGHFghke1y/
l1g8+K+pRMCze1ZkoaERfbodFLwMAq8986jIuNIyvvDqCJ4a+3+EVhOCW4i6uVAc
ubbYLLmMsMzHzDUkBdQnnBnMJxPNpvhP1Gw7cbguTO+69HhGojemGyiuUYUv2Rcq
V/baAL9RxLs5V9xjTPD+THkhRssMLduwd4OIkTNTbo+XV3A4dZ8AYAEzzPE/X7f/
p+ToqS1+HXsu9Ws39+7ICrBoAZNyHO873P4avtkJe+S8tQj6uMzygpMWnbRaQf6i
3xPKZwqZ0D5dBtIwVUxuuZ+JHjVkSBWH6zRhukdllaVxxEIRvXBYXm6hIS5JH/ND
kwrK1bQMpq0=
=UpW2
-----END PGP SIGNATURE-----

--=-o58o+A7NmxNd/vmGU8av--
