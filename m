From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] bnx2x: Fix link problem with some DACs
Date: Sun, 13 Jun 2010 17:52:26 -0700 (PDT)
Message-ID: <20100613.175226.104061309.davem@davemloft.net>
References: <1276429385.13056.13.camel@lb-tlvb-yanivr.il.broadcom.com>
	<4C154D5B.8000004@ans.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yanivr@broadcom.com, netdev@vger.kernel.org
To: ole@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35169
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753534Ab0FNAwP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Jun 2010 20:52:15 -0400
In-Reply-To: <4C154D5B.8000004@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Krzysztof Ol=EAdzki <ole@ans.pl>
Date: Sun, 13 Jun 2010 23:27:55 +0200

> On 2010-06-13 13:43, Yaniv Rosner wrote:
>> Change 2wire transfer rate of SFP+ module EEPROM from 400Khz to 100K=
hz
>> since some DACs(direct attached cables) do not work at 400Khz.
>>
>> Reported-by: Krzysztof Oldzki <ole@ans.pl>
>> Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
>> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>> ---
>> diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
>> index a22a7e0..9b15b64 100644
>> --- a/drivers/net/bnx2x_link.c
>> +++ b/drivers/net/bnx2x_link.c
>> @@ -4274,7 +4274,7 @@ static u8 bnx2x_ext_phy_init(struct link_param=
s
>> *params, struct link_vars *vars)
>>   				       ext_phy_addr,
>>   				       MDIO_PMA_DEVAD,
>>   				       MDIO_PMA_REG_8727_TWO_WIRE_SLAVE_ADDR,
>> -				       0xa001);
>> +				       0xa101);
>>
>>   			/* Set TX PreEmphasis if needed */
>>   			if ((params->feature_config_flags&
>=20
> Tested-by: Krzysztof Piotr Oledzki <ole@ans.pl>
>=20
> However, I believe the comment before this code should also be
> changed, because it is now: "Set 2-wire transfer rate to 400Khz since
> 100Khz
> is not operational ".

Agreed, Yaniv please update your patch.
