From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V3] tun/macvtap: use consume_skb() instead of
 kfree_skb() when needed
Date: Mon, 01 Dec 2014 05:43:15 +0008
Message-ID: <1417412115.7521.2@smtp.corp.redhat.com>
References: <1417070166-7026-1-git-send-email-jasowang@redhat.com>
	<20141129.210350.1994537005887744173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141129.210350.1994537005887744173.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sun, Nov 30, 2014 at 1:03 PM, David Miller <davem@davemloft.net> 
wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Thu, 27 Nov 2014 14:36:06 +0800
> 
>>  To be more friendly with drop monitor, we should only call 
>> kfree_skb() when
>>  the packets were dropped and use consume_skb() in other cases.
>>  
>>  Cc: Eric Dumazet <eric.dumazet@gmail.com>
>>  Signed-off-by: Jason Wang <jasowang@redhat.com>
>>  ---
>>  Changes from V2:
>>  - use unlikely() when necessary
>>  Changes from V1:
>>  - check the return value of tun/macvtap_put_user()
> 
> This does not apply cleanly to net-next and will thus need to
> be respun, thanks.

Will post V3.

Thanks
