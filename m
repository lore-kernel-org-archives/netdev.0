From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH v4 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Wed, 26 Aug 2015 10:55:13 +0200
Message-ID: <20150826085513.GB12087@calimero.vinschen.de>
References: <20150825.141540.472110106537790402.davem@davemloft.net>
 <20150825225406.GA24297@electric-eye.fr.zoreil.com>
 <20150825.155921.399025256241133988.davem@davemloft.net>
 <20150825.160302.947112090610933000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="uZ3hkaAS1mZxFaxD"
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
	hayeswang@realtek.com, ivecera@redhat.com, nic_swsd@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:40674 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbbHZIzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 04:55:15 -0400
Content-Disposition: inline
In-Reply-To: <20150825.160302.947112090610933000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--uZ3hkaAS1mZxFaxD
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug 25 16:03, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 25 Aug 2015 15:59:21 -0700 (PDT)
>=20
> > From: Francois Romieu <romieu@fr.zoreil.com>
> > Date: Wed, 26 Aug 2015 00:54:06 +0200
> >=20
> >>> Bringing the interface is brought down/up should not reset the
> >>> counters.
> >>=20
> >> Afaiks rtl8169_tc_offsets.inited in rtl8169_init_counter_offsets
> >> takes care of it: it's set during the first open() after probe().
> >=20
> > Ok, then it's fine.
>=20
> And as such I've applied this patch, thanks.

Thanks,
Corinna

--uZ3hkaAS1mZxFaxD
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV3X7xAAoJEPU2Bp2uRE+gT8gP/Rg32rPiaWYVFdhgFUmz2APj
+m0jz0eIJrBki9Whlg0LmF6CrtxpYJDP+RTRZiu6PvjqdtKDFZ8z11nUjTw+Qcln
RgqCjOcCJ5iejeVZpirKalV4YZtemEaeTT37OLFGnMmYg8AcpsQbnfFbzgudavSf
eBmuWciFw/1EzOpNNopA8LXOjpnttI1jo1sgtKPzrzd6Um+In/jQCZPZEZuS9eNw
LscM3G2ev8HFDI6c0P+gtNDSnQWUILfqQ0ubC0EzRDn3Ygv3odJ/RRwStYdpZe5j
hwFYW2V15SpDd5uGGupNnvL1bvMBCSZRtdhyqw+Ax5MG0EykCEcQmDycJhhE97Rr
RiFOwDKCJ8Y1vvoJm1ETpyPN5t7NiQTkP5CGJm+NwtRndsCNH6xhR/nGhdJVvgmo
ZwF6FOiLuEMC7Ow8g7FAVZg1KXuxm2oAFl+xroyvJZTec+ZEcD677DvEi/GR7/+/
ujfik31HDqNQ9jjyV7kVbEJNLwjiA9nY4xKpzAa0cszmIp4SES6jH0DZuXgSAVTV
v8VJjOafUNVqRIBStEXdYRtCvLtZJXdJHOFE3JcoVjclYG2Ofa8GlNVR5RGxuEv7
TfrVbEGIojEJNa19/+AshhZnD9pd2m3HEUK/glUWRO0sVeXvY+e/JPAXwtaX98SB
/vkWjkhHBNMEKS5Ak1iM
=fTT+
-----END PGP SIGNATURE-----

--uZ3hkaAS1mZxFaxD--
