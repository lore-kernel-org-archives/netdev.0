From: oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4 2/3] IB/hns: Add HiSilicon RoCE driver support
Date: Wed, 23 Mar 2016 20:20:52 +0800
Message-ID: <56F28A24.5010107@huawei.com>
References: <1458655621-3618-1-git-send-email-oulijun@huawei.com>
 <1458655621-3618-3-git-send-email-oulijun@huawei.com>
 <20160322185412.GA6262@infradead.org>
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
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160322185412.GA6262-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2016/3/23 2:54, Christoph Hellwig wrote:
>>  drivers/infiniband/Kconfig                         |    1 +
>>  drivers/infiniband/hw/Makefile                     |    1 +
>>  drivers/infiniband/hw/hisilicon/hns/Kconfig        |   10 +
> 
> To fit in with the other drivers drop the hisilicon level
> of the directory hierarchy.
> 
> Haven't had time to look at the actual driver yet so far, though.
> 
> .
> 
Hi Christoph Hellwig,
   surely, I considered that other drivers will be put into the hisilicon
level of the directory hierarchy. These drivers will support RDMA function which
will be developed for a series of hisilicon chip. Because of the consideration, I drop the
level.
   In additon that, i thought that the patch of RoCE driver which supported the base function of RDMA is huge. However,
It is not splitted into patches in form of patchset. I don't put a better strategy that it neither make mistakes
of building and running nor huge.

thanks
Lijun Ou

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
