From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net/macb: add config for Atmel sama5d2 SoCs
Date: Thu, 18 Jun 2015 16:22:44 +0200
Message-ID: <5582D434.7030906@atmel.com>
References: <1434622699-2689-1-git-send-email-nicolas.ferre@atmel.com> <20150618133022.GD27492@piout.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-arm-kernel@lists.infradead.org>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:19676 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293AbbFROXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 10:23:46 -0400
In-Reply-To: <20150618133022.GD27492@piout.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/06/2015 15:30, Alexandre Belloni a =E9crit :
> On 18/06/2015 at 12:18:19 +0200, Nicolas Ferre wrote :
>> From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
>>
>> Add the compatible string for Atmel sama5d2 SoC family as the config=
uration
>> options differ from other instances of the GEM.
>>
>> Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
>> ---
>>  drivers/net/ethernet/cadence/macb.c | 8 ++++++++
>>  1 file changed, 8 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ether=
net/cadence/macb.c
>> index 740d04fd2223..caeb39561567 100644
>> --- a/drivers/net/ethernet/cadence/macb.c
>> +++ b/drivers/net/ethernet/cadence/macb.c
>> @@ -2713,6 +2713,13 @@ static const struct macb_config pc302gem_conf=
ig =3D {
>>  	.init =3D macb_init,
>>  };
>> =20
>> +static const struct macb_config sama5d2_config =3D {
>> +	.caps =3D 0,
>> +	.dma_burst_length =3D 16,
>> +	.clk_init =3D macb_clk_init,
>> +	.init =3D macb_init,
>> +};
>> +
>>  static const struct macb_config sama5d3_config =3D {
>>  	.caps =3D MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE=
,
>>  	.dma_burst_length =3D 16,
>> @@ -2756,6 +2763,7 @@ static const struct of_device_id macb_dt_ids[]=
 =3D {
>>  	{ .compatible =3D "cdns,macb" },
>>  	{ .compatible =3D "cdns,pc302-gem", .data =3D &pc302gem_config },
>>  	{ .compatible =3D "cdns,gem", .data =3D &pc302gem_config },
>> +	{ .compatible =3D "atmel,sama5d2-gem", .data =3D &sama5d2_config }=
,
>=20
> This compatible has to be documented

Sure, I re-send a series right now (and add some documentation fixes).

Thanks, bye,

>=20
>>  	{ .compatible =3D "atmel,sama5d3-gem", .data =3D &sama5d3_config }=
,
>>  	{ .compatible =3D "atmel,sama5d4-gem", .data =3D &sama5d4_config }=
,
>>  	{ .compatible =3D "cdns,at91rm9200-emac", .data =3D &emac_config }=
,
>> --=20
>> 2.1.3
>>
>=20


--=20
Nicolas Ferre
