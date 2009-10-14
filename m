From: Massimo Cetra <mcetra@navynet.it>
Subject: Re: [Bug #14378] Problems with net/core/skbuff.c
Date: Wed, 14 Oct 2009 21:27:34 +0200
Message-ID: <4AD62626.6010709@navynet.it>
References: <zJ_pXHNwoHC.A.akB.Aal0KB@chimera>	<r-4Wjt4coy.A.CwC.Wal0KB@chimera> <20091012.034224.64980795.davem@davemloft.net> <4AD44435.3050703@navynet.it> <4AD45447.7030705@gmail.com> <4AD455E4.2070105@navynet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Massimo Cetra <ctrixk@navynet.it>,
	David Miller <davem@davemloft.net>, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758976AbZJNT2W@vger.kernel.org>
In-Reply-To: <4AD455E4.2070105@navynet.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Massimo Cetra ha scritto:
> Eric Dumazet ha scritto:
>> Could you please following patch ?
>>
>> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
>> index 8d00976..54bf091 100644
>> --- a/drivers/net/virtio_net.c
>> +++ b/drivers/net/virtio_net.c
>> @@ -454,7 +454,7 @@ static unsigned int free_old_xmit_skbs(struct 
>> virtnet_info *vi)
>>          vi->dev->stats.tx_bytes += skb->len;
>>          vi->dev->stats.tx_packets++;
>>          tot_sgs += skb_vnet_hdr(skb)->num_sg;
>> -        kfree_skb(skb);
>> +        dev_kfree_skb_any(skb);
>>      }
>>      return tot_sgs;
>>  }
>>
>>
>>   
> Thank you very much.
>
> Compiling.
> It' will be in production in a few minutes.
> I'll let you know if the problem arises again.
> give me a couple of days because this problem is randomly triggered.
> Sometimes it happens multiple times a day, sometimes none.
>
Eric,
thanks for the patch.
The problem didn't arise again and i haven't seen any warning like that 
on both servers where that problem was happening more frequently.

I would say that it's fixed and if it's not, i'll let you know as soon 
as it happens again.

Thanks again,
Max
