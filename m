From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][-next] net: macb: remove extraneous return when
 MACB_EXT_DESC is defined
Date: Wed, 05 Jul 2017 09:09:58 +0100 (WEST)
Message-ID: <20170705.090958.2221041161435076999.davem@davemloft.net>
References: <20170704150959.18315-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@microchip.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170704150959.18315-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue,  4 Jul 2017 16:09:59 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> When macro MACB_EXT_DESC is defined we end up with two identical
> return statements and just one is sufficient. Remove the extra
> return.
> 
> Detected by CoverityScan, CID#1449361 ("Structurally dead code")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks.
