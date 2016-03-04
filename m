From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH 3/4] infiniband: hns: add Hisilicon RoCE support(driver
 code)
Date: Fri, 4 Mar 2016 10:16:28 +0100
Message-ID: <20160304091628.GB2150@nanopsycho.orion>
References: <1457080877-13456-1-git-send-email-xavier.huwei@huawei.com>
 <1457080877-13456-4-git-send-email-xavier.huwei@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gongyangming@huawei.com, xiaokun@huawei.com,
	tangchaofei@huawei.com, oulijun@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	lisheng011@huawei.com, charles.chenxin@huawei.com,
	linuxarm@huawei.com
To: "Wei Hu(Xavier)" <xavier.huwei@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1457080877-13456-4-git-send-email-xavier.huwei@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Mar 04, 2016 at 09:41:16AM CET, xavier.huwei@huawei.com wrote:

<snip>

>+int hns_roce_buf_alloc(
>+			struct hns_roce_dev *hr_dev,
>+			int size, int max_direct,
>+			struct hns_roce_buf *buf)

<snip>	
	
>+
>+			pages =
>+				kmalloc(sizeof(*pages) * buf->nbufs,
>+					GFP_KERNEL);

<snip>

>+
>+			buf->direct.buf = vmap(
>+						pages, buf->nbufs, VM_MAP,
>+						PAGE_KERNEL);

<snip>

>+	if (
>+		event_type != HNS_ROCE_EVENT_TYPE_CQ_ID_INVALID &&
>+		event_type != HNS_ROCE_EVENT_TYPE_CQ_ACCESS_ERROR &&
>+		event_type != HNS_ROCE_EVENT_TYPE_CQ_OVERFLOW) {
>+		dev_err(&hr_dev->pdev->dev,
>+			"hns_roce_ib: Unexpected event type 0x%x on CQ %06x\n",
>+			event_type, hr_cq->cqn);
>+		return;
>+	}

Although checkpatch does not complain, I find this semi-random adding of
newlines quite odd.
