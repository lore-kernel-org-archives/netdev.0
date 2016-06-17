From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Subject: Re: [PATCH v9 09/22] IB/hns: Add hca support
Date: Fri, 17 Jun 2016 09:29:13 +0800
Message-ID: <57635269.3030905@huawei.com>
References: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
 <1464795484-77395-10-git-send-email-oulijun@huawei.com>
 <20160609071014.GR3663@leon.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <dledford@redhat.com>, <sean.hefty@intel.com>,
	<hal.rosenstock@gmail.com>, <davem@davemloft.net>,
	<jeffrey.t.kirsher@intel.com>, <jiri@mellanox.com>,
	<ogerlitz@mellanox.com>, <linux-rdma@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<gongyangming@huawei.com>, <xiaokun@huawei.com>,
	<tangchaofei@huawei.com>, <haifeng.wei@huawei.com>,
	<yisen.zhuang@huawei.com>, <yankejian@huawei.com>,
	<charles.chenxin@huawei.com>, <linuxarm@huawei.com>
To: <leon@kernel.org>, Lijun Ou <oulijun@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160609071014.GR3663@leon.nu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/6/9 15:10, Leon Romanovsky wrote:
> On Wed, Jun 01, 2016 at 11:37:51PM +0800, Lijun Ou wrote:
>> This patch mainly setup hca for RoCE. It will do a series of
>> initial works, as follows:
>>      1. init uar table, allocate uar resource
>>      2. init pd table
>>      3. init cq table
>>      4. init mr table
>>      5. init qp table
>>
>> Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
>> Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
>> Signed-off-by: Lijun Ou <oulijun@huawei.com>
>> ---
> <...>
>
>> +
>> +	ret = hns_roce_bitmap_init(&cq_table->bitmap, hr_dev->caps.num_cqs,
>> +				   hr_dev->caps.num_cqs - 1,
>> +				   hr_dev->caps.reserved_cqs, 0);
>> +	if (ret)
>> +		return ret;
>> +
>> +	return 0;
> You can return directly ret, instead last 4 lines.
Hi, leon
     We have fixed it.
     And Oulijun have sent PATCH V10. Thanks

Regards
Wei Hu
>
>> +}
>> +
