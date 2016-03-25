From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1] net: macb: remove BUG_ON() and reset the queue
 to handle RX errors
Date: Fri, 25 Mar 2016 11:44:23 -0400 (EDT)
Message-ID: <20160325.114423.859412154606595295.davem@davemloft.net>
References: <1458898654-25864-1-git-send-email-cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, soren.brinkmann@xilinx.com,
	linux-kernel@vger.kernel.org, narmstrong@baylibre.com
To: cyrille.pitchen@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458898654-25864-1-git-send-email-cyrille.pitchen@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Date: Fri, 25 Mar 2016 10:37:34 +0100

> This patch removes two BUG_ON() used to notify about RX queue corruptions
> on macb (not gem) hardware without actually handling the error.
> 
> The new code skips corrupted frames but still processes faultless frames.
> Then it resets the RX queue before restarting the reception from a clean
> state.
> 
> This patch is a rework of an older patch proposed by Neil Armstrong:
> http://patchwork.ozlabs.org/patch/371525/
> 
> Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
> Acked-by: Neil Armstrong <narmstrong@baylibre.com>
> Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Applied, thank you.
