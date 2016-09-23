From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][V2] cxgb4: fix signed wrap around when decrementing
 index idx
Date: Fri, 23 Sep 2016 07:25:37 -0400 (EDT)
Message-ID: <20160923.072537.1771650721180471237.davem@davemloft.net>
References: <20160922174858.31922-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160922174858.31922-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu, 22 Sep 2016 18:48:58 +0100

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

Applied to net-next, thanks.
