From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug? GRE tunnel periodically won't transmit some packets
Date: Tue, 08 Nov 2011 08:34:01 +0100
Message-ID: <1320737641.8976.4.camel@edumazet-laptop>
References: <20111108070819.C643236221@apps0.cs.toronto.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chris Siebenmann <cks@cs.toronto.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36156 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620Ab1KHHeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 02:34:06 -0500
Received: by wwi36 with SMTP id 36so320963wwi.1
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 23:34:05 -0800 (PST)
In-Reply-To: <20111108070819.C643236221@apps0.cs.toronto.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 novembre 2011 =C3=A0 02:08 -0500, Chris Siebenmann a =C3=A9=
crit :

>  Let me know if you want a full dump of 'ip link show' (with or
> without verbosity).
>=20
> 	- cks

Oh yes, I meant "ip -s -s link show dev extun"

to get detailed infos :

# ip -s -s link show dev ppp0
8: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1500 qdisc
pfifo_fast state UNKNOWN qlen 3
    link/ppp=20
    RX: bytes  packets  errors  dropped overrun mcast  =20
    21120910   21103    0       0       0       0     =20
    RX errors: length  crc     frame   fifo    missed
               0        0       0       0       0     =20
    TX: bytes  packets  errors  dropped carrier collsns=20
    1310652    13736    0       0       0       0     =20
    TX errors: aborted fifo    window  heartbeat
               0        0       0       0     =20
