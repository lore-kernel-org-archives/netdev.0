From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 1/2] net: macb: Include multi queue support for xilinx
 ZynqMP ethernet version
Date: Fri, 6 Mar 2015 17:48:49 +0100
Message-ID: <54F9DA71.804@atmel.com>
References: <c4d6dd80406da35180f2f4fc163b1c7fc526d92a.1425560649.git.michal.simek@xilinx.com> <54F86171.3020700@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>,
	<netdev@vger.kernel.org>
To: <monstr@monstr.eu>, Michal Simek <michal.simek@xilinx.com>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F86171.3020700@monstr.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 05/03/2015 15:00, Michal Simek a =E9crit :
> Hi Nicolas,
>=20
> On 03/05/2015 02:04 PM, Michal Simek wrote:
>> From: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.co=
m>
>>
>> Include multi queue support for the ethernet IP version in xilinx Zy=
nqMP
>> SoC.
>>
>> Signed-off-by: Punnaiah Choudary Kalluri <punnaia@xilinx.com>
>> Signed-off-by: Michal Simek <michal.simek@xilinx.com>
>> ---
>>
>>  drivers/net/ethernet/cadence/macb.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ether=
net/cadence/macb.c
>> index ad76b8e35a00..24b1eb466e52 100644
>> --- a/drivers/net/ethernet/cadence/macb.c
>> +++ b/drivers/net/ethernet/cadence/macb.c
>> @@ -2192,7 +2192,7 @@ static void macb_probe_queues(void __iomem *me=
m,
>> =20
>>  	/* is it macb or gem ? */
>>  	mid =3D __raw_readl(mem + MACB_MID);
>> -	if (MACB_BFEXT(IDNUM, mid) !=3D 0x2)
>> +	if (MACB_BFEXT(IDNUM, mid) < 0x2)
>>  		return;
>> =20
>>  	/* bit 0 is never set but queue 0 always exists */
>>
>=20
> Can you please check this?
> (There will be definitely v2 because I forget to base it on net-next)=
=2E

Michal,

It seems correct to me: you can add my:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Bye,
--=20
Nicolas Ferre
