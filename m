From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cavium: liquidio: fix check for in progress flag
Date: Sat, 13 Feb 2016 06:06:40 -0500 (EST)
Message-ID: <20160213.060640.863091898671472122.davem@davemloft.net>
References: <1454689839-6360-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com,
	satananda.burla@caviumnetworks.com,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454689839-6360-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri,  5 Feb 2016 16:30:39 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> smatch detected a suspicious looking bitop condition:
> 
> drivers/net/ethernet/cavium/liquidio/lio_main.c:2529
>   handle_timestamp() warn: suspicious bitop condition
> 
> (skb_shinfo(skb)->tx_flags | SKBTX_IN_PROGRESS is always non-zero,
> so the logic is definitely not correct.  Use & to mask the correct
> bit.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks.

But this means one of the code paths was never tested...
