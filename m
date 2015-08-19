From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH] r8169: Add values missing in @get_stats64 from HW
 counters
Date: Wed, 19 Aug 2015 15:07:44 +0200
Message-ID: <20150819130744.GA24832@calimero.vinschen.de>
References: <1439888664-28620-1-git-send-email-vinschen@redhat.com>
 <20150818214017.GA14914@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2F4B846@RTITMBSV03.realtek.com.tw>
 <20150819091318.GV17917@calimero.vinschen.de>
 <0835B3720019904CB8F7AA43166CEEB2F4BF49@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="82I3+IH0IqGh5yIs"
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>, Ivan Vecera <ivecera@redhat.com>
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:41520 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750958AbbHSNHr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 09:07:47 -0400
Content-Disposition: inline
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2F4BF49@RTITMBSV03.realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Aug 19 09:31, Hayes Wang wrote:
> Corinna Vinschen [mailto:vinschen@redhat.com]
> > Sent: Wednesday, August 19, 2015 5:13 PM
> [...]
> > > It could be cleared by setting bit 0, such as rtl_tally_reset() of r8=
152.
> >=20
> > Is it safe to assume that this is implemented in all NICs covered by r8=
169?=20
>=20
> It is supported from RTL8111C. That is, RTL_GIGA_MAC_VER_19 and later.

Thanks.  In that case I would prefer the same generic method for all
chip versions, so I'd opt for storing the offset values at rtl_open
time as my patch is doing right now.  Is that acceptable?

If so, wouldn't it make even more sense to use the hardware collected
information in @get_stats64 throughout, except for the numbers collected
*only* in software? =20

I would be willing to propose a matching patch.


Thanks,
Corinna

--82I3+IH0IqGh5yIs
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV1H+gAAoJEPU2Bp2uRE+g46UP/2PKhQBWQZ927oZSzoSlLwUr
Cez5bLT/ZZXLnAMR6+vARuYOlxaoeeaF2mxxLWEXXUgW9yK9XxMRpDRtEwl1hRgN
3Mx6RQLjyOZeJN5w6m8MNuQHHutwq0ZIGl/0t328jn4AjvG2NSvB/x0CTQOslpgO
bLrReDOZMoJRkj2RvBrPRTl6saKHqJnxiyYQXdeIPZHmNvJ0ihsK3HUBKvG7s7mD
KndXEJyCYwNzctA0lro09YStYY4Qwz7PQlx0zXcXnxhjjcLmGfb/bbjV4WIQIbNs
wTHosAhM4GPLhqMIIDX0Hzr5DotLzRt4bqUJewJQFoRnspAMPgOUFtx1Dmq0HYlI
M40FBWc60f/B5t5bZCJvze/rpC3HB40kXvYwa2qD0e0EUH6ZftXgLPBmo8h8T3dK
EpmeVo7D5r6u1XCdqRwmBp5Y6F6ilj5wPqlmlWQR7TS5HECqeAXqhtayJcuSqzL1
6QovK3SyaQbChqTji9lA4ng4IkId3fU+gySfufEK7LGm4xe+bW6wDv4k/2cdfyma
jaMG6uTxLTFfeAq70HVS9y79N+KjghsX5py2ve/xTrpOhgp+61URtIjTcb1ScI9u
ZurUFEU7p09Ckst/75x55jkzqjbthozdcLI+zMhjxBpajokIqqi979bmlNC273pe
emTtcTqNw3sk3sx0Ijmi
=CFen
-----END PGP SIGNATURE-----

--82I3+IH0IqGh5yIs--
