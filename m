From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-next: mediatek: fix compile error inside
 mtk_poll_controller()
Date: Sat, 02 Jul 2016 16:39:03 -0400 (EDT)
Message-ID: <20160702.163903.1756164632554941051.davem@davemloft.net>
References: <1467439250-48222-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@nbd.name, keyhaede@gmail.com, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: john@phrozen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467439250-48222-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john@phrozen.org>
Date: Sat,  2 Jul 2016 08:00:50 +0200

> commit 8067302973a1 ("net-next: mediatek: add support for IRQ grouping")
> failed to properly update the irq handling inside mtk_poll_controller()
> causing compile errors if netconsole was enabled. Fix this by updating
> the code to use the new separated irq handler function for RX.
> 
> Signed-off-by: John Crispin <john@phrozen.org>

Applied.

> ideally you could fold this into the following patch inside net-next.git

There is no "folding" in my tree, commits are forever and history is
never changed or modified ever.
