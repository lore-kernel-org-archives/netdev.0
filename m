From: Salil Mehta <salil.mehta@huawei.com>
Subject: Re: [PATCH V3 net-next 2/5] net:hns: Add Hip06 "RSS(Receive Side
 Scaling)" support to HNS Driver
Date: Thu, 26 Nov 2015 07:31:07 +0000
Message-ID: <5656B53B.3080205__18907.9035576016$1448523188$gmane$org@huawei.com>
References: <1447966706-16219-1-git-send-email-salil.mehta@huawei.com> <1447966706-16219-3-git-send-email-salil.mehta@huawei.com> <CO2PR11MB0088B852596B9F86F7BDCF6F97180@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	David Miller <davem@davemloft.net>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"paul.gortmaker@windriver.com" <paul.gortmaker@windriver.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"catalin.marinas@arm.com" <catalin.marinas@arm.com>,
	"will.deacon@arm.com" <will.deacon@arm.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"liguozhu@hisilicon.com" <liguozhu@hisilicon.com>,
	"yisen.zhuang@huawei.com" <yisen.zhuang@huawei.com>,
	"dingtianhong@huawei.com" <dingtianhong@huawei.com>,
	"zhangfei.gao@linaro.org" <zhangfei.gao@linaro.org>,
	"huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
	"kenneth-lee-2012@foxmail.com" <kenneth-lee-2012@foxmail.com>,
	"mehta.salil.lnk@gmail.com" <mehta.sal
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:56224 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbbKZHc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 02:32:29 -0500
In-Reply-To: <CO2PR11MB0088B852596B9F86F7BDCF6F97180@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 11/22/2015 9:30 AM, Yuval Mintz wrote:
>>   static void hns_ppe_init_hw(struct hns_ppe_cb *ppe_cb)  {
> ...
>> +	/* Set default RSS key and indrection table*/
>> +	const u32 rss_key[HNS_PPEV2_RSS_KEY_NUM] = {
>> +		0x6d5a56da, 0x255b0ec2,
>> +		0x4167253d, 0x43a38fb0,
>> +		0xd0ca2bcb, 0xae7b30b4,
>> +		0x77cb2da3, 0x8030f20c,
>> +		0x6a42b73b, 0xbeac01fa,
>> +	};
>> +
>> +	/* set default RSS key and remember it */
>> +	for (i = 0; i < HNS_PPEV2_RSS_KEY_NUM; i++)
>> +		ppe_cb->rss_key[i]  = rss_key[i];
>>
> Is there any reason for the special default key?
> Why not use netdev_rss_key_fill()?
Thanks for pointing out this. I have incorported this change in latest 
PATCH V5
>
