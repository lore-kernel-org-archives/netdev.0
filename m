From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC] ixp4xx_eth: Allow setting the MDIO bus name in
 platform data
Date: Mon, 24 Mar 2014 13:42:29 -0700
Message-ID: <CAGVrzcaJ5LKE_HAvsmbnFxYsLbNwi9h9UYrz60AQ3z4DOZKwYw@mail.gmail.com>
References: <20140324151729.1b8e3bb5@marrow.netinsight.se> <m3r45r72u9.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?U2ltb24gS8OlZ3N0csO2bQ==?=
	<simon.kagstrom@netinsight.net>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Arnd Bergmann <arnd@arndb.de>, netdev <netdev@vger.kernel.org>,
	"arm@kernel.org" <arm@kernel.org>,
	David Miller <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:59368 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862AbaCXUnK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 16:43:10 -0400
Received: by mail-pb0-f54.google.com with SMTP id ma3so6021060pbc.27
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 13:43:09 -0700 (PDT)
In-Reply-To: <m3r45r72u9.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-24 13:34 GMT-07:00 Krzysztof Halasa <khc@pm.waw.pl>:
> Simon K=C3=A5gstr=C3=B6m <simon.kagstrom@netinsight.net> writes:
>
>> Allows using e.g., a fixed MDIO bus with the ixp4xx_eth driver.
>> Example:
>>
>>   static struct eth_plat_info board_plat_eth_internal[] =3D {
>>       {
>>               .mdio_bus_id    =3D "fixed-0",
>>               .phy            =3D 31,
>>               .rxq            =3D 4,
>>               .txreadyq       =3D 21,
>>               .hwaddr         =3D {0x02, 0x00, 0x00, 0x00, 0x00, 0x0=
0},
>>       }
>>   };
>
> Why do we need it? I'm not sure I know what constitutes a "fixed MDIO
> bus".

This is a software emulation MDIO bus for when your Ethernet MAC is
connected to a PHY which does not appear on the MDIO bus. This is
typically used to provide the Ethernet driver with a link that is
always seen as UP, when you cannot directly query it via MDIO/MDC.
--=20
=46lorian
