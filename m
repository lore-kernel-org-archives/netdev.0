From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [Bug 79821] New: ethernet/freescale/gianfar_ethtool.c:1584:
 possible bad expression ?
Date: Thu, 10 Jul 2014 21:37:47 -0300
Message-ID: <CAOMZO5BDzOQU62-ibYH6sL+tzMGtjXcYFUtW1YUG9eKpoF=SPw@mail.gmail.com>
References: <20140710055100.394e6a09@samsung-9>
	<20140710.170610.787241466056112359.davem@davemloft.net>
	<20140710.170704.1439211670228191396.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	sebastian.poehn@belden.com
To: David Miller <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:48294 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbaGKAht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 20:37:49 -0400
Received: by mail-lb0-f179.google.com with SMTP id z11so271501lbi.24
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 17:37:47 -0700 (PDT)
In-Reply-To: <20140710.170704.1439211670228191396.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2014 at 9:07 PM, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Thu, 10 Jul 2014 17:06:10 -0700 (PDT)
>
>> From: Stephen Hemminger <stephen@networkplumber.org>
>> Date: Thu, 10 Jul 2014 05:51:00 -0700
>>
>>> [linux-3.16-rc4/drivers/net/ethernet/freescale/gianfar_ethtool.c:1584]: (style)
>>> Same expression on both sides of '|'.
>>>
>>>     for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].ctrl);
>>
>> Probably this is meant to be:
>>
>> diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
>> index 76d7070..f697118 100644
>> --- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
>> +++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
>> @@ -1581,7 +1581,7 @@ static int gfar_write_filer_table(struct gfar_private *priv,
>>               return -EBUSY;
>>
>>       /* Fill regular entries */
>> -     for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].ctrl);
>> +     for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].prop);
>>            i++)
>>               gfar_write_filer(priv, i, tab->fe[i].ctrl, tab->fe[i].prop);
>>       /* Fill the rest with fall-troughs */
>>
>> But only a Gianfar expert can say for sure.
>>
>> Sebastian, this is your code, please help us out.
>
> Ok, we have a problem, Sebastian's email bounces.
>
> Anyone else who knows this chip can help us out?  We don't have a listed
> maintainer for Gianfar in MAINTAINERS :-/

Adding Claudiu on Cc in case he could help.
