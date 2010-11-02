From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Routing over multiple interfaces
Date: Tue, 02 Nov 2010 21:04:27 +0100
Message-ID: <1288728267.2467.4.camel@edumazet-laptop>
References: <1288645922.5977.41.camel@macbook.infradead.org>
	 <20101101.141638.116372747.davem@davemloft.net>
	 <1288647330.2660.116.camel@edumazet-laptop>
	 <4CD06AA4.6090005@plouf.fr.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dwmw2@infradead.org, netdev@vger.kernel.org
To: Pascal Hambourg <pascal.mail@plouf.fr.eu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:53881 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750796Ab0KBUEj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Nov 2010 16:04:39 -0400
Received: by eye27 with SMTP id 27so4184202eye.19
        for <netdev@vger.kernel.org>; Tue, 02 Nov 2010 13:04:38 -0700 (PDT)
In-Reply-To: <4CD06AA4.6090005@plouf.fr.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 02 novembre 2010 =C3=A0 20:46 +0100, Pascal Hambourg a =C3=A9c=
rit :
> Hello,
>=20
> Eric Dumazet a =C3=A9crit :
> >=20
> > David W. probably wants to use teql or some bonding ?
>=20
> I doubt that (ethernet) bonding works with PPP links.
>=20

Well, I was asking if some ppp bonding was possible. I am not a ppp
user.

> > # tc qdisc add dev ppp0 root teql0
> > # tc qdisc add dev ppp1 root teql0
> > # ip link set dev teql0 up
> > # ip route add default src 90.155.92.214 dev teql0
>=20
> What about using iptables + routing rules ?
> Mark every other packet going through the default PPP link with
> iptables, and reroute marked packets through the other PPP link.

OK. I provided a working setup, maybe you also could provide one based
on iptables as well ?



