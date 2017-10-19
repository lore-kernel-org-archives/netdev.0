From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][next] mqprio: fix potential null pointer dereference
 on opt
Date: Thu, 19 Oct 2017 13:15:50 +0100 (WEST)
Message-ID: <20171019.131550.485803458070670938.davem@davemloft.net>
References: <20171017150130.23606-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171017150130.23606-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue, 17 Oct 2017 16:01:30 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The pointer opt has a null check however before for this check opt is
> dereferenced when len is initialized, hence we potentially have a null
> pointer deference on opt.  Avoid this by checking for a null opt before
> dereferencing it.
> 
> Detected by CoverityScan, CID#1458234 ("Dereference before null check")
> 
> Fixes: 4e8b86c06269 ("mqprio: Introduce new hardware offload mode and shaper in mqprio")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
