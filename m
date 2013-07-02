From: Shuah Khan <shuah.kh@samsung.com>
Subject: Re: [PATCH] wireless: Convert mwifiex/pcie to dev_pm_ops from legacy
 pm ops
Date: Tue, 02 Jul 2013 22:59:00 +0000
Message-ID: <B8EFE96D1287C24090BAD9D858E15E6173482E@sisaex02sj>
References: <1372778675-2909-1-git-send-email-shuah.kh@samsung.com>
 <51D32116.4010109@hauke-m.de>
 <B8EFE96D1287C24090BAD9D858E15E61734462@sisaex02sj>
 <51D32F7F.4090606@metafoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Hauke Mehrtens <hauke@hauke-m.de>,
	"bzhao@marvell.com" <bzhao@marvell.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"rjw@sisk.pl" <rjw@sisk.pl>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"shuahkhan@gmail.com" <shuahkhan@gmail.com>,
	Shuah Khan <shuah.kh@samsung.com>
To: Lars-Peter Clausen <lars@metafoo.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/02/2013 01:49 PM, Lars-Peter Clausen wrote:
> On 07/02/2013 09:24 PM, Shuah Khan wrote:
> [...]
>>>> +#ifdef CONFIG_PM
>>>> +/* Power Management Hooks */
>>>> +static const struct dev_pm_ops mwifiex_pcie_pm_ops = {
>>>> +	.suspend = mwifiex_pcie_suspend,
>>>> +	.resume = mwifiex_pcie_resume,
>>>> +};
>>>> +#endif
>>>> +
>>>
>>> Is it intended that you do not use SIMPLE_DEV_PM_OPS() like most of the
>>> other wifi drivers?
>>
>> So the reason for this is SIMPLE_DEV_PM_OPS() is defined only when
>> CONFIG_PM_SLEEP is enabled. This driver doesn't defines suspend and
>> resume when CONFIG_PM is enabled and I didn't want to change that. Hope
>> that helps understand why I didn't use SIMPLE_DEV_PM_OPS()
>
> Change the ifdefs to CONFIG_PM_SLEEP and use SIMPLE_DEV_PM_OPS. The driver does
> not support runtime PM.
>
> - Lars
>
>


Thanks. I will update the patch to use SIMPLE_DEV_PM_OPS.

-- Shuah

Shuah Khan, Linux Kernel Developer - Open Source Group Samsung Research 
America (Silicon Valley) shuah.kh@samsung.com | (970) 672-0658
