From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: NAPI documentation needed
Date: Thu, 20 Dec 2012 12:04:38 -0800
Message-ID: <1356033878.21834.3163.camel@edumazet-glaptop>
References: <CACna6rzG3KcMYUpMZv-wv6e62J9j1NLuZpTRSQHLpyfTTbKyUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: =?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:45144 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009Ab2LTUEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 15:04:40 -0500
Received: by mail-da0-f54.google.com with SMTP id n2so1681859dad.13
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 12:04:40 -0800 (PST)
In-Reply-To: <CACna6rzG3KcMYUpMZv-wv6e62J9j1NLuZpTRSQHLpyfTTbKyUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-20 at 20:39 +0100, Rafa=C5=82 Mi=C5=82ecki wrote:
> I wanted to report some problem I've encouraged during bgmac driver d=
evelopment.
>=20
> At the very beginning I've implemented IRQ using threaded IRQ
> (request_threaded_irq). I didn't know about NAPI until someone pointe=
d
> me that mistake. So I decided to rewrite IRQs handling to use NAPI.
> I've found following documents:
> http://www.linuxfoundation.org/collaborate/workgroups/networking/napi
> ftp://robur.slu.se/pub/Linux/net-development/NAPI/README
> ftp://robur.slu.se/pub/Linux/net-development/NAPI/NAPI_HOWTO.txt
> ftp://robur.slu.se/pub/Linux/net-development/NAPI/converting-to-NAPI.=
txt~
> but nothing really official sitting in kernel's Documentation dir.
>=20
> So I started to using found documents, but then noticed they are quit=
e outdated.
>=20
> 1) We don't have netif_rx_schedule and netif_rx_complete anymore.
> 2) We don't set poll and weight manually anymore but use netif_napi_a=
dd
> 3) Return type and arguments has changed in poll. None of the
> following is up-to-date:
> static void my_poll (struct net_device *dev, int *budget)
> int (*poll)(struct net_device *dev, int *budget);
>=20
> It would be great if someone with NAPI knowledge could document it in
> a kernel. Would be really helpful for new network drivers developers.

I think you might be the one to update/create the official NAPI
documentation, now ideas are clear for you.

That would be really great indeed.
