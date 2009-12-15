From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] wireless: wext: allocate space for NULL-termination
 for 32byte SSIDs
Date: Tue, 15 Dec 2009 11:31:23 +0100
Message-ID: <1260873083.3692.8.camel@johannes.local>
References: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
	 <20091215.014308.77044043.davem@davemloft.net>
	 <1260871411.3692.4.camel@johannes.local>
	 <1260871634.3692.6.camel@johannes.local>
	 <20091215102035.GJ28375@buzzloop.caiaq.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-MTUIoK4uGX41ZSlBruir"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, m.hirsch-5g8ninUHluJWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, stable-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Mack <daniel-rDUAYElUppE@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20091215102035.GJ28375-ahpEBR4enfnCULTFXS99ULNAH6kLmebB@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-MTUIoK4uGX41ZSlBruir
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-12-15 at 18:20 +0800, Daniel Mack wrote:

> > > Since you indicate the kernel crashed, it is likely that libertas is
> > > treating the buffer as a string, instead of an SSID.
>=20
> Ok, I dodn't know that - thanks for pointing it out. In my setup here,
> SSIDs are always valid alphanumeric strings, and I was mislead by the
> comment that mentions the NULL-termination.

Yeah ... that's an unfortunate historic mistake in wireless extensions
that we try to fix up there. It cannot always be successfully fixed up,
but the NUL-termination is nothing that anything but this code should be
worried about or rely on.

> > drivers/net/wireless/libertas$ grep lbs_deb_ * | grep ssid|grep '%s'
> > assoc.c:	lbs_deb_join("current SSID '%s', ssid length %u\n",
> > assoc.c:	lbs_deb_join("requested ssid '%s', ssid length %u\n",
> > assoc.c:	lbs_deb_join("ADHOC_START: SSID '%s', ssid length %u\n",
> > scan.c:		lbs_deb_wext("set_scan, essid '%s'\n",
>=20
> Those macros are stubbed out as nops in my setup, so they can
> unfortunately not be the reason. I'll dig deeper :)

Well, the stack trace ought to help.

johannes

--=-MTUIoK4uGX41ZSlBruir
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLJ2V3AAoJEODzc/N7+Qmad3gQAJ1FPGr7txGCvsafXohdRLlh
7h7VnJQ21rmpB/g8KuKumBdUwh5ALEHmYNq5LMIbAGEzX7e7qOB5Dmhbh9BHWEzI
Rs+rxA4kDom3fKx96P+O/6Nd4LCcVLql+tGcVZZMdEhDWJUFUcFfcEY793hDwcub
LylfhXxRfcbIT5Kd2I9R6gqh3w7RT7ak6QP42lzab8L4s6vpAzudr7YImqAJMnOA
Y3XjAFeqyxovu2EwiUIcyFDJGO805cbD16QsZiN3HwjNMya/VCZPe+TIDSPU3uOX
IgsYdkyqgwsrOEsXj4drfiNBB68IGHLMej8dPoENLDHv1eoYafPgNEMHh3dQppE0
WMfgGz6EB8pQMWgLMHlLP2TFS7q0cBZJU2GPjdMNxi5bIY54NrU+TyxCjs09iolB
TptMCsdzq/M89+x9H2mqlo8jti63UxuU5uLahywngWWMCOvdlVpSVFmnOmxf6EJu
4zrd3p2UpjI+xXqPAKVMVHJHdcl08Lz6xVZT3MVMkzJITUCyO/PWk06GzTMQA8+5
D0U7KkXJBOGdqrGWh4Fxi9EjXB6TPt5CjUu5vGBXfODtODjEPhC7otwEV2pzxePI
uYZwg78VNnx3F6Dw0YLRHC/QxUkUBFj/btV1belk2LSGAQ9J5DwUibG0ffvWZdJM
sinj7IxKO+iEcbH7H2KD
=rYi1
-----END PGP SIGNATURE-----

--=-MTUIoK4uGX41ZSlBruir--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
