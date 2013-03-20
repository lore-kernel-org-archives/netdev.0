From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] fec: Fix the build as module
Date: Wed, 20 Mar 2013 16:27:44 -0300
Message-ID: <CAOMZO5C+rYXy5uN2Nq0E6ikodDa=HgdUSNNhu02q=hdmRWDqKg@mail.gmail.com>
References: <1363803572-17039-1-git-send-email-festevam@gmail.com>
	<20130320191630.GJ20530@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Frank.Li@freescale.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: =?UTF-8?Q?Uwe_Kleine=2DK=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f174.google.com ([209.85.128.174]:48404 "EHLO
	mail-ve0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753605Ab3CTT1r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 15:27:47 -0400
Received: by mail-ve0-f174.google.com with SMTP id pb11so1742647veb.5
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 12:27:47 -0700 (PDT)
In-Reply-To: <20130320191630.GJ20530@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 20, 2013 at 4:16 PM, Uwe Kleine-K=C3=B6nig
<u.kleine-koenig@pengutronix.de> wrote:
> Hello,
>
> On Wed, Mar 20, 2013 at 03:19:32PM -0300, Fabio Estevam wrote:
>> From: Fabio Estevam <fabio.estevam@freescale.com>
>>
>> Since commit ff43da86c69 (NET: FEC: dynamtic check DMA desc buff typ=
e) the
>> following build error happens when CONFIG_FEC=3Dm
>>
>> ERROR: "fec_ptp_init" [drivers/net/ethernet/freescale/fec.ko] undefi=
ned!
>> ERROR: "fec_ptp_ioctl" [drivers/net/ethernet/freescale/fec.ko] undef=
ined!
>> ERROR: "fec_ptp_start_cyclecounter" [drivers/net/ethernet/freescale/=
fec.ko] undefined!
>>
>> Fix it by exporting the required fec_ptp symbols.
> IMHO this is not sensible. There is no need to make the fec driver 2
> modules. Just loading one is impossible (fec.ko) or useless
> (fec_ptp.ko). That's why I suggested to make them a single module.

Ok, I wil do as you suggested on a subsequent patch.

Regards,

=46abio Estevam
