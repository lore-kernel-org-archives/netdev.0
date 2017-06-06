From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] net/mlxfw: remove redundant goto on error
 check
Date: Tue, 06 Jun 2017 12:22:50 -0400 (EDT)
Message-ID: <20170606.122250.1431459979681086413.davem@davemloft.net>
References: <20170606104740.15712-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yotamg@mellanox.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170606104740.15712-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue,  6 Jun 2017 11:47:40 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The check to see of err is set and the subsequent goto is extraneous
> as the next statement is where the goto is jumping to. Remove this
> redundant check and goto.
> 
> Detected by CoverityScan, CID#1437734 ("Identical code for
> different branches")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks.
