From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regarding Routing cache
Date: Thu, 17 Nov 2011 07:26:54 +0100
Message-ID: <1321511214.3274.25.camel@edumazet-laptop>
References: <CADAe=+Lmp=e3NRH5NOYewJp=XZ0CncPzC-4V=Ct-TEuGjfq3nw@mail.gmail.com>
	 <CADAe=+K8bf_VOe=KszDZRqZnxQH2VFS3C05mpG=RarN+R5BSbA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ajith Adapa <adapa.ajith@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46270 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442Ab1KQG06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 01:26:58 -0500
Received: by wyh11 with SMTP id 11so1530558wyh.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 22:26:57 -0800 (PST)
In-Reply-To: <CADAe=+K8bf_VOe=KszDZRqZnxQH2VFS3C05mpG=RarN+R5BSbA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please dont top post on netdev

Le jeudi 17 novembre 2011 =C3=A0 11:34 +0530, Ajith Adapa a =C3=A9crit =
:
> Hi,
>=20
> Actually I have doubt with IPv6 related packets.
>=20
> In case of IPv6 packet in ip6_route_output function is called for
> destination related information.
> where ip6_route_output calls "fib6_rule_lookup" function. Why lookup
> is done in fib table instead of routing cache in case of IPv6 packet =
?
>=20
> In case of IPv4 packet ... ip_route_output checks in routing cache an=
d
> if there is a cache miss then it checks the fib table.
>=20

IPv6 has no routing cache, and wont have one, since we are trying to
remove IPv4 routing cache :)

>=20
>=20
>=20
> On Thu, Nov 17, 2011 at 10:30 AM, Ajith Adapa <adapa.ajith@gmail.com>=
 wrote:
> > Hi,
> >
> > I have a small doubt regarding routing cache in linux kernel.
> >
> > It seems ip_route_connect is the way we have to access routing cach=
e
> > entries. In case of all locally generated packets I see that struct
> > dst_entry is filled up with a lookup in routing cache.
> >
> > What about in case of forwarding packets ? I dont see any usage of
> > routing cache mechanism to fill up the struct dst_entry. So it seem=
s
> > we directly check the fib_rules or fib table to fill the structure.
> > If it is true then it would be very slow right ?
> >
> > Sorry if I am wrong about above findings. Do correct me if I am wro=
ng about it ?
> >
> > Regards,
> > Ajith
> >
> --
