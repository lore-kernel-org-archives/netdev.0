From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 00/10] net/fec: add dual fec support for i.MX28
Date: Sun, 09 Jan 2011 15:44:09 -0800 (PST)
Message-ID: <20110109.154409.242134862.davem@davemloft.net>
References: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerg@snapgear.com, baruch@tkos.co.il, eric@eukrea.com,
	bryan.wu@canonical.com, r64343@freescale.com, B32542@freescale.com,
	u.kleine-koenig@pengutronix.de, lw@karo-electronics.de,
	w.sang@pengutronix.de, s.hauer@pengutronix.de, jamie@jamieiles.com,
	jamie@shareable.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: shawn.guo@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46370
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752655Ab1AIXnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 18:43:37 -0500
In-Reply-To: <1294297998-26930-1-git-send-email-shawn.guo@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Guo <shawn.guo@freescale.com>
Date: Thu, 6 Jan 2011 15:13:08 +0800

> This patch series is to add dual fec support for mx28, which is
> a mxs-based soc. Some code changes related to the following commits
> are also made in this patch set for some reasons.
> 
>  e6b043d512fa8d9a3801bf5d72bfa3b8fc3b3cc8
>  netdev/fec.c: add phylib supporting to enable carrier detection (v2)
> 
>  e3fe8558c7fc182972c3d947d88744482111f304
>  net/fec: fix pm to survive to suspend/resume
> 
> It's been tested on mx28 evk and mx51 babbage. For mx28, it has
> to work against the tree
> 
>  git://git.pengutronix.de/git/imx/linux-2.6.git imx-for-2.6.38
> 
> plus patch
> 
>  [PATCH v4] ARM: mxs: Change duart device to use amba-pl011
> 
> The 3 patches below preceding with * have changes since v3, and
> the detailed change log can be found in individual patch.

I've applied all of the "net/fec:" patches (#1 to #5) to net-2.6,
please push the ARM changes via the appropriate ARM tree.

Thanks.
