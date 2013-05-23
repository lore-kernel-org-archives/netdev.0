From: Tomi Valkeinen <tomi.valkeinen@ti.com>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Thu, 23 May 2013 10:46:57 +0300
Message-ID: <519DC971.80406@ti.com>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="----enig2FCLOGUJKJTLPIAPAOUPR"
Cc: <jirislaby@gmail.com>, <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jeff Mahoney <jeffm@suse.com>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<linux-usb@vger.kernel.org>,
	Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
	<linux-geode@lists.infradead.org>, <linux-fbdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>, Ben Hutchings <ben@decadent.org.uk>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369214326-6558-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------enig2FCLOGUJKJTLPIAPAOUPR
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi,

On 22/05/13 12:18, Jiri Slaby wrote:
> Some drivers can be built on more platforms than they run on. This
> causes users and distributors packaging burden when they have to
> manually deselect some drivers from their allmodconfigs. Or sometimes
> it is even impossible to disable the drivers without patching the
> kernel.
>=20
> Introduce a new config option COMPILE_TEST and make all those drivers
> to depend on the platform they run on, or on the COMPILE_TEST option.
> Now, when users/distributors choose COMPILE_TEST=3Dn they will not have=

> the drivers in their allmodconfig setups, but developers still can
> compile-test them with COMPILE_TEST=3Dy.
>=20
> Now the drivers where we use this new option:
> * PTP_1588_CLOCK_PCH: The PCH EG20T is only compatible with Intel Atom
>   processors so it should depend on x86.
> * FB_GEODE: Geode is 32-bit only so only enable it for X86_32.
> * USB_CHIPIDEA_IMX: The OF_DEVICE dependency will be met on powerpc
>   systems -- which do not actually support the hardware via that
>   method.

I had this exact same idea some time ago. The mail below contains some
of my reasoning for this:

http://comments.gmane.org/gmane.linux.kbuild.devel/9829

I proposed a new Kconfig keyword, but Sam was quite against it as the
Kconfig language already does what is required.

 Tomi



------enig2FCLOGUJKJTLPIAPAOUPR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJRncl1AAoJEPo9qoy8lh71qFoP/3PjrIvuoEgFhp4JW4uj0+zO
9OWNwwh3EWsolDOiaexaDrJvgdNwK2PMlXbihBUEfYHx3rIh7hR8GZPUwnCXIsur
edYF+octUiWGWh5UykQzX5tVM0Z+OyvSPJ/mBDsacDnUQFfNdJFAjbxaQmzHzwmZ
jAlhcGW1yT4qDahNi3aRtk4QTjWF5uBRMBFpRSjp3IT5mh5wEtvQxNRKcLxCt98E
m4T5UQE16j73lMhyGfaYCGP6EqGZ9ymCK2ewuOt9ziDpCAqhWPeImrKZOC97vQZ2
z5hYmlkAvV41FP8xpPO5bPqVUeFvNBvS+YVY+Hx8W3DZokPBU2QDs5w/9h9xqm7m
Rhf3ce1VVVx+UjWOMQFKZMOiZJA6LQ+hSIjJ16Nr41QQvqBMKwZDQVJHcynzCSFH
Id5g8/Ut9VIVTflkWFuaBEBp1QMzMnyzjwvu17NSjSCLtfWjfCtA2Ccy7zhV00XH
8MpmkHL1tmCD3CHM0ckJqYiYd2U9MsgT91Egk/w+AS0c0q45qClkrAY26896O1CT
zGKNIcmbc1Z35Rtvbk3g3H1CKn3rtWzC8Qb+EVAE2gJ61DYNTm7OaDRRqEn2xbAa
PZhaM841bJnaFkPt+fRF9ZD4FZVnKgL1/MkuTA4XWmMqPe01oQYE9tjUWidnw+CO
qNQkXF3hX8gYoy7IaDwa
=ggmg
-----END PGP SIGNATURE-----

------enig2FCLOGUJKJTLPIAPAOUPR--
