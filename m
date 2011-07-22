From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the final tree
Date: Fri, 22 Jul 2011 16:24:33 +1000
Message-ID: <20110722162433.a280b3b71cff9c08fe18956f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__22_Jul_2011_16_24_33_+1000_PSJTPNz7XozWM5js"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matt Evans <matt@ozlabs.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:51391 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752503Ab1GVGYm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2011 02:24:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__22_Jul_2011_16_24_33_+1000_PSJTPNz7XozWM5js
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc64
allnoconfig) produced this warning:

warning: (PPC) selects HAVE_BPF_JIT which has unmet direct dependencies (NE=
T)

Introduced by commit 0ca87f05ba8b ("net: filter: BPF 'JIT' compiler for
PPC64").

I suspect that the fix is to move the

config HAVE_BPF_JIT
        bool

lines to outside the "if NET" in net/Kconfig.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__22_Jul_2011_16_24_33_+1000_PSJTPNz7XozWM5js
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOKRehAAoJEDMEi1NhKgbsDM0H+QGsEdg2DWZidtXQrg6frF8F
e4TYIiOYZlSME+K4TXVOHZnI4vbA0I75SyLIw6feKaaQ0a/fek7CBV0xYeiobiJT
3lbJqOBf2BmOvs6b60w6ACZKLEnNH1RK0yVzGXhMZziqcrgyqG+ZOBIh6sHmW3lu
xy0ACUdTyzN92J9mkUEL/jO2mqoaX3xYiq3avu0iDVA2rvdMHI7tm0PSX49wY2OT
1MG6Lkd9i51x6ezvVo78sBzN43E1z4L95f2H8kJl0wdcF5MDAAHXbXiCVQPq5VQV
ZPePKE6cIWYGpa7tcR+BMp3CxuPR19SdSHxxHK2zttY1QI0wu2Z3f5JJcMBDink=
=TfOi
-----END PGP SIGNATURE-----

--Signature=_Fri__22_Jul_2011_16_24_33_+1000_PSJTPNz7XozWM5js--
