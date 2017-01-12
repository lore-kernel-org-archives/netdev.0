From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v2 net-next] ravb: unmap descriptors when freeing
 rings
Date: Thu, 12 Jan 2017 19:37:06 +0300
Message-ID: <08e00682-a8da-1483-b2d8-f58d32587fd6@cogentembedded.com>
References: <1483613000-537-1-git-send-email-horms+renesas@verge.net.au>
 <6fcec500-bed6-ffa3-2887-d45b34703682@cogentembedded.com>
 <20170112091116.GC7724@verge.net.au>
 <d840eddd-f6a3-fe8c-dbaa-242c117b5274@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org
To: Lino Sanfilippo <lsanfil@marvell.com>,
        Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f49.google.com ([209.85.215.49]:32825 "EHLO
        mail-lf0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750945AbdALQhK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 11:37:10 -0500
Received: by mail-lf0-f49.google.com with SMTP id k86so17107887lfi.0
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 08:37:10 -0800 (PST)
In-Reply-To: <d840eddd-f6a3-fe8c-dbaa-242c117b5274@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2017 04:23 PM, Lino Sanfilippo wrote:

>>>> +
>>>> +    for (; priv->cur_tx[q] - priv->dirty_tx[q] > 0; priv->dirty_tx[q]++) {
>
> BTW: How can this work correctly when cur_tx wraps and dirty_tx is greater?

    {cur|dirty}_tx never wrap.

> Regards,
> Lino

MBR, Sergei
