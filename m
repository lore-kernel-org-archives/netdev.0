From: Zhi Li <lznuaa@gmail.com>
Subject: Re: [PATCH] MAINTAINERS: add maintainer entry for FREESCALE FEC
 ethernet driver
Date: Wed, 2 Mar 2016 14:22:22 -0600
Message-ID: <CAHrpEqSF-WMO6r5_Cn_HBo-idDstWw5OfaHc11D5_3yRL=jJNQ@mail.gmail.com>
References: <1456910693-25787-1-git-send-email-b38611@freescale.com>
	<VI1PR0401MB18552E858B53A8C92A73F733FFBC0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "b38611@freescale.com" <b38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Fugang Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:35263 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754590AbcCBUWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 15:22:23 -0500
Received: by mail-ob0-f174.google.com with SMTP id xx9so272047obc.2
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2016 12:22:22 -0800 (PST)
In-Reply-To: <VI1PR0401MB18552E858B53A8C92A73F733FFBC0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 2, 2016 at 3:38 AM, Fugang Duan <fugang.duan@nxp.com> wrote:
> From: Fugang Duan <b38611@freescale.com> Sent: Wednesday, March 02, 2016 5:25 PM
>> To: davem@davemloft.net
>> Cc: netdev@vger.kernel.org; Fugang Duan <fugang.duan@nxp.com>
>> Subject: [PATCH] MAINTAINERS: add maintainer entry for FREESCALE FEC
>> ethernet driver
>>
>> Add a maintainer entry for FREESCALE FEC ethernet driver and add myself as a
>> maintainer.
>>
>> Signed-off-by: Fugang Duan <fugang.duan@nxp.com>
>> ---
>
> Hi David,
>
> Recently, there have many fec Ethernet driver patches sent out review, to avoid introducing impact on fec driver stable for all i.MX platforms, I request to add myself as the driver maintainer for helping patch review.
> Current the driver supports FEC and ENET controllers, support HW PTP for i.MX25/i.MX50/i.MX51/i.MX53/i.MX6x/i.MX7x/i.MX8x...    There have some feature extensions in later chips.
> It is more convenient for us to test reviewing patches.

We are glad about that many contributor is interesting this driver and
contribute many works.
But we also found some fec driver quality regression.

I hope get Andy's ACK before merge into your tree.

best regards
Frank Li

>
> Regards,
> Andy
>
>>  MAINTAINERS | 9 +++++++++
>>  1 file changed, 9 insertions(+)
>>
>> diff --git a/MAINTAINERS b/MAINTAINERS
>> index 0499f9e..4d4b18f 100644
>> --- a/MAINTAINERS
>> +++ b/MAINTAINERS
>> @@ -4552,6 +4552,15 @@ S:     Maintained
>>  F:   drivers/net/ethernet/freescale/fs_enet/
>>  F:   include/linux/fs_enet_pd.h
>>
>> +FREESCALE IMX / MXC FEC DRIVER
>> +M:   Fugang Duan <fugang.duan@nxp.com>
>> +L:   netdev@vger.kernel.org
>> +S:   Maintained
>> +F:   drivers/net/ethernet/freescale/fec_main.c
>> +F:   drivers/net/ethernet/freescale/fec_ptp.c
>> +F:   drivers/net/ethernet/freescale/fec.h
>> +F:   Documentation/devicetree/bindings/net/fsl-fec.txt
>> +
>>  FREESCALE QUICC ENGINE LIBRARY
>>  L:   linuxppc-dev@lists.ozlabs.org
>>  S:   Orphan
>> --
>> 1.9.1
