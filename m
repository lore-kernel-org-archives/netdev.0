From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 1/1] net: cdc_ncm: Fix TX zero padding
Date: Mon, 08 May 2017 16:01:48 -0400 (EDT)
Message-ID: <20170508.160148.1055084315233926966.davem@davemloft.net>
References: <1494247797-1732-1-git-send-email-jim_baxter@mentor.com>
        <1494247797-1732-2-git-send-email-jim_baxter@mentor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, oliver@neukum.org
To: jim_baxter@mentor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1494247797-1732-2-git-send-email-jim_baxter@mentor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jim Baxter <jim_baxter@mentor.com>
Date: Mon, 8 May 2017 13:49:57 +0100

> The zero padding that is added to NTB's does
> not zero the memory correctly.
> This is because the skb_put modifies the value
> of skb_out->len which results in the memset
> command not setting any memory to zero as
> (ctx->tx_max - skb_out->len) == 0.
> 
> I have resolved this by storing the size of
> the memory to be zeroed before the skb_put
> and using this in the memset call.
> 
> Signed-off-by: Jim Baxter <jim_baxter@mentor.com>
> Reviewed-by: Bjørn Mork <bjorn@mork.no>

Applied, thank you.
