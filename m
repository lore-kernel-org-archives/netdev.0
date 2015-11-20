From: Salil Mehta <salil.mehta@huawei.com>
Subject: Re: [PATCH V2 net-next 1/5] net:hns: Add support of Hip06 SoC to
 the Hislicon Network Subsystem
Date: Fri, 20 Nov 2015 14:15:09 +0000
Message-ID: <564F2AED.30906@huawei.com>
References: <1447786347-147518-1-git-send-email-salil.mehta@huawei.com>	<1447786347-147518-2-git-send-email-salil.mehta@huawei.com> <20151118.135250.2066223916643044258.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<paul.gortmaker@windriver.com>, <ijc+devicetree@hellion.org.uk>,
	<galak@codeaurora.org>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <arnd@arndb.de>, <liguozhu@hisilicon.com>,
	<yisen.zhuang@huawei.com>, <dingtianhong@huawei.com>,
	<zhangfei.gao@linaro.org>, <huangdaode@hisilicon.com>,
	<kenneth-lee-2012@foxmail.com>, <mehta.salil.lnk@gmail.com>,
	<xuwei5@hisilicon.com>, <lisheng011@huawei.com>,
	<devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <yankejian@huawei.com>,
	<lipeng321@huawei.com>, <fengguang.wu@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151118.135250.2066223916643044258.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 11/18/2015 6:52 PM, David Miller wrote:
> From: Salil <salil.mehta@huawei.com>
> Date: Wed, 18 Nov 2015 02:52:23 +0800
>
>> @@ -387,19 +409,23 @@ static void hns_rcb_ring_get_cfg(struct hnae_queue *q, int ring_type)
>>   	struct rcb_common_cb *rcb_common;
>>   	struct ring_pair_cb *ring_pair_cb;
>>   	u32 buf_size;
>> -	u16 desc_num;
>> -	int irq_idx;
>> +	u16 desc_num, mdnum_ppkt;
>> +	int irq_idx, is_ver1;
> Please use "bool" and true/false for boolean conditions like is_ver1.
>
> Please audit your entire submission for this problem.
Thanks for your time and comments. As per your suggestions, I have 
changed the data type of variable "is_ver" to "bool" where ever possible 
in the PATCH V3 floated yesterday.

Best Regards
Salil
