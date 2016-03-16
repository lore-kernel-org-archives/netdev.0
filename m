From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 2/5] net: macb: Fix coding style warnings
Date: Wed, 16 Mar 2016 14:46:03 +0100
Message-ID: <56E9639B.7020007@atmel.com>
References: <1457896247-25934-1-git-send-email-moritz.fischer@ettus.com>
 <1457896247-25934-3-git-send-email-moritz.fischer@ettus.com>
 <56E724BB.5030600@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <joe@perches.com>, <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <moritz.fischer.private@gmail.com>
To: Michal Simek <michal.simek@xilinx.com>,
	Moritz Fischer <moritz.fischer@ettus.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56E724BB.5030600@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 14/03/2016 21:53, Michal Simek a =E9crit :
> On 13.3.2016 20:10, Moritz Fischer wrote:
>> This commit takes care of the coding style warnings
>> that are mostly due to a different comment style and
>> lines over 80 chars, as well as a dangling else.
>>
>> Signed-off-by: Moritz Fischer <moritz.fischer@ettus.com>
>> ---
>>  drivers/net/ethernet/cadence/macb.c | 101 +++++++++++++++----------=
-----------
>>  1 file changed, 43 insertions(+), 58 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ether=
net/cadence/macb.c
>> index 4370f37..c2d31c5 100644
>> --- a/drivers/net/ethernet/cadence/macb.c
>> +++ b/drivers/net/ethernet/cadence/macb.c
>> @@ -58,8 +58,7 @@
>> =20
>>  #define GEM_MTU_MIN_SIZE	68
>> =20
>> -/*
>> - * Graceful stop timeouts in us. We should allow up to
>> +/* Graceful stop timeouts in us. We should allow up to
>>   * 1 frame time (10 Mbits/s, full-duplex, ignoring collisions)
>>   */
>>  #define MACB_HALT_TIMEOUT	1230
>> @@ -127,8 +126,7 @@ static void hw_writel(struct macb *bp, int offse=
t, u32 value)
>>  	writel_relaxed(value, bp->regs + offset);
>>  }
>> =20
>> -/*
>> - * Find the CPU endianness by using the loopback bit of NCR registe=
r. When the
>> +/* Find the CPU endianness by using the loopback bit of NCR registe=
r. When the
>=20
> TBH: I would rather see this converting to kernel-doc format instead =
of
> using this networking block.

As there is hardly any kernel-doc comments in this driver, I won't forc=
e
Moritz to move this one to it.

I would advice, if someone want to move to kernel-doc for some function
comments, to do it in a separate patch (series).


> Also splitting this to more patches will be better. Just by categorie=
s
> but that's just my opinion.

Well, yes... but I won't be too picky for such a patch. So here is my:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thank for your feedback, bye,
--=20
Nicolas Ferre
