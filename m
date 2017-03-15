From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen_nic: remove redundant check if retries is zero
Date: Wed, 15 Mar 2017 15:06:18 -0700 (PDT)
Message-ID: <20170315.150618.516724613328619597.davem@davemloft.net>
References: <20170315153158.16122-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170315153158.16122-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Wed, 15 Mar 2017 15:31:58 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> At the end of the timeout loop, retries will always be zero so
> the check for zero is redundant so remove it.  Also replace
> printk with pr_err as recommended by checkpatch.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
