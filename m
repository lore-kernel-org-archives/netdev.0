From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4: fix signed wrap around when decrementing index
 idx
Date: Thu, 22 Sep 2016 01:49:20 -0400 (EDT)
Message-ID: <20160922.014920.1225574247564649882.davem@davemloft.net>
References: <20160920144846.21765-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160920144846.21765-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue, 20 Sep 2016 15:48:45 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Change predecrement compare to post decrement compare to avoid an
> unsigned integer wrap-around comparison when decrementing idx in
> the while loop.
> 
> For example, when idx is zero, the current situation will
> predecrement idx in the while loop, wrapping idx to the maximum
> signed integer and cause out of bounds reads on rxq_info->msix_tbl[idx].
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

This doesn't apply cleanly to the 'net' tree, please respin.
