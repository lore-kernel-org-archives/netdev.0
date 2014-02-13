From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: cpsw: fix buggy loop condition
Date: Thu, 13 Feb 2014 18:51:31 -0500 (EST)
Message-ID: <20140213.185131.1052801902077727878.davem@davemloft.net>
References: <1392299247-16917-1-git-send-email-hs@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, mugunthanvnm@ti.com,
	bigeasy@linutronix.de, zonque@gmail.com, balbi@ti.com,
	mpa@pengutronix.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hs@denx.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392299247-16917-1-git-send-email-hs@denx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Schocher <hs@denx.de>
Date: Thu, 13 Feb 2014 14:47:27 +0100

> commit:
> From 0cd8f9cc0654c06adde353c6532114c5f53a18e8 Mon Sep 17 00:00:00 2001
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Thu, 23 Jan 2014 00:03:12 +0530
> Subject: [PATCH] drivers: net: cpsw: enable promiscuous mode support

The correct way to reference a commit is:

$(SHA1_ID) ("Commit message header text.")

So in this case it would be:

Commit 0cd8f9cc0654c06adde353c6532114c5f53a18e8 ("drivers: net: cpsw:
enable promiscuous mode support")

I fixed this up when applying this patch.  I will not extend this same
courtesy next time.

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

Applied, thanks.
