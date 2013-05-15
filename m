From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] fec: Invert the order of function calls in
 fec_restart()
Date: Wed, 15 May 2013 14:54:49 -0700 (PDT)
Message-ID: <20130515.145449.143324877111226754.davem@davemloft.net>
References: <1368637587-13391-1-git-send-email-fabio.estevam@freescale.com>
	<1368637587-13391-2-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, Frank.Li@freescale.com,
	kernel@pengutronix.de, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34025 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752555Ab3EOVyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 17:54:50 -0400
In-Reply-To: <1368637587-13391-2-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Wed, 15 May 2013 14:06:27 -0300

> commit 54309fa6 ("net: fec: fix kernel oops when plug/unplug cable many times")
> introduced the following 'if' block in the beginning of fec_start():
 ...
> Then later in the end of fec_restart() there is another block that calls the
> opposite of each one of these functions.
> 
> The correct approach would be to also call them with in the reverse order, so 
> that we have as result:
 ...
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
