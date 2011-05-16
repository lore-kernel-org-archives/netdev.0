From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] ethernet: avoid pre-assigned OUI values in
 random_ether_addr
Date: Mon, 16 May 2011 08:46:44 -0700
Message-ID: <20110516084644.483290f6@nehalam>
References: <20110513171729.247b126e@nehalam>
	<1305488809.3120.162.camel@edumazet-laptop>
	<1305490850.8178.57.camel@Joe-Laptop>
	<1305493826.3120.174.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44519 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756198Ab1EPPqr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 11:46:47 -0400
In-Reply-To: <1305493826.3120.174.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 15 May 2011 23:10:26 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le dimanche 15 mai 2011 =C3=A0 13:20 -0700, Joe Perches a =C3=A9crit =
:
> > On Sun, 2011-05-15 at 21:46 +0200, Eric Dumazet wrote:
> > > Le vendredi 13 mai 2011 =C3=A0 17:17 -0700, Stephen Hemminger a =C3=
=A9crit :
> > > > There are some addresses in the assigned vendor block that don'=
t obey
> > > > the locally assigned convention. These should be avoided by ran=
dom_ether_addr
> > > > assignment.
> > > We call random_ether_addr() for some virtual devices, maybe we ca=
n add a
> > > __random_ether_addr() helper for them and not avoid these OUI ?
> >=20
> > Unless it's speed critical, it's probably not worthwhile.
> >=20
>=20
> Speed was not my concern, but getting idea of why avoiding pre-assign=
ed
> OUI was a concern for them, if they dont hit a real Ethernet domain.

My concern was that after some discussion with IEEE committee that many
virtual environments are using locally assigned addresses that get brid=
ged
onto real networks.

That started me thinking that the current code should be more careful
to avoid potential conflicts. My opinion is that this not worth worryin=
g
about because the likelihood of conflict with any one of these old
addresses is as about as the unlikely as two hosts choosing the same
value. But I wanted to raise the issue for explicit discussion and fram=
e
it with what would be required to handle it.

--=20
