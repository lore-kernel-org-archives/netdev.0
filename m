From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug#595265: linux-image-2.6.32-5-686: Nerwork card fails to
 come up again after suspend
Date: Tue, 19 Oct 2010 00:50:57 +0200
Message-ID: <1287442257.2361.11.camel@edumazet-laptop>
References: <20100902154312.12515.10390.reportbug@bird.umass.edu>
	 <201009211624.12744.aboelens@engin.umass.edu>
	 <1286760421.2955.287.camel@localhost>
	 <201010171116.00514.aboelens@engin.umass.edu>
	 <1287361431.20865.133.camel@localhost>
	 <20101018214536.GA14344@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Arnout Boelens <aboelens@engin.umass.edu>,
	595265@bugs.debian.org, netdev <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57367 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838Ab0JRWvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 18:51:13 -0400
Received: by wwj40 with SMTP id 40so407055wwj.1
        for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 15:51:01 -0700 (PDT)
In-Reply-To: <20101018214536.GA14344@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 18 octobre 2010 =C3=A0 23:45 +0200, Francois Romieu a =C3=A9cr=
it :
> Ben Hutchings <ben@decadent.org.uk> :
> [...]
> > Arnout Boelens reported that his RTL8111/8168B fails to link-up aft=
er
> > suspend and resume, both under Debian's kernel based on 2.6.32 and =
under
> > 2.6.36-rc6.  Full details are at <http://bugs.debian.org/595265>, t=
hough
> > the log isn't very informative:
> >=20
> > [31837.396594] PM: Finishing wakeup.
> > [31837.396597] Restarting tasks ... done.
> > [31840.267267] r8169: eth0: link down
> >=20
> > Can you suggest how to investigate this further?
>=20
> Something like the patch made by Stanislaw at :
> https://bugzilla.redhat.com/show_bug.cgi?id=3D502974
>=20

Seems to be down at this moment, patch is also here (and included in
2.6.36-rc8 ) :

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commitdiff;h=3Daeb19f6052b5e5c8a24aa444fbff73b84341beac



