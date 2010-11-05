From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ping -I eth1 ....
Date: Fri, 05 Nov 2010 16:06:54 +0100
Message-ID: <1288969614.2882.590.camel@edumazet-laptop>
References: <OF339BCA8A.B674D6AE-ONC12577D2.00481B5E-C12577D2.0048B214@transmode.se>
	 <1288964206.2882.402.camel@edumazet-laptop>
	 <OF22F5901E.A7276220-ONC12577D2.004C79CB-C12577D2.004D1571@transmode.se>
	 <20101105142510.GA14986@canuck.infradead.org>
	 <1288967665.2882.522.camel@edumazet-laptop>
	 <OF6C6C2970.245A64ED-ONC12577D2.00518CF6-C12577D2.00522AAD@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@infradead.org>
To: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37351 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074Ab0KEPqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Nov 2010 11:46:52 -0400
Received: by wwb39 with SMTP id 39so1541348wwb.1
        for <netdev@vger.kernel.org>; Fri, 05 Nov 2010 08:46:51 -0700 (PDT)
In-Reply-To: <OF6C6C2970.245A64ED-ONC12577D2.00518CF6-C12577D2.00522AAD@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 novembre 2010 =C3=A0 15:57 +0100, Joakim Tjernlund a =C3=
=A9crit :
> Eric Dumazet <eric.dumazet@gmail.com> wrote on 2010/11/05 15:34:25:
> t be a reason why in many places we only test (dev->flags &
> > IFF_UP), and _never_ netif_oper_up() (only in dev_get_flags() to ex=
port
> > it at userspace)
>=20
> Hopefully most of that is legacy or just plain wrong? Unless
> someone can say why only test IFF_UP one should consider changing the=
m.
>=20

Most of the places are hot path.

You dont want to replace one test by four tests.

_This_ would be wrong :)



