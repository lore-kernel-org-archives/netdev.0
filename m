From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net-next compilation failure since 76ff5cc9
Date: Sun, 22 Jul 2012 20:37:30 -0400
Message-ID: <20120723003730.GA8040@neilslaptop.think-freely.org>
References: <20120722162107.GA23219@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42290 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759Ab2GWAhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 20:37:52 -0400
Content-Disposition: inline
In-Reply-To: <20120722162107.GA23219@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 22, 2012 at 06:21:07PM +0200, Richard Cochran wrote:
> Without CONFIG_RPS, net-next fails to compile with
>=20
>   CC      net/core/rtnetlink.o
> /linux/net/core/rtnetlink.c: In function =E2=80=98rtnl_fill_ifinfo=E2=
=80=99:
> /linux/net/core/rtnetlink.c:895: error: =E2=80=98struct net_device=E2=
=80=99 has no member named =E2=80=98num_rx_queues=E2=80=99
> make[3]: *** [net/core/rtnetlink.o] Error 1
>=20
> Looks like this was caused by
>=20
> 76ff5cc9  rtnl: allow to specify number of rx and tx queues on device=
 creation
>=20
> Not sure how to fix.
>=20
> Thanks,
> Richard
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
Its fixed already by 1d69c2b3.  Just pull and you should be good to go.
Neil
