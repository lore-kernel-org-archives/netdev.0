From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] macvlan: remove one synchronize_rcu() call
Date: Fri, 20 May 2011 06:28:05 +0200
Message-ID: <1305865685.3156.46.camel@edumazet-laptop>
References: <1305843856.3156.36.camel@edumazet-laptop>
	 <4DD5B36C.2020407@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:59594 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233Ab1ETE2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 00:28:11 -0400
Received: by wwk4 with SMTP id 4so118184wwk.1
        for <netdev@vger.kernel.org>; Thu, 19 May 2011 21:28:09 -0700 (PDT)
In-Reply-To: <4DD5B36C.2020407@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 19 mai 2011 =C3=A0 17:18 -0700, Ben Greear a =C3=A9crit :

> I applied this to today's wireless-testing kernel.  There is a consis=
tent
> speedup in deleting mac-vlans!  I wouldn't read much into changes in
> creating macvlans or adding IPs..those numbers just jump around a bit
> from run to run.
>=20
> Before the patch:
> Deleted 500 macvlan in 25.424282 seconds. (0.050848564 per interface)
>=20
>=20
> After the patch:
>=20
> Deleted 500 macvlan in 21.831413 seconds. (0.043662826 per interface)
>=20

Thanks for testing !

My ultimate goal would be to reduce vlan/macvlan delete latency from 50
ms to less than 5 ms. Step by step...

(But this will wait after this merge window, since next changes are a
bit more complex)

Stay tuned ;)



