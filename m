From: Jason Wang <jasowang@redhat.com>
Subject: Re: [V2 PATCH] net: sock: validate data_len before allocating skb
 in sock_alloc_send_pskb()
Date: Fri, 01 Jun 2012 11:09:43 +0800
Message-ID: <4FC83277.2090301@redhat.com>
References: <20120531071809.6392.26677.stgit@amd-6168-8-1.englab.nay.redhat.com> <20120531.182145.119572313886189417.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, mst@redhat.com,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120531.182145.119572313886189417.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/01/2012 06:21 AM, David Miller wrote:
> From: Jason Wang<jasowang@redhat.com>
> Date: Thu, 31 May 2012 15:18:10 +0800
>
>> We need to validate the number of pages consumed by data_len, otherwise frags
>> array could be overflowed by userspace. So this patch validate data_len and
>> return -EMSGSIZE when data_len may occupies more frags than MAX_SKB_FRAGS.
>>
>> Signed-off-by: Jason Wang<jasowang@redhat.com>
> Applied and queued up for -stable.
>
> Please do not add explicit stable CC:'s to networking patches, I queue
> appropriate changes up myself, and submit them only when I feel that
> the change has had sufficient exposure and testing in Linus's tree.

Sure, would pay attention next time.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
