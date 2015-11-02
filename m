From: Gilberto Bertin <gilberto.bertin@gmail.com>
Subject: Re: [BUG] Any-IP IPv6 support broken
Date: Mon, 2 Nov 2015 10:45:39 -0800
Message-ID: <C98935CD-7723-4903-A4E2-DEB98DCC5912@gmail.com>
References: <0977189F-9778-4D1C-939D-FAD71595E5F6@gmail.com> <1446132888.7476.153.camel@edumazet-glaptop2.roam.corp.google.com> <CAHo-OowqDLe1d+bJEo9B_1AC41n+RM+5Kkq7NknA-CouWoeYAQ@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 9.1 \(3096.5\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux NetDev <netdev@vger.kernel.org>
To: =?utf-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33982 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221AbbKBSpm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 13:45:42 -0500
Received: by padec8 with SMTP id ec8so46935061pad.1
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 10:45:41 -0800 (PST)
In-Reply-To: <CAHo-OowqDLe1d+bJEo9B_1AC41n+RM+5Kkq7NknA-CouWoeYAQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On 29 Oct 2015, at 17:44, Maciej =C5=BBenczykowski <zenczykowski@gmai=
l.com> wrote:
>=20
> What are you trying to do?

I would like to have a "bind-to-subnet" semantic with IPv6.

This is currently working with IPv4, and the setup is the follow:

- setup a dummy network device configured with any-IP
- add an any-IP route
- bind() on the dummy device

in this way we can effectively bind a process to a particular subnet
(by binding it to a dummy device which is receiving all the packets
from a particular subnet).

The point of using dummy devices is that we can configure multiple ones
(and so we can bind multiple processes to multiple subnets).

>=20
> Does what you're trying to do work on an older kernel?  Which kernel
> version does it break at?
>=20
> btw. afaik any-ip doesn't work with IPv4 on any un-patched kernel (th=
e
> IPv4 support patch was reverted).


This is actually working with IPv4 (as I said I'm using a recent kernel=
,
4.1), and the fact that you say it's not supposed to work leads me to
think that maybe we are not talking about the same feature.

Cheers,
	gilberto
