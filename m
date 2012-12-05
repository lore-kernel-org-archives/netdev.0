From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ksoftirqd 100% after disabling IPv4 route cache on high pps.
Date: Wed, 05 Dec 2012 15:48:51 -0800
Message-ID: <1354751331.31222.295.camel@edumazet-glaptop>
References: <CAJygYd187B1305puZwdiK6kfP=LPPvyX_rGJn9g2azaRs4p8ZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?=E5=8F=B6=E9=9B=A8=E9=A3=9E?= <sunyucong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:38500 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918Ab2LEXsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 18:48:54 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so3974333pad.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 15:48:54 -0800 (PST)
In-Reply-To: <CAJygYd187B1305puZwdiK6kfP=LPPvyX_rGJn9g2azaRs4p8ZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-12-05 at 13:22 -0800, =E5=8F=B6=E9=9B=A8=E9=A3=9E wrote:
> Hi Eric,
>=20
> After disabling the route cache, I found a forwarding performance
> problem (inevitable ?). Basically the kernel couldn't keep up under
> about 100k pps and ksoftirqd is dominating the CPU. This problem went
> away right away if I do
>=20
> echo  1 > rt_cache_rebuild_count
>=20
> and comes back as soon as i do echo -1 > rt_cache_rebuild_count.
>=20
> I then tried to use RPS/RFS to share the load on to mulitple cpus
> (since ksoftirqd is only using 1 core, clearly). but that has little
> effect.
>=20
> Is there some tweaks/patches you recommend?

Yes, upgrade your kernel to 3.6 or 3.7, this problem has been solved fo=
r
good. No more IP route cache and good performance.
