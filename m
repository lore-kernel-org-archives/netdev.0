From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: any way to let host act as TCP server OR client on same
 IP/port?
Date: Wed, 13 Jul 2011 19:52:00 +0200
Message-ID: <1310579520.2509.17.camel@edumazet-laptop>
References: <4E1DC83C.3020506@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:55704 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932230Ab1GMRwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 13:52:06 -0400
Received: by wwe5 with SMTP id 5so6227046wwe.1
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 10:52:05 -0700 (PDT)
In-Reply-To: <4E1DC83C.3020506@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 13 juillet 2011 =C3=A0 10:30 -0600, Chris Friesen a =C3=A9c=
rit :
> I've been asked an interesting question about TCP.  We have some peop=
le=20
> that want to set up a TCP socket that can listen for connections on a=
=20
> given IP/port, but also initiate connections from that same IP/port.=20
> (Only one at a time, of course.)
>=20
> The TCP state machine seems to allow this (moving from LISTEN to=20
> SYN_SENT) but it's not a normal transition.
>=20
> Is there any way to do this using the socket API?
>=20
> I thought up a hack whereby we could use NFQUEUE to detect an incomin=
g=20
> SYN and delay it while we call listen() on the socket.  Is there any=20
> better way to do this?

Could you try SO_REUSEADDR, on both listener and connect attempt ?



