From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Shaping TCP ACK packets
Date: Tue, 06 Dec 2011 06:59:26 +0100
Message-ID: <1323151166.2467.11.camel@edumazet-laptop>
References: <7cf7b0f6-b30f-465a-9e50-20bd2c31bbe9@jasiiieee>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:41507 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752567Ab1LFF7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 00:59:30 -0500
Received: by eeaq14 with SMTP id q14so2545077eea.19
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2011 21:59:29 -0800 (PST)
In-Reply-To: <7cf7b0f6-b30f-465a-9e50-20bd2c31bbe9@jasiiieee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 d=C3=A9cembre 2011 =C3=A0 23:18 -0500, John A. Sullivan III=
 a =C3=A9crit :
> Hello, all.  I've seen several sites recommend prioritizing TCP ACK
> packets using tc.  Is that a good idea? I have two reservations:
>=20
> 1) If my line is congested, isn't delaying ACKs a good way to slow
> down the conversation? Accelerating ACKs under congestion sounds a bi=
t
> like stuffing more food in my mouth when I'm already choking.
>=20
It depends which way is congested. Sites recommends prioritizing ACKS o=
n
the up way, because most of the time ADSL links are assymetric. an
uplink is congested.


> 2) By messing with normal coordination of TCP, do I risk making a
> mess.  Specifically, can I create problems with out of order packet
> delivery - send an ACK before the packet which should have preceded
> it? I suppose in a well behaved protocol that wouldn't happen but I'm
> not sure.  Thanks - John
> --

Well, if you prioritize true acks (packets with no payload), there is n=
o
reorder problem per se.
