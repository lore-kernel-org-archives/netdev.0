From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] make POSIX timers optional
Date: Thu, 22 Sep 2016 02:09:41 -0400 (EDT)
Message-ID: <20160922.020941.60363145556877289.davem@davemloft.net>
References: <1474401400-18491-1-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.stultz@linaro.org, tglx@linutronix.de,
        richardcochran@gmail.com, josh@joshtriplett.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: nicolas.pitre@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474401400-18491-1-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Pitre <nicolas.pitre@linaro.org>
Date: Tue, 20 Sep 2016 15:56:38 -0400

> Many embedded systems don't need the full POSIX timer support.
> Configuring them out provides a nice kernel image size reduction.
> 
> When POSIX timers are configured out, the PTP clock subsystem should be
> left out as well. However a bunch of ethernet drivers currently *select*
> it in their Kconfig entries. Therefore some more tweaks were needed to
> break that hard dependency for those drivers to still be configured in
> if desired.
> 
> It was agreed that the best path upstream for those patches is via
> John Stultz's timer tree.

Acked-by: David S. Miller <davem@davemloft.net>
