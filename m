From: huangdaode <huangdaode@hisilicon.com>
Subject: Re: [PATCH v2] net: Fix Hisilicon Network Subsystem Support Compilation
Date: Fri, 25 Sep 2015 15:55:34 +0800
Message-ID: <5604FDF6.5050604@hisilicon.com>
References: <1443163643-112192-1-git-send-email-huangdaode@hisilicon.com> <20150925.001212.866826387271637011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
	<paul.gortmaker@windriver.com>, <dingtianhong@huawei.com>,
	<zhangfei.gao@linaro.org>, <devicetree@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <salil.mehta@huawei.com>,
	<kenneth-lee-2012@foxmail.com>, <xuwei5@hisilicon.com>,
	<lisheng011@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150925.001212.866826387271637011.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/9/25 15:12, David Miller wrote:
> From: huangdaode <huangdaode@hisilicon.com>
> Date: Fri, 25 Sep 2015 14:47:23 +0800
>
>> @@ -966,7 +966,15 @@ static inline u32 dsaf_get_reg_field(void *base, u32 reg, u32 mask, u32 shift)
>>   #define dsaf_read_b(addr)\
>>   	readb((__iomem unsigned char *)(addr))
>>   
>> +#ifndef readq
>> +static inline u64 readq(void __iomem *reg)
>> +{
> Nope, try instead "#include <asm/io-64-nonatomic-lo-hi.h" or
> "#include <asm/io-64-nonatomic-hi-lo.h".
>
> .
>
yes, it's defined in #include <asm-generic/io-64-nonatomic-hi-lo.h>.
will fix in v3,
thanks
