From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sched: remove redundant null check on head
Date: Thu, 04 May 2017 11:01:47 -0400 (EDT)
Message-ID: <20170504.110147.2043314141111893708.davem@davemloft.net>
References: <20170503135040.32023-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170503135040.32023-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Wed,  3 May 2017 14:50:40 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> head is previously null checked and so the 2nd null check on head
> is redundant and therefore can be removed.
> 
> Detected by CoverityScan, CID#1399505 ("Logically dead code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
