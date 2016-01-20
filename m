From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [PATCH v2 next-next] net: hns: enet specifies a reference to dsaf
Date: Wed, 20 Jan 2016 19:10:19 +0800
Message-ID: <569F6B1B.6080902@huawei.com>
References: <1452654880-28980-1-git-send-email-yankejian@huawei.com>
 <56970F48.9060504@huawei.com> <1452764635.2521.28.camel@linux.intel.com>
 <569F2DEC.9040209@huawei.com> <1453282570.2521.130.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Yisen Zhuang <Yisen.zhuang@huawei.com>, <davem@davemloft.net>,
	<robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
	<ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<huangdaode@hisilicon.com>, <liguozhu@huawei.com>, <arnd@arndb.de>,
	<fengguang.wu@intel.com>, <salil.mehta@huawei.com>,
	<lisheng011@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453282570.2521.130.camel@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/1/20 17:36, Andy Shevchenko wrote:
> On Wed, 2016-01-20 at 14:49 +0800, Yankejian (Hackim Yim) wrote:
>>>> +
>>>>>>> +	snprintf(ae_dev->name, AE_NAME_SIZE, "%s%d",
>>>>>>> DSAF_DEVICE_NAME,
>>>>>>> +		 (int)atomic_inc_return(&id));
>>> If you bind/unbind device enough times you may get an overflow and
>>> end
>>> up with name of existing device (if you have 1+ of them in the
>>> system).
>>>
>>> To avoid such situation better to use IDA/IDR framework.
>>>
>> Hi, Andy
>> Thanks again for your suggestion.
>> It seems that using IDA/IDR framework is better, but all of the
>> functions must be serialized by lock.
> AFAIR it's designed in a way you don't need to do any additional
> locking or synchronization.

really? if so, that is great.
could you sent me an example.
thanks very much. Andy.

Best Regards,
Kejian Yan
