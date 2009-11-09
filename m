From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] netlink: add socket destruction notification
Date: Mon, 09 Nov 2009 17:51:42 +0100
Message-ID: <1257785502.29454.178.camel@johannes.local>
References: <1254473048.3959.76.camel@johannes.local>
	 <4AF43EF9.3020707@trash.net> <1257521204.29454.31.camel@johannes.local>
	 <4AF442C2.9040704@trash.net> <1257762132.29454.161.camel@johannes.local>
	 <4AF8122F.9060807@trash.net> <1257771787.29454.173.camel@johannes.local>
	 <4AF816D3.7000304@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-n4DGqLnbMNQb/hFN6Jg6"
Cc: netdev <netdev@vger.kernel.org>, Jouni Malinen <j@w1.fi>,
	Thomas Graf <tgraf@suug.ch>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:37449 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753872AbZKIQwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 11:52:08 -0500
In-Reply-To: <4AF816D3.7000304@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-n4DGqLnbMNQb/hFN6Jg6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-11-09 at 14:19 +0100, Patrick McHardy wrote:

> > Ok, cool, thanks. Do you want me to send the change removing the
> > multicast check, or would you want to do that since you audited all the
> > netlink callers?
>=20
> Please go ahead.

Will do.

> > Also, it's called URELEASE for unicast -- should we rename it to just
> > RELEASE?
>=20
> I think URELEASE is still fine since won't necessarily get called
> for sockets that are used for pure multicast reception when using
> setsockopt to bind to groups.

Oh? So on which sockets can I rely on it being used? After sending at
least one unicast message into the kernel? This seems to depend on pid
being assigned -- when is that?

johannes

--=-n4DGqLnbMNQb/hFN6Jg6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJK+EiaAAoJEODzc/N7+QmahsAQAIosBfMB2zYmmYN2CA0EDu+j
BOsQujqx/ddavYnOJqLcVXlylh2UnPODbKGl1oy6i8fNnhD30zlYmbXCfEF8euhz
JBvdlJ45qDP5nw7GDPp3grO2ShrZRrLqKXsdPTiodeOwqEcXBRpuRAyLFR+MjyY9
k7ow40JZ9Ye2HeYYhdhbeWfLt6yVTBUtfVOn1APs7N7DcN9IBzRt8p+OWgHyTYvC
jM9i0ZZG/uWdJb6fJFVZkAnbU5RKoRkJHMYOGfK3a6iMdv3qp+cTiknbcVuT8Guz
dr9sK13wRSS6wVCy2YsXNoBdh617mFVPNSnAgNTTYwJuFNoErwZmSgQRzJs0wYEb
1/LqZGOuMdilv8sHmC+EeQNNpDZrSLVT38XVLT8qc4j7lUYTr5DcH2PeUvTT9j6g
5fFrdPaCajAc9qEC0qX3YicWJv7N7IK6LvS7g14+REG+hQ03YCbbkNzDtYSlqw0c
1yhShpxsW8myg2j95n8/pkX2z/BN49M2eBZxxDFsvj/SP/9Zn142+/Wq+87T3SCj
g5f8jFy8mbUH/g3N9eLIy2/vppjoUnSiZwJN2oZNpPUbYSZAQlzAbSAjETFI4dJc
nP3ZxraCOIWveA4MxoD8UovE1TLtuOzHSPPpIHfnfktBucN4eCRDlp6789ZeKk3N
PRP4SFrhKGhQH35dSlaI
=XSSe
-----END PGP SIGNATURE-----

--=-n4DGqLnbMNQb/hFN6Jg6--

