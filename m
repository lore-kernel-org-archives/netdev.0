From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][net-next] cxgb4: fix missing break in switch and
 indent return statements
Date: Sat, 14 Oct 2017 18:38:31 -0700 (PDT)
Message-ID: <20171014.183831.2067315477541257966.davem@davemloft.net>
References: <20171013162900.16911-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ganeshgr@chelsio.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013162900.16911-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri, 13 Oct 2017 17:29:00 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The break statement for the Macronix case is missing and will
> fall through to the Winbond case and re-assign the size setting.
> Fix this by adding the missing break statement.  Also correctly
> indent the return statements.
> 
> Detected by CoverityScan, CID#1458020 ("Missing break in switch")
> 
> Fixes: 96ac18f14a5a ("cxgb4: Add support for new flash parts")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
