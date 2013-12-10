From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bgmac: connect to PHY and make use of PHY device
Date: Mon, 09 Dec 2013 20:59:47 -0500 (EST)
Message-ID: <20131209.205947.2139145054909970576.davem@davemloft.net>
References: <1386374035-31762-1-git-send-email-zajec5@gmail.com>
	<CAGVrzcbQPugVMG7N7y4BP4d_Z2i_DLRqBPVpbqaFQhA4nbM4sQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: zajec5@gmail.com, netdev@vger.kernel.org, hauke@hauke-m.de
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45039 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab3LJB7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 20:59:49 -0500
In-Reply-To: <CAGVrzcbQPugVMG7N7y4BP4d_Z2i_DLRqBPVpbqaFQhA4nbM4sQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 6 Dec 2013 16:59:26 -0800

> 2013/12/6 Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>:
>> We were already registering MDIO bus, but we were not connecting bgm=
ac
>> to the PHY. Add proper call and implement adjust link function to sw=
itch
>> MAC into requested state.
>> At the same time it's possible to drop our internal PHY management.
>> This is a "standard" PHY, so the "Generic PHY" driver works perfectl=
y
>> fine with this. Don't duplicate the code.
>> Finally make use of phy_ethtool_[gs]set functions instead implementi=
ng
>> them from scratch.
>>
>> This change was successfully tested on BCM5357. I was able to
>> autonegotiate 1000Mb/s full duplex, as well as force any of the
>> 10/100/1000 half/full modes.
>=20
> The diffstat is really impressive, nice job!
>=20
>>
>> Signed-off-by: Rafa=A9=A9 Mi=A9=A9ecki <zajec5@gmail.com>
>=20
> Acked-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks everyone.
