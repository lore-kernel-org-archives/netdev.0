From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] bgmac: connect to PHY and make use of PHY device
Date: Fri, 6 Dec 2013 16:59:26 -0800
Message-ID: <CAGVrzcbQPugVMG7N7y4BP4d_Z2i_DLRqBPVpbqaFQhA4nbM4sQ@mail.gmail.com>
References: <1386374035-31762-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:51882 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755901Ab3LGBAH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 20:00:07 -0500
Received: by mail-pb0-f41.google.com with SMTP id jt11so2024280pbb.28
        for <netdev@vger.kernel.org>; Fri, 06 Dec 2013 17:00:07 -0800 (PST)
In-Reply-To: <1386374035-31762-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/12/6 Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>:
> We were already registering MDIO bus, but we were not connecting bgma=
c
> to the PHY. Add proper call and implement adjust link function to swi=
tch
> MAC into requested state.
> At the same time it's possible to drop our internal PHY management.
> This is a "standard" PHY, so the "Generic PHY" driver works perfectly
> fine with this. Don't duplicate the code.
> Finally make use of phy_ethtool_[gs]set functions instead implementin=
g
> them from scratch.
>
> This change was successfully tested on BCM5357. I was able to
> autonegotiate 1000Mb/s full duplex, as well as force any of the
> 10/100/1000 half/full modes.

The diffstat is really impressive, nice job!

>
> Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
--
=46lorian
