From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qcom/emac: make function emac_isr static
Date: Thu, 05 Oct 2017 21:27:12 -0700 (PDT)
Message-ID: <20171005.212712.1114511156589357681.davem@davemloft.net>
References: <20171005091023.27781-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timur@codeaurora.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005091023.27781-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu,  5 Oct 2017 10:10:23 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The function emac_isr is local to the source and does not need to
> be in global scope, so make it static.
> 
> Cleans up sparse warnings:
> symbol 'emac_isr' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
