From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: why does skb->tstamp use getnstimeofday?
Date: Sun, 15 Jan 2012 19:56:53 +0100
Message-ID: <1326653813.5287.84.camel@edumazet-laptop>
References: <op.v74shh18fzo5me@stalin>
	 <1326645750.5287.48.camel@edumazet-laptop> <op.v74z14g2fzo5me@stalin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Anatoly Sivov <mm05@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:57489 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab2AOS47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2012 13:56:59 -0500
Received: by wibhm6 with SMTP id hm6so123142wib.19
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2012 10:56:57 -0800 (PST)
In-Reply-To: <op.v74z14g2fzo5me@stalin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 15 janvier 2012 =C3=A0 21:55 +0400, Anatoly Sivov a =C3=A9c=
rit :

> I missed that field tstamp is used for things other than RTT and can =
be =20
> even user-spaced with SO_TIMESTAMP.
> However, timekeeper speed up/slow down (due to ntp) can seriously aff=
ect =20
> some congestion avoidance algorithm quality, I guess.
> Am I wrong?

=46or what kind of application or protocol do you feel there could be a
problem ?

TCP stack doesnt use skb->tstamp/jtime_t, for example, but jiffies.

ntp adjustements are normally very small and nobody notice.
