From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 0/3 v3] phy: allow flagging PHY devices as internal
Date: Fri, 24 May 2013 22:31:11 +0100
Message-ID: <201305242231.11632.f.fainelli@gmail.com>
References: <1369307473-20696-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, afleming@freescale.com, jogo@openwrt.org,
	bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:35610 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755659Ab3EXVbQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 May 2013 17:31:16 -0400
Received: by mail-wg0-f47.google.com with SMTP id e11so2929251wgh.26
        for <netdev@vger.kernel.org>; Fri, 24 May 2013 14:31:15 -0700 (PDT)
In-Reply-To: <1369307473-20696-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben,

Le jeudi 23 mai 2013 12:11:10, Florian Fainelli a =C3=A9crit :
> David, Andy,
>=20
> This small patch set updates libphy to allow PHY drivers to flag a
> specific PHY device as internal, which is then used to accurately
> report the transceiver type (internal vs external) in ethtool.

Does the first patch works for you or you do want me to be more descrip=
tive?

Thanks

>=20
> As far as I can tell we only have one in-tree driver for the moment
> which is known to be for internal PHYs.
>=20
> Florian Fainelli (3):
>   net: ethtool: disambiguate XCVR_* meaning
>   phy: allow drivers to flag a PHY device as internal
>   phy: bcm63xx: report Broadcom BCM63xx PHYs as internal
>=20
>  drivers/net/phy/bcm63xx.c    |  4 ++--
>  drivers/net/phy/phy.c        |  3 ++-
>  drivers/net/phy/phy_device.c |  3 +++
>  include/linux/phy.h          | 12 ++++++++++++
>  include/uapi/linux/ethtool.h |  4 ++--
>  5 files changed, 21 insertions(+), 5 deletions(-)

--=20
=46lorian
