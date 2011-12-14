From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Wed, 14 Dec 2011 18:57:55 +0100
Message-ID: <1323885475.2334.73.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4EE8C6A8.3060308@iki.fi>
	 <20111214.125010.82857701285437834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63233 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755466Ab1LNR57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 12:57:59 -0500
Received: by wgbdr13 with SMTP id dr13so2205636wgb.1
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2011 09:57:58 -0800 (PST)
In-Reply-To: <20111214.125010.82857701285437834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 14 d=C3=A9cembre 2011 =C3=A0 12:50 -0500, David Miller a =C3=
=A9crit :
> From: Timo Ter=C3=A4s <timo.teras@iki.fi>
> Date: Wed, 14 Dec 2011 17:54:16 +0200
>=20
> > So something is does not get updated here. This used to work though=
=2E
> > The current production boxes where I know this work is 2.6.38.8.
>=20
> We store the PMTU externally in inetpeer entries, Eric Dumazet
> fixed recently but that fix hasn't been submitted to -stable
> yet.
>=20
> I'd recommend using 3.1.x if possible if you can't wait.

I am wondering if this not another problem ?

I did a quick check on net-next, and it seems to have same problem.

Sorry, I have to run right now and wont be able to full check before 4/=
5
hours.
