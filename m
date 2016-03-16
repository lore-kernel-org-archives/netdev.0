From: oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/3] infiniband: IB/hns: add Hisilicon RoCE support
Date: Wed, 16 Mar 2016 18:26:28 +0800
Message-ID: <56E934D4.2070100@huawei.com>
References: <1457692631-9290-1-git-send-email-oulijun@huawei.com>
 <1457692631-9290-2-git-send-email-oulijun@huawei.com>
 <20160312103940.GA15703@leon.nu>
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
In-Reply-To: <20160312103940.GA15703-2ukJVAZIZ/Y@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi dledford, thanks for reviewing.

I have modified according to your reivews. I will send a new patch
at soon.

thanks
Lijun Ou

On 2016/3/12 18:39, Leon Romanovsky wrote:
> On Fri, Mar 11, 2016 at 06:37:09PM +0800, Lijun Ou wrote:
>> The driver for Hisilicon RoCE is a platform driver.
>> The driver will support mulitple versions of hardware. Currently only "v1"
>> for hip06 SOC is supported.
>> The driver includes two parts: common driver and hardware-specific
>> operations. hns_roce_v1_hw.c and hns_roce_v1_hw.h are files for
>> hardware-specific operations only for v1 engine, and other files(.c and .h)
>> for common algorithm and common hardware operations
>>
>> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Wei Hu(Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: Znlong <zhaonenglong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
>> ---
>>  drivers/infiniband/Kconfig                         |    2 +-
>>  drivers/infiniband/hw/Makefile                     |    1 +
>>  drivers/infiniband/hw/hisilicon/hns/Kconfig        |   10 +
>>  drivers/infiniband/hw/hisilicon/hns/Makefile       |    9 +
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c  |  114 +
>>  .../infiniband/hw/hisilicon/hns/hns_roce_alloc.c   |  253 ++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c |  354 +++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h |  163 ++
>>  .../infiniband/hw/hisilicon/hns/hns_roce_common.h  |  704 +++++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c  |  454 +++
>>  .../infiniband/hw/hisilicon/hns/hns_roce_device.h  |  840 ++++++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c  |  798 ++++++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h  |  138 +
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c |  608 ++++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h |  121 +
>>  .../infiniband/hw/hisilicon/hns/hns_roce_main.c    | 1124 ++++++++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c  |  637 +++++
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c  |  129 +
>>  drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c  |  890 ++++++
>>  .../infiniband/hw/hisilicon/hns/hns_roce_user.h    |   31 +
>>  .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c   | 2992 ++++++++++++++++++++
>>  .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h   | 1068 +++++++
>>  22 files changed, 11439 insertions(+), 1 deletion(-)
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/Kconfig
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/Makefile
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_ah.c
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_alloc.c
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.c
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cmd.h
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_common.h
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_cq.c
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_device.h
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.c
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_eq.h
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.c
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_icm.h
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_main.c
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_mr.c
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_pd.c
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_qp.c
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_user.h
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c
>>  create mode 100644 drivers/infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h
>>
>> diff --git a/drivers/infiniband/Kconfig b/drivers/infiniband/Kconfig
>> index 8a8440c..c7a24bb 100644
>> --- a/drivers/infiniband/Kconfig
>> +++ b/drivers/infiniband/Kconfig
>> @@ -73,7 +73,7 @@ source "drivers/infiniband/hw/mlx5/Kconfig"
>>  source "drivers/infiniband/hw/nes/Kconfig"
>>  source "drivers/infiniband/hw/ocrdma/Kconfig"
>>  source "drivers/infiniband/hw/usnic/Kconfig"
>> -
> 
> No need to remove this line. It separates HW from ULPs.
> 
>> +source "drivers/infiniband/hw/hisilicon/hns/Kconfig"
>>  source "drivers/infiniband/ulp/ipoib/Kconfig"
>>  
>>  source "drivers/infiniband/ulp/srp/Kconfig"
> 
> <snip>
> 
>> +int hns_roce_bitmap_alloc_range(
>> +					struct hns_roce_bitmap *bitmap,
>> +					int cnt, int align, u32 *obj)
> 
> You have indentation issues.
> 
>> +{
>> +	int i;
>> +	int ret = 0;
>> +
>> +	if (likely(cnt == 1 && align == 1))
>> +		return hns_roce_bitmap_alloc(bitmap, obj);
>> +
>> +	spin_lock(&bitmap->lock);
>> +
>> +	*obj = bitmap_find_next_zero_area(bitmap->table, bitmap->max,
>> +					  bitmap->last, cnt, align - 1);
>> +	if (*obj >= bitmap->max) {
>> +		bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
>> +			       & bitmap->mask;
>> +		*obj = bitmap_find_next_zero_area(bitmap->table, bitmap->max, 0,
>> +						  cnt, align - 1);
>> +	}
>> +
>> +	if (*obj < bitmap->max) {
>> +		for (i = 0; i < cnt; i++)
>> +			set_bit(*obj + i, bitmap->table);
>> +
>> +		if (*obj == bitmap->last) {
>> +			bitmap->last = (*obj + cnt);
>> +			if (bitmap->last >= bitmap->max)
>> +				bitmap->last = 0;
>> +		}
>> +		*obj |= bitmap->top;
>> +	} else {
>> +		ret = -1;
>> +	}
>> +
>> +	spin_unlock(&bitmap->lock);
>> +
>> +	return ret;
>> +}
>> +
>> +void hns_roce_bitmap_free_range(
>> +					struct hns_roce_bitmap *bitmap,
>> +					u32 obj,
>> +					int cnt)
>> +{
>> +	int i;
>> +
>> +	obj &= bitmap->max + bitmap->reserved_top - 1;
>> +
>> +	spin_lock(&bitmap->lock);
>> +	for (i = 0; i < cnt; i++)
>> +		clear_bit(obj + i, bitmap->table);
>> +
>> +	bitmap->last = min(bitmap->last, obj);
>> +	bitmap->top = (bitmap->top + bitmap->max + bitmap->reserved_top)
>> +		       & bitmap->mask;
>> +	spin_unlock(&bitmap->lock);
>> +}
>> +
>> +int hns_roce_bitmap_init(struct hns_roce_bitmap *bitmap, u32 num,
>> +			       u32 mask, u32 reserved_bot,
>> +			       u32 reserved_top)
>> +{
>> +	u32 i;
>> +
>> +	if (num != roundup_pow_of_two(num))
>> +		return -EINVAL;
>> +
>> +	bitmap->last = 0;
>> +	bitmap->top  = 0;
>> +	bitmap->max  = num - reserved_top;
>> +	bitmap->mask = mask;
>> +	bitmap->reserved_top = reserved_top;
>> +	spin_lock_init(&bitmap->lock);
>> +	bitmap->table =
>> +		kzalloc(BITS_TO_LONGS(bitmap->max) * sizeof(long), GFP_KERNEL);
> 
> Here and below, please consider to use kcalloc.
> 
>> +	if (!bitmap->table)
>> +		return -ENOMEM;
>> +
>> +	for (i = 0; i < reserved_bot; ++i)
> 
> .
> 


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
