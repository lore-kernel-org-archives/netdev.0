From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Tue, 18 Jun 2013 11:51:54 +0300
Message-ID: <20130618085154.GN5461@arwen.pp.htv.fi>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz>
 <20130523022327.GB6159@kroah.com>
 <519D8876.9050405@suse.com>
 <51BF6BFF.7050705@suse.cz>
 <51BFE754.5080301@suse.cz>
 <20130618081858.GD5461@arwen.pp.htv.fi>
 <51C01948.9060708@suse.cz>
 <20130618083425.GI5461@arwen.pp.htv.fi>
 <51C01E04.2050908@suse.cz>
Reply-To: <balbi-l0cyMroinI0@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="prC3/KjdfqNV7evK"
Cc: <balbi-l0cyMroinI0@public.gmane.org>, Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>,
	Jeff Mahoney <jeffm-IBi9RG/b67k@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	<jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Alexander Shishkin <alexander.shishkin-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Florian Tobias Schandinat <FlorianSchandinat-Mmb7MZpHnFY@public.gmane.org>,
	<linux-geode-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	"Keller, Jacob E" <jacob.e.keller-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<tomi.valkeinen-l0cyMroinI0@public.gmane.org>
To: Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51C01E04.2050908-AlSwsSmVLrQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--prC3/KjdfqNV7evK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Jun 18, 2013 at 10:44:52AM +0200, Michal Marek wrote:
> > On Tue, Jun 18, 2013 at 10:24:40AM +0200, Jiri Slaby wrote:
> >>>>> Sam Ravnborg (the kconfig ex-maintainer) once wrote that
> >>>>> he doesn't want to extend the kconfig language for this
> >>>>> purpose (which I support). That a config option is fine and
> >>>>> sufficient in this case [1]. Except he called the config
> >>>>> option "SHOW_ALL_DRIVERS". Adding the current maintainer to
> >>>>> CCs ;).
> >>>>=20
> >>>> I agree with Sam. 'depends on XY || COMPILE_TEST' is quite=20
> >>>> self-explanatory. And even if it's not, you can look up the
> >>>> help text for COMPILE_TEST. With "archdepends on" or
> >>>> "available on", you need to know what to look for to override
> >>>> the dependency.
> >>>=20
> >>> you will still end up with:
> >>>=20
> >>> depends on (ARCH_OMAP || ARCH_EXYNOS || ARCH_DAVINCI ||
> >>> ARCH_PPC || ...)
> >>>=20
> >>> And every now and again that particular line will be updated
> >>> to add another arch dependency.
> >>=20
> >> But that is perfectly fine *when* the driver is supported on
> >> those archs only.
> >>=20
> >> And come on, how much often will this "every now and again"
> >> happen? We don't have that much cases where a driver is augmented
> >> to work on another arch or platform. It either works on all of
> >> them =3D> doesn't need COMPILE_TEST, or work on one or two arches
> >> at most.
> >=20
> > MUSB alone has 8 different arch choices. Before, it used to be that
> > core driver was dependendent on all of them, so whenever someone
> > wanted to build MUSB for another arch, they had to introdude their
> > glue code and modify the dependency of the core driver.
>=20
> But that you have complex dependencies in some drivers is mostly
> orthogonal to the two choices of syntax, isn't it?
>=20
> depends on ARCH1 || ARCH2 || .... || ARCH8 || COMPILE_TEST
>=20
> vs.
>=20
> archdepends on ARCH1 || ARCH2 || .... || ARCH8

right, but my argument is that I rather not have either. Depend on PCI
if you us PCI, depend on EXTCON if you use extcon, but no driver should
have an ARCH dependency. Specially since it lets people include mach/*
and asm/* headers because "it doesn't break compilation for anyone".

--=20
balbi

--prC3/KjdfqNV7evK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRwB+qAAoJEIaOsuA1yqREx3QQALabOoSQQJZR0TRQhm9mGOm2
5M7w9aX+cWRhRdAa1fww6WUDaZWPmwIbmpmax6oSKbzteu/f2o1HUtKlu2rKWaZ7
kQ4wzaFBvgR94qM3JJk69I5QLRrJPoDxIetwUbcQfY3N994m8cUUU1Oqe4PWqwGm
C1qTPAtfRKI3BNQrleA1/TNtSZqGFK+09/iUKvdR2rZ3W5FHZJ1zlM+uDYlYIY5F
uAuC7nXxjOqig//VHIE8mdr5tBa3mRhsEEjcDmeHyKpYtEzJvA0FYPKsufQzP/yX
oF7xJhQTPBampyX5sRNPnAC2jqrQ0tE70iJkGw2kla8fSC61WNjq5Jpi93afD2Zf
RXJOpdEAtwI/zJ3BOCl1+oZEclHe/kS1EC2ru71fjq+Q1kvzUtt8GvZrETXx8W9i
X6D27lJydBMxqHEcEoXKHPdagOIefgBlEQcJb7dYBXqCILehGHKNoCHoUMb+QYAm
aQpJfJNAB2Iha3yOcaokxCW5SQhlsBMbBqSE/rCzSaYpPymf0R5gzD5V8liWdJAs
8PZ9Sq3Dz/NKYaR+zeBb9eIrzSPY7MIxzqb0aZ2ZWFvlEzG7w3D7b6CdMX1e4NPz
ErfPWQflXIlS9aFlXMFSWCq2Z51fnofW5xiO8AO4skuMYHYkMD9sbb/CjcDLFQOH
JClOM06BvYJYCJUlqAlQ
=fpvV
-----END PGP SIGNATURE-----

--prC3/KjdfqNV7evK--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
