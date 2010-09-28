From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] dummy: percpu stats and lockless xmit
Date: Tue, 28 Sep 2010 10:02:08 +0200
Message-ID: <1285660928.2607.0.camel@edumazet-laptop>
References: <636709308.22102.1285660327977.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:33619 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939Ab0I1ICO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 04:02:14 -0400
Received: by fxm3 with SMTP id 3so2421272fxm.19
        for <netdev@vger.kernel.org>; Tue, 28 Sep 2010 01:02:13 -0700 (PDT)
In-Reply-To: <636709308.22102.1285660327977.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 28 septembre 2010 =C3=A0 00:52 -0700, Stephen Hemminger a =C3=A9=
crit :
> > Converts dummy network device driver to :
> >=20
> > - percpu stats
> >=20
> > - 64bit stats
> >=20
> > - lockless xmit (NETIF_F_LLTX)
> >=20
> > - performance features added (NETIF_F_SG | NETIF_F_FRAGLIST |
> > NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_HIGHDMA)
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> IFB device could use many of these enhancements.

Yes, probably ;)

I was considering the NETIF_F_NETNS_LOCAL, should we set it for dummy
device ?



