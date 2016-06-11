From: Shawn Guo <shawnguo@kernel.org>
Subject: Re: [PATCH v2 1/2] ARM: imx6: disable deeper idle states when FEC is
 active w/o HW workaround
Date: Sat, 11 Jun 2016 17:04:38 +0800
Message-ID: <20160611090438.GG20243@tiger>
References: <1464971480-9203-1-git-send-email-l.stach@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fugang Duan <fugang.duan@nxp.com>, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	kernel@pengutronix.de, patchwork-lst@pengutronix.de
To: Lucas Stach <l.stach@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:34474 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750929AbcFKJFU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jun 2016 05:05:20 -0400
Content-Disposition: inline
In-Reply-To: <1464971480-9203-1-git-send-email-l.stach@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 03, 2016 at 06:31:19PM +0200, Lucas Stach wrote:
> The i.MX6 Q/DL has an erratum (ERR006687) that prevents the FEC from
> waking the CPUs when they are in wait(unclocked) state. As the hardware
> workaround isn't applicable to all boards, disable the deeper idle state
> when the workaround isn't present and the FEC is in use.
> 
> This allows to safely run a kernel with CPUidle enabled on all i.MX6
> boards.
> 
> Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> Acked-by: David S. Miller <davem@davemloft.net> (for network changes)

Applied both, thanks.
