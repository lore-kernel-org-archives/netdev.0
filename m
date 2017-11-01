From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: thunderx: remove a couple of redundant assignments
Date: Wed, 01 Nov 2017 21:30:46 +0900 (KST)
Message-ID: <20171101.213046.1800118728866748105.davem@davemloft.net>
References: <20171031143755.26021-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgoutham@cavium.com, rric@kernel.org,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171031143755.26021-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue, 31 Oct 2017 14:37:55 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> The assignment to pointer msg is redundant as it is never read, so
> remove msg.  Also remove the first assignment to qset as this is not
> read before the next re-assignment of a new value to qset in the
> for-loop. Cleans up two clang warnings:
> 
> drivers/net/ethernet/cavium/thunder/nic_main.c:589:2: warning: Value
> stored to 'msg' is never read
> drivers/net/ethernet/cavium/thunder/nic_main.c:611:2: warning: Value
> stored to 'qset' is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
