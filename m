From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next-2.6] bonding: remove useless assignment
Date: Mon, 5 Oct 2009 16:52:05 +0200
Message-ID: <20091005145205.GE7035@psychotron.lab.eng.brq.redhat.com>
References: <4AB67242.6060803@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	bonding-devel@lists.sourceforge.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?= <nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43989 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753071AbZJEOww (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Oct 2009 10:52:52 -0400
Content-Disposition: inline
In-Reply-To: <4AB67242.6060803@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Sep 20, 2009 at 08:19:46PM CEST, nicolas.2p.debian@free.fr wrote:
> The variable old_active is first set to bond->curr_active_slave.
> Then, it is unconditionally set to new_active, without being used in =
between.
>
> The first assignment, having no side effect, is useless.

Correct.

>
> Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

Reviewed-by: Jiri Pirko <jpirko@redhat.com>

>
> ---
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index a7e731f..fce7233 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1084,7 +1084,7 @@ static struct slave *bond_find_best_slave(struc=
t bonding *bond)
>         int mintime =3D bond->params.updelay;
>         int i;
>
> -       new_active =3D old_active =3D bond->curr_active_slave;
> +       new_active =3D bond->curr_active_slave;
>
>         if (!new_active) { /* there were no active slaves left */
>                 if (bond->slave_cnt > 0)   /* found one slave */
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
