From: oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 3/4] infiniband: hns: add Hisilicon RoCE support(driver
 code)
Date: Wed, 9 Mar 2016 19:18:06 +0800
Message-ID: <56E0066E.1000106@huawei.com>
References: <1457080877-13456-1-git-send-email-xavier.huwei@huawei.com>
 <1457080877-13456-4-git-send-email-xavier.huwei@huawei.com>
 <20160304091628.GB2150@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
	"Wei Hu(Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160304091628.GB2150-6KJVSR23iU488b5SBfVpbw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Jiri Pirko, thanks for reviewing
On 2016/3/4 17:16, Jiri Pirko wrote:
> Fri, Mar 04, 2016 at 09:41:16AM CET, xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org wrote:
> 
> <snip>
> 
>> +int hns_roce_buf_alloc(
>> +			struct hns_roce_dev *hr_dev,
>> +			int size, int max_direct,
>> +			struct hns_roce_buf *buf)
> 
> <snip>	
> 	
>> +
>> +			pages =
>> +				kmalloc(sizeof(*pages) * buf->nbufs,
>> +					GFP_KERNEL);
> 
> <snip>
> 
>> +
>> +			buf->direct.buf = vmap(
>> +						pages, buf->nbufs, VM_MAP,
>> +						PAGE_KERNEL);
> 
> <snip>
> 
>> +	if (
>> +		event_type != HNS_ROCE_EVENT_TYPE_CQ_ID_INVALID &&
>> +		event_type != HNS_ROCE_EVENT_TYPE_CQ_ACCESS_ERROR &&
>> +		event_type != HNS_ROCE_EVENT_TYPE_CQ_OVERFLOW) {
>> +		dev_err(&hr_dev->pdev->dev,
>> +			"hns_roce_ib: Unexpected event type 0x%x on CQ %06x\n",
>> +			event_type, hr_cq->cqn);
>> +		return;
>> +	}
> 
> Although checkpatch does not complain, I find this semi-random adding of
> newlines quite odd.
> 
    Really, the question you mentioned exit in many location in currently patch. I done it
in order to make it complain checkpatch and linux norms. Now, I have checked and adjust it
properly combined to checkpatch
    I will send a new patch in future. if not modified in some locations, it have to violate
checkpatch once modified and is unable to adjust it better. About these,  have you best strategy?

Thanks
Lijun Ou
> .
> 


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
