From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][V2] net: ethernet: slicoss: remove redundant
 initialization of idx
Date: Wed, 01 Nov 2017 21:20:30 +0900 (KST)
Message-ID: <20171101.212030.879951866741665289.davem@davemloft.net>
References: <20171031100823.19733-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: LinoSanfilippo@gmx.de, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171031100823.19733-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue, 31 Oct 2017 10:08:23 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> Variable idx is being initialized and later on over-written by
> a new value in a do-loop without the initial value ever being
> read. Hence the initializion is redundant and can be removed.
> Cleans up clang warning:
> 
> drivers/net/ethernet/alacritech/slicoss.c:358:15: warning: Value
> stored to 'idx' during its initialization is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied to net-next.
