From: oulijun <oulijun@huawei.com>
Subject: Re: [PATCH 1/3] infiniband: IB/hns: add Hisilicon RoCE support
Date: Sat, 19 Mar 2016 19:11:41 +0800
Message-ID: <56ED33ED.5050800@huawei.com>
References: <1457692631-9290-1-git-send-email-oulijun@huawei.com>
 <1457692631-9290-2-git-send-email-oulijun@huawei.com>
 <20160311104239.GD3931@nanopsycho.orion> <56E9340E.3040207@huawei.com>
 <20160316103638.GB2254@nanopsycho.orion> <20160317064359.GA25216@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Jiri Pirko <jiri@resnulli.us>, <dledford@redhat.com>,
	<sean.hefty@intel.com>, <hal.rosenstock@gmail.com>,
	<davem@davemloft.net>, <jeffrey.t.kirsher@intel.com>,
	<jiri@mellanox.com>, <ogerlitz@mellanox.com>,
	<linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <gongyangming@huawei.com>,
	<xiaokun@huawei.com>, <tangchaofei@huawei.com>,
	<haifeng.wei@huawei.com>, <yisen.zhuang@huawei.com>,
	<yankejian@huawei.com>, <lisheng011@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:23908 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbcCSLMd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2016 07:12:33 -0400
In-Reply-To: <20160317064359.GA25216@leon.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/3/17 14:43, Leon Romanovsky wrote:
> On Wed, Mar 16, 2016 at 11:36:38AM +0100, Jiri Pirko wrote:
>>> so, I continue to have it.
>>
>> I will continue to bash on your odd codingstyle. Please fix it!
> 
> Jiri,
> 
> Checkpatch errors is an easiest issue with this patch.
> 
> It is full of functions without use, unconnected macros and
> if you replace "hsi" to name of other well known driver, you will get
> same code :).
> 
> They need to redesign the whole driver before resubmission.
> 
> Thanks.
> 
> .
> 
Hi, Leon Romanovsky
    Firstly, thanks for reviewing.
    I have checked the patch v2, surely, some funtions without use and unconnected
macros exist. I have removed it according to analyse. I will leave few marcos as follow:
    #define CQ_STATE_INVALID    0
    #define CQ_STATE_RESERV     1
    #define CQ_STATE_VALID      2
    #define CQ_STATE_ERR        3

I thought that these are defined for hardware information. So, I reserved these macros.

In addtion, I didn't completly understand your review as below:
  if you replace "hsi" to name of other well known driver, you will get > same code :).

thanks
Lijun Ou
