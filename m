From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Fix for mv643xx_eth built as module
Date: Sun, 24 Mar 2013 17:07:26 -0400 (EDT)
Message-ID: <20130324.170726.2271831814087007906.davem@davemloft.net>
References: <1364157240-28883-1-git-send-email-gmbnomis@gmail.com>
	<201303242148.33842.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gmbnomis@gmail.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	thomas.petazzoni@free-electrons.com, jason@lakedaemon.net,
	andrew@lunn.ch
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43773 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754646Ab3CXVHb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 17:07:31 -0400
In-Reply-To: <201303242148.33842.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <florian@openwrt.org>
Date: Sun, 24 Mar 2013 21:48:33 +0100

> Hello Simon,
>=20
> Le dimanche 24 mars 2013 21:33:58, Simon Baatz a =E9crit :
>> Recently [1], mv643xx_eth was changed to make use of mvmdio. However=
,
>> this change introduces two problems when mvmdio and mv643xx_eth are
>> built as modules:
>>=20
>> - mvmdio is not loaded automatically by udev
>> - mv643xx_eth oopses when it can't find its PHY, i.e. when mvmdio is
>>   not yet loaded
>>=20
>> The first problem can be fixed easily by adding a module alias for t=
he
>> respective platform device.  The proposed fix for the second problem
>> uses EPROBE_DEFER as suggested by Thomas Petazzoni when the driver
>> can't find its PHY.
>>=20
>> These patches apply on top of Florian Fainelli's patchset. They have
>> been tested on Marvel Kirkwood non-DT.
>=20
> Both fixes look good to me, thanks for fixing this!
>=20
> Acked-by: Florian Fainelli <florian@openwrt.org>

All applied, thanks.
