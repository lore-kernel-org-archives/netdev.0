From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?= <nicolas.2p.debian@free.fr>
Subject: Re: [Bonding-devel] [PATCH net-next-2.6] bonding: remove useless
 assignment
Date: Wed, 07 Oct 2009 22:24:45 +0200
Message-ID: <4ACCF90D.6080005@free.fr>
References: <4ACCF4D5.9050502@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	bonding-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:46892 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754424AbZJGUZg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 16:25:36 -0400
In-Reply-To: <4ACCF4D5.9050502@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas de Peslo=FCan wrote:
> The variable old_active is first set to bond->curr_active_slave.
> Then, it is unconditionally set to new_active, without being used in =
between.
>=20
> The first assignment, having no side effect, is useless.
>=20
> Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
> Reviewed-by: Jiri Pirko <jpirko@redhat.com>
>=20
> ---
>=20
> Resent after fixing tab to space corruption.
>=20
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index a7e731f..fce7233 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1084,7 +1084,7 @@ static struct slave *bond_find_best_slave(struc=
t bonding *bond)
> 	int mintime =3D bond->params.updelay;
> 	int i;
>=20
> -	new_active =3D old_active =3D bond->curr_active_slave;
> +	new_active =3D bond->curr_active_slave;
>=20
> 	if (!new_active) { /* there were no active slaves left */
> 		if (bond->slave_cnt > 0)   /* found one slave */

Apparently still some issues with patch formating. I will investigate t=
his and post later.

	Nicolas.
