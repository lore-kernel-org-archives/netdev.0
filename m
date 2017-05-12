From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][V2] ethernet: aquantia: remove redundant checks on
 error status
Date: Thu, 11 May 2017 21:42:33 -0400 (EDT)
Message-ID: <20170511.214233.1981021610793266657.davem@davemloft.net>
References: <20170511182940.18774-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pavel.belous@aquantia.com, vomlehn@texas.net,
        Alexander.Loktionov@aquantia.com, Dmitry.Bezrukov@aquantia.com,
        Dmitrii.Tarakanov@aquantia.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170511182940.18774-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu, 11 May 2017 19:29:40 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The error status err is initialized as zero and then being checked
> several times to see if it is less than zero even when it has not
> been updated.  It may seem that the err should be assigned to the
> return code of the call to the various *offload_en_set calls and
> then we check for failure, however, these functions are void and
> never actually return any status.  
> 
> Since these error checks are redundant we can remove these
> as well as err and the error exit label err_exit.
> 
> Detected by CoverityScan, CID#1398313 and CID#1398306 ("Logically
> dead code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thank you.
