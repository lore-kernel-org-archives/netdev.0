From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH V5 net-next 01/21] net-next/hinic: Initialize hw interface
Date: Sun, 20 Aug 2017 12:20:00 +0300
Message-ID: <a1428fb3-818d-1e93-b3c8-6aac7dea4052@huawei.com>
References: <cover.1502970631.git.aviad.krawczyk@huawei.com>
 <544e2ccb65ea083d9b736df6ea0bdd59353da815.1502970631.git.aviad.krawczyk@huawei.com>
 <20170817174540.46986450@xeon-e3>
 <20170817.220358.1098888253167010337.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <zhaochen6@huawei.com>, <tony.qu@huawei.com>
To: David Miller <davem@davemloft.net>, <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170817.220358.1098888253167010337.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We will remove all the casting from void *.

Thanks

On 8/18/2017 8:03 AM, David Miller wrote:
> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Thu, 17 Aug 2017 17:45:40 -0700
> 
>> On Thu, 17 Aug 2017 19:52:42 +0800
>> Aviad Krawczyk <aviad.krawczyk@huawei.com> wrote:
>>
>>> +	nic_dev = (struct hinic_dev *)netdev_priv(netdev);
>>
>> Since netdev_priv() returns void *, a cast is not necessary here.
> 
> Agreed.
> 
> .
> 
