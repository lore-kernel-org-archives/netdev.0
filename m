From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] vlan: remove ndo_select_queue() logic
Date: Tue, 16 Nov 2010 20:54:11 +0100
Message-ID: <1289937251.2732.4.camel@edumazet-laptop>
References: <1289497978.17691.1582.camel@edumazet-laptop>
	 <AANLkTik-b5jYgN9e2cgYQvW1V3kuHem2x6wDpw4_=GJJ@mail.gmail.com>
	 <1289504565.17691.1710.camel@edumazet-laptop>
	 <20101116.112454.179916339.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jesse@nicira.com, netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:36593 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755554Ab0KPTyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 14:54:17 -0500
Received: by ewy8 with SMTP id 8so615131ewy.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 11:54:16 -0800 (PST)
In-Reply-To: <20101116.112454.179916339.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 novembre 2010 =C3=A0 11:24 -0800, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 11 Nov 2010 20:42:45 +0100
>=20
> > [PATCH] vlan: remove ndo_select_queue() logic
> >=20
> > Now vlan are lockless, we dont need special ndo_select_queue() logi=
c.
> > dev_pick_tx() will do the multiqueue stuff on the real device trans=
mit.
> >=20
> > Suggested-by: Jesse Gross <jesse@nicira.com>
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Also applied, but again there were conflicts I had to resolve,
> please check that I got it right.
>=20

Both patches seem fine to me.

I am going to test them.

Thanks !


