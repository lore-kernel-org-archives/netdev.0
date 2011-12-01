From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: nuclear neigh patch
Date: Thu, 01 Dec 2011 22:17:20 +0100
Message-ID: <1322774240.2750.30.camel@edumazet-laptop>
References: <20111201.152057.981138658170403943.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62464 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901Ab1LAVRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 16:17:24 -0500
Received: by faaq16 with SMTP id q16so1762874faa.19
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2011 13:17:23 -0800 (PST)
In-Reply-To: <20111201.152057.981138658170403943.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 01 d=C3=A9cembre 2011 =C3=A0 15:20 -0500, David Miller a =C3=A9=
crit :
> Eric, how lucky are you feeling today? :-)
>=20
> Here is a patch that gets rid of the neighbour reference for ipv4 rou=
tes.
> Neigh entries are computed at packet send time in ip_output.c
>=20
> Some minor work is needed before we can flat out use something like t=
his,
> the main issue being that there are places that assume that if we hav=
e
> a 'dst' entry then there is a non-NULL neighbour unconditionally avai=
lable.
> Mainly this happens in the infiniband layer.
>=20
> So we can't create a situation where dst_get_neighbour() might return=
 NULL
> just yet.
>=20
> This is worth sorting out, because then we can get rid of the neigh
> pointer entirely from dst entries.
>=20
> But anyways, if this patch works it would be interesting to see what
> it does to the UDP tests on your test machine(s).

Sure, this looks great.

I'll try this tomorrow on my test machines, its 10:15pm here ;)
