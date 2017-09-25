From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [for 4.14] net: qcom/emac: specify the correct size
 when mapping a DMA buffer
Date: Mon, 25 Sep 2017 16:35:11 -0700 (PDT)
Message-ID: <20170925.163511.25037798110859886.davem@davemloft.net>
References: <1506112364-26787-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: timur@codeaurora.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1506112364-26787-1-git-send-email-timur@codeaurora.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Timur Tabi <timur@codeaurora.org>
Date: Fri, 22 Sep 2017 15:32:44 -0500

> When mapping the RX DMA buffers, the driver was accidentally specifying
> zero for the buffer length.  Under normal circumstances, SWIOTLB does not
> need to allocate a bounce buffer, so the address is just mapped without
> checking the size field.  This is why the error was not detected earlier.
> 
> Fixes: b9b17debc69d ("net: emac: emac gigabit ethernet controller driver")
> Cc: stable@vger.kernel.org
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Applied and queued up for -stable, thanks.
