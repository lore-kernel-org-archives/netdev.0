From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] drivers: net: cpsw: fix buggy loop condition
Date: Thu, 13 Feb 2014 19:44:46 +0530
Message-ID: <52FCD356.4060201@ti.com>
References: <1392299247-16917-1-git-send-email-hs@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Sebastian Siewior <bigeasy@linutronix.de>,
	Daniel Mack <zonque@gmail.com>, Felipe Balbi <balbi@ti.com>,
	Markus Pargmann <mpa@pengutronix.de>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Heiko Schocher <hs@denx.de>, <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392299247-16917-1-git-send-email-hs@denx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 13 February 2014 07:17 PM, Heiko Schocher wrote:
> commit:
> From 0cd8f9cc0654c06adde353c6532114c5f53a18e8 Mon Sep 17 00:00:00 2001
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Thu, 23 Jan 2014 00:03:12 +0530
> Subject: [PATCH] drivers: net: cpsw: enable promiscuous mode support
>
> Enable promiscuous mode support for CPSW.
>
> Introduced a crash on an am335x based board (similiar to am335x-evm).
> Reason is buggy end condition in for loop in cpsw_set_promiscious()
>
> for (i = 0; i <= priv->data.slaves; i++)
>
> should be
>
> for (i = 0; i < priv->data.slaves; i++)
>
> Fix this ...
>
> Signed-off-by: Heiko Schocher <hs@denx.de>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Sebastian Siewior <bigeasy@linutronix.de>
> Cc: Daniel Mack <zonque@gmail.com>
> Cc: Felipe Balbi <balbi@ti.com>
> Cc: Markus Pargmann <mpa@pengutronix.de>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
Ah, it's copy paste error, thanks for the fix.

Acked-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
