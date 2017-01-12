From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [EXT] Re: [PATCH/RFC v2 net-next] ravb: unmap descriptors when
 freeing rings
Date: Thu, 12 Jan 2017 21:00:14 +0300
Message-ID: <8d3a42b2-1883-58c9-7377-59b0673b4308@cogentembedded.com>
References: <1483613000-537-1-git-send-email-horms+renesas@verge.net.au>
 <6fcec500-bed6-ffa3-2887-d45b34703682@cogentembedded.com>
 <20170112091116.GC7724@verge.net.au>
 <d840eddd-f6a3-fe8c-dbaa-242c117b5274@marvell.com>
 <08e00682-a8da-1483-b2d8-f58d32587fd6@cogentembedded.com>
 <4950c7fd-dfe5-ea02-ba23-5477a0ba8e5e@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Lino Sanfilippo <lsanfil@marvell.com>,
        Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:35389 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750791AbdALSAS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 13:00:18 -0500
Received: by mail-lf0-f50.google.com with SMTP id m78so19065085lfg.2
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 10:00:18 -0800 (PST)
In-Reply-To: <4950c7fd-dfe5-ea02-ba23-5477a0ba8e5e@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 07:55 PM, Lino Sanfilippo wrote:

>>>>>> +
>>>>>> +    for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {
>>>
>>> BTW: How can this work correctly when cur_tx wraps and dirty_tx is greater?
>>
>>    {cur|dirty}_tx never wrap.
>>
>
> Both values are 32 bit and AFAICS they are only incremented (and never reset or
> decremented).

    Yeah, sorry, O thought you mean the TX ring size wrapping.

> So what prevents them from wrapping every 2^32 processed tx descriptors? Am I
> missing
> something?

    The math should still work all right IIUC.

> Regards,
> Lino

MBR, Sergei
