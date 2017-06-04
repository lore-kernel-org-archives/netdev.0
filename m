From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] rxrpc: remove redundant proc_remove call
Date: Sun, 04 Jun 2017 19:59:40 -0400 (EDT)
Message-ID: <20170604.195940.396015419684829733.davem@davemloft.net>
References: <20170602152227.3626-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170602152227.3626-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri,  2 Jun 2017 16:22:27 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The proc_remove call is dead code as it occurs after a return and
> hence can never be called. Remove it.
> 
> Detected by CoverityScan, CID#1437743 ("Logically dead code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
