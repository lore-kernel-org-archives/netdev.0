From: Tilman Schmidt <tilman-ZTO5kqT2PaM@public.gmane.org>
Subject: Re: [RFC 13/13] USB: Disable hub-initiated LPM for comms devices.
Date: Thu, 17 May 2012 19:07:32 +0200
Message-ID: <4FB53054.9070309@imap.cc>
References: <cover.1337203535.git.sarah.a.sharp@linux.intel.com> <3c634afbbe15598cdcbf77bb9393d22ad4bfa373.1337203535.git.sarah.a.sharp@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB1133729D4FC7A3C4EB0E715"
Cc: Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>,
	Hansjoerg Lipp <hjlipp-S0/GAf8tV78@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gigaset307x-common-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
To: Sarah Sharp <sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <3c634afbbe15598cdcbf77bb9393d22ad4bfa373.1337203535.git.sarah.a.sharp-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB1133729D4FC7A3C4EB0E715
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Am 16.05.2012 23:55, schrieb Sarah Sharp:
> Set the disable_hub_initiated_lpm flag for for all USB communications
> drivers.  I know there aren't currently any USB 3.0 devices that
> implement these class specifications, but we should be ready if they do=
=2E

I follow the argument for class drivers. But this patch also
modifies drivers for specific existing USB 2.0 only devices
which are unlikely to ever grow USB 3.0 support, such as the
Gigaset ISDN driver:

>  drivers/isdn/gigaset/bas-gigaset.c            |    1 +
>  drivers/isdn/gigaset/usb-gigaset.c            |    1 +

What is the interest of setting the disable_hub_initiated_lpm
flag for these?

Thanks,
Tilman

--=20
Tilman Schmidt                    E-Mail: tilman-ZTO5kqT2PaM@public.gmane.org
Bonn, Germany
In theory there is no difference between theory and practice.
In practice there is. (Yogi Berra)


--------------enigB1133729D4FC7A3C4EB0E715
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk+1MFQACgkQQ3+did9BuFtEjQCghpEKnCJ4LI0vjWtFhiOSuLxp
6h0AnjwiirhAQDf2qjydFRszMK1aywSt
=nhOe
-----END PGP SIGNATURE-----

--------------enigB1133729D4FC7A3C4EB0E715--
