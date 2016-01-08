From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: Support for non-HW interrupt devices
Date: Fri, 8 Jan 2016 12:27:02 -0800
Message-ID: <56901B96.8020606@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D40493795@CHN-SV-EXMX02.mchp-main.com>
 <20160108004238.GD4389@lunn.ch> <568F1A1B.1040808@gmail.com>
 <20160108192436.GB26321@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Woojung.Huh@microchip.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:34318 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755962AbcAHU1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 15:27:06 -0500
Received: by mail-ob0-f176.google.com with SMTP id wp13so228117387obc.1
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2016 12:27:05 -0800 (PST)
In-Reply-To: <20160108192436.GB26321@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Andrew,

Le 08/01/2016 11:24, Andrew Lunn a =C3=A9crit :
>> That seems like an elegant way to solve the problem, without adding =
code
>> in the PHY library that does not use the interrupt API, but it also
>> seems to me like there are some other potential issues associated wi=
th
>> doing that:
>=20
> Hi Florian
>=20
> I don't want to hijack this thread with DSA stuff. Plus you gave me
> some ideas for improvements :-)
>=20
> Lets come back to this in a couple of weeks once i have the DSA
> proposal patches rebased on mdio device, and i've played a bit more.

Sounds good, I will send some patches shortly which really fix the PHY
state machine not to poll PHYs configured with PHY_IGNORE_INTERRUPT and
fixing phy_mac_interrupt() to be callable in hard IRQ context (finally)=
=2E

Maybe these patches can help Woojung get what he needs for his driver.
--=20
=46lorian
