From: =?UTF-8?B?RnLDqWTDqXJpYyBMZXJveQ==?= <fredo@starox.org>
Subject: Re: Realtek r8168 hangs when sending data at full speed on a gigabit
 link
Date: Mon, 02 Sep 2013 11:46:42 +0200
Message-ID: <52245E82.5020004@starox.org>
References: <5221C226.9040209@starox.org> <20130901213610.GA25211@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-34071.dedibox.fr ([88.191.154.35]:58074 "EHLO
	sd-34071.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752995Ab3IBJqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 05:46:45 -0400
In-Reply-To: <20130901213610.GA25211@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Francois,

Le 01/09/2013 23:36, Francois Romieu a =C3=A9crit :
> Fr=C3=A9d=C3=A9ric Leroy <fredo@starox.org> :
> [...]
> > For triggering the bug, I use iperf, which either works, or hangs a=
lmost
> > immediately
> > with multiple threads :
> >=20
> >         iperf -c myiperfserver -P 3 -t 60
> >=20
> > Could you help me to fix this ?
>
> Does it behave the same if you don't load the vbox modules at all ?
>

When I don't load the vbox modules, it behaves the same.

I forget to say that with an unique tcp stream, it hangs after a longer
time.
I took one capture of a hanged tcp stream.
You can find it there : http://www.starox.org/pub/linux/r8169/

Regards,

--=20
=46r=C3=A9d=C3=A9ric Leroy
