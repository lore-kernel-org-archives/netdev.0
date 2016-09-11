From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net 6/9] net/mlx4_core: Use RCU to perform radix tree
 lookup for SRQ
Date: Sun, 11 Sep 2016 10:27:29 +0300
Message-ID: <e0a39044-0a5e-ea0e-55c6-adc153907faf@gmail.com>
References: <1473324721-5206-1-git-send-email-tariqt@mellanox.com>
 <1473324721-5206-7-git-send-email-tariqt@mellanox.com>
 <20160908.133625.34803140270615515.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, leonro@mellanox.com
To: David Miller <davem@davemloft.net>, tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:32946 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751623AbcIKH1h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Sep 2016 03:27:37 -0400
Received: by mail-wm0-f49.google.com with SMTP id b187so1239516wme.0
        for <netdev@vger.kernel.org>; Sun, 11 Sep 2016 00:27:37 -0700 (PDT)
In-Reply-To: <20160908.133625.34803140270615515.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On 08/09/2016 11:36 PM, David Miller wrote:
> From: Tariq Toukan <tariqt@mellanox.com>
> Date: Thu,  8 Sep 2016 11:51:58 +0300
>
>> From: Leon Romanovsky <leonro@mellanox.com>
>>
>> Radix tree lookup can be performed without locking.
>>
>> Fixes: 225c7b1feef1 ("IB/mlx4: Add a driver Mellanox ConnectX InfiniBand adapters")
>> Suggested-by: Sagi Grimberg <sagi@grimberg.me>
>> Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
>> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
> Unless this fixes a bug, it isn't appropriate for 'net'.
I see, I will exclude these patches and re-submit the others.
>
> If it does fix a bug, you have to explain what that bug is and
> how this fixes it.
Thanks,
Tariq
