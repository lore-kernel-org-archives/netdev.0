From: Sascha Silbe <sascha-ml-reply-to-2011-2-OgEpK5h/+1LYtjvyW6yDsg@public.gmane.org>
Subject: Re: [PATCH] Add libertas_disablemesh module parameter to disable mesh interface
Date: Fri, 13 May 2011 15:26:24 +0200
Message-ID: <1305292756-sup-4842@xo15-sascha.sascha.silbe.org>
References: <1305118354-17337-1-git-send-email-silbe@activitycentral.com> <20110511100030.cad34893.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-1305293187-827477-1562-6606-12-="; protocol="application/pgp-signature"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	devel <devel-oU9gvf+ajcRuEWckB3OYtg@public.gmane.org>, Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	John-i2JScjCrrBUtjPN9IyLgGT5Lv7v+73c5YPYVAmT7z5s@public.gmane.org,
	W.Linville-i2JScjCrrBUtjPN9IyLgGT5Lv7v+73c5YPYVAmT7z5s@public.gmane.org, <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	libertas-dev <libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Randy Dunlap <rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <20110511100030.cad34893.rdunlap-/UHa2rfvQTnk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-1305293187-827477-1562-6606-12-=
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Excerpts from Randy Dunlap's message of Wed May 11 19:00:30 +0200 2011:
> On Wed, 11 May 2011 14:52:34 +0200 Sascha Silbe wrote:
> =

> > This allows individual users and deployments to disable mesh support =
at
> > runtime, i.e. without having to build and maintain a custom kernel.
> =

> I guess a user could want to do this on a per-driver basis, but ISTM th=
at
> it would be better to be something like a sysctl that applies to all (w=
ireless)
> drivers.

AFAIK libertas is the only driver with a mesh implementation based on an
outdated 802.11s draft. To clarify, we could rename the parameter to
lbs_disable_olpcmesh (or just disable_olpcmesh).
Disabling 802.11s (latest draft) based mesh support is a separate
matter.

Sascha

-- =

http://sascha.silbe.org/
http://www.infra-silbe.de/

--=-1305293187-827477-1562-6606-12-=
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.1.0beta1 (GNU/Linux)

iQEcBAEBCgAGBQJNzTGAAAoJELpz82VMF3DaJHYH+gMFPvB8brmrYbDVbteoIl+5
aUQ43A9MxtJKDFXr/51azfBFxAVu7JSxhHA+I1U/lY3xjubqyslOObZ7sOnEh9iP
lAP1nyjNNLNqZblwu5uPh7Z81Kz7cl4RLF4Li7dHc9Xq7Ewy/o6TQeOCPhHt/QAm
eBlNEWXIbZSc5yRYD7HfTp+3enDKE6I/Wmj+bB+vL6mOq23yisx5E93tifZaNeNx
etFGiOq35kUBZUjm7ibYcDgx+kDN01IbKynodHSFE4PPC64nmYRv02amR+bpl2QF
67j4YNZCnAsqHdWcivHHfJ1j11c35TTmX4tQqOSu02qSfoWTxvoJxvMJjIhRd9o=
=SSLj
-----END PGP SIGNATURE-----

--=-1305293187-827477-1562-6606-12-=--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
