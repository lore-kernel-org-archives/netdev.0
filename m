From: Keerthy <j-keerthy@ti.com>
Subject: Re: [PATCH] net: netcp: correct netcp_get_stats function signature
Date: Wed, 11 Jan 2017 08:58:33 +0530
Message-ID: <63403509-0dc6-42f3-4b77-897645d0cc71@ti.com>
References: <1484047585-16733-1-git-send-email-j-keerthy@ti.com>
 <20170110.115213.1856085394233309828.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <w-kwok2@ti.com>, <m-karicheri2@ti.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <stephen@networkplumber.org>,
        <m-scherban@ti.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170110.115213.1856085394233309828.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tuesday 10 January 2017 10:22 PM, David Miller wrote:
> From: Keerthy <j-keerthy@ti.com>
> Date: Tue, 10 Jan 2017 16:56:25 +0530
>
>> @@ -1909,7 +1909,7 @@ static int netcp_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
>>  	return 0;
>>  }
>>
>> -static struct rtnl_link_stats64 *
>> +void
>>  netcp_get_stats(struct net_device *ndev, struct rtnl_link_stats64 *stats)
>
> Please do not remove the static qualifier.

Sure. I will add that back.

>
