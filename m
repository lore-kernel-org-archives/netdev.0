From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][next] mlxsw: spectrum: fix uninitialized value in err
Date: Sun, 01 Oct 2017 23:06:20 -0700 (PDT)
Message-ID: <20171001.230620.73466517361012407.davem@davemloft.net>
References: <20171001162735.8091-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, idosch@mellanox.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171001162735.8091-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Sun,  1 Oct 2017 17:27:35 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> In the unlikely event that mfc->mfc_un.res.ttls[i] is 255 for all
> values of i from 0 to MAXIVS-1, the err is not set at all and hence
> has a garbage value on the error return at the end of the function,
> so initialize it to 0.  Also, the error return check on err and goto
> to err: inside the for loop makes it impossible for err to be zero
> at the end of the for loop, so we can remove the redundant err check
> at the end of the loop.
> 
> Detected by CoverityScan CID#1457207 ("Unitialized scalar value")
> 
> Fixes: c011ec1bbfd6 ("mlxsw: spectrum: Add the multicast routing offloading logic")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
