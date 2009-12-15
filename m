From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless: wext: allocate space for NULL-termination
 for 32byte SSIDs
Date: Tue, 15 Dec 2009 11:07:14 +0100
Message-ID: <1260871634.3692.6.camel@johannes.local>
References: <1260650850-16163-1-git-send-email-daniel@caiaq.de>
	 <20091215.014308.77044043.davem@davemloft.net>
	 <1260871411.3692.4.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-r6YB1NbF3MRdj3ecHy74"
Cc: daniel@caiaq.de, linux-kernel@vger.kernel.org, dcbw@redhat.com,
	m.hirsch@raumfeld.com, netdev@vger.kernel.org,
	libertas-dev@lists.infradead.org, stable@kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:50177 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752219AbZLOKHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 05:07:35 -0500
In-Reply-To: <1260871411.3692.4.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-r6YB1NbF3MRdj3ecHy74
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-12-15 at 11:03 +0100, Johannes Berg wrote:

> Since you indicate the kernel crashed, it is likely that libertas is
> treating the buffer as a string, instead of an SSID.

drivers/net/wireless/libertas$ grep lbs_deb_ * | grep ssid|grep '%s'
assoc.c:	lbs_deb_join("current SSID '%s', ssid length %u\n",
assoc.c:	lbs_deb_join("requested ssid '%s', ssid length %u\n",
assoc.c:	lbs_deb_join("ADHOC_START: SSID '%s', ssid length %u\n",
scan.c:		lbs_deb_wext("set_scan, essid '%s'\n",

johannes

--=-r6YB1NbF3MRdj3ecHy74
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLJ1/PAAoJEODzc/N7+Qmax1cQANNVqB5R6BTqIt9JfqOtkgPu
+SG0Sae0601AI+4aRwTj2ROOmDuh2Q+/DelahR7US2FnuVcUHArHWg7CQQ1iXvsi
E7o9NMG+VY84/ZWShYBDW1bfpr6l2fbBh0Vl+2PE2B/epWwgw1Z5axfx6QWdvEqG
V4SDMugBJy2a1N3X2YX0WWvQHmuZblzr1QwoeWGYPpWUJ/MqcnNCNXlOhT4G9n9c
pD4PNET0EoVfqf/R9QiskCKtWJCjQuXw/lYm6quA47CBZNVePis7vtGRa8mGLltb
vXCuSHq1LYzXA1srIr3G11hCoC52irB3+xdAI62g7o+rLX4WMw53HVKU6Nm59jVu
ewfrssCk2kkn6P4U3jrthjENQrKA85wrwwrW9q3H6mvZMwVC0Q9cIQ1c8DxUlJQA
6Kbd79STZ5cug6SgrmsowupPHMHvwwTskPnHjP/u+60bRYtVXEhLbRvFpZNCW/3G
9xDILpXorhLDV0dYG18TFkKmh9w+2K2xVIXioct2Sp2kifYgyUk4u/tgtIEANNGT
pW7cmUyekpdzZRaLReTluHmrwb2zo+jQOgGv6KK7EpfhtUeTJrYDN1KqPNAC9jFy
bzP7kNJM3tSMI9X2xGcwXVlV1MIO+dcWoU7X+Dgn4LP9bwZLh7rkDk8BbYnfxElA
wy1sLkPblKw/1I+cWtkn
=Zxn7
-----END PGP SIGNATURE-----

--=-r6YB1NbF3MRdj3ecHy74--

