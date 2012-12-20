From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: NAPI documentation needed
Date: Thu, 20 Dec 2012 20:39:02 +0100
Message-ID: <CACna6rzG3KcMYUpMZv-wv6e62J9j1NLuZpTRSQHLpyfTTbKyUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:43997 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751274Ab2LTTof convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 14:44:35 -0500
Received: by mail-wi0-f177.google.com with SMTP id hm2so2249949wib.4
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 11:44:33 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wanted to report some problem I've encouraged during bgmac driver dev=
elopment.

At the very beginning I've implemented IRQ using threaded IRQ
(request_threaded_irq). I didn't know about NAPI until someone pointed
me that mistake. So I decided to rewrite IRQs handling to use NAPI.
I've found following documents:
http://www.linuxfoundation.org/collaborate/workgroups/networking/napi
ftp://robur.slu.se/pub/Linux/net-development/NAPI/README
ftp://robur.slu.se/pub/Linux/net-development/NAPI/NAPI_HOWTO.txt
ftp://robur.slu.se/pub/Linux/net-development/NAPI/converting-to-NAPI.tx=
t~
but nothing really official sitting in kernel's Documentation dir.

So I started to using found documents, but then noticed they are quite =
outdated.

1) We don't have netif_rx_schedule and netif_rx_complete anymore.
2) We don't set poll and weight manually anymore but use netif_napi_add
3) Return type and arguments has changed in poll. None of the
following is up-to-date:
static void my_poll (struct net_device *dev, int *budget)
int (*poll)(struct net_device *dev, int *budget);

It would be great if someone with NAPI knowledge could document it in
a kernel. Would be really helpful for new network drivers developers.

--=20
Rafa=C5=82
