From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net 0/3] net: phy: Finally fix PHY_IGNORE_INTERRUPTS
Date: Wed, 20 Jan 2016 13:29:50 -0800
Message-ID: <569FFC4E.20803@gmail.com>
References: <1453174388-26752-1-git-send-email-f.fainelli@gmail.com>
 <20160119.143312.940032083335697894.davem@davemloft.net>
 <9235D6609DB808459E95D78E17F2E43D40499B30@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
	sergei.shtylyov@cogentembedded.com
To: Woojung.Huh@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f195.google.com ([209.85.214.195]:33222 "EHLO
	mail-ob0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892AbcATV3y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 16:29:54 -0500
Received: by mail-ob0-f195.google.com with SMTP id oj9so1441258obc.0
        for <netdev@vger.kernel.org>; Wed, 20 Jan 2016 13:29:54 -0800 (PST)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40499B30@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/01/2016 13:20, Woojung.Huh@microchip.com a =C3=A9crit :
>>> Targetting the "net" tree since these are bugfixes, but I would lik=
e
>>> Woojun and Andrew to take a look and test that on their respective
>>> HW setups as well.
>>
>> Ok I'll wait for Woojun and Andrew to give feedback.
>=20
> This patch fixes periodic phy read_status access when phy is configur=
ed as PHY_IGNORE_INTERRUPTS.

Great, thanks for the feedback!

> Tested and confirmed with LAN78xx USB-to-Ethernet driver except follo=
wing checkpatch.pl warnings.
>=20
> WARNING: line over 80 characters
> #54: FILE: drivers/net/phy/phy.c:1008:
> +		queue_delayed_work(system_power_efficient_wq, &phydev->state_queue=
,

This one is definitively added by the patch

>=20
> WARNING: Comparisons should place the constant on the right side of t=
he test
> #68: FILE: drivers/net/phy/phy.c:714:
> +		if (PHY_HALTED !=3D phydev->state &&
>=20

This one is an existing warning.

David, let me know if you consider the over 80 columns issue worth a
resubmission or not, either way is fine with me.

Thanks!
--=20
=46lorian
