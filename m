From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH V2 net-next 12/21] net-next/hinic: Add qp resources
Date: Sun, 23 Jul 2017 13:07:29 +0300
Message-ID: <c3ca84a0-2e38-bd80-f513-45db5e6ae92b@huawei.com>
References: <cover.1500454998.git.aviad.krawczyk@huawei.com>
 <493b105a36b5ddcf3570ed165aedfb4d6517ee6e.1500454998.git.aviad.krawczyk@huawei.com>
 <20170719.161316.2138496537830668352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <zhaochen6@huawei.com>, <tony.qu@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170719.161316.2138496537830668352.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Strange that checkpatch.pl --strict didn't warn about it.
We will fix it.

Thanks for review,
Aviad

On 7/20/2017 2:13 AM, David Miller wrote:
> From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
> Date: Wed, 19 Jul 2017 17:19:10 +0800
> 
>> diff --git a/drivers/net/ethernet/huawei/hinic/Makefile b/drivers/net/ethernet/huawei/hinic/Makefile
>> index 519382b..24728f0 100644
>> --- a/drivers/net/ethernet/huawei/hinic/Makefile
>> +++ b/drivers/net/ethernet/huawei/hinic/Makefile
>> @@ -1,5 +1,5 @@
>>  obj-$(CONFIG_HINIC) += hinic.o
>>  
>>  hinic-y := hinic_main.o hinic_tx.o hinic_rx.o hinic_port.o hinic_hw_dev.o \
>> -	   hinic_hw_io.o hinic_hw_wq.o hinic_hw_mgmt.o hinic_hw_api_cmd.o \
>> -	   hinic_hw_eqs.o hinic_hw_if.o
>> \ No newline at end of file
>> +	   hinic_hw_io.o hinic_hw_qp.o hinic_hw_wq.o hinic_hw_mgmt.o \
>> +	   hinic_hw_api_cmd.o hinic_hw_eqs.o hinic_hw_if.o
>> \ No newline at end of file
> 
> Please add the missing newline to the end of this Makefile so that these patches
> don't keep emitting this message.
> 
> .
> 
