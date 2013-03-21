From: Frank Li <lznuaa@gmail.com>
Subject: Re: [PATCH] fec: Unify fec_ptp.c and fec.c
Date: Thu, 21 Mar 2013 18:15:28 +0800
Message-ID: <CAHrpEqSKS66EK_0L-e3=kDGAAYH3uBKzs=4pkmzvrJoVZpBgyQ@mail.gmail.com>
References: <1363810268-24398-1-git-send-email-festevam@gmail.com>
	<20130321062146.GL20530@pengutronix.de>
	<CAHrpEqTd2mVaTW6pwJaHqYreDo6rT_6s_o=Z=OtU71PZzZCSVg@mail.gmail.com>
	<20130321100949.GO20530@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fabio Estevam <festevam@gmail.com>, davem@davemloft.net,
	Frank.Li@freescale.com, netdev@vger.kernel.org,
	Fabio Estevam <fabio.estevam@freescale.com>
To: =?ISO-8859-1?Q?Uwe_Kleine=2DK=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:51309 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752245Ab3CUKPa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 06:15:30 -0400
Received: by mail-wg0-f49.google.com with SMTP id gg9so1670239wgb.4
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 03:15:29 -0700 (PDT)
In-Reply-To: <20130321100949.GO20530@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/3/21 Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>:
> Hello,
>
> On Thu, Mar 21, 2013 at 06:02:02PM +0800, Frank Li wrote:
>> I suggest use below patch to fix this problem
>>
>> --- a/drivers/net/ethernet/freescale/Makefile
>> +++ b/drivers/net/ethernet/freescale/Makefile
>> @@ -2,7 +2,8 @@
>>  # Makefile for the Freescale network device drivers.
>>  #
>>
>> -obj-$(CONFIG_FEC) +=3D fec.o fec_ptp.o
>> +obj-$(CONFIG_FEC) +=3D fec_driver.o
>> +fec_driver-objs :=3D fec.o fec_ptp.o
>>  obj-$(CONFIG_FEC_MPC52xx) +=3D fec_mpc52xx.o
>>  ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
>>         obj-$(CONFIG_FEC_MPC52xx) +=3D fec_mpc52xx_phy.o
> I thought about suggesting something similar, too. I would have renam=
ed
> fec.c to (say) fec_base.c and then kept the module name fec.ko. Not s=
ure
> keeping the module name is critical.

Okay, how about rename fec.c to fec_main.c?

>
> What is missing from your patch is dropping the EXPORT_SYMBOLs. Other
> than that I like it better than using a single .c file.

There are not EXPORT_SYMBOL in my fec.c? which version do you use?

>
> Best regards
> Uwe
>
> --
> Pengutronix e.K.                           | Uwe Kleine-K=F6nig      =
      |
> Industrial Linux Solutions                 | http://www.pengutronix.d=
e/  |
