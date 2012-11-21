From: Sven Eckelmann <sven@narfation.org>
Subject: Re: Re: [PATCH 9/9] batman-adv: Use packing of 2 for all headers before an ethernet header
Date: Wed, 21 Nov 2012 19:20:21 +0100
Message-ID: <8108710.8oNxxR0rRd@sven-laptop.home.narfation.org>
References: <1353499919-28596-1-git-send-email-ordex@autistici.org> <1353499919-28596-10-git-send-email-ordex@autistici.org> <20121121.125759.322762083309845086.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2155651.Jmk407CeqG"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: ordex@autistici.org, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org, lindner_marek@yahoo.de,
	kevin.curtis@farsite.co.uk, linux-driver@qlogic.com,
	ron.mercer@qlogic.com, jitendra.kalsaria@qlogic.com,
	rmody@brocade.com, andy@greyhouse.net, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:40283 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755409Ab2KUSUZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2012 13:20:25 -0500
In-Reply-To: <20121121.125759.322762083309845086.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart2155651.Jmk407CeqG
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Wednesday 21 November 2012 12:57:59 David Miller wrote:
> From: Antonio Quartulli <ordex@autistici.org>
> Date: Wed, 21 Nov 2012 13:11:59 +0100
> 
> > +#pragma pack(2)
> 
>  ...
> 
> > -} __packed;
> 
> The __packed attribute is an abstraction of the actual syntax
> the compiler uses, if it is supported at all.
> 
> Therefore, you can't just unconditionally use the #pragma, and
> you would need to use some kind of similar compiler abstraction
> for it.
> 
> But to be honest this is really ugly and for very little, if any,
> gain.

Agree. But we should get this message also to the other guys

$ git grep pragma -- drivers/net
drivers/net/bonding/bond_3ad.h:#pragma pack(1)
drivers/net/bonding/bond_3ad.h:#pragma pack()
drivers/net/bonding/bond_3ad.h:#pragma pack(8)
drivers/net/bonding/bond_3ad.h:#pragma pack()
drivers/net/bonding/bond_alb.c:#pragma pack(1)
drivers/net/bonding/bond_alb.c:#pragma pack()
drivers/net/ethernet/brocade/bna/bfa_defs.h:#pragma pack(1)
drivers/net/ethernet/brocade/bna/bfa_defs.h:#pragma pack()
drivers/net/ethernet/brocade/bna/bfa_defs_cna.h:#pragma pack(1)
drivers/net/ethernet/brocade/bna/bfa_defs_cna.h:#pragma pack()
drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h:#pragma pack(1)
drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h:#pragma pack()
drivers/net/ethernet/brocade/bna/bfi.h:#pragma pack(1)
drivers/net/ethernet/brocade/bna/bfi.h:#pragma pack()
drivers/net/ethernet/brocade/bna/bfi_cna.h:#pragma pack(1)
drivers/net/ethernet/brocade/bna/bfi_cna.h:#pragma pack()
drivers/net/ethernet/brocade/bna/bfi_enet.h:#pragma pack(1)
drivers/net/ethernet/brocade/bna/bfi_enet.h:#pragma pack()
drivers/net/ethernet/brocade/bna/cna.h:#pragma pack(1)
drivers/net/ethernet/brocade/bna/cna.h:#pragma pack()
drivers/net/ethernet/qlogic/qla3xxx.h:#pragma pack(1)
drivers/net/ethernet/qlogic/qla3xxx.h:#pragma pack()
drivers/net/wan/farsync.c:#pragma pack(1)
drivers/net/wan/farsync.c:#pragma pack()

Kind regards,
	Sven
--nextPart2155651.Jmk407CeqG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQrRtlAAoJEF2HCgfBJntGM18P/jxOhZ0svfq4/zPuN2v9ptXt
/8e15tDGPJES51vFBkPRqUUBS3hw10O0kRnXnUroECUW3d9jTEhgt6Y0I+gMK6Sd
ktnnArPyO3Eh76DBRbh355OMjWMCP/ir4/rE6DHgFS45WuaVYhkaOxI86aSCLWa3
h96R0PI05Xm+mqmBUlD7GYEHmwq7oTmum0WWsOiQlBIvfXHK3PvlMTxekJ7JQFB6
PVFB3TSeZl7ptcjPlTw/M4UZk8kRP7Eype7O3VyvPL/qth9jkIkBTzUTzjCk2zX5
Ano5zJPav2NNM3yf8Ncx4GUBvjKMhcAZGCHpLlVp5LpQmf8ze5kg3pRCS6OIbEJE
0ud7UApkSpUnOu8ydIw4LJ23sw1n4wOG33TS/kXBFO6pqj55w453YWHQYWzJyL8F
H1yI0OVBynQyZ7Y0whVABKF7PENWiIzFX0t2AK46HaW0cOtin517H7MU0Z0Xu659
QgBQczYjrWJyXEt2h+M5vtCAQEBtQNYFh4mi+JNQnTbFRzdFyZX46rdLJmS2hwpp
jAoBYk70JderEcxW4xQlyrLpfX9LQotjdHk5YOrAVPQct/BY2lAoPiD/X1aLp72J
n/k/4Ho0RZe1i10Z2oF+obtsbkqGFGFht9u84D47j7G/wVd2jHcZrgZqotT3Qit+
VWjWG+A6VqhRzSeOaACB
=G1cb
-----END PGP SIGNATURE-----

--nextPart2155651.Jmk407CeqG--
