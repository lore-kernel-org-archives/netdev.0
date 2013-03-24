From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 0/2] Fix for mv643xx_eth built as module
Date: Sun, 24 Mar 2013 21:48:33 +0100
Message-ID: <201303242148.33842.florian@openwrt.org>
References: <1364157240-28883-1-git-send-email-gmbnomis@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, thomas.petazzoni@free-electrons.com,
	jason@lakedaemon.net, andrew@lunn.ch, davem@davemloft.net
To: Simon Baatz <gmbnomis@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:51164 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754135Ab3CXUsi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 16:48:38 -0400
Received: by mail-we0-f173.google.com with SMTP id t57so419303wey.32
        for <netdev@vger.kernel.org>; Sun, 24 Mar 2013 13:48:37 -0700 (PDT)
In-Reply-To: <1364157240-28883-1-git-send-email-gmbnomis@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Simon,

Le dimanche 24 mars 2013 21:33:58, Simon Baatz a =C3=A9crit :
> Recently [1], mv643xx_eth was changed to make use of mvmdio. However,
> this change introduces two problems when mvmdio and mv643xx_eth are
> built as modules:
>=20
> - mvmdio is not loaded automatically by udev
> - mv643xx_eth oopses when it can't find its PHY, i.e. when mvmdio is
>   not yet loaded
>=20
> The first problem can be fixed easily by adding a module alias for th=
e
> respective platform device.  The proposed fix for the second problem
> uses EPROBE_DEFER as suggested by Thomas Petazzoni when the driver
> can't find its PHY.
>=20
> These patches apply on top of Florian Fainelli's patchset. They have
> been tested on Marvel Kirkwood non-DT.

Both fixes look good to me, thanks for fixing this!

Acked-by: Florian Fainelli <florian@openwrt.org>
--=20
=46lorian
