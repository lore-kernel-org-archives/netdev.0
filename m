From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: netlink: hide struct module parameter in netlink_kernel_create
Date: Mon, 10 Sep 2012 09:37:12 +1000
Message-ID: <20120910093712.18e5718b605f84aa4e76f7d9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__10_Sep_2012_09_37_12_+1000_PV8FnS2eXKkH9gtC"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:34813 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755703Ab2IIXhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2012 19:37:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Mon__10_Sep_2012_09_37_12_+1000_PV8FnS2eXKkH9gtC
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

I didn't see the original patch until it reached linux-enxt this morning,
but just a comment:

THIS_MODULE is defined in linux/export.h, so that should be included in
linux/netlink.h instead of linux/module.h as it is much smaller.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__10_Sep_2012_09_37_12_+1000_PV8FnS2eXKkH9gtC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQTSgoAAoJEECxmPOUX5FEkW4P/0kCSS+103zPIB1wm33KTo23
hjq4g9pNPZAlwqrfCh+hAmLyAsGDgCpe++sOHULMidtE4+9r1VJKMwE18bjv6Ss/
oBiWVnCFd5PtwiZaSizV8K/qERfR/9PkpmSpt5rcDA7O4qHZBjOCZyzdu5hZxg1Z
yE8R1sO7rmsRSisuPxncqEDnGFnTG8Qu28sYE3+xLNlJmWX40+Ryo9mQGcy6k9ev
a9m2HjPqtDv8QnZZpIg2p9PjIAGOgmuYjBss9p0ImkDIZ6dykc+v8O69FWrXYpbA
zI3EKPBq9wk7vQZFB836/LBJhHK41Tjc4Uyg3eOOWAar1Msk4t9zyW//V1+uMMi1
DUbehc2h4Xcw0oIB5NUXAbL9p7GFKtuWpEIsYc6rLEIjBYVt/9dQYAyNLCPONjxS
cMDI7cj4g58aUbNJygpOmFMXIYSrQBAiVNypdiUl/UHo/iOPRhwP/KQuktKemrdw
nDMHDvsI4iZwAOdiltd0f3fOLze2CbjTvuwKGfbEEuJbNdYrsLdJRPU6At1YaNMT
Inxbq903GuisAvhTdqzueJTE3+Y+3Gq9o1F9pJMqCOvxA6EElV8F4zK4v18tpEu6
C4cmtGyOFoJpS5bvwJLFCuIyj3rcley5Yf8snlUHw0p4cyFEiArgBMhs9w4mkQCr
4n3uYSfLhImSbyZhqpRm
=PTZH
-----END PGP SIGNATURE-----

--Signature=_Mon__10_Sep_2012_09_37_12_+1000_PV8FnS2eXKkH9gtC--
