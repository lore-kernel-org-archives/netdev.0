From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvtap: fix up direction in comment on offloading
Date: Thu, 15 Aug 2013 15:39:56 -0700 (PDT)
Message-ID: <20130815.153956.753981075193965537.davem@davemloft.net>
References: <20130815174626.GA10874@redhat.com>
	<CAFeW=paTeaNsvK7ai-PPs6+MVW3LbaPaW9et_eu3XuGPpMqnuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, linux-kernel@vger.kernel.org, jasowang@redhat.com,
	edumazet@google.com, vyasevic@redhat.com, netdev@vger.kernel.org
To: kongjianjun@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFeW=paTeaNsvK7ai-PPs6+MVW3LbaPaW9et_eu3XuGPpMqnuw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amos Kong <kongjianjun@gmail.com>
Date: Fri, 16 Aug 2013 04:41:26 +0800

> On Fri, Aug 16, 2013 at 1:46 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>> It speaks about receiving frames, so while
>> it says GSO, it really means GRO.
>>
>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>> ---
>>  drivers/net/macvtap.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
>> index a98fb0e..a98ed9f 100644
>> --- a/drivers/net/macvtap.c
>> +++ b/drivers/net/macvtap.c
>> @@ -1047,7 +1047,7 @@ static int set_offload(struct macvtap_queue *q, unsigned long arg)
>>          * accept TSO frames and turning it off means that user space
>>          * does not support TSO.
>>          * For macvtap, we have to invert it to mean the same thing.
>> -        * When user space turns off TSO, we turn off GSO/LRO so that
>> +        * When user space turns off TSO, we turn off GRO/LRO so that
> 
> Right fix.
> 
> Reviewed-by: Amos Kong <kongjianjun@gmail.com>

Applied, thanks.
