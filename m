From: =?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH] net: phy: at803x: support interrupt on 8030 and 8035
Date: Thu, 12 Nov 2015 19:09:05 +0000
Message-ID: <E36D31CC-04BA-4BE5-83C5-DE3264B617D4@mansr.com>
References: <1447350020-27969-1-git-send-email-mans@mansr.com> <5644E32F.6010104@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mason <slash.tmp@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5644E32F.6010104@free.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12 November 2015 19:06:23 GMT+00:00, Mason <slash.tmp@free.fr> wrote=
:
>On 12/11/2015 18:40, Mans Rullgard wrote:
>> Commit 77a993942 "phy/at8031: enable at8031 to work on interrupt
>mode"
>> added interrupt support for the 8031 PHY but left out the other two
>> chips supported by this driver.
>>=20
>> This patch sets the .ack_interrupt and .config_intr functions for th=
e
>> 8030 and 8035 drivers as well.
>>=20
>> Signed-off-by: Mans Rullgard <mans@mansr.com>
>> ---
>> I have only tested this with an 8035.  I can't find a datasheet for
>> the 8030, but since 8031, 8032, and 8035 all have the same register
>> layout, there's a good chance 8030 does as well.
>> ---
>>  drivers/net/phy/at803x.c | 4 ++++
>>  1 file changed, 4 insertions(+)
>>=20
>> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
>> index fabf11d..2d020a3 100644
>> --- a/drivers/net/phy/at803x.c
>> +++ b/drivers/net/phy/at803x.c
>> @@ -308,6 +308,8 @@ static struct phy_driver at803x_driver[] =3D {
>>  	.flags			=3D PHY_HAS_INTERRUPT,
>>  	.config_aneg		=3D genphy_config_aneg,
>>  	.read_status		=3D genphy_read_status,
>> +	.ack_interrupt		=3D at803x_ack_interrupt,
>> +	.config_intr		=3D at803x_config_intr,
>>  	.driver			=3D {
>>  		.owner =3D THIS_MODULE,
>>  	},
>> @@ -327,6 +329,8 @@ static struct phy_driver at803x_driver[] =3D {
>>  	.flags			=3D PHY_HAS_INTERRUPT,
>>  	.config_aneg		=3D genphy_config_aneg,
>>  	.read_status		=3D genphy_read_status,
>> +	.ack_interrupt		=3D at803x_ack_interrupt,
>> +	.config_intr		=3D at803x_config_intr,
>>  	.driver			=3D {
>>  		.owner =3D THIS_MODULE,
>>  	},
>
>Shouldn't we take the opportunity to clean up the duplicated register
>definitions? (I'll send an informal patch to spur discussion.)
>
>Regards.

That can be done independently. Feel free to send a patch.
--=20
M=C3=A5ns Rullg=C3=A5rd
