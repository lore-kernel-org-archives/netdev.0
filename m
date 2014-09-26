From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "net/macb: add pinctrl consumer support"
Date: Fri, 26 Sep 2014 15:49:30 -0400 (EDT)
Message-ID: <20140926.154930.1459165439870528648.davem@davemloft.net>
References: <1411429748-31444-1-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: soren.brinkmann@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411429748-31444-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Soren Brinkmann <soren.brinkmann@xilinx.com>
Date: Mon, 22 Sep 2014 16:49:08 -0700

> This reverts commit 8ef29f8aae524bd51298fb10ac6a5ce6c4c5a3d8.
> The driver core already calls pinctrl_get() and claims the default
> state. There is no need to replicate this in the driver.
> ---
> Hi,
> 
> I might be mistaken, but I think the driver core does already take care of
> calling into the pinctrl framework and the driver does not need to do it on its
> own (drivers/base/dd.c:really_probe() calls 'pinctrl_bind_pins() which takes
> care of the pinctrl setup).
> 

Applied and queued up for -stable, thanks.

Next time please provide a proper "Signed-off-by: " in the commit message
of your submission.
