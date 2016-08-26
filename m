From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [PATCH] net: hns: dereference ppe_cb->ppe_common_cb if it is
 non-null
Date: Fri, 26 Aug 2016 08:42:05 +0800
Message-ID: <57BF905D.6050304@huawei.com>
References: <20160825065110.10104-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: <linux-kernel@vger.kernel.org>
To: Colin King <colin.king@canonical.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "David S . Miller" <davem@davemloft.net>,
        Lisheng <lisheng011@huawei.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160825065110.10104-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



在 2016/8/25 14:51, Colin King 写道:
> From: Colin Ian King <colin.king@canonical.com>
> 
> ppe_cb->ppe_common_cb is being dereferenced before a null check is
> being made on it.  If ppe_cb->ppe_common_cb is null then we end up
> with a null pointer dereference when assigning dsaf_dev.  Fix this
> by moving the initialisation of dsaf_dev once we know
> ppe_cb->ppe_common_cb is OK to dereference.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Acked-by: Yisen Zhuang <yisen.zhuang@huawei.com>
