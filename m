From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: Re: [PATCH net] net/mlx4_en: Fixed crash when port type is changed
Date: Sun, 16 Feb 2014 16:25:58 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1402161623240.23286@cisco.com>
References: <1383815310-19116-1-git-send-email-amirv@mellanox.com> <20131107.191418.2145129150067281446.davem@davemloft.net> <20140216100307.GA3859@mtl-eit-vdi-22.mtl.labs.mlnx>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	yevgenyp@mellanox.com, ogerlitz@mellanox.com
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-4.cisco.com ([72.163.197.28]:31307 "EHLO
	bgl-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040AbaBPKyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 05:54:39 -0500
In-Reply-To: <20140216100307.GA3859@mtl-eit-vdi-22.mtl.labs.mlnx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 16 Feb 2014, Amir Vadai wrote:

> On 07/11/13 19:14 -0500, David Miller wrote:
>> From: Amir Vadai <amirv@mellanox.com>
>> Date: Thu,  7 Nov 2013 11:08:30 +0200
>>
>>> timecounter_init() was was called only after first potential
>>> timecounter_read().
>>> Moved mlx4_en_init_timestamp() before mlx4_en_init_netdev()
>>>
>>> Signed-off-by: Amir Vadai <amirv@mellanox.com>
>>> ---
>>> Please pull into -stable for kernels >= 3.10
>>
>> Applied and queued up for -stable, thanks.
>
> Hi,
>
> I see that this patch [1] was applied to 3.10.y and 3.12.y.
> But somehow it was dropped from 3.11.y
> Please pull it there too.
>

I think 3.11 is EOL. Check https://www.kernel.org/

//govind

> Thanks,
> Amir
>
> [1] - 1ec4864 net/mlx4_en: Fixed crash when port type is changed
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
