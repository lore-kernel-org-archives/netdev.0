From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IPv4 route cache DOS attack
Date: Tue, 27 Nov 2012 17:01:14 -0800
Message-ID: <1354064474.14302.44.camel@edumazet-glaptop>
References: <CAJygYd1OSTfpdbA57q0c6ppMtft3iB7uzo-RCXFOamGp2XVzBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?=E5=8F=B6=E9=9B=A8=E9=A3=9E?= <sunyucong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:53836 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752263Ab2K1BBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 20:01:16 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so9304683pbc.19
        for <netdev@vger.kernel.org>; Tue, 27 Nov 2012 17:01:16 -0800 (PST)
In-Reply-To: <CAJygYd1OSTfpdbA57q0c6ppMtft3iB7uzo-RCXFOamGp2XVzBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 15:15 -0800, =E5=8F=B6=E9=9B=A8=E9=A3=9E wrote:
> Hi,
>=20
> I have a linux router running kernel 3.2  that receive public ingress
> packets and route them through an GRE tunnel, return packets don't go
> through it
>=20
> I've recently faced a serious issue with the route cache,  when the
> router received spoofed source , the route cache will quickly get
> exhausted (depending on the size of it) and soon the ip dst cache
> overflow will be printed and network subsystem will hang until
> restarted.
>=20
> So, my question is, how can I turn off the route cache without
> recompile the kernel or adding the  patch for removal  in 3.7?  I
> tried to set
>=20
> echo 0 > /proc/sys/net/ipv4/route/max_size but that has no effect at =
all.
>=20
> And if some one can share some insight on why when dst cache
> overflows, the network subsystem hangs, it would be great.

echo -1 >/proc/sys/net/ipv4/rt_cache_rebuild_count
