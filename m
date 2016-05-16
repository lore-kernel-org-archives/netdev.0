From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [patch net-next 07/11] net: hns: dsaf adds support of acpi
Date: Mon, 16 May 2016 10:06:52 +0800
Message-ID: <57392B3C.2060609@huawei.com>
References: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1463127557-90824-8-git-send-email-Yisen.Zhuang@huawei.com>
 <1463145136.17131.344.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <arnd@arndb.de>, <andrew@lunn.ch>, <geliangtang@163.com>,
	<ivecera@redhat.com>, <fengguang.wu@intel.com>,
	<charles.chenxin@huawei.com>, <haifeng.wei@huawei.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linuxarm@huawei.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Yisen Zhuang <Yisen.Zhuang@huawei.com>, <davem@davemloft.net>,
	<rjw@rjwysocki.net>, <lenb@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463145136.17131.344.camel@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/5/13 21:12, Andy Shevchenko wrote:
> On Fri, 2016-05-13 at 16:19 +0800, Yisen Zhuang wrote:
>> From: Kejian Yan <yankejian@huawei.com>
>>
>> Dsaf needs to get configuration parameter by ACPI, so this patch add
>> support of ACPI.
>>
> Looks like at some point better to split driver to core part, and PCI
> and ACPI/DT/platform code.
>
> Too many changes where IS_ENABLED() involved shows as I can imagine bad
> architecture / split of the driver.

Hi Andy,
Actully, we use the unified function asap. The routine in DT/ACPI maybe difference. Some routine
will be treated in BIOS in ACPI case, but it will be treated in OS in DT case, so we need to distinguish
it.
And we will try to reduce the use of IS_ENABLED().

Thanks very much for your suggestions, Andy

Kejian
