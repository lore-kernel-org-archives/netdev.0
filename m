From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net: qualcomm: rmnet: Fix a double free
Date: Sat, 09 Sep 2017 14:34:17 -0700 (PDT)
Message-ID: <20170909.143417.548324364987922693.davem@davemloft.net>
References: <2ddbb6da514108b4e70ccd8362292134@codeaurora.org>
        <20170909085803.zgfqhp23yt4ol3ka@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subashab@codeaurora.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170909085803.zgfqhp23yt4ol3ka@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 9 Sep 2017 11:58:03 +0300

> There is a typo here so we accidentally free "skb" instead of "skbn".
> It leads to a double free and a leak.  After discussing with Subash,
> it's better to just move the check before the allocation and avoid the
> need to free.
> 
> Fixes: ceed73a2cf4a ("drivers: net: ethernet: qualcomm: rmnet: Initial implementation")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: Fix the leak as well.  Thanks Subash!

Applied, thanks Dan.
