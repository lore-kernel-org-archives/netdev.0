From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: Re: [PATCH] net: hns: declare function as static
Date: Wed, 7 Sep 2016 09:47:39 +0800
Message-ID: <ad38db1d-7aae-6ade-8341-03b5e0262dab@huawei.com>
References: <1473162791-43858-1-git-send-email-wangkefeng.wang@huawei.com>
 <20160906.162056.2216637267409495822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <yisen.zhuang@huawei.com>, <yankejian@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160906.162056.2216637267409495822.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/9/7 7:20, David Miller wrote:
> From: Kefeng Wang <wangkefeng.wang@huawei.com>
> Date: Tue, 6 Sep 2016 19:53:11 +0800
> 
>> Declare function as static to kill warning about missing-prototypes.
>>
>> Cc: Yisen Zhuang <yisen.zhuang@huawei.com>
>> Cc: Kejian Yan <yankejian@huawei.com>
>> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
>  ...
>> @@ -73,7 +73,7 @@ static struct ring_pair_cb *hns_ae_get_ring_pair(struct hnae_queue *q)
>>  	return container_of(q, struct ring_pair_cb, q);
>>  }
>>  
>> -struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
>> +static struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
>>  				      u32 port_id)
> 
> You have to adjust the indentation of the arguments on the following lines
> if you change where the openning parenthesis is.  They must start exactly
> at the column folling that openning parenthesis.

Hi David,

Talked with Yisen, please ignore it for now, will resend it after some hns/roce functional changes.

Thanks,
Kefeng



> 
> 
> .
> 
