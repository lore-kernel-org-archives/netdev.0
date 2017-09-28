From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][next] cxgb4: make function ch_flower_stats_cb, fixes
 warning
Date: Thu, 28 Sep 2017 10:22:32 -0700 (PDT)
Message-ID: <20170928.102232.867664274639714198.davem@davemloft.net>
References: <20170926151409.18244-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ganeshgr@chelsio.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926151409.18244-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue, 26 Sep 2017 16:14:09 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The function ch_flower_stats_cb is local to the source and does not need
> to be in global scope, so make it static.
> 
> Cleans up sparse warnings:
> symbol 'ch_flower_stats_cb' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
