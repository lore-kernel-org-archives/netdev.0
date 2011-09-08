From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] interface for outgoing packet
Date: Thu, 08 Sep 2011 08:09:05 +0200
Message-ID: <1315462145.2532.10.camel@edumazet-laptop>
References: <CANX6DanC8DJsAZj4dV3oZo3DnLV6AyxBDm82vHaJm3C51aRqEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Viral Mehta <viral.vkm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:41909 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757994Ab1IHGJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2011 02:09:10 -0400
Received: by wwe5 with SMTP id 5so251689wwe.1
        for <netdev@vger.kernel.org>; Wed, 07 Sep 2011 23:09:09 -0700 (PDT)
In-Reply-To: <CANX6DanC8DJsAZj4dV3oZo3DnLV6AyxBDm82vHaJm3C51aRqEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 07 septembre 2011 =C3=A0 20:24 -0400, Viral Mehta a =C3=A9c=
rit :
> Hi All,
>=20
> How reasonably I can assume that,
>=20
> on whatever interface, I received the last packet
> for a particular Socket Connection, the same interface will be
> used to SEND the next packet for same socket connection?
>=20

No

> I am collecting the logs on one of my test machines.
> And it shows, I can assume all the time that "interface" which receiv=
ed packet
> for some socket connection, the same will be used to send packet for
> that connection
>=20
> But, I am not sure if I am missing some scenarios
> or setup (for e.g., bonding) where it can be wrong ?
>=20
> It would be more help if some one can shed some light.

By default, a socket is not bound to one interface, so you cant assume
this.

Check SO_BINDTODEVICE socket option if you need it.
