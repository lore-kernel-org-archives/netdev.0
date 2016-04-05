From: Leon Romanovsky <leon@leon.nu>
Subject: Re: [RESEND PATCH V4 2/3] IB/hns: Add HiSilicon RoCE driver support
Date: Tue, 5 Apr 2016 18:32:03 +0300
Message-ID: <20160405153203.GJ5264@leon.nu>
References: <1459502492-19891-1-git-send-email-oulijun@huawei.com>
 <1459502492-19891-3-git-send-email-oulijun@huawei.com>
 <20160402015830.GD8565@leon.nu>
 <57036A25.9000106@huawei.com>
Reply-To: leon@leon.nu
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gongyangming@huawei.com, xiaokun@huawei.com,
	tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	lisheng011@huawei.com, charles.chenxin@huawei.com,
	linuxarm@huawei.com
To: oulijun <oulijun@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57036A25.9000106@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 05, 2016 at 03:32:53PM +0800, oulijun wrote:
> >>  .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.c   | 2832 ++++++++++++++++++++
> >>  .../infiniband/hw/hisilicon/hns/hns_roce_v1_hw.h   |  985 +++++++
> >                                           ^^^^^^
> > Do you support v1 of RoCE or v1 of your HW?
> > 
> Here, v1 stands for hw, that is, we support v1 of our hw.

So you should write hns_roce_hw_v1 and not hns_roce_v1_hw

> >>  23 files changed, 10429 insertions(+)
> > 
> > Please appreciate the effort needed to review such large patch and
> > invest time and effort to divide this to number of small easy review patches.
> > 
>     Surely, i have pay attention to the patch, but i consider that it is not better to
> split the patch into small patch. because it will the base function of RoCE.
>     For your advice, i will make further efforts to taking a discussion how to reslove the question.

Faisal Latif's submission [1] can help you to get inspiration.

Also please DON'T submit your patches till you get rid of unrelated
functions/macros/defines and DMA operations for register access.

[1] https://lwn.net/Articles/668721/

> 
> thanks
> Lijun Ou
> > .
> > 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
