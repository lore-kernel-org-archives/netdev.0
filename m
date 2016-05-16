From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [patch net-next 06/11] ACPI: bus: move acpi_match_device_ids() to
 linux/acpi.h
Date: Mon, 16 May 2016 09:57:33 +0800
Message-ID: <5739290D.9020701@huawei.com>
References: <1463127557-90824-1-git-send-email-Yisen.Zhuang@huawei.com>
 <1463127557-90824-7-git-send-email-Yisen.Zhuang@huawei.com>
 <1463145312.17131.347.camel@linux.intel.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:54938 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbcEPB6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 21:58:22 -0400
In-Reply-To: <1463145312.17131.347.camel@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/5/13 21:15, Andy Shevchenko wrote:
> On Fri, 2016-05-13 at 16:19 +0800, Yisen Zhuang wrote:
>> From: Hanjun Guo <hanjun.guo@linaro.org>
>>
>> acpi_match_device_ids() will be used for drivers to match
>> different hardware versions, it will be compiled in non-ACPI
>> case, but acpi_match_device_ids() in acpi_bus.h and it can
>> only be used in ACPI case, so move it to linux/acpi.h and
>> introduce a stub function for it.
> I somehow doubt this is right move.
>
> Like I said in the previous comment the architectural split might make
> this a bit better.
>
> You might use 
>
> #ifdef IS_ENABLED(CONFIG_ACPI)
> #else
> #endif
>
> only once to some big part of code. If kernel is build without ACPI
> support you even will not have this in your driver at all.

Hi Andy,

Thanks for your suggestions. It will add stub function instead in next submit.


> -- 
> Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> Intel Finland Oy
>
>
> .
>
