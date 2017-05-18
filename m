From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sched: fix a use-after-free error on chain on the
 error exit path
Date: Thu, 18 May 2017 11:31:26 -0400 (EDT)
Message-ID: <20170518.113126.77172400948863631.davem@davemloft.net>
References: <20170518140702.6072-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170518140702.6072-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu, 18 May 2017 15:07:02 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Set chain to null after the call to tcf_chain_destroy so that we don't
> call tcf_chain_put on the error exit path, thus avoiding a use-after-free
> error.
> 
> Detected by CoverityScan, CID#1436357 ("Use after free")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Colin, you really need to make some adjustments to how you are submitting
these kinds of patches.

First of all, you must indicate the target tree in your Subject line
as "[PATCH net-next] " in this case.

Also, you need to add an appropriate Fixes: tag right before your
signoff.

Thank you.
