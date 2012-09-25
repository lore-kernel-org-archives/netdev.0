From: leroy christophe <christophe.leroy@c-s.fr>
Subject: Re: [PATCH v4] lxt PHY: Support for the buggy LXT973 rev A2
Date: Tue, 25 Sep 2012 08:23:42 +0200
Message-ID: <50614DEE.9050400@c-s.fr>
References: <201209241400.q8OE0w38011790@localhost.localdomain> <20120924183035.GA2252@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David S Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120924183035.GA2252@netboy.at.omicron.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Le 24/09/2012 20:30, Richard Cochran a =E9crit :
> On Mon, Sep 24, 2012 at 04:00:58PM +0200, Christophe Leroy wrote:
>
>> diff -u a/drivers/net/phy/lxt.c b/drivers/net/phy/lxt.c
>> --- a/drivers/net/phy/lxt.c	2012-09-23 03:08:48.000000000 +0200
>> +++ b/drivers/net/phy/lxt.c	2012-09-23 03:18:00.000000000 +0200
> ...
>
>> @@ -175,6 +292,16 @@
>>   	.driver		=3D { .owner =3D THIS_MODULE,},
>>   }, {
>>   	.phy_id		=3D 0x00137a10,
>> +	.name		=3D "LXT973-A2",
>> +	.phy_id_mask	=3D 0xffffffff,
>> +	.features	=3D PHY_BASIC_FEATURES,
>> +	.flags		=3D 0,
>> +	.probe		=3D lxt973_probe,
>> +	.config_aneg	=3D lxt973_config_aneg,
>> +	.read_status	=3D lxt973a2_read_status,
> I like this way of matching the A2 chips much better than what you ha=
d
> before. But are you sure this will work correctly?
Apparently it does.
>
> What do A3 chips have in the last nibble of phy_id?

A2 chip has phy_id 0x00137a10
A3 chip has phy_id 0x00137a11

Christophe
>
>> +	.driver		=3D { .owner =3D THIS_MODULE,},
>> +}, {
>> +	.phy_id		=3D 0x00137a10,
>>   	.name		=3D "LXT973",
>>   	.phy_id_mask	=3D 0xfffffff0,
>>   	.features	=3D PHY_BASIC_FEATURES,
> Thanks,
> Richard
>
