From: Felipe Balbi <balbi-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Tue, 18 Jun 2013 11:34:26 +0300
Message-ID: <20130618083425.GI5461@arwen.pp.htv.fi>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz>
 <20130523022327.GB6159@kroah.com>
 <519D8876.9050405@suse.com>
 <51BF6BFF.7050705@suse.cz>
 <51BFE754.5080301@suse.cz>
 <20130618081858.GD5461@arwen.pp.htv.fi>
 <51C01948.9060708@suse.cz>
Reply-To: <balbi-l0cyMroinI0@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="svExV93C05KqedWb"
Cc: <balbi-l0cyMroinI0@public.gmane.org>, Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>,
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
To: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <51C01948.9060708-AlSwsSmVLrQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--svExV93C05KqedWb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Tue, Jun 18, 2013 at 10:24:40AM +0200, Jiri Slaby wrote:
> >>> Sam Ravnborg (the kconfig ex-maintainer) once wrote that he
> >>> doesn't want to extend the kconfig language for this purpose
> >>> (which I support). That a config option is fine and sufficient
> >>> in this case [1]. Except he called the config option
> >>> "SHOW_ALL_DRIVERS". Adding the current maintainer to CCs ;).
> >>=20
> >> I agree with Sam. 'depends on XY || COMPILE_TEST' is quite=20
> >> self-explanatory. And even if it's not, you can look up the help
> >> text for COMPILE_TEST. With "archdepends on" or "available on",
> >> you need to know what to look for to override the dependency.
> >=20
> > you will still end up with:
> >=20
> > depends on (ARCH_OMAP || ARCH_EXYNOS || ARCH_DAVINCI || ARCH_PPC ||
> > ...)
> >=20
> > And every now and again that particular line will be updated to
> > add another arch dependency.
>=20
> But that is perfectly fine *when* the driver is supported on those
> archs only.
>=20
> And come on, how much often will this "every now and again" happen? We
> don't have that much cases where a driver is augmented to work on
> another arch or platform. It either works on all of them =3D> doesn't
> need COMPILE_TEST, or work on one or two arches at most.

MUSB alone has 8 different arch choices. Before, it used to be that core
driver was dependendent on all of them, so whenever someone wanted to
build MUSB for another arch, they had to introdude their glue code and
modify the dependency of the core driver.

Also EHCI, it works on pretty much everything, so does DWC3.

DWC3 already has three possibilities but I know of at least 3 others
which could show up soonish.

--=20
balbi

--svExV93C05KqedWb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRwBuRAAoJEIaOsuA1yqRE8NgP/0SPxsOBuTHMy2orol3LighN
pJRgtLCaxN0/ODQnK+riD/mpw7NuneUsqAC4ULib79QEXkL8nNSjL5s2aaihO4gg
vbW+8UYXrWw8rVX58b4dr0MNqwm0n6qXIs3hXJCx9Dv0wi/DfoKN+XKaZALFvP/U
lzUAbzVTlehZXrp1b4Nc/jYaX1UP85o7JPbyy6S7+G5bYkfNDWCy24xZYO8gAzF0
F0yCJaFxTvgmTTjeSJDzpYLbt9NFl6IOKl5RMuBUszJ/T4hADWcjveol9y1wfzov
EauHIcrgnTgn8nqzYNbdSVoMf+w62GsaJcF8M7fG84FMNnNiuoSB5YGLj/sRJjG6
CgY5SMYFTk3EAsWKiN8uW5mpQixGa0g4bUJuiPiON/zMPfJukDr2jMcqyquK5U8q
eurgbZYomNAz4HPUP7BD0u8BTrcVZp9EYiyiEsK6+O/9lf/bkc+Z5Zr3PdDKjXH6
eXz/MC1XwBdJdqUscHBtyQ02QY5ZDUEH/BPYoFXm2BYxV2wYO8aZox/V2NYCbLWV
mjOlTyw0qSQALN4i5FAy9gsJ6FgTyOh/IoXdftd6+EEg9/RmyodQb+qBYgczJnO+
Ske0XR05jrBz2AYDn15dHm6vi3W15CYGAHLJpS//w6H+IKDG8FTfUk6HKKaeNnUS
xcMNkoxmPjO0wiKsjIvl
=MDJ7
-----END PGP SIGNATURE-----

--svExV93C05KqedWb--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
