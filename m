From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tg3: Fix advertisement handling
Date: Mon, 21 Nov 2011 07:38:13 +0100
Message-ID: <1321857493.17419.5.camel@edumazet-laptop>
References: <20111121080720.0e68f096.shimoda.hiroaki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org
To: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49143 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256Ab1KUGiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 01:38:16 -0500
Received: by wwe5 with SMTP id 5so9917608wwe.1
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2011 22:38:15 -0800 (PST)
In-Reply-To: <20111121080720.0e68f096.shimoda.hiroaki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 novembre 2011 =C3=A0 08:07 +0900, Hiroaki SHIMODA a =C3=A9c=
rit :
> Commit 28011cf19b (net: Add ethtool to mii advertisment conversion
> helpers) added a helper function ethtool_adv_to_mii_100bt() and
> tg3_copper_is_advertising_all(), tg3_phy_autoneg_cfg() were
> modified to use this.
> Before that commit, ethtool to mii advertisement conversion was
> done wrt speed, but now pause operation is also taken account.
> So, in tg3_copper_is_advertising_all(), below condition becomes
> true and this makes link up fails.
>=20
> 	if ((adv_reg & ADVERTISE_ALL) !=3D all_mask)
> 		return 0;
>=20
> To fix this add ADVERTISE_ALL bit and operation to cap speed.
>=20
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

Reported-and-tested-by: Eric Dumazet <eric.dumazet@gmail.com>


Thanks a lot !
