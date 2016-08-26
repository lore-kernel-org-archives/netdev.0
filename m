From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hns: dereference ppe_cb->ppe_common_cb if it is
 non-null
Date: Fri, 26 Aug 2016 11:45:44 -0700 (PDT)
Message-ID: <20160826.114544.331469797150439600.davem@davemloft.net>
References: <20160825065110.10104-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        lisheng011@huawei.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160825065110.10104-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu, 25 Aug 2016 07:51:10 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> ppe_cb->ppe_common_cb is being dereferenced before a null check is
> being made on it.  If ppe_cb->ppe_common_cb is null then we end up
> with a null pointer dereference when assigning dsaf_dev.  Fix this
> by moving the initialisation of dsaf_dev once we know
> ppe_cb->ppe_common_cb is OK to dereference.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
