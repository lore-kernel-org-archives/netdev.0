From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 8/9] net: dsa: bcm_sf2: Make it a real platform
 device driver
Date: Sun, 5 Jun 2016 15:30:30 -0700
Message-ID: <5754A806.9010800@gmail.com>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-13-git-send-email-f.fainelli@gmail.com>
 <20160604205532.GJ2063@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:36035 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753508AbcFEWac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 18:30:32 -0400
Received: by mail-oi0-f68.google.com with SMTP id n3so5681792oig.3
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 15:30:32 -0700 (PDT)
In-Reply-To: <20160604205532.GJ2063@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/06/2016 13:55, Andrew Lunn a =C3=A9crit :
>> -static struct dsa_switch_driver bcm_sf2_switch_driver =3D {
>> +static struct dsa_switch_driver bcm_sf2_switch_ops =3D {
>>  	.tag_protocol		=3D DSA_TAG_PROTO_BRCM,
>>  	.probe			=3D bcm_sf2_sw_drv_probe,
>>  	.setup			=3D bcm_sf2_sw_setup,
>=20
> Does this also allow you to kill bcm_sf2_sw_drv_probe?
>=20
> dsa2 will never call it, and now you have your old binding parsed by
> the legacy code in dsa2, you might not need it at all.

Good point, yes, that can go away now, thanks!
--=20
=46lorian
