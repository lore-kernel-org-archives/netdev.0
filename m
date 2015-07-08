From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/6] genirq: Fix the documentation of request_percpu_irq
Date: Wed, 08 Jul 2015 14:05:18 -0700 (PDT)
Message-ID: <20150708.140518.1912932449236610733.davem@davemloft.net>
References: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com>
	<1435933551-28696-3-git-send-email-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, gregory.clement@free-electrons.com,
	jason@lakedaemon.net, andrew@lunn.ch,
	sebastian.hesselbarth@gmail.com,
	thomas.petazzoni@free-electrons.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: maxime.ripard@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435933551-28696-3-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxime Ripard <maxime.ripard@free-electrons.com>
Date: Fri,  3 Jul 2015 16:25:47 +0200

> The documentation of request_percpu_irq is confusing and suggest that the
> interrupt is not enabled at all, while it is actually enabled on the local
> CPU.
> 
> Clarify that.
> 
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>

You should submit this separately to the IRQ layer maintainers, rather
than try to include it in an unrelated set of changes targetting net-next.

Thanks.
