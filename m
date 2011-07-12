From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inetpeer: kill inet_putpeer race
Date: Tue, 12 Jul 2011 06:01:42 +0200
Message-ID: <1310443302.2860.24.camel@edumazet-laptop>
References: <1310388592.26049.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <20110711.202525.960905313394921992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33724 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752Ab1GLEBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 00:01:49 -0400
Received: by wwe5 with SMTP id 5so4523200wwe.1
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 21:01:48 -0700 (PDT)
In-Reply-To: <20110711.202525.960905313394921992.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 juillet 2011 =C3=A0 20:25 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 11 Jul 2011 14:49:52 +0200
>=20
> > We currently can free inetpeer entries too early :
> ...
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> I assume this is only relevant to net-next-2.6, am I right?
>=20
> Applied.

Indeed, I caught this kmemcheck warning in net-next-2.6

linux-2.6 doesnt trigger it, since we hold a spinlock in inet_putpeer()

Thanks !


