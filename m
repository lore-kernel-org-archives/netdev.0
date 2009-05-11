From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH v3 00/17] virtual-bus
Date: Mon, 11 May 2009 10:41:54 -0400
Message-ID: <4A083932.50605@novell.com>
References: <20090421183341.12548.33393.stgit@dev.haskins.net> <20090511113731.GA6205@nik-comp.linuxbox.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD2EBDE3F49001BFCDC924DD4"
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, agraf@suse.de,
	pmullaney@novell.com, pmorreale@novell.com, alext@novell.com,
	anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, avi@redhat.com, bhutchings@solarflare.com,
	andi@firstfloor.org, gregkh@suse.de, chrisw@sous-sol.org,
	shemminger@vyatta.com, alex.williamson@hp.com,
	nikola.ciprich@linuxbox.cz
To: Nikola Ciprich <extmaillist@linuxbox.cz>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090511113731.GA6205@nik-comp.linuxbox.cz>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD2EBDE3F49001BFCDC924DD4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Nikola Ciprich wrote:
> Hi Gregory,
>
> I'd like to try Your vbus patches, but compiling 2.6.30-rc2 (or 2.6.30-=
rc5) fails
> with following error:
> drivers/vbus/proxy/kvm-guest-vbus: struct pci_device_id is 32 bytes.  T=
he last of 1 is:
> 0xda 0x11 0x00 0x00 0x00 0x20 0x00 0x00 0xff 0xff 0xff 0xff 0xff 0xff 0=
xff 0xff 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00=
 0x00 0x00 0x00
> FATAL: drivers/vbus/proxy/kvm-guest-vbus: struct pci_device_id is not t=
erminated with a NULL entry!
>
> Do You have any idea on what might be wrong?
> thanks a lot in advance...
>  =20
Hi Nik,
  I haven't seen that error with vbus itself, but oddly enough I just
encountered something similar when I was working on a different series
(nullio).   The fix there was trivial, and I suspect it will be here as
well.  What I am more confused on is why this suddenly started
happening....  I will get back to you with a fix.

Regards,
-Greg



--------------enigD2EBDE3F49001BFCDC924DD4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iEYEARECAAYFAkoIOTIACgkQlOSOBdgZUxnhxACgjL/ON3Z9VbdZbI2IRwH+QNrV
zm4AmQHazMQ86K/fIMWS1rUKo7jwNuRq
=7vrT
-----END PGP SIGNATURE-----

--------------enigD2EBDE3F49001BFCDC924DD4--
