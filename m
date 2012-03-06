From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: export netdev_stats_to_stats64
Date: Mon, 05 Mar 2012 20:44:53 -0800
Message-ID: <1331009093.2474.27.camel@edumazet-laptop>
References: <20120305113353.GA12969@Spy32>
	 <1330954326.2474.9.camel@edumazet-laptop>
	 <1330955921.2474.18.camel@edumazet-laptop>
	 <CABoNC82c2G+2ubS8it+dAdQBK3EvyaArdGxhZh-KY=3YraMdNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Junchang Wang <junchangwang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:63363 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757924Ab2CFEo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 23:44:58 -0500
Received: by pbcun15 with SMTP id un15so3609136pbc.19
        for <netdev@vger.kernel.org>; Mon, 05 Mar 2012 20:44:57 -0800 (PST)
In-Reply-To: <CABoNC82c2G+2ubS8it+dAdQBK3EvyaArdGxhZh-KY=3YraMdNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 mars 2012 =C3=A0 12:38 +0800, Junchang Wang a =C3=A9crit :
> > Some drivers use internal netdev stats member to store part of thei=
r
> > stats, yet advertize ndo_get_stats64() to implement some 64bit fiel=
ds.
> >
> > Allow them to use netdev_stats_to_stats64() helper to make the copy=
 of
> > netdev stats before they compute their 64bit counters.
> >
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Hi Eric,
> And I think we can add a netdev_stats_add_to_stats64() helper to avoi=
d
> following duplicate code. Is that acceptable? Thanks.
>=20
> drivers/net/bonding/bond_main.c
>                 stats->rx_packets +=3D sstats->rx_packets;

Oops, I misread your mail, I was preparing other stuff, not an add()
helper. I dont think it would be that usefull (only bond AFAIK)
