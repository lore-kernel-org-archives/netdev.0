From: "Yankejian (Hackim Yim)" <yankejian@huawei.com>
Subject: Re: [PATCH v3 net-next 0/2] net: hns: get and set RSS indirection
 table by using ethtool
Date: Mon, 14 Mar 2016 12:27:01 +0800
Message-ID: <56E63D95.6080702@huawei.com>
References: <1457666747-244953-1-git-send-email-yankejian@huawei.com>
 <1457686918.1347.56.camel@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
	<liguozhu@huawei.com>, <huangdaode@hisilicon.com>, <arnd@arndb.de>,
	<andrew@lunn.ch>, <chenny.xu@huawei.com>, <ivecera@redhat.com>,
	<lisheng011@huawei.com>, <fengguang.wu@intel.com>,
	<haifeng.wei@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:24417 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbcCNE23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 00:28:29 -0400
In-Reply-To: <1457686918.1347.56.camel@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/3/11 17:01, Andy Shevchenko wrote:
> On Fri, 2016-03-11 at 11:25 +0800, Kejian Yan wrote:
>> When we use ethtool to retrieves or configure the receive flow hash 
>> indirection table, ethtool needs to call .get_rxnfc to get the ring
>> number
>> so this patchset implements the .get_rxnfc and fixes the bug that we
>> can
>> not get the tatal table each time.
>>
> FWIW:
>
> Reviewed-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Hi Andy,
I'm sorry for missing it.i will fix it in next submit.

MBR, Kejian

>> ---
>> change log:
>> PATCH v3:
>>  - This patchset fixes the building warning and error
>>
>> PATCH v2:
>>  - This patchset fixes the comments provided by Andy Shevchenko <Andy
>> Shevchenko>
>>
>> PATCH v1:
>>  - first submit
>>
>> Kejian Yan (2):
>>   net: hns: fix return value of the function about rss
>>   net: hns: fixes a bug of RSS
>>
>>  drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |  8 ++++---
>>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c |  2 +-
>>  drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  | 28
>> ++++++++++++++++-------
>>  3 files changed, 26 insertions(+), 12 deletions(-)
>>
