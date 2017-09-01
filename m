From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: remove redundant zero check on retries counter
Date: Fri, 01 Sep 2017 10:34:08 -0700 (PDT)
Message-ID: <20170901.103408.279665918180927406.davem@davemloft.net>
References: <20170901134431.23179-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harish.patil@cavium.com, manish.chopra@cavium.com,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170901134431.23179-1-colin.king@canonical.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri,  1 Sep 2017 14:44:31 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> At the end of the do while loop the integer counter retries will
> always be zero and so the subsequent check to see if it is zero
> is always true and therefore redundant.  Remove the redundant check
> and always return -EIO on this return path.  Also unbreak the literal
> string in dev_err message to clean up a checkpatch warning.
> 
> Detected by CoverityScan, CID#744279 ("Logically dead code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied to net-next, thanks.
