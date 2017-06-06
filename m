From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: fix a broken u32 less than zero check
Date: Tue, 06 Jun 2017 16:27:21 -0400 (EDT)
Message-ID: <20170606.162721.673605809605221722.davem@davemloft.net>
References: <20170606131049.26887-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170606131049.26887-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue,  6 Jun 2017 14:10:49 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The check that queue is less or equal to zero is always true
> because queue is a u32; queue is decremented and will wrap around
> and never go -ve. Fix this by making queue an int.
> 
> Detected by CoverityScan, CID#1428988 ("Unsigned compared against 0")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks Colin.
