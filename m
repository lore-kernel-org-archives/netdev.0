From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netxen: fix incorrect loop counter decrement
Date: Fri, 18 Aug 2017 10:59:20 -0700 (PDT)
Message-ID: <20170818.105920.806261873907360749.davem@davemloft.net>
References: <20170818131206.15417-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manish.chopra@cavium.com, rahul.verma@cavium.com,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818131206.15417-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri, 18 Aug 2017 14:12:06 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The loop counter k is currently being decremented from zero which
> is incorrect. Fix this by incrementing k instead
> 
> Detected by CoverityScan, CID#401847 ("Infinite loop")
> 
> Fixes: 83f18a557c6d ("netxen_nic: fw dump support")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
