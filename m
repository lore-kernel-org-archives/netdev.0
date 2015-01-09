From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] Revert "ARM: imx: add FEC sleep mode
 callback function"
Date: Thu, 08 Jan 2015 20:05:41 -0800 (PST)
Message-ID: <20150108.200541.293054368842403637.davem@davemloft.net>
References: <1420634393-30027-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, fugang.duan@freescale.com,
	netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50678 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964AbbAID74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 22:59:56 -0500
In-Reply-To: <1420634393-30027-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Wed,  7 Jan 2015 10:39:52 -0200

> From: Fabio Estevam <fabio.estevam@freescale.com>
> 
> i.MX platform maintainer Shawn Guo is not happy with the such commit as
> explained below [1]:
> 
> "The GPR difference between SoCs can be encoded in device tree as well.
> It's pointless to repeat the same code pattern for every single
> platform, that need to set up GPR bits for enabling magic packet wake
> up, while the only difference is the register and bit offset.
> 
> The platform code will become quite messy and unmaintainable if every
> device driver dump their GPR register setup code into platform.
> 
> Sorry, but it's NACK from me."
> 
> This reverts commit 456062b3ec6f5b9 ("ARM: imx: add FEC sleep mode callback 
> function").
> 
> [1] http://www.spinics.net/lists/netdev/msg310922.html
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
