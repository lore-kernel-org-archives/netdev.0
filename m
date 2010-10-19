From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Nested GRE locking bug
Date: Tue, 19 Oct 2010 11:02:36 +0200
Message-ID: <1287478956.2676.13.camel@edumazet-laptop>
References: <1287028842.11178.68.camel@localhost>
	 <1287029519.2649.108.camel@edumazet-laptop>
	 <20101019.015303.104063240.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@decadent.org.uk, netdev@vger.kernel.org,
	beatrice.barbe@gmail.com, 599816@bugs.debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:36177 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871Ab0JSJCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 05:02:41 -0400
Received: by fxm4 with SMTP id 4so1401735fxm.19
        for <netdev@vger.kernel.org>; Tue, 19 Oct 2010 02:02:40 -0700 (PDT)
In-Reply-To: <20101019.015303.104063240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 octobre 2010 =C3=A0 01:53 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 14 Oct 2010 06:11:59 +0200
>=20
> > net-next-2.6 contains a fix for this, adding the perc_cpu
> > xmit_recursion limit. We might push it to net-2.6
>=20
> We need to think a bit more about this.
>=20
> We are essentially now saying that one can only configure
> tunnels 3 levels deep, and no more.
>=20
> I can guarentee you someone out there uses at least 4,
> perhaps more.
>=20
> And those people will be broken by the new limit.
>=20
> So putting this into net-2.6 with such a low limit will
> be quite dangerous.

Well limit is actually 4, but I get your point ;)



