From: Bodo Eggert <harvested.in.lkml@posting.7eggert.dyndns.org>
Subject: Re: want to randomly drop packets based on percent
Date: Mon, 17 Apr 2006 12:45:29 +0200
Message-ID: <E1FVREs-0000bf-I1@be1.lrz>
References: <62wv1-U5-1@gated-at.bofh.it>
Reply-To: 7eggert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-in-08.arcor-online.net ([151.189.21.48]:10633 "EHLO
	mail-in-08.arcor-online.net") by vger.kernel.org with ESMTP
	id S1750748AbWDQKpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Apr 2006 06:45:55 -0400
To: George Nychis <gnychis@cmu.edu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

George Nychis <gnychis@cmu.edu> wrote:

> But then I ran into the problem of properly seeding the random number
> generator... srand(time(0)) is one way... however time() returns
> seconds, therefore i would drop multiple packets in a single second i=
f I
> used this method which is very undesirable.  What is the proper way t=
o
> generate a random number here?

You seed the random generator once, not each time you use it.

--=20
Ich danke GMX daf=FCr, die Verwendung meiner Adressen mittels per SPF
verbreiteten L=FCgen zu sabotieren.
