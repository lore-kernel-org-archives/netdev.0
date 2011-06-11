From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] inetpeer: lower false sharing effect
Date: Sat, 11 Jun 2011 06:54:12 +0200
Message-ID: <1307768052.2872.50.camel@edumazet-laptop>
References: <1307600810.3980.85.camel@edumazet-laptop>
	 <1307664235.17300.44.camel@schen9-DESK>
	 <20110609.204330.2090335955971650557.davem@davemloft.net>
	 <1307745190.17300.85.camel@schen9-DESK>
	 <BANLkTikU_ug=zUdfOZAX6eJ+BD9ZZvDrJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tim Chen <tim.c.chen@linux.intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	andi@firstfloor.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:50135 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527Ab1FKEyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 00:54:17 -0400
Received: by wwk4 with SMTP id 4so1272326wwk.1
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 21:54:16 -0700 (PDT)
In-Reply-To: <BANLkTikU_ug=zUdfOZAX6eJ+BD9ZZvDrJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 11 juin 2011 =C3=A0 08:54 +0800, Changli Gao a =C3=A9crit :

> Did you disable routing cache when profiling? If so, enable it and tr=
y again.
>=20

Whole point of the exercice is to prepare ground for routing cache
removal :)

If you want a server being hit by millions of clients around the world,
routing cache is a real pain because of memory needs.


