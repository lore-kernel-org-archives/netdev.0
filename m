From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mkiss: remove redundant check on len being zero
Date: Sat, 30 Sep 2017 05:44:54 +0100 (WEST)
Message-ID: <20170930.054454.1056054589514297047.davem@davemloft.net>
References: <20170927214513.22562-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, johannes.berg@intel.com,
        ralf@linux-mips.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170927214513.22562-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Wed, 27 Sep 2017 22:45:13 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The check on len is redundant as it is always greater than 1,
> so just remove it and make the printk less complex.
> 
> Detected by CoverityScan, CID#1226729 ("Logically dead code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks.
