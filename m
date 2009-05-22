From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: sparc: struct device - replace bus_id with dev_name(),
	dev_set_name()
Date: Fri, 22 May 2009 13:42:42 +0200
Message-ID: <ac3eb2510905220442n4a1c087nba2ab54a2fba360c@mail.gmail.com>
References: <ac3eb2510903270521i113df787u7ac5d842ece83740@mail.gmail.com>
	<20090327.172743.30040617.davem@davemloft.net> <1239898912.17211.7.camel@poy>
	<20090416.155643.06066521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: greg@kroah.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:64567 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbZEVLnB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 07:43:01 -0400
In-Reply-To: <20090416.155643.06066521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2009 at 00:56, David Miller <davem@davemloft.net> wrote=
:
>>> > The name size limit is gone, there is no BUS_ID_SIZE thing anymor=
e in
>>> > the driver core. BUS_ID_SIZE should go away in the 2.6.30 timefra=
me.
>>> >
>>> > Could you please convert/remove BUS_ID_SIZE value from:
>>> > =C2=A0 drivers/net/gianfar.h: =C2=A0 char =C2=A0 =C2=A0phy_bus_id=
[BUS_ID_SIZE];
>>> > =C2=A0 drivers/net/ucc_geth.h: =C2=A0char phy_bus_id[BUS_ID_SIZE]=
;
>>> > =C2=A0 drivers/net/pasemi_mac.h: =C2=A0 =C2=A0 =C2=A0 =C2=A0char =
=C2=A0 =C2=A0phy_id[BUS_ID_SIZE];
>>> > =C2=A0 include/linux/phy.h:#define MII_BUS_ID_SIZE =C2=A0 =C2=A0 =
=C2=A0(BUS_ID_SIZE - 3)
>>> > =C2=A0 include/linux/phy.h: =C2=A0 =C2=A0 char bus_id[BUS_ID_SIZE=
];
>>> >
>>> > Or let me know how you want to convert it, so I can do it?
>>>
>>> Thanks a lot Kay, I'll look into these cases and take care
>>> of it.
>>
>> This moves the 20 into the netdevice header, we need to get rid
>> of the driver core define now, otherwise people start adding new
>> code using it, and we want to finish this thankless job finally. :)
>
> I was working on fixing this properly Kay, please be patient.
>
> I'll have it killed off in net-next-2.6 soon enough.

Hey David,
just a quick check, to make sure we are prepared when 2.6.31 opens.
Any updates regarding the BUS_ID_SIZE conversion?

Thanks,
Kay
