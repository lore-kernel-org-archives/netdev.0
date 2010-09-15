From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] ipv4: release dev refcnt early when destroying
 inetdev
Date: Wed, 15 Sep 2010 08:01:24 +0200
Message-ID: <1284530484.2271.5.camel@edumazet-laptop>
References: <1284128679.24675.38.camel@edumazet-laptop>
	 <4C8A474C.3040502@6wind.com> <1284131774.24675.46.camel@edumazet-laptop>
	 <20100914.134529.45905377.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38055 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab0IOGB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 02:01:29 -0400
Received: by wyf22 with SMTP id 22so8226189wyf.19
        for <netdev@vger.kernel.org>; Tue, 14 Sep 2010 23:01:28 -0700 (PDT)
In-Reply-To: <20100914.134529.45905377.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 septembre 2010 =C3=A0 13:45 -0700, David Miller a =C3=A9cri=
t :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 10 Sep 2010 17:16:14 +0200
>=20
> > Le vendredi 10 septembre 2010 =C3=A0 16:57 +0200, Nicolas Dichtel a=
 =C3=A9crit :
> >=20
> >> Is this not true in IPv6? What is the difference?
> >=20
> > It might be a bug on ipv6, who knows ?
> >=20
> > Releasing a reference count, but not setting idev->dev to NULL is=20
> > a sign something is wrong...
>=20
> If anything this is more of a BUG trap than a true correctness patch,
> but either way if you want me to apply this please formally submit
> this with a proper commit message and signoff, thanks!

This was not a patch for inclusion, this was to show my point.
I suspect this will trigger NULL dereference at some points later...

I do think a correct patch would be to change ipv6 to mimic ipv4 way of
course. I'll take a look at this later.

Thanks


