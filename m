From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont" <remi@remlab.net>
Subject: Re: tun.c non formal header protocol?
Date: Thu, 24 Feb 2011 21:04:40 +0200
Message-ID: <201102242104.40835.remi@remlab.net>
References: <AANLkTin-PJs07ruhhbC5U0DmqFd-rP8Csorethz_1kes@mail.gmail.com> <AANLkTikpkgiTRDJe0gxuXosp_uvg0gKM_c7GcvL+hhLm@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kfir Lavi <lavi.kfir@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:60312 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756107Ab1BXTEo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Feb 2011 14:04:44 -0500
In-Reply-To: <AANLkTikpkgiTRDJe0gxuXosp_uvg0gKM_c7GcvL+hhLm@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 24 f=C3=A9vrier 2011 20:37:32 Kfir Lavi, vous avez =C3=A9crit =
:
> I would like to use custom protocol over tun/tap device.

Over TAP, you can only exchange Ethernet frames. However you can use wh=
atever=20
network layer you like (so long as it has an Ethernet type associated).

Over TUN, you can exchange packets without any link layer header, for a=
ny=20
network layer protocol defined in Linux.

In principles, you can probably just use a (Ethernet) type that is not =
used by=20
any existing stack in the Linux kernel. But I don't see any point in do=
ing so,=20
as the kernel will just drop the packets on the floor afterward.

> I'm grabbing packets, and changing them, to deliver via tap,
> to a listener that knows this custom protocol.
> The custom protocol is just wrapping the packet with another
> small header.
> Is it possible to move custom packets via tun.c ?

It's difficult to say without a clearer picture what you are trying to =
do.

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.info/
http://fi.linkedin.com/in/remidenis
