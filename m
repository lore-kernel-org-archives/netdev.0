From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: Fix internal PHY link state
Date: Thu, 18 Feb 2016 21:49:10 -0800
Message-ID: <56C6ACD6.60202@gmail.com>
References: <1455857330-18092-1-git-send-email-jaedon.shin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Petri Gynther <pgynther@google.com>, opendmb@gmail.com
To: Jaedon Shin <jaedon.shin@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33767 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757332AbcBSFtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 00:49:12 -0500
Received: by mail-pa0-f49.google.com with SMTP id fl4so44453794pad.0
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 21:49:12 -0800 (PST)
In-Reply-To: <1455857330-18092-1-git-send-email-jaedon.shin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/02/2016 20:48, Jaedon Shin a =E9crit :
> The PHY link state is not chaged in GENETv2 caused by the previous
> commit 49f7a471e4d1 ("net: bcmgenet: Properly configure PHY to ignore
> interrupt") was set to PHY_IGNORE_INTERRUPT in bcmgenet_mii_probe().
>=20
> The internal PHY should use phy_mac_interrupt() when not in use
> PHY_POLL. The statement for phy_mac_interrupt() has two conditions. T=
he
> first condition to check GENET_HAS_MDIO_INTR is not related PHY link
> state, so this patch removes it.
>=20
> Fixes: 49f7a471e4d1 ("net: bcmgenet: Properly configure PHY to ignore=
 interrupt")
> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Thanks!
--=20
=46lorian
