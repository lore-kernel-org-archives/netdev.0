From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH v4 net-next] r8169: Add values missing in @get_stats64
 from HW counters
Date: Wed, 26 Aug 2015 10:54:46 +0200
Message-ID: <20150826085446.GA12087@calimero.vinschen.de>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <1440413559-9354-1-git-send-email-vinschen@redhat.com>
 <20150825.141540.472110106537790402.davem@davemloft.net>
 <20150825225406.GA24297@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="45Z9DzgjV8m4Oswq"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hayeswang@realtek.com, ivecera@redhat.com, nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:39676 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898AbbHZIyt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 04:54:49 -0400
Content-Disposition: inline
In-Reply-To: <20150825225406.GA24297@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--45Z9DzgjV8m4Oswq
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug 26 00:54, Francois Romieu wrote:
> David Miller <davem@davemloft.net> :
> [...]
> > Your counter offsets should be read at probe time, not open time.
>=20
> It can be done but the "CmdRxEnb / rx traffic must be enabled" constraint
> will make it a major pita.=20
>=20
> Reading counter offsets at the end of open() naturally solves this
> constraint (retentive error unwinding in opne() stops being completely
> trivial though :o/ ).
>=20
> > Bringing the interface is brought down/up should not reset the
> > counters.
>=20
> Afaiks rtl8169_tc_offsets.inited in rtl8169_init_counter_offsets
> takes care of it: it's set during the first open() after probe().
>=20
> Looking at it again, the patch directly stores 16 and 32 bit values
> in rtnl_link_stats64. Nobody should care about exact exceedingly high
> error count but rx_multicast ought to be accumulated.

I'll have a look into that for a followup patch.


Thanks,
Corinna

--45Z9DzgjV8m4Oswq
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV3X7WAAoJEPU2Bp2uRE+gK/gP/1MZU0uSiZcYUxCW3R9vcWXA
TnedTf2bqHrtKVJ21y2FBq0q+lkcuHj8pppLQA+YnaY0+NxITFIcfzUPVAuhv/NE
PHh/pvD4ksS9oA5s2/uHGPvljMwLIaSHS0iG3QGPU8RFhS2oRDFDbIUyNWVHhHup
QdlIj9DJtlszDGVWiEeNcd34vDySocF7lwtv7GsYHEPh+UThJz3oJa82NgvjEZdR
sDmUA2RiqZbiGwgUlG+NwaghIQgvSsaKnGioiRJ5nZ7yO1tBwAOtZW6aRuENYMkv
rjyk8h8nl/iPwewxa5oCrm07tzWujVPv/YVSpVq8PNYiAvm2tvi7uBwMk1bYinMy
oFg9V1cvUPF5cXmqxKF9KZA0WKSLOS8CAfP+oFvOexhxXaeJtc/6QgrAMwDBo0/J
GYrBKDmekrRV1E1ZBRQ30XzK2Wgy2Ows5MSuiYDS+G6YJwYoibutLh8BieQbxA1d
LOge/+6FTsb5+C2bJu4J+0LHHYYsYM16UJMXifUrv0hf3+i22gjXeK4aqaHajbDL
HLIhNuVSI9jXq8w2DKz/msf8mZi2DsuSxH+5oTc2Oo0bF6LJwzPkXVaWd0McqVvW
Mme0KYYnmjlkbyal4fjFuHcZZa4vzgh5XvT8NXf+Gz4imax9ARsrCUED/kTGMxOb
cgpQMu6kdKFBY+Ye6G5f
=lQrP
-----END PGP SIGNATURE-----

--45Z9DzgjV8m4Oswq--
