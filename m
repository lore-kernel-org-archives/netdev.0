From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mlx4: do not call napi_schedule() without care
Date: Mon, 16 Jan 2017 11:45:06 -0500 (EST)
Message-ID: <20170116.114506.889699414533682932.davem@davemloft.net>
References: <1484325564.13165.30.camel@edumazet-glaptop3.roam.corp.google.com>
        <352911f4-7073-ad7f-83d9-dbcc6e07d553@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
        erezsh@mellanox.com, eugenia@mellanox.com, tariqt@mellanox.com
To: ttoukan.linux@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750826AbdAPQpI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 11:45:08 -0500
In-Reply-To: <352911f4-7073-ad7f-83d9-dbcc6e07d553@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <ttoukan.linux@gmail.com>
Date: Mon, 16 Jan 2017 11:02:44 +0200

> Thanks Eric.
> 
> On 13/01/2017 6:39 PM, Eric Dumazet wrote:
>> From: Eric Dumazet <edumazet@google.com>
>>
>> Disable BH around the call to napi_schedule() to avoid following
>> warning
>>
>> [   52.095499] NOHZ: local_softirq_pending 08
>> [   52.421291] NOHZ: local_softirq_pending 08
>> [   52.608313] NOHZ: local_softirq_pending 08
>>
>> Fixes: 8d59de8f7bb3 ("net/mlx4_en: Process all completions in RX rings
>> after port goes up")
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
 ...
> Acked-by: Tariq Toukan <tariqt@mellanox.com>

Applied and queued up for -stable, thanks.
