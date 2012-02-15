From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ethernet: ks8851_mll fix irq handling
Date: Wed, 15 Feb 2012 15:41:40 -0500 (EST)
Message-ID: <20120215.154140.2082640267957831845.davem@davemloft.net>
References: <1329291315-7973-1-git-send-email-j.weitzel@phytec.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: j.weitzel@phytec.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329291315-7973-1-git-send-email-j.weitzel@phytec.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Weitzel <j.weitzel@phytec.de>
Date: Wed, 15 Feb 2012 08:35:15 +0100

> There a two different irq variables ks->irq and netdev->irq.
> Only ks->irq is set on probe, so disabling irq in ks_start_xmit fails.
> 
> This patches remove ks->irq from private data and use only netdev->irq.
> 
> Tested on a kernel 3.0 based OMAP4430 SMP Board
> 
> Signed-off-by: Jan Weitzel <j.weitzel@phytec.de>

Applied, thanks.
