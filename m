From: oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [RESEND PATCH V4 2/3] IB/hns: Add HiSilicon RoCE driver support
Date: Tue, 5 Apr 2016 15:32:53 +0800
Message-ID: <57036A25.9000106@huawei.com>
References: <1459502492-19891-1-git-send-email-oulijun@huawei.com>
 <1459502492-19891-3-git-send-email-oulijun@huawei.com>
 <20160402015830.GD8565@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160402015830.GD8565-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,  Leon Romanovsky
On 2016/4/2 9:58, Leon Romanovsky wrote:
> On Fri, Apr 01, 2016 at 05:21:31PM +0800, Lijun Ou wrote:
>> The driver for HiSilicon RoCE is a platform driver.
>> The driver will support multiple versions of hardware. Currently only "v1"
>> for hip06 SoC is supported.
>> The driver includes two parts: common driver and hardware-specific
>> operations. hns_roce_v1_hw.c and hns_roce_v1_hw.h are files for
>> hardware-specific operations only for v1 engine, and other files(.c and .h)
>> for common algorithm and common hardware operations.
>>
>> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Wei Hu(Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Znlong <zhaonenglong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> ---
>>  MAINTAINERS                                        |    8 +
>>  drivers/infiniband/Kconfig                         |    1 +
>>  drivers/infiniband/hw/Makefile                     |    1 +
>>  drivers/infiniband/hw/hisilicon/hns/Kconfig        |   10 +
>>  drivers/infiniband/hw/hisilicon/hns/Makefile       |    9 +
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c  |  110 +
> 
> We are not adding name of company (hisilicon) for infiniband HW drivers
> drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c
> --->
> drivers/infiniband/hw/hns/hns_roce_ah.c
>
Surely, i will modify the location of RoCE driver code after disscussed in next patch

> 
>>  .../infiniband/hw/hisilicon/hns/hns_roce_alloc.c   |  239 ++
>  ^^^^^^
> Please fix you paths.
> 
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c |  338 +++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h |   80 +
>>  .../infiniband/hw/hisilicon/hns/hns_roce_common.h  |  308 +++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c  |  436 +++
>>  .../infiniband/hw/hisilicon/hns/hns_roce_device.h  |  794 ++++++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c  |  758 ++++++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h  |  132 +
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c |  578 ++++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h |  112 +
>>  .../infiniband/hw/hisilicon/hns/hns_roce_main.c    | 1097 ++++++++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c  |  605 +++++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c  |  124 +
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c  |  841 ++++++
>>  .../infiniband/hw/hisilicon/hns/hns_roce_user.h    |   31 +
>>  .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c   | 2832 ++++++++++++++++++++
>>  .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h   |  985 +++++++
>                                           ^^^^^^
> Do you support v1 of RoCE or v1 of your HW?
> 
Here, v1 stands for hw, that is, we support v1 of our hw.
>>  23 files changed, 10429 insertions(+)
> 
> Please appreciate the effort needed to review such large patch and
> invest time and effort to divide this to number of small easy review patches.
> 
    Surely, i have pay attention to the patch, but i consider that it is not better to
split the patch into small patch. because it will the base function of RoCE.
    For your advice, i will make further efforts to taking a discussion how to reslove the question.

thanks
Lijun Ou
> .
> 


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
