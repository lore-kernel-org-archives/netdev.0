From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Subject: Re: [PATCH v5 09/21] IB/hns: Add hca support
Date: Tue, 3 May 2016 15:57:59 +0800
Message-ID: <57285A07.8090407@huawei.com>
References: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
 <1461407219-72027-10-git-send-email-oulijun@huawei.com>
 <20160424075424.GE7974@leon.nu> <571F0C04.2010005@huawei.com>
 <20160426141821.GJ7974@leon.nu> <20160426142517.GA1937@nanopsycho.orion>
 <57203347.4000107@huawei.com>
 <CAJ3xEMgvcRa=qFDs0wDv25Ue2yw0hQoK_E=01G7zikyr7kLKUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Leon Romanovsky <leon@kernel.org>,
	"Doug Ledford" <dledford@redhat.com>,
	"Hefty, Sean" <sean.hefty@intel.com>,
	"Hal Rosenstock" <hal.rosenstock@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, <linuxarm@huawei.com>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	<gongyangming@huawei.com>, <xiaokun@huawei.com>,
	<tangchaofei@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<lisheng011@huawei.com>, <charles.chenxin@huawei.com>
To: Or Gerlitz <gerlitz.or@gmail.com>, oulijun <oulijun@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:58665 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752772AbcECIPb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 04:15:31 -0400
In-Reply-To: <CAJ3xEMgvcRa=qFDs0wDv25Ue2yw0hQoK_E=01G7zikyr7kLKUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/4/30 12:33, Or Gerlitz wrote:
> On Wed, Apr 27, 2016 at 6:34 AM, oulijun <oulijun@huawei.com> wrote:
>> On 2016/4/26 22:25, Jiri Pirko wrote:
>>> Tue, Apr 26, 2016 at 04:18:21PM CEST, leon@kernel.org wrote:
>>>>>      I appreciate your keen eye. this code is meant for ARM64bit therefore should run corretly for 64-bit AARCH64.
>>> The driver should run correctly on any arch.
>>   Hi Jiri Pirko,
>>      Our driver run in ARM64 platform by depending on Kconfig. It will be configure in Kconfig file.
> Can you elaborate what design aspects in the driver or anywhere else
> should impose that limitation?
>
> Or.
Hi, Or Gerlitz

1.  Oulijun resloved the problem, and sent PATCH V6 on 2016-4-28. Thanks 
for more comments.

2.  This driver for Hisilicon RoCE Engine run in ARM SoCs.

The Hisilicon Network Subsystem is a long term evolution IP which is
supposed to be used in Hisilicon ICT SoCs. HNS(Hisilicon Network Subsystem)
has a hardware support of performing RDMA with RoCE engine.

This Kconfig related with this driver as below:

config INFINIBAND_HISILICON_HNS
     tristate "Hisilicon Hns ROCE Driver"
     depends on NET_VENDOR_HISILICON
     depends on ARM64 && HNS && HNS_DSAF && HNS_ENET

Regards
Wei Hu
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> .
>
