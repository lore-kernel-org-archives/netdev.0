From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFC 26/72] arm: Move the ARM/ACORN drivers
Date: Sat, 25 Jun 2011 11:06:56 -0700
Message-ID: <1309025217.2454.89.camel@jtkirshe-mobl>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <201106251803.53416.arnd@arndb.de>
	 <20110625161227.GJ23234@n2100.arm.linux.org.uk>
	 <201106251859.38963.arnd@arndb.de>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-dJvfC3ISeE6I+yXlgs1f"
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sriram <srk@ti.com>, Vinay Hegde <vinay.hegde@ti.com>,
	Cyril Chemparathy <cyril@ti.com>,
	Wan ZongShun <mcuos.com@gmail.com>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Anant Gole <anantgole@ti.com>,
	Chaithrika U S <chaithrika@ti.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31419 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751678Ab1FYSG5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 14:06:57 -0400
In-Reply-To: <201106251859.38963.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dJvfC3ISeE6I+yXlgs1f
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-06-25 at 09:59 -0700, Arnd Bergmann wrote:
> > More interestingly, if you have one of the 8390 clones, which
> directory
> > do you look in?  And shouldn't etherh.c live along side 8390's files
> > as etherh is 8390-derived?
>=20
> Jeff created a drivers/net/ethernet/8390/ directory for all of those,
> which sounds sensible to me, but apparently he missed some of the
> nonobvious ones.=20

I was trying to keep the drivers that use the 8390 common files grouped
together.

I know that there are other instances like this (for instance drivers
derived from the lance.c driver) yet these derived drivers do not use
the common files that other lance drivers use.  Because they are
derived, yet do not use the common code, should they still be grouped
together?  Just a question, I am fine with the idea.

--=-dJvfC3ISeE6I+yXlgs1f
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOBiPAAAoJECTsCADr/EWUAOUIAKm8cJwU2Hpf0SapSFdfAlRg
4ZDVFgxRE23R2T4WPAwKSzJJgDhTj8P6RLSfcrStGyw1/LwVrW87ya29RIBQuWE8
K89pBCbU3TlE4qBzf0lbrihFFAqKMBII2TdRo24VM2jXCBtVc0BucusWlgwTn7BK
JxeYWotxUJegFZn8/L5p/x/DHtroKKeo7jyX2hUz0NbfLjXq2tshcGVmmOZdzGJ8
QeggkRSB9ue7nNl8hUG6KuFhqLDT+TESPpYbgofRBAmYARyHVEsH0fzGR5Q8rjHd
cwePiYGqd1h5lckotmtv//SK4wcxz+j7+Xu/Pz9VqRau7/frv7TSX563kS18O2g=
=IHoV
-----END PGP SIGNATURE-----

--=-dJvfC3ISeE6I+yXlgs1f--

