From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Subject: Re: [PATCH v5 09/21] IB/hns: Add hca support
Date: Tue, 3 May 2016 16:39:45 +0800
Message-ID: <572863D1.5020700@huawei.com>
References: <1461407219-72027-1-git-send-email-oulijun@huawei.com>
 <1461407219-72027-10-git-send-email-oulijun@huawei.com>
 <20160424075424.GE7974@leon.nu> <571F0C04.2010005@huawei.com>
 <20160426141821.GJ7974@leon.nu> <20160426142517.GA1937@nanopsycho.orion>
 <57203347.4000107@huawei.com>
 <CAJ3xEMgvcRa=qFDs0wDv25Ue2yw0hQoK_E=01G7zikyr7kLKUw@mail.gmail.com>
 <57285A07.8090407@huawei.com>
 <CAJ3xEMj5KMcdEmpD5YYAMPJYmDW-X1J2nU0OjfJ1V93VKJ+A+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oulijun <oulijun@huawei.com>, Jiri Pirko <jiri@resnulli.us>,
	Doug Ledford <dledford@redhat.com>,
	"Hefty, Sean" <sean.hefty@intel.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
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
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAJ3xEMj5KMcdEmpD5YYAMPJYmDW-X1J2nU0OjfJ1V93VKJ+A+A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/5/3 16:14, Or Gerlitz wrote:
> On Tue, May 3, 2016 at 10:57 AM, Wei Hu (Xavier)
> <xavier.huwei@huawei.com> wrote:
>> On 2016/4/30 12:33, Or Gerlitz wrote:
>
>>> Can you elaborate what design aspects in the driver or anywhere else
>>> should impose that limitation?
>> 1.  Oulijun resolved the problem, and sent PATCH V6 on 2016-4-28. Thanks for
>> more comments.
> V6 still conditions things on ARM
>
>
>> 2.  This driver for Hisilicon RoCE Engine run in ARM SoCs.
>> The Hisilicon Network Subsystem is a long term evolution IP which is
>> supposed to be used in Hisilicon ICT SoCs. HNS(Hisilicon Network Subsystem)
>> has a hardware support of performing RDMA with RoCE engine.
> I understand that the HW is targeted just for ARM environments. Is
> this the reason
> why you want to impose this build limitation or there's something in
> the driver design
> or code that is not going to work in other environments?
yes.

Regards
Wei Hu
>
>> This Kconfig related with this driver as below:
>>
>> config INFINIBAND_HISILICON_HNS
>>      tristate "Hisilicon Hns ROCE Driver"
>>      depends on NET_VENDOR_HISILICON
>>      depends on ARM64 && HNS && HNS_DSAF && HNS_ENET
> this is understood, my question came to better understand the limitations
>
> .
>
