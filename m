From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: "tm->when" at /proc/net/tcp shows some negative numbers.
Date: Mon, 11 Jul 2011 19:28:20 +0200
Message-ID: <1310405300.2860.1.camel@edumazet-laptop>
References: <CAAVaN8wcu+=p9sD76s7m3=M6hqPScOsq3WPJmAN5TBp4fAoLGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andreas O <andreas2025@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44227 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758235Ab1GKR20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 13:28:26 -0400
Received: by wyg8 with SMTP id 8so2738102wyg.19
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2011 10:28:25 -0700 (PDT)
In-Reply-To: <CAAVaN8wcu+=p9sD76s7m3=M6hqPScOsq3WPJmAN5TBp4fAoLGQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 11 juillet 2011 =C3=A0 17:47 +0100, Andreas O a =C3=A9crit :
> Dear devnet list,
>=20
> I am doing some performance improvements on  linux-2.6.33.15 with
> real-time support. When my tests fails I observe that "tm->when" at
> /proc/net/tcp shows
> some negative numbers. That negative number is the difference  of
> "timer_expires - jeffies" and in this case timer_expires is smaller
> than jiffies.
> Does this negative number indicates a bug in the stack?
>=20
>=20

Not necessarly.

If the thread handling timers is delayed (because of other more urgent
RT things), the delay between timer is fired and handled could be long.


