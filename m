From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 0/4] net-next: mediatek: IRQ cleanups, fixes and
 grouping
Date: Thu, 30 Jun 2016 08:52:50 -0400 (EDT)
Message-ID: <20160630.085250.1236377588787063326.davem@davemloft.net>
References: <1467200291-60106-1-git-send-email-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@nbd.name, keyhaede@gmail.com, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: john@phrozen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467200291-60106-1-git-send-email-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john@phrozen.org>
Date: Wed, 29 Jun 2016 13:38:07 +0200

> This series contains 2 small code cleanups that are leftovers from the
> MIPS support. There is also a small fix that adds proper locking to the
> code accessing the IRQ registers. Without this fix we saw deadlocks caused
> by the last patch of the series, which adds IRQ grouping. The grouping
> feature allows us to use different IRQs for TX and RX. By doing so we can
> use affinity to let the SoC handle the IRQs on different cores.
> 
> This series depends on a previous series currently sitting in net.git
> starting with
> 	commit 562c5a70400c ("net: mediatek: only wake the queue if it is stopped")
> up to
> 	commit 82c6544dddc6 ("net: mediatek: remove superfluous queue wake up call")

Series applied, thanks.
