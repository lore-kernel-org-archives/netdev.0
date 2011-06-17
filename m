From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] drivers/net: Remove casts of void *
Date: Fri, 17 Jun 2011 15:19:03 -0400 (EDT)
Message-ID: <20110617.151903.1203335395245647912.davem@davemloft.net>
References: <3bea9d0803a4ebfee2bb0f6e42defbf76126dc86.1308287030.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: acme@ghostprotocols.net, jcliburn@gmail.com, chris.snook@gmail.com,
	jie.yang@atheros.com, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com,
	rmody@brocade.com, ddutt@brocade.com,
	sjur.brandeland@stericsson.com, divy@chelsio.com,
	leitao@linux.vnet.ibm.com, amit.salecha@qlogic.com,
	ron.mercer@qlogic.com, linux-driver@qlogic.com,
	anirban.chakraborty@qlogic.com, jdmason@kudzu.us,
	linux-net-drivers@solarflare.com, shodgson@solarflare.com,
	bhutchings@solarflare.com, venza@brownhat.org, dave@thedillows.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3bea9d0803a4ebfee2bb0f6e42defbf76126dc86.1308287030.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Joe Perches <joe@perches.com>
Date: Thu, 16 Jun 2011 22:08:06 -0700

> Unnecessary casts of void * clutter the code.
>=20
> These are the remainder casts after several specific
> patches to remove netdev_priv and dev_priv.
>=20
> Done via coccinelle script (and a little editing):
>=20
> $ cat cast_void_pointer.cocci
> @@
> type T;
> T *pt;
> void *pv;
> @@
>=20
> - pt =3D (T *)pv;
> + pt =3D pv;
>=20
> Signed-off-by: Joe Perches <joe@perches.com>
> Acked-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
> Acked-By: Chris Snook <chris.snook@gmail.com>
> Acked-by: Jon Mason <jdmason@kudzu.us>

Applied, thanks.
