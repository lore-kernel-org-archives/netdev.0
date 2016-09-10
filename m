From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-velocity: remove null pointer check on array
 tdinfo->skb_dma
Date: Fri, 09 Sep 2016 18:17:49 -0700 (PDT)
Message-ID: <20160909.181749.1305604778627776550.davem@davemloft.net>
References: <20160908090424.16545-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160908090424.16545-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Thu,  8 Sep 2016 10:04:24 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> tdinfo->skb_dma is a 7 element array of dma_addr_t hence cannot be
> null, so the pull pointer check on tdinfo->skb_dma  is redundant.
> Remove it.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks Colin.
