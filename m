From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next] mlx4: do not use rwlock in fast path
Date: Wed, 15 Feb 2017 11:51:23 +0200
Message-ID: <540a3fdc-0fc1-6da0-18cf-591e00566001@gmail.com>
References: <1486660204.7793.104.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170214.112851.873582209944615021.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com,
        sbohrer@rgmadvisors.com
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36289 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750817AbdBOJvm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 04:51:42 -0500
Received: by mail-wr0-f193.google.com with SMTP id k90so30403247wrc.3
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2017 01:51:36 -0800 (PST)
In-Reply-To: <20170214.112851.873582209944615021.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 14/02/2017 6:28 PM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 09 Feb 2017 09:10:04 -0800
>
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Using a reader-writer lock in fast path is silly, when we can
>> instead use RCU or a seqlock.
>>
>> For mlx4 hwstamp clock, a seqlock is the way to go, removing
>> two atomic operations and false sharing.
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Cc: Tariq Toukan <tariqt@mellanox.com>
> Tariq or someone else at Mellanox please review, this patch has been
> rotting for 5 days in patchwork.
>
> Thank you.
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
Thanks.
