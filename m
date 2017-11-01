From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: macb: remove redundant assignment to variable
 work_done
Date: Wed, 01 Nov 2017 21:27:24 +0900 (KST)
Message-ID: <20171101.212724.2093826633682146421.davem@davemloft.net>
References: <20171031142324.25740-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@microchip.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171031142324.25740-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue, 31 Oct 2017 14:23:24 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> Variable work_done is set to zero and this value is never read, instead
> it is set to another value a few statements later.  Remove the redundant
> assignment. Cleans up clang warning:
> 
> drivers/net/ethernet/cadence/macb_main.c:1221:2: warning: Value stored
> to 'work_done' is never read
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
