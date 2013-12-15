From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/8] b44: add support for external PHY
Date: Sun, 15 Dec 2013 21:26:51 +0000
Message-ID: <7394379.FK49e23POm@lenovo>
References: <1387132925-18651-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, zambrano@broadcom.com, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:35881 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914Ab3LOV06 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 16:26:58 -0500
Received: by mail-wg0-f51.google.com with SMTP id b13so3792624wgh.6
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 13:26:57 -0800 (PST)
In-Reply-To: <1387132925-18651-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Hauke,

Le dimanche 15 d=E9cembre 2013, 19:41:57 Hauke Mehrtens a =E9crit :
> This adds support for an external phy connected to the mac controlled
> by b44. This is used on home routers of the BCM47xx line where this M=
AC
> core was used and is contended to an external switch core through MII=
=2E
> These patches are in OpenWrt for some time and are tested by differen=
t
> users with different devices.

Besides my comment on patch 8, this series looks fine to me, thanks!

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

>=20
> Hauke Mehrtens (8):
>   b44: cheek register instead of PHY address to detect external PHY
>   b44: rename B44_PHY_ADDR_NO_PHY to B44_PHY_ADDR_NO_LOCAL_PHY
>   b44: abort when no PHY is available at all
>   b44: rename b44_mii_{read,write} to b44_mdio_{read,write}_mii
>   b44: add phylib support
>   b44: activate PHY when MAC is off
>   b44: do not set PHY address to 30 for every ext PHY
>   b44: add dummy PHY device if we do not find any
>=20
>  drivers/net/ethernet/broadcom/Kconfig |    1 +
>  drivers/net/ethernet/broadcom/b44.c   |  254
> ++++++++++++++++++++++++++++++--- drivers/net/ethernet/broadcom/b44.h=
   | =20
> 15 +-
>  3 files changed, 244 insertions(+), 26 deletions(-)

--=20
=46lorian
