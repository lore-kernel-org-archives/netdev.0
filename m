From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] macb: fix PHY reset
Date: Wed, 23 Mar 2016 09:54:05 +0100
Message-ID: <56F259AD.9010009@atmel.com>
References: <3349780.3Prc3uV314@wasted.cogentembedded.com>
 <56F19E2D.8000700@cogentembedded.com>
 <20160322.160738.145737905213296810.davem@redhat.com>
 <56F1BA16.9070601@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:27214 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754085AbcCWIyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 04:54:01 -0400
In-Reply-To: <56F1BA16.9070601@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/03/2016 22:33, Sergei Shtylyov a =E9crit :
> On 03/22/2016 11:07 PM, David Miller wrote:
>=20
>>> On 03/22/2016 10:27 PM, Sergei Shtylyov wrote:
>>>
>>>> The driver calls gpiod_set_value() with GPIOD_OUT_* instead of 0 a=
nd
>>>> 1, as
>>>> a result the PHY isn't really put back into reset state in
>>>> macb_remove().
>>>> Moreover, the driver assumes that something else has set the GPIO
>>>> direction
>>>> to output, so if it has not, the PHY wouldn't be taken out of rese=
t in
>>>
>>>     s/wouldn't/may not/, sorry. Do I need to resend?
>>
>> No need, I fixed it up by hand.
>>
>> Applied, thanks.
>=20
>     Oops, forgot another tag:
>=20
> Fixes: 270c499f0993 ("net/macb: Update device tree binding for resett=
ing PHY=20
> using GPIO")
>=20
>    Too late probably... :-(

Too late also:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks Sergei!

Bye,
--=20
Nicolas Ferre
