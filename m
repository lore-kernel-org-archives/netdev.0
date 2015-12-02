From: Salil Mehta <salil.mehta@huawei.com>
Subject: Re: [PATCH V5 net-next 1/5] net:hns: Add support of Hip06 SoC to
 the Hislicon Network Subsystem
Date: Wed, 2 Dec 2015 17:02:08 +0000
Message-ID: <565F2410.9040607@huawei.com>
References: <1448522050-5576-1-git-send-email-salil.mehta@huawei.com>	<1448522050-5576-2-git-send-email-salil.mehta@huawei.com> <20151130.145057.216796732457000987.davem@davemloft.net>
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
In-Reply-To: <20151130.145057.216796732457000987.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 11/30/2015 7:50 PM, David Miller wrote:
> From: Salil Mehta <salil.mehta@huawei.com>
> Date: Thu, 26 Nov 2015 07:14:06 +0000
>
>> -#define ENABLE		(0x1)
>> -#define DISABLE		(0x0)
>> +#define ENABLE		0x1
>> +#define DISABLE		0x0
> Defining such common macros names for such incredibly simple boolean values
> is asking for trouble, in particular it can possibly collide with other
> defines in the global namespace.
>
> Use "true", "false", and the "bool" type, because that is exactly how you
> are using these values.
>
> Thanks.
Hi David,
Thanks for your suggestions. I have worked upon the comments and removed 
these macros
and introduced the 'bool' type here as well. I think I missed this in my 
earlier rework. Thanks
again for pointing it out. I have floated new V6 patch for your 
consideration.

Best Regards
Salil
>
