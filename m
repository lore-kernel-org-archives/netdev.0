From: Tomi Valkeinen <tomi.valkeinen@ti.com>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Wed, 19 Jun 2013 10:10:21 +0300
Message-ID: <51C1595D.60706@ti.com>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz> <20130523022327.GB6159@kroah.com> <519D8876.9050405@suse.com> <51BF6BFF.7050705@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="----enig2HOUBHJGSQADMUMIBTWTR"
Cc: Jeff Mahoney <jeffm@suse.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<jirislaby@gmail.com>, <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	<linux-usb@vger.kernel.org>,
	Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
	<linux-geode@lists.infradead.org>, <linux-fbdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>, Ben Hutchings <ben@decadent.org.uk>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>,
	Michal Marek <mmarek@suse.cz>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51BF6BFF.7050705@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------enig2HOUBHJGSQADMUMIBTWTR
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 17/06/13 23:05, Jiri Slaby wrote:

> The last point I inclined to the Greg's argument to remove the EXPERT
> dependency.
>=20
> So currently I have what is attached... Comments?

The patch looks a bit odd with the USB_CHIPIDEA_IMX parts. You're not
adding COMPILE_TEST there, but you're adding a totally new config
option, and also changing the Makefile.

Maybe that's ok, but there's no mention about this in the desc.

 Tomi



------enig2HOUBHJGSQADMUMIBTWTR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJRwVldAAoJEPo9qoy8lh71n1EP/A1yWcfkOmSPUdZ4XbOT46TD
1cXo1qMm4BpLedIaLKdzr8A7YP+1baCqTTq68Ec+9n49irAPXwCCMCw2szxAsPNb
ABE7meU/AO5aB5knIzu80u6oUb+NSDamLFsgGKP+on2b9WQp72rq3/1eqELH3yay
Xp3l3T/IDsP1o7Sdtylwr/2oNAdYj1SaC6kH3Wo++NG3oD53kdg8KY5iLN1ul0wn
DpzpP6T/1PWmPVgqAuAy1s+6l6Bk937ZiqD1KBZtR348ZfDOAxIVfZfUuAXnZoYB
oktewrAA9CNkGLZWr/CPBDrnNQIqsLYb0wS9KkQC3UzisOhBEtWQZSVQRj4WpkmO
trKkgXtbmqIBLMaF3tkx4ifjTTAevxcGALUoWQpG7zIeUhSmwNoKyeXxIrqFQvw8
4oVVQZ9ehl02kMkpoiHjosVzNGTBoLgmScB3ORtJs3qlMan9Ew6/tL2rq5IgiwzD
UacoUfC/oHc2EkvjBVHpfNaWvlxU4X6mGPCRjE8YRIybiCdiFouVP9D6Jc8YnluI
fXyvqGb4riJGDYZXVArQWvldIw7iBRjVo0wx3xnTJGMDCxQR7zSfHDgJnD2r1B4x
1TphGGR11T9il341zo6/11V0SHtGUDL8ECeFDB8xUWWM4W0+bmp1dpSSg+6JWpOv
cyfUAABA3eWk0j6B4+vB
=R8ux
-----END PGP SIGNATURE-----

------enig2HOUBHJGSQADMUMIBTWTR--
