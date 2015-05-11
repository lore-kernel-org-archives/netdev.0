From: Dominick Grift <dac.override@gmail.com>
Subject: Re: Suspicious RCU usage in bridge with Linux v4.0-9362-g1fc149933fd4
Date: Mon, 11 May 2015 15:15:17 +0200
Message-ID: <20150511131516.GC10375@x131e>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
 <20150504133943.GA17043@x131e>
 <CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
 <20150504132714.55dca5b0@urahara>
 <CAHA+R7PVpNdqrOHQgHXYRM8io9GZpeucZ_Gk8YNHqQC=f9+egw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="2/5bycvrmDh4d1IB"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:37129 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbbEKNPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 09:15:22 -0400
Received: by widdi4 with SMTP id di4so95932144wid.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 06:15:20 -0700 (PDT)
Received: from x131e (217-19-24-195.dsl.cambrium.nl. [217.19.24.195])
        by mx.google.com with ESMTPSA id q4sm22810059wja.24.2015.05.11.06.15.19
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 May 2015 06:15:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAHA+R7PVpNdqrOHQgHXYRM8io9GZpeucZ_Gk8YNHqQC=f9+egw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--2/5bycvrmDh4d1IB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 04, 2015 at 02:35:27PM -0700, Cong Wang wrote:

<snip>

> It _looks like_ we only retrieve vlan info to fill netlink
> messages in timer context, so it doesn't seem we need to
> hold br->lock here.
>=20
> But I never look into br vlan code of course.

This is just a friendly reminder that this issue still exits in: 4.1.0-0.rc=
2.git3.1

Ignore me if you are aware of the above

--=20
02DFF788
4D30 903A 1CF3 B756 FB48  1514 3148 83A2 02DF F788
http://keys.gnupg.net/pks/lookup?op=3Dvindex&search=3D0x314883A202DFF788
Dominick Grift

--2/5bycvrmDh4d1IB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQGcBAEBCgAGBQJVUKtfAAoJENAR6kfG5xmcSEgMAMKSlV0jOsO+d9/L+M4NqpqD
rV6pEThg5wZFyyQRBvKM2QNrWP60cI4/ML5rXkGi7ro8ZIqgqkqV1MqLCsJ0kcsc
mnZdM8SWtQx7h/86U9yBx1ELAbA+6Q5m73rzlZvyG99U6HDOIL5XI/EDew4T/CUq
jh1UVvahc03o/E7oesrxFdfqXpcJbG9Eu0n56VZ0hIG3Zx09dRHS1HyIcdE2VZdz
Bm2NjHQlS7ldV2M3Lu7IZj5udNu0JZkOW73/GQAKKZjSoyZo+QUrsNcOZWAMDEVD
bYhUg9DGvLB9KYl8dA2L+w61qV9LCw1qYPZQ/E+zARhn+IMFgOS92jbDxj1a+VZM
unn8Na+gBKhmeemJJbZ49Y0QDxnbGuJMVmHDVasozGhqiTj1O0OqggscERU4448X
UDCBSfcQ4hlgIpBR04XVXeqZFH+Bd9gVGwK3tHox2TN+E2h8cy0drDDit9tOk+ue
hJL5xVbgiwI4r3I4U95AFvZQ/SgeOh5dm0nbcbR7GQ==
=NGcn
-----END PGP SIGNATURE-----

--2/5bycvrmDh4d1IB--
