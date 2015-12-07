From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] I.MX6: Fix Ethernet PHY mode on Ventana boards
Date: Mon, 7 Dec 2015 11:08:34 -0200
Message-ID: <CAOMZO5CxaVsztHZjwEjMjF-hSaJMGZYNFv+6PVO_BuYDH09LFw@mail.gmail.com>
References: <m3egeyct8o.fsf@t19.piap.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tim Harvey <tharvey@gateworks.com>,
	netdev <netdev@vger.kernel.org>, Shawn Guo <shawnguo@kernel.org>
To: =?UTF-8?Q?Krzysztof_Ha=C5=82asa?= <khalasa@piap.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:33482 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562AbbLGNIf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 08:08:35 -0500
Received: by iouu10 with SMTP id u10so183768739iou.0
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 05:08:35 -0800 (PST)
In-Reply-To: <m3egeyct8o.fsf@t19.piap.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 7, 2015 at 10:56 AM, Krzysztof Ha=C5=82asa <khalasa@piap.pl=
> wrote:
> Gateworks Ventana boards seem to need "RGMII-ID" (internal delay)
> PHY mode, instead of simple "RGMII", for their Marvell 88E1510
> transceiver. Otherwise, the Ethernet MAC doesn't work with Marvell PH=
Y
> driver (TX doesn't seem to work correctly).
>
> Tested on GW5400 rev. C.
>
> This bug affects ARM Fedora 23.
>
> Signed-off-by: Krzysztof Ha=C5=82asa <khalasa@piap.pl>

It seems you missed to Cc the i.MX maintainer, Shawn Guo.
