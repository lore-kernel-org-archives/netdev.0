From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6] pkt_sched: gen_estimator: add a new lock
Date: Tue, 08 Jun 2010 07:39:22 +0200
Message-ID: <1275975562.2775.93.camel@edumazet-laptop>
References: <1275921171.2545.102.camel@edumazet-laptop>
	 <AANLkTimgmYjA7Xp19gycRHDXmwP1w1twn92cfT08tCv2@mail.gmail.com>
	 <1275924638.2545.121.camel@edumazet-laptop>
	 <1275926151.2545.126.camel@edumazet-laptop>
	 <1275929761.2545.159.camel@edumazet-laptop>
	 <1275931108.2545.168.camel@edumazet-laptop>
	 <AANLkTik7k__McJk8VCu0WP1RYEDHUfBJA4dyGYQTUmBV@mail.gmail.com>
	 <1275973091.2775.51.camel@edumazet-laptop>
	 <AANLkTik6xx0cxZKezU31K4vYg4Rz0o7ndmN4D9vYSCKX@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36218 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570Ab0FHFj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 01:39:27 -0400
Received: by wyi11 with SMTP id 11so2915236wyi.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 22:39:26 -0700 (PDT)
In-Reply-To: <AANLkTik6xx0cxZKezU31K4vYg4Rz0o7ndmN4D9vYSCKX@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 08 juin 2010 =C3=A0 13:20 +0800, Changli Gao a =C3=A9crit :

> IMO, this bug should be fixed by adding rtnl_lock to xt_RATEEST.c.
> Killing rtnl should be done in separated patches. They are different
> things. Your patch introduces another locks, and it is extra overhead
> for other users.
>=20

extra overhead, in new/kill estimators ?=20

Are you kidding ?

RTNL is taken, taking an extra-uncontended spinlock is free.

Nope, I wont add rtnl lock to xt_RATEEST.c

I believe you dont really understood what I patiently explained to you.

Thats becoming rediculous.



